#!/usr/bin/env python3
"""./dev: one front door for a coding agent working on the AI Engineer database contract.

Modelled on Mission Control's ./dev (SPEC-03 K2). Not a release tool: the release and fresh-install
path stays scripts/install-ai-engineer.mjs. Every input is a flag, JSON on stdout where a result is
data, typed exit codes, and an error names the fix. Standard library only, so ``./dev status`` and
``./dev doctor`` run before ``pnpm install``. Nothing here connects to a database; ``status`` reads
``docker ps`` only.

  ./dev status                  orient in one call (JSON): branch, ahead/behind, dirty files,
                                contract version, migration head and count, local Supabase stacks up
  ./dev doctor                  read-only readiness (JSON); each failure names its fix
  ./dev check                   the fast gate: npm run typecheck, npm test, npm run version:check,
                                node .agent-docs/cli.mjs check --repo ., then the provenance check
                                (trace.py check --range <upstream>..HEAD, warn-only)
  ./dev test unit|installer     npm test | npm run test:installer
  ./dev trace show|build|check|linear pull   the provenance chain (docs/tools/trace.py)
  ./dev hooks install|status    the warn-only commit-msg hook (scripts/dev/hooks/commit-msg)
  ./dev slow                    the slow commands CI runs on a disposable stack: printed, never run
  ./dev planes list|show P|check            the data-plane registry config/planes.toml (no network)
  ./dev db status|schema|query --plane P    read-only database sessions (scripts/dev/planes.py,
                                            copied from Mission Control); --plane is always required

Exit codes: 0 ok, 1 a check or test failed, 2 usage error, 3 the environment is not ready.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRACE = ROOT / "docs" / "tools" / "trace.py"
HOOK_SOURCE = ROOT / "scripts" / "dev" / "hooks" / "commit-msg"
HOOK_MARKER = "# aidb-provenance-managed-v1"
MIGRATION_FILE = re.compile(r"^(\d{14})_.*\.sql$")
WORKSPACE_ROOT = ROOT.parents[1]
REVIEW_WORKSPACE = WORKSPACE_ROOT / "platform" / "ai-engineer-research-2026-11-02" / "10-review-workspace"
ENTRYPOINTS = [
    "AGENTS.md",
    "features/README.md",
    "features/schema-change.md",
    "README.md",
]
SIBLINGS = {
    "review-workspace": REVIEW_WORKSPACE,
    "mission-control": WORKSPACE_ROOT / "platform" / "mission-control",
    "knowledge-services": WORKSPACE_ROOT / "platform" / "knowledge-services",
}
# Supabase container names are supabase_<service>_<project>; some services hold an underscore.
SUPABASE_SERVICES = sorted(
    (
        "db", "kong", "auth", "rest", "realtime", "storage", "imgproxy", "inbucket", "mailpit",
        "pg_meta", "studio", "edge_runtime", "analytics", "vector", "pooler",
    ),
    key=len,
    reverse=True,
)  # fmt: skip
SHARED_LOCAL_PROJECT = "aiengineer"  # supabase/config.toml project_id: the populated local stack
CHECK_STEPS = [
    ("typecheck", ["npm", "run", "typecheck"]),
    ("test", ["npm", "test"]),
    ("version", ["npm", "run", "version:check"]),
    ("agent-docs", ["node", ".agent-docs/cli.mjs", "check", "--repo", "."]),
    ("planes", [sys.executable, "-X", "utf8", "scripts/dev/planes.py", "planes", "check"]),
]
TEST_LAYERS = {
    "unit": ["npm", "test"],
    "installer": ["npm", "run", "test:installer"],
}
DISPOSABLE = ".ci/disposable"
CI_DSN = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"
INSTALL = (
    f"node scripts/install-ai-engineer.mjs --workdir {DISPOSABLE} --ks-root .ci/knowledge-services "
    "--component-installation-id 0195f0a0-5b08-7000-8000-0000000c1a1d --skip-mission-control"
)
SLOW = [
    {
        "name": "disposable stack",
        "why": "every command below needs a database; CI starts an empty one from a copy of the config",
        "commands": [
            f'mkdir -p "{DISPOSABLE}/supabase/migrations"',
            "sed -e 's/^project_id = \"aiengineer\"$/project_id = \"disposable-ci-aidb\"/' "
            f'supabase/config.toml > "{DISPOSABLE}/supabase/config.toml"',
            f'npx supabase db start --workdir "{DISPOSABLE}"',
        ],
        "notes": "about 2 GB of RAM; never start the shared `aiengineer` project for a proof",
    },
    {
        "name": "Knowledge Services component",
        "why": "the installer installs the pinned knowledge_verification component first",
        "commands": [
            "git clone https://github.com/jbell-rusty-vantage/agent-knowledge-services .ci/knowledge-services"
            "  # or --ks-root ../../platform/knowledge-services",
            "cd .ci/knowledge-services && corepack enable && pnpm install --frozen-lockfile "
            '--filter "@aiengineer/knowledge-db-contract..." && pnpm --filter '
            "@aiengineer/knowledge-db-contract build",
        ],
    },
    {
        "name": "fresh install from empty, then a repeat that applies nothing",
        "commands": [
            f"{INSTALL} --receipt .ci/install-receipt.json",
            f"{INSTALL} --receipt .ci/install-receipt-repeat.json",
            "node -e \"process.exit(JSON.parse(require('fs').readFileSync("
            "'.ci/install-receipt-repeat.json','utf8')).changed ? 1 : 0)\"",
        ],
    },
    {
        "name": "SQL suites",
        "why": "every supabase/tests/*.sql except the six CI leaves out (named with a reason in "
        ".github/workflows/contract.yml); each rolls back",
        "commands": [
            "docker exec -i supabase_db_disposable-ci-aidb psql -X -U postgres -d postgres "
            "-v ON_ERROR_STOP=1 -At -q < supabase/tests/<suite>.sql",
        ],
        "notes": "a suite fails on a psql error, a pgTAP `not ok` or a plan mismatch",
    },
    {
        "name": "generated types",
        "commands": [f'node scripts/generate-types.mjs --local --check --workdir="{DISPOSABLE}"'],
    },
    {
        "name": "schema workspace",
        "why": "the committed workspace/ must match the installed database and re-render byte for byte",
        "commands": [
            f"npm run workspace:check -- --db-url {CI_DSN}",
            f"npm run workspace:validate -- --db-url {CI_DSN}",
            f"npm run workspace:build -- --db-url {CI_DSN}   # only to regenerate after a change",
        ],
        "notes": "local by default: without --db-url the workspace commands read a loopback "
        "AIENG_DB_LOCAL_DSN; the remote admin DSN only with --target remote",
    },
]


def git(*args: str) -> str:
    done = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )
    return done.stdout.strip() if done.returncode == 0 else ""


def emit(data: object) -> None:
    print(json.dumps(data, indent=2, ensure_ascii=False))


def fail(message: str, fix: str, code: int = 2) -> int:
    print(f"dev: {message}\n  fix: {fix}", file=sys.stderr)
    return code


def resolve(command: list[str]) -> list[str]:
    """npm and node are .cmd shims on Windows; resolve the executable so no shell is needed."""

    found = shutil.which(command[0])
    return [found or command[0], *command[1:]]


def run(command: list[str]) -> int:
    print(f"$ {' '.join(command)}", file=sys.stderr, flush=True)
    try:
        return subprocess.run(resolve(command), cwd=ROOT, check=False).returncode
    except FileNotFoundError:
        print(f"dev: {command[0]} is not on PATH (./dev doctor)", file=sys.stderr)
        return 127


def upstream() -> str:
    return git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}")


def hooks_dir() -> Path:
    path = Path(git("rev-parse", "--git-path", "hooks") or ".git/hooks")
    return path if path.is_absolute() else ROOT / path


def hook_state() -> str:
    hook = hooks_dir() / "commit-msg"
    if not hook.is_file():
        return "absent"
    text = hook.read_text(encoding="utf-8", errors="replace")
    return "managed" if HOOK_MARKER in text else "unmanaged"


# ------------------------------------------------------------------------------------- status


def contract_version() -> dict[str, object] | None:
    path = ROOT / "contract.version.json"
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    return {key: data.get(key) for key in ("version", "migration_head", "migrations")}


def migrations() -> dict[str, object]:
    folder = ROOT / "supabase" / "migrations"
    names = sorted(p.name for p in folder.iterdir() if p.is_file() and MIGRATION_FILE.match(p.name))
    drafts = ROOT / "supabase" / "drafts"
    draft_names = (
        sorted(p.name for p in drafts.iterdir() if MIGRATION_FILE.match(p.name))
        if drafts.is_dir()
        else []
    )
    return {
        "head": names[-1].removesuffix(".sql") if names else None,
        "count": len(names),
        "draft_head": draft_names[-1].removesuffix(".sql") if draft_names else None,
    }


def supabase_stacks() -> dict[str, object]:
    """Read-only: `docker ps`, grouped by Supabase project. Never starts or stops anything."""

    if not shutil.which("docker"):
        return {"docker": None, "detail": "docker not on PATH"}
    try:
        done = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}\t{{.Status}}\t{{.Ports}}"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=15,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return {"docker": False, "detail": "docker ps timed out"}
    if done.returncode != 0:
        return {"docker": False, "detail": "daemon not reachable (Docker Desktop stopped?)"}
    stacks: dict[str, dict[str, object]] = {}
    others = 0
    for line in done.stdout.splitlines():
        name, _, rest = line.partition("\t")
        status, _, ports = rest.partition("\t")
        if not name.startswith("supabase_"):
            others += 1
            continue
        tail = name.removeprefix("supabase_")
        service = next((s for s in SUPABASE_SERVICES if tail.startswith(f"{s}_")), tail.split("_")[0])
        project = tail.removeprefix(f"{service}_")
        stack = stacks.setdefault(
            project,
            {
                "posture": "shared-local (populated; never reset)"
                if project == SHARED_LOCAL_PROJECT
                else ("disposable" if project.startswith("disposable") else "unknown"),
                "services": [],
            },
        )
        stack["services"].append(service)  # type: ignore[union-attr]
        if service == "db":
            stack["db"] = {"container": name, "status": status, "ports": ports}
    return {"docker": True, "supabase_stacks": stacks, "other_containers": others}


def status() -> int:
    up = upstream()
    ahead = behind = None
    if up:
        counts = git("rev-list", "--left-right", "--count", f"{up}...HEAD").split()
        if len(counts) == 2:
            behind, ahead = int(counts[0]), int(counts[1])
    porcelain = [line for line in git("status", "--porcelain").splitlines() if line]
    recorded = contract_version()
    chain = migrations()
    snapshot = ROOT / ".sdlc" / "trace" / "linear-snapshot.json"
    hints = []
    if ahead:
        hints.append(f"{ahead} commit(s) not pushed to {up}")
    if recorded and chain["head"] and not str(recorded.get("migration_head", "")).startswith(
        str(chain["head"])
    ):
        hints.append(
            "supabase/migrations is past contract.version.json: `npm run version:check` will fail "
            "until a version is cut (features/version-and-release.md)"
        )
    if hook_state() != "managed":
        hints.append("the provenance commit-msg hook is not installed: `./dev hooks install`")
    if not snapshot.is_file():
        hints.append("no Linear snapshot: OVE ids are checked for shape only (`./dev trace linear pull`)")
    if not REVIEW_WORKSPACE.is_dir():
        hints.append("the review workspace is absent: B08-S<n> and D-<n> refs are noted, not checked")
    emit(
        {
            "repo": "ai-engineer-db-contract",
            "branch": git("branch", "--show-current"),
            "head": git("log", "-1", "--format=%h %s"),
            "upstream": up or None,
            "ahead": ahead,
            "behind": behind,
            "dirty": {
                "modified": sum(1 for line in porcelain if not line.startswith("??")),
                "untracked": sum(1 for line in porcelain if line.startswith("??")),
                "files": [line[3:] for line in porcelain[:40]],
                "truncated": len(porcelain) > 40,
            },
            "contract": recorded,
            "migrations": chain,
            "local_databases": supabase_stacks(),
            "hooks": {"commit-msg": hook_state(), "dir": str(hooks_dir())},
            "trace": {"linear_snapshot": snapshot.is_file()},
            "siblings": {name: path.is_dir() for name, path in SIBLINGS.items()},
            "entrypoints": ENTRYPOINTS,
            "hints": hints,
        }
    )
    return 0


# ------------------------------------------------------------------------------------- doctor


def version_of(command: list[str]) -> str | None:
    try:
        done = subprocess.run(
            resolve(command), capture_output=True, text=True, timeout=20, check=False, cwd=ROOT
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    return (done.stdout or done.stderr).strip().splitlines()[0] if done.returncode == 0 else None


def doctor() -> int:
    checks: list[dict[str, object]] = []

    def record(name: str, ok: bool, detail: str, fix: str, required: bool = True) -> None:
        checks.append(
            {
                "name": name,
                "ok": ok,
                "required": required,
                "detail": detail,
                "fix": None if ok else fix,
            }
        )

    record("git", shutil.which("git") is not None, shutil.which("git") or "absent", "install Git")
    node = version_of(["node", "--version"])
    node_ok = bool(node) and int(node.lstrip("v").split(".")[0]) >= 20
    record("node", node_ok, node or "absent", "install Node 20 or newer (CI uses 22)")
    pnpm = version_of(["pnpm", "--version"]) or version_of(["corepack", "pnpm", "--version"])
    record("pnpm", pnpm is not None, pnpm or "absent", "corepack enable (packageManager pins pnpm)")
    record(
        "python",
        sys.version_info >= (3, 11),
        sys.version.split()[0],
        "Python 3.11 or newer runs ./dev and the trace",
    )
    modules = ROOT / "node_modules"
    record("node_modules", modules.is_dir(), str(modules), "pnpm install --frozen-lockfile")
    cli = ROOT / "node_modules" / ".bin"
    has_cli = any((cli / name).exists() for name in ("supabase", "supabase.cmd"))
    record("supabase CLI (pinned)", has_cli, str(cli), "pnpm install (devDependency supabase)")
    env = ROOT / ".env"
    record(
        ".env",
        True,
        "present (values not read)" if env.is_file() else "absent (fine: nothing here needs it)",
        "",
        required=False,
    )
    state = hook_state()
    record(
        "commit-msg hook",
        state == "managed",
        f"{state} in {hooks_dir()}",
        "./dev hooks install",
        required=False,
    )
    for name, path in SIBLINGS.items():
        record(
            f"sibling {name}",
            path.is_dir(),
            str(path),
            "only needed to resolve its record ids (trace) or to install its component",
            required=False,
        )
    docker = supabase_stacks()
    record(
        "docker",
        bool(docker.get("docker")),
        str(docker.get("detail") or "daemon reachable"),
        "start Docker Desktop; only the slow commands need it (./dev slow)",
        required=False,
    )
    failed = [c for c in checks if not c["ok"] and c["required"]]
    emit({"ok": not failed, "checks": checks})
    return 3 if failed else 0


# ---------------------------------------------------------------------------- check and test


def check() -> int:
    if not (ROOT / "node_modules").is_dir():
        return fail("node_modules is absent", "pnpm install --frozen-lockfile", 3)
    results: dict[str, str] = {}
    for name, command in CHECK_STEPS:
        results[name] = "passed" if run(command) == 0 else "failed"
    up = upstream()
    revision_range = f"{up}..HEAD" if up else "HEAD~1..HEAD"
    trace_code = run([sys.executable, "-X", "utf8", str(TRACE), "check", "--range", revision_range])
    results["provenance"] = "passed (warn-only)" if trace_code == 0 else "failed (block mode)"
    emit({"check": results})
    return 1 if any(value.startswith("failed") for value in results.values()) else 0


def test(layer: str) -> int:
    if layer == "installer":
        print(
            "dev: database-backed installer cases run only when INSTALL_WIPE_PG_ADMIN_DSN / "
            "INSTALL_SEAL_PG_ADMIN_DSN (loopback) are set; otherwise they are skipped",
            file=sys.stderr,
        )
    return 1 if run(TEST_LAYERS[layer]) else 0


def trace(args: list[str]) -> int:
    if not args:
        args = ["--help"]
    return run([sys.executable, "-X", "utf8", str(TRACE), *args])


def hooks(action: str) -> int:
    target = hooks_dir() / "commit-msg"
    state = hook_state()
    if action == "status":
        emit({"commit-msg": state, "path": str(target), "source": "scripts/dev/hooks/commit-msg"})
        return 0
    if state == "unmanaged":
        return fail(
            f"{target} exists and is not ours; it is preserved",
            "chain it by adding this line to that hook: "
            'sh "$(git rev-parse --show-toplevel)/scripts/dev/hooks/commit-msg" "$1" || exit $?',
            3,
        )
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        "#!/bin/sh\n"
        f"{HOOK_MARKER}\n"
        "# Dispatcher written by ./dev hooks install; the logic is the tracked file below.\n"
        'root=$(git rev-parse --show-toplevel) || exit 0\n'
        '[ -f "$root/scripts/dev/hooks/commit-msg" ] || exit 0\n'
        'exec sh "$root/scripts/dev/hooks/commit-msg" "$@"\n',
        encoding="utf-8",
        newline="\n",
    )
    os.chmod(target, 0o755)
    emit({"installed": str(target), "was": state, "mode": os.environ.get("SDLC_TRACE", "warn")})
    return 0


def slow() -> int:
    emit(
        {
            "run_by": ".github/workflows/contract.yml on every push to main (Linux); "
            "./dev never runs these",
            "steps": SLOW,
        }
    )
    return 0


PLANES = ROOT / "scripts" / "dev" / "planes.py"


def planes(group: str, args: list[str]) -> int:
    """`planes` runs here (standard library); `db` needs psycopg, so it runs through
    `uv run --with psycopg[binary]` unless this interpreter has it. Credentials resolve inside
    planes.py, never here."""

    command = [sys.executable, "-X", "utf8", str(PLANES), group, *args]
    if group == "db":
        try:
            import psycopg  # noqa: F401
        except ImportError:
            if not shutil.which("uv"):
                return fail("`./dev db` needs psycopg", "install uv (it supplies psycopg per run)", 3)
            command = [
                "uv", "run", "--no-project", "--quiet", "--with", "psycopg[binary]",
                "python", "-X", "utf8", str(PLANES), group, *args,
            ]  # fmt: skip
    return subprocess.run(command, cwd=ROOT, check=False).returncode


# --------------------------------------------------------------------------------------- main


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    parser = argparse.ArgumentParser(
        prog="./dev", description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="command", metavar="COMMAND")
    sub.add_parser("status", help="orient in one call (JSON)", description="Example: ./dev status")
    sub.add_parser("doctor", help="read-only readiness (JSON)", description="Example: ./dev doctor")
    sub.add_parser(
        "check",
        help="the fast gate: typecheck, npm test, version:check, agent-docs check, provenance",
        description="Runs, in order: " + "; ".join(" ".join(c) for _, c in CHECK_STEPS)
        + "; python docs/tools/trace.py check --range <upstream>..HEAD (warn-only)",
    )
    p_test = sub.add_parser(
        "test", help="one test layer: unit (npm test) or installer (npm run test:installer)"
    )
    p_test.add_argument("layer", choices=sorted(TEST_LAYERS))
    sub.add_parser(
        "trace",
        help="the provenance chain: show ID | build | check | linear pull",
        description="Examples: ./dev trace show AS-S9   ./dev trace check   ./dev trace build",
        add_help=False,
    )
    p_hooks = sub.add_parser("hooks", help="install or inspect the warn-only commit-msg hook")
    p_hooks.add_argument("action", choices=("install", "status"))
    sub.add_parser("slow", help="print (never run) the slow commands CI runs on a disposable stack")
    sub.add_parser("planes", help="the data-plane registry: list | show PLANE | check", add_help=False)
    sub.add_parser("db", help="read-only database sessions: status | schema | query --plane P", add_help=False)
    argv = sys.argv[1:]
    if argv and argv[0] == "trace":
        return trace(argv[1:])
    if argv and argv[0] in {"planes", "db"}:
        return planes(argv[0], argv[1:] or ["--help"])
    args = parser.parse_args(argv)
    if args.command is None:
        parser.print_help()
        return 2
    if args.command == "status":
        return status()
    if args.command == "doctor":
        return doctor()
    if args.command == "check":
        return check()
    if args.command == "hooks":
        return hooks(args.action)
    if args.command == "slow":
        return slow()
    return test(args.layer)


if __name__ == "__main__":
    sys.exit(main())
