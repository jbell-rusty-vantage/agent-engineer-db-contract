"""Build 08 knowledge loop 4: build the probe environments and run the probes (no lab write; loop4_process.py registers the runs).

Cells are dates: each cell is the environment `uv pip install --exclude-newer <date>` resolves that day (what a learner who followed
a tutorial written then would get). The latest cell has no cutoff. Every run is a subprocess in its cell's venv with a clean
environment (no secrets), except the live arm P12, which receives the Anthropic key under ANTHROPIC_API_KEY for that process only.
Run: python -I -X utf8 scripts/knowledge-lab/loop4_probes.py envs | run [P1 P2 ...] | resolve
"""
import hashlib, json, os, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C

HERE = os.path.dirname(os.path.abspath(__file__))
PROBES = os.path.join(HERE, "probes")
RUN4 = os.path.join(C.LAB, "knowledge-loop-4")
OUT = os.path.join(RUN4, "probe-runs")
ENVS = os.environ.get("LOOP4_ENV_DIR") or os.path.join(os.environ.get("TEMP") or "/tmp", "aieng-loop4-envs")
os.makedirs(OUT, exist_ok=True)
os.makedirs(ENVS, exist_ok=True)

CELLS = {
    "D0-2025-10-16": {"exclude_newer": "2025-10-17T00:00:00Z", "packages": ["langgraph", "langchain", "langchain-core", "langgraph-prebuilt"], "optional": []},
    # the same day with deepagents added: its 0.0.x line required the 1.0 pre-releases, so the resolver pulled langchain 1.0.0rc1 / langgraph 1.0.0a4
    "D0b-2025-10-16-with-deepagents": {"exclude_newer": "2025-10-17T00:00:00Z", "packages": ["langgraph", "langchain", "langchain-core", "langgraph-prebuilt", "deepagents"], "optional": []},
    "D1-2025-10-18": {"exclude_newer": "2025-10-19T00:00:00Z", "packages": ["langgraph", "langchain", "langchain-core", "langgraph-prebuilt", "langchain-classic"], "optional": ["deepagents"]},
    "D2-2026-04-23": {"exclude_newer": "2026-04-24T00:00:00Z", "packages": ["langgraph", "langchain", "langchain-core", "langgraph-prebuilt", "langchain-classic", "deepagents"], "optional": []},
    "D3-latest": {"exclude_newer": None, "packages": ["langgraph", "langchain", "langchain-core", "langgraph-prebuilt", "langchain-classic", "deepagents", "langchain-anthropic"], "optional": []},
}
ALL = [c for c in CELLS if not c.startswith("D0b")]
PLAN = {  # probe -> (script, cells)
    "P1": ("p01_crea_deprecation.py", ALL + ["D0b-2025-10-16-with-deepagents"]), "P2": ("p02_create_agent_prompt_kwarg.py", ALL + ["D0b-2025-10-16-with-deepagents"]), "P3": ("p03_stream_node_name.py", ALL),
    "P4": ("p04_crea_new_kwargs.py", ALL), "P5": ("p05_pydantic_state.py", ALL), "P6": ("p06_legacy_imports.py", ALL),
    "P7": ("p07_docs_link_target.py", ["D3-latest"]), "P8": ("p08_stale_structured_response.py", ["D1-2025-10-18", "D2-2026-04-23", "D3-latest"]),
    "P9": ("p09_hitl_ainvoke.py", ["D1-2025-10-18", "D2-2026-04-23", "D3-latest"]), "P10": ("p10_compiled_subagent.py", ["D2-2026-04-23", "D3-latest"]),
    "P12": ("p12_token_overhead_live.py", ["D3-latest"]),
}
RESOLVE = {"P11": {"requirements": "langgraph>=1.0.0\nlanggraph-swarm\n", "cells": {"2025-10-28": "2025-10-29T00:00:00Z", "D3-latest": None}}}


def py(cell):
    return os.path.join(ENVS, cell, "Scripts", "python.exe") if os.name == "nt" else os.path.join(ENVS, cell, "bin", "python")


def uv(args, stdin=None, timeout=900):
    p = subprocess.run(["uv"] + args, input=stdin, capture_output=True, text=True, encoding="utf-8", timeout=timeout)
    return p.returncode, p.stdout, p.stderr


def build_envs():
    for cell, spec in CELLS.items():
        d = os.path.join(ENVS, cell)
        info_path = os.path.join(d, "probe-env.json")
        if os.path.exists(info_path):
            C.log(f"{cell}: exists")
            continue
        rc, _, err = uv(["venv", "--python", "3.12", d])
        assert rc == 0, err
        base = ["pip", "install", "--python", py(cell)] + (["--exclude-newer", spec["exclude_newer"]] if spec["exclude_newer"] else [])
        t0 = time.time()
        rc, out, err = uv(base + spec["packages"] + spec["optional"])
        dropped = []
        if rc != 0 and spec["optional"]:
            dropped = list(spec["optional"])
            rc, out, err = uv(base + spec["packages"])
        if rc != 0:
            C.write_json(info_path + ".failed", {"cell": cell, "stderr": err[-3000:]})
            C.log(f"{cell}: install FAILED {err[-400:]}")
            continue
        rc2, freeze, _ = uv(["pip", "freeze", "--python", py(cell)])
        info = {"cell": cell, "exclude_newer": spec["exclude_newer"], "requested": spec["packages"] + spec["optional"], "dropped_optional": dropped, "dropped_reason": err[-1500:] if dropped else None,
                "freeze": freeze, "lock_sha256": hashlib.sha256(freeze.encode()).hexdigest(), "built_at": C.now_iso(), "install_seconds": round(time.time() - t0, 1)}
        C.write_json(info_path, info)
        C.log(f"{cell}: built in {info['install_seconds']}s, dropped {dropped}; " + ", ".join(l for l in freeze.splitlines() if l.split("==")[0] in ("langgraph", "langchain", "langchain-core", "deepagents", "langchain-classic")))


def clean_env(extra=None):
    keep = {k: v for k, v in os.environ.items() if k.upper() in ("PATH", "SYSTEMROOT", "TEMP", "TMP", "USERPROFILE", "APPDATA", "LOCALAPPDATA", "HOMEDRIVE", "HOMEPATH", "COMSPEC", "PATHEXT", "WINDIR")}
    keep.update({"PYTHONIOENCODING": "utf-8", "PYTHONUTF8": "1"})
    keep.update(extra or {})
    return keep


def run(only):
    for probe, (script, cells) in PLAN.items():
        if only and probe not in only:
            continue
        for cell in cells:
            info_path = os.path.join(ENVS, cell, "probe-env.json")
            started = C.now_iso()
            rec = {"probe": probe, "cell": cell, "script": "scripts/knowledge-lab/probes/" + script, "script_sha256": hashlib.sha256(open(os.path.join(PROBES, script), "rb").read()).hexdigest(), "started_at": started}
            if not os.path.exists(info_path):
                rec.update(outcome="skipped", reason="environment not resolvable for this cell", ended_at=C.now_iso())
            else:
                env_info = json.load(open(info_path, encoding="utf-8"))
                extra = {}
                if probe == "P12":
                    extra = {"ANTHROPIC_API_KEY": C.load_secret("ANTHROPIC_PRODUCER_API_KEY"), "PROBE_RUNS": "5", "PROBE_MODEL": os.environ.get("PROBE_MODEL", "claude-haiku-4-5")}
                t0 = time.time()
                try:
                    p = subprocess.run([py(cell), "-E", "-s", script], cwd=PROBES, capture_output=True, text=True, encoding="utf-8", timeout=300, env=clean_env(extra))
                    rc, so, se = p.returncode, p.stdout, p.stderr
                except subprocess.TimeoutExpired as e:
                    rc, so, se = -9, (e.stdout or ""), "timeout after 300 s"
                line = next((l for l in reversed((so or "").splitlines()) if l.startswith("{")), None)
                result = json.loads(line) if line else None
                rec.update(exit_code=rc, ended_at=C.now_iso(), elapsed_ms=int((time.time() - t0) * 1000), lock_sha256=env_info["lock_sha256"], exclude_newer=env_info["exclude_newer"],
                           result=result, stderr_tail=(se or "")[-2500:], outcome=("pass" if rc == 0 and result else ("error" if rc != 0 else "fail")))
            path = os.path.join(OUT, f"{probe}__{cell}.json")
            C.write_json(path, rec)
            C.log(f"{probe} {cell}: {rec['outcome']} checks={json.dumps((rec.get('result') or {}).get('checks'))[:300]}")


RESOLVE_CELLS = {  # P11 cells: (requirements, cutoff). The reporter's pins come from langgraph-swarm-py #106.
    "2025-10-28-unpinned": ("langgraph>=1.0.0\nlanggraph-swarm\n", "2025-10-29T00:00:00Z"),
    "2025-11-04-reporter-pins": ("langchain>=1.0.2\nlanggraph>=1.0.1\nlanggraph-swarm>=0.0.14\n", "2025-11-05T00:00:00Z"),
    "D3-latest-reporter-pins": ("langchain>=1.0.2\nlanggraph>=1.0.1\nlanggraph-swarm>=0.0.14\n", None),
}


def pinned(out, name):
    return next((l.split("==")[1] for l in out.splitlines() if l.startswith(name + "==")), None)


def resolve():
    for probe in RESOLVE:
        for cell, (reqs, cutoff) in RESOLVE_CELLS.items():
            started = C.now_iso()
            args = ["pip", "compile", "-", "--python-version", "3.12", "--no-header"] + (["--exclude-newer", cutoff] if cutoff else [])
            rc, out, err = uv(args, stdin=reqs, timeout=300)
            core = pinned(out, "langchain-core") if rc == 0 else None
            rec = {"probe": probe, "cell": cell, "script": "uv pip compile (requirements inline)", "requirements": reqs, "exclude_newer": cutoff, "started_at": started, "ended_at": C.now_iso(),
                   "exit_code": rc, "outcome": "pass", "result": {"probe": probe, "observations": {"resolved": out if rc == 0 else None, "resolver_error": err[-2500:] if rc != 0 else None},
                                                                     "checks": {"resolves": rc == 0, "langgraph": pinned(out, "langgraph") if rc == 0 else None, "langgraph_swarm": pinned(out, "langgraph-swarm") if rc == 0 else None,
                                                                                "langchain_core": core, "mixed_major": bool(core and core.startswith("0.") and (pinned(out, "langgraph") or "").startswith("1."))}}}
            C.write_json(os.path.join(OUT, f"{probe}__{cell}.json"), rec)
            C.log(f"{probe} {cell}: rc={rc} checks={rec['result']['checks']}")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "run"
    {"envs": build_envs, "run": lambda: run(sys.argv[2:]), "resolve": resolve}[cmd]()
