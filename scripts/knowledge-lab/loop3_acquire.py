"""Build 08 knowledge loop 3, stage A: acquire the selection (reviews/BUILD-08-LOOP-3-SELECTION.md §2-§3) with honest provenance.

Same ledger as loops 1-2 (acquisition.fetch -> artifact -> source_capture -> document/version/representation). New in loop 3:
- object paths are derived from the digest (<tenant>/sha256/<sha>), on disk too (<key>-<sha12>.<ext>): closes D-37 (CAP-D7);
- API surfaces (R3) for every deepagents release tag and three tags each of langchain / langchain-core, cap 3,000 symbols,
  one unit per overloaded name, per-symbol external uses (imports resolved from the module's import table);
- capability manifests at custody level C1: the repository tree at a pinned commit (git blob ids) plus the entry and config
  files, each fetched file verified against its git blob id. No bundle bytes beyond those files are stored.
Run: python -I -X utf8 scripts/knowledge-lab/loop3_acquire.py [web|surfaces|capabilities] [keys ...]
"""
import json, os, re, sys, uuid, tarfile, ast, hashlib, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_acquire as A
import loop2_acquire as A2

SOURCES3 = os.path.join(C.LAB, "sources", "2026-11-10")
RUN3 = os.path.join(C.LAB, "knowledge-loop-3")
TARBALLS = os.environ.get("LOOP3_TARBALL_DIR") or os.path.join(os.environ.get("TEMP") or "/tmp", "aieng-loop3-tarballs")
for d in (SOURCES3, RUN3, TARBALLS):
    os.makedirs(d, exist_ok=True)
A.SOURCES_DIR = C.SOURCES_DIR = SOURCES3
A.RUN_DIR = C.RUN_DIR = RUN3
ORIGIN = "native harness fetch, Build 08 knowledge loop 3 (claude-code session 2026-11-10)"
LEDGER = os.path.join(RUN3, "ACQUISITION-LEDGER.jsonl")
EXT = dict(A2.EXT)
GITHUB_ACCEPT = A2.GITHUB_ACCEPT
CAP = 3000
http = A2.http

DOCS = "https://docs.langchain.com/"
DEEPAGENTS_PAGES = "acp ag-ui async-subagents backends browser-use comparison content-builder context-engineering customization data-analysis deep-research dynamic-subagents event-streaming fault-tolerance frontend/overview frontend/sandbox frontend/subagent-streaming frontend/todo-list going-to-production human-in-the-loop interpreters memory models multimodal overview permissions profiles quickstart rag retrieval rubric sandboxes skills streaming subagents tools".split()
CODE_PAGES = "approval-modes cli-reference config-file configuration credentials extensions goals-and-rubrics hooks mcp-tools memory-and-skills overview plugins providers quickstart remote-sandboxes subagents".split()
LANGCHAIN_PAGES = "agents component-architecture context-engineering deep-agent-from-scratch deploy event-streaming frontend/branching-chat frontend/controlled-generative-ui frontend/declarative-generative-ui frontend/generative-ui-overview frontend/headless-tools frontend/human-in-the-loop frontend/integrations/ai-elements frontend/integrations/assistant-ui frontend/integrations/copilotkit frontend/integrations/openui frontend/integrations/overview frontend/join-rejoin frontend/markdown-messages frontend/message-queues frontend/open-ended-generative-ui frontend/overview frontend/reasoning-tokens frontend/structured-output frontend/time-travel frontend/tool-calling get-help guardrails human-in-the-loop install knowledge-base long-term-memory mcp/auth mcp/connections mcp/index mcp/tools messages middleware/built-in middleware/custom middleware/overview models multi-agent/custom-workflow multi-agent/handoffs multi-agent/handoffs-customer-support multi-agent/index multi-agent/router multi-agent/router-knowledge-base multi-agent/skills multi-agent/skills-sql-assistant multi-agent/subagents multi-agent/subagents-personal-assistant observability overview philosophy quickstart runtime short-term-memory sql-agent streaming structured-output studio test/evals test/index test/integration-testing test/unit-testing tools ui voice-agent".split()
OTHER_PAGES = ["oss/python/releases/changelog", "oss/python/releases/langchain-v1", "oss/python/releases/langgraph-v1", "oss/python/migrate/langchain-mcp-adapters", "oss/python/migrate/langchain-v1", "oss/python/migrate/langgraph-supervisor", "oss/python/migrate/langgraph-v1",
               "oss/python/concepts/context", "oss/python/concepts/human-in-the-loop", "oss/python/concepts/memory", "oss/python/concepts/products", "oss/python/concepts/providers-and-models"]
LANGSMITH_PAGES = ["langsmith/engine", "langsmith/use-the-context-hub", "langsmith/prompt-context-hub", "langsmith/python/managed-deep-agents-memory", "langsmith/python/managed-deep-agents-skills", "langsmith/observability-concepts", "langsmith/insights"]
# pages that get model-written structured digests (selection file §3.2); the six longest also get section digests (decided at run time)
DIGEST_PAGES = {"oss/python/deepagents/" + p for p in "overview customization subagents async-subagents skills memory backends sandboxes context-engineering human-in-the-loop going-to-production permissions".split()} \
    | {"oss/deepagents/code/" + p for p in "hooks plugins memory-and-skills".split()} | {"oss/python/langchain/" + p for p in "agents middleware/overview middleware/built-in long-term-memory".split()} \
    | {"oss/python/migrate/langchain-v1", "oss/python/releases/langchain-v1", "langsmith/engine"}


def doc_entry(path):
    sw = "deepagents" if "/deepagents/" in path else ("langsmith" if path.startswith("langsmith/") else ("langgraph" if "langgraph" in path.split("/")[-1] else "langchain"))
    product = "deep-agents-code" if path.startswith("oss/deepagents/code/") else None
    kind = "official_docs_page" if path.startswith("langsmith/") else ("release_notes" if "/releases/" in path else "framework_docs_page")
    title = "LangChain docs: " + path
    return dict(key="doc-" + re.sub(r"[^a-z0-9]+", "-", path), kind=kind, role="first_party", fmt="markdown", url=DOCS + path + ".md", title=title, publisher="LangChain", software=sw, product=product, docs_path=path,
                digest=path in DIGEST_PAGES, loop=3)


MANIFEST = [
    dict(key="talk-trivedy-data-mining", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/CvRngaQZQ3Y-improving-agents-is-data-mining-problem.md", title="Improving Agents is a Data Mining Problem (Vivek Trivedy, LangChain)", publisher="AI Engineer", event="worldsfair-2026", digest=True, loop=3, video_url="https://www.youtube.com/watch?v=CvRngaQZQ3Y", session_title="Improving Agents is a Data Mining Problem"),
    dict(key="talk-broekhuizen-next-run", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/KGFyOtl5ktI-giving-ai-agents-memory-that-learns.md", title="The Next Run Should Be Better / Giving AI Agents Memory That Learns (Jake Broekhuizen, LangChain)", publisher="AI Engineer", event="worldsfair-2026", digest=True, loop=3, video_url="https://www.youtube.com/watch?v=KGFyOtl5ktI", session_title="The Next Run Should Be Better"),
    dict(key="langchain-repo-record", kind="registry_listing_page", role="registry", fmt="json", url="https://api.github.com/repos/langchain-ai/langchain", title="GitHub repository record: langchain-ai/langchain", publisher="GitHub", accept=GITHUB_ACCEPT, software="langchain", loop=3),
    dict(key="langchain-readme", kind="repository_readme", role="first_party", fmt="markdown", url="https://raw.githubusercontent.com/langchain-ai/langchain/master/README.md", title="langchain-ai/langchain README", publisher="LangChain", software="langchain", loop=3),
    dict(key="pypi-langchain", kind="package_version_page", role="registry", fmt="json", url="https://pypi.org/pypi/langchain/json", title="PyPI: langchain", publisher="PyPI", accept="application/json", software="langchain", timeout=180, loop=3),
    dict(key="pypi-langchain-core", kind="package_version_page", role="registry", fmt="json", url="https://pypi.org/pypi/langchain-core/json", title="PyPI: langchain-core", publisher="PyPI", accept="application/json", software="langchain-core", timeout=180, loop=3),
    dict(key="pypi-deepagents-c2", kind="package_version_page", role="registry", fmt="json", url="https://pypi.org/pypi/deepagents/json", title="PyPI: deepagents", publisher="PyPI", accept="application/json", software="deepagents", timeout=180, loop=3, existing_title=True),
    dict(key="mcp-registry-github-mcp-server", kind="registry_listing_page", role="registry", fmt="json", url="https://registry.modelcontextprotocol.io/v0/servers?limit=30&version=latest&search=github-mcp-server", title="MCP Registry: servers matching 'github-mcp-server'", publisher="Model Context Protocol", accept="application/json", registry="mcp-registry", loop=3),
] + [dict(key=f"langchain-releases-p{i}", kind="github_release", role="first_party", fmt="json", url=f"https://api.github.com/repos/langchain-ai/langchain/releases?per_page=100&page={i}", title=f"langchain-ai/langchain releases (page {i} of 7)", publisher="LangChain", accept=GITHUB_ACCEPT, software="langchain", loop=3, release_packages=["langchain", "langchain-core"], release_major=1) for i in range(1, 8)] \
  + [doc_entry("oss/python/deepagents/" + p) for p in DEEPAGENTS_PAGES] + [doc_entry("oss/deepagents/code/" + p) for p in CODE_PAGES] + [doc_entry("oss/python/langchain/" + p) for p in LANGCHAIN_PAGES] \
  + [doc_entry(p) for p in OTHER_PAGES] + [doc_entry(p) for p in LANGSMITH_PAGES]

# software slug -> repository, candidate package dirs (first that exists in the tarball wins), tags
SURFACES = {
    "deepagents": dict(repo="langchain-ai/deepagents", dirs=["libs/deepagents/deepagents", "src/deepagents", "deepagents"], tags="ALL:deepagents=="),
    "langchain": dict(repo="langchain-ai/langchain", dirs=["libs/langchain_v1/langchain", "libs/langchain/langchain"], tags=["langchain==0.3.27", "langchain==1.0.0", "langchain==1.4.10"]),
    "langchain-core": dict(repo="langchain-ai/langchain", dirs=["libs/core/langchain_core"], tags=["langchain-core==0.3.79", "langchain-core==1.0.0", "langchain-core==1.7.7"]),
    # D-41: at the tag langchain==0.3.27 the repository already carried libs/langchain_v1 (the v1 package under development); the released
    # 0.3.27 package is libs/langchain. The first run parsed langchain_v1 for that tag; that document stays (append-only) but is never
    # unit-ized (SKIP_SURFACE_KEYS) and this entry is the 0.3.27 surface.
    "langchain-legacy": dict(repo="langchain-ai/langchain", dirs=["libs/langchain/langchain"], tags=["langchain==0.3.27"], software="langchain", note="legacy package libs/langchain"),
}
SKIP_SURFACE_KEYS = {"surface3-langchain-langchain-0.3.27"}
EXTERNAL_ROOTS = ("langchain", "langchain_core", "langgraph", "langsmith", "langchain_anthropic", "langchain_openai", "langchain_google_genai", "deepagents", "langchain_classic", "langchain_text_splitters")


def register_capture3(src, body, fetched, origin_label, requested_at, fmt, outcome="captured", prior_capture=None, tool="http", credits=None):
    """Loop-3 registration: the artifact object path is derived from the digest; identical bytes reuse the artifact row."""
    sha = sha256_bytes(body)
    media = A.MEDIA_BY_FMT.get(fmt, "application/octet-stream")
    fetch_id = str(uuid.uuid4())
    sql(f"""insert into acquisition.fetch(id, tenant_id, origin_kind, origin_label, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, credits_used, prior_capture_id, notes)
            values ({q(fetch_id)}, {q(TENANT)}, 'native_harness', {q(origin_label)}, {q(tool)}, 'urllib/python3.12', {q(src['url'])}, {q(fetched.get('final_url'))}, {q(requested_at)}, now(), {q(fetched.get('status'))}, {q(outcome)}, {q(sha)}, {q(media)}, {len(body)}, {q(credits)}, {q(prior_capture)}, {q({'elapsed_ms': fetched.get('elapsed_ms'), 'kind': src['kind'], 'format': fmt, 'error': fetched.get('error'), 'loop': 3})})""")
    if outcome != "captured":
        return fetch_id, None, sha, None
    object_path = f"{TENANT}/sha256/{sha}"
    artifact = one(f"select id from orchestration.artifact where tenant_id={q(TENANT)} and storage_bucket='lab-sources' and object_path={q(object_path)}")
    if not artifact:
        artifact = str(uuid.uuid4())
        sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
                values ({q(artifact)}, {q(TENANT)}, 'source_capture', 1, {q(sha)}, 'source_captures', 'lab-sources', {q(object_path)}, {q(media)}, {len(body)}, 'available', now())""")
    existing = one(f"select id from evidence.source_capture where artifact_id={q(artifact)}")
    if existing:  # identical bytes already in custody (one capture per artifact): the new fetch row stands, the capture is shared
        return fetch_id, existing, sha, artifact
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if fmt == "json" else ("repository" if fmt == "archive" else "web_page"))
    capture = str(uuid.uuid4())
    sql(f"""insert into evidence.source_capture(id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, context, acquisition_fetch_id)
            values ({q(capture)}, {q(TENANT)}, {q(source_id)}, {q(artifact)}, {q(sha)}, {q(media)}, {q(requested_at)}, 'native_harness_http', '0.3', {q(src['url'])}, {q(fetched.get('status'))}, {q({'origin': origin_label, 'final_url': fetched.get('final_url'), 'tool': tool})}, {q(fetch_id)});
            update evidence.source set capture_count = capture_count + 1, last_seen_at = now(), last_capture_id = {q(capture)} where id = {q(source_id)}""")
    return fetch_id, capture, sha, artifact


A.register_capture = register_capture3


def record_fetch_only(url, fetched, kind, note):
    """A fetch that feeds a derived representation (a bundle file, a commit lookup) is still one acquisition.fetch row."""
    body = fetched.get("body") or b""
    sql(f"""insert into acquisition.fetch(tenant_id, origin_kind, origin_label, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, notes)
            values ({q(TENANT)}, 'native_harness', {q(ORIGIN)}, 'http', 'urllib/python3.12', {q(url)}, {q(fetched.get('final_url'))}, now(), now(), {q(fetched.get('status'))}, {q('captured' if fetched.get('status') == 200 else 'failed')}, {q(sha256_bytes(body))}, {q(fetched.get('media_type'))}, {len(body)}, {q({'kind': kind, 'note': note, 'loop': 3})})""")


def save(key, body, fmt):
    path = os.path.join(SOURCES3, f"{key}-{sha256_bytes(body)[:12]}{EXT.get(fmt, '.bin')}")
    if not os.path.exists(path):
        open(path, "wb").write(body)
    return path


def ensure_document3(src):
    doc = one(f"select id from content.document where tenant_id={q(TENANT)} and canonical_title={q(src['title'])} and document_type_code={q(src['kind'])}")
    if doc:
        return doc
    doc = str(uuid.uuid4())
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if src["fmt"] == "json" else ("repository" if src["fmt"] == "archive" else "web_page"))
    attrs = {k: v for k, v in src.items() if k not in ("url", "title", "fmt", "tool", "accept", "timeout", "refresh", "kind", "role", "existing_title") and v is not None}
    sql(f"""insert into content.document(id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, source_role_code, source_role_method, attributes)
            values ({q(doc)}, {q(TENANT)}, {q(src['kind'])}, {q(src['title'])}, {q(source_id)}, 'active', {q(src['role'])}, 'rule', {q(attrs)});
            insert into content.document_kind_assignment(tenant_id, document_id, document_type_code, method, confidence, rationale)
            values ({q(TENANT)}, {q(doc)}, {q(src['kind'])}, 'rule', 0.9, 'URL/publisher rule in the loop-3 manifest (BUILD-08-LOOP-3-SELECTION.md)')""")
    return doc


def prior_of(doc):
    prior = sql_rows(f"select vc.source_capture_id, c.content_sha256, vc.document_version_id from content.document_version v join content.document_version_source_capture vc on vc.document_version_id=v.id join evidence.source_capture c on c.id=vc.source_capture_id where v.document_id={q(doc)} order by c.captured_at desc limit 1")
    return prior[0] if prior else (None, None, None)


def acquire_web(only):
    for src in MANIFEST:
        if only and src["key"] not in only:
            continue
        doc = ensure_document3(src)
        prior_capture, prior_sha, prior_ver = prior_of(doc)
        if prior_capture and not src.get("existing_title") and not only:
            continue
        if prior_capture and src.get("existing_title") and one(f"select 1 from content.document_version v where v.document_id={q(doc)} and v.created_at > '2026-11-10T20:00:00Z'"):
            continue
        requested_at = now_iso()
        fetched = http(src["url"], accept=src.get("accept") or ("text/markdown" if src["fmt"] == "markdown" else None), timeout=src.get("timeout", 120), github="api.github.com" in src["url"])
        ok = fetched["status"] == 200 and len(fetched["body"]) > 0
        fmt = src["fmt"]
        if ok and fmt == "markdown" and fetched["body"].lstrip()[:15].lower().startswith(b"<!doctype html"):
            fmt = "html"
        outcome = "captured" if ok else ("blocked" if fetched["status"] in (401, 403, 429) else "failed")
        if ok and prior_sha and prior_sha == sha256_bytes(fetched["body"]):
            outcome = "unchanged"
        path = save(src["key"], fetched["body"], fmt) if ok else None
        f_id, cap, sha, art = A.register_capture(dict(src, fmt=fmt), fetched["body"] if ok else b"", fetched, ORIGIN, requested_at, fmt, outcome=outcome, prior_capture=prior_capture)
        ver = None
        if outcome == "captured":
            ver, _ = A.add_version(doc, cap, sha, art, fmt, f"c{2 if prior_capture else 1}-{requested_at[:10]}-{sha[:8]}")
        if prior_capture:
            sql(f"""insert into content.refresh_check(tenant_id, document_id, prior_version_id, fetch_id, outcome, content_sha256, new_version_id)
                    values ({q(TENANT)}, {q(doc)}, {q(prior_ver)}, {q(f_id)}, {q('unchanged' if outcome == 'unchanged' else ('changed' if outcome == 'captured' else 'failed'))}, {q(sha if ok else None)}, {q(ver)})""")
        append_jsonl(LEDGER, {"key": src["key"], "capture": 2 if prior_capture else 1, "url": src["url"], "status": fetched["status"], "fetched_at": requested_at, "sha256": sha if ok else None, "bytes": len(fetched["body"]), "format": fmt, "outcome": outcome, "fetch_id": f_id, "capture_id": cap, "version_id": ver, "document_id": doc, "file": os.path.basename(path) if path else None, "error": fetched.get("error")})
        log(f"{src['key']}: {fetched['status']} {outcome} {len(fetched['body'])} bytes")
        time.sleep(0.15)


# ------------------------------------------------------------------ R3: API surface (python ast, no import)
def import_table(tree, own_root):
    """alias -> external qualified name, for imports of the tracked LangChain-family packages other than the package itself."""
    table = {}
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module and node.level == 0:
            root = node.module.split(".")[0]
            if root in EXTERNAL_ROOTS and root != own_root:
                for a in node.names:
                    if a.name != "*":
                        table[a.asname or a.name] = (f"{node.module}.{a.name}", False)
        elif isinstance(node, ast.Import):
            for a in node.names:
                root = a.name.split(".")[0]
                if root in EXTERNAL_ROOTS and root != own_root:
                    table[a.asname or root] = (a.name if a.asname else root, True)
    return table


def uses_of(node, table):
    """External names a definition's body refers to: imported names, and attributes of imported modules (`lg.StateGraph`)."""
    used = set()
    for sub in ast.walk(node):
        if isinstance(sub, ast.Name) and sub.id in table and not table[sub.id][1]:
            used.add(table[sub.id][0])
        elif isinstance(sub, ast.Attribute) and isinstance(sub.value, ast.Name) and sub.value.id in table and table[sub.value.id][1]:
            used.add(table[sub.value.id][0] + "." + sub.attr)
    return sorted(used)


def parse_surface3(tar_path, repo, tag, pkg_dirs, cap=CAP):
    symbols, modules, skipped = [], 0, 0
    with tarfile.open(tar_path, "r:gz") as tf:
        members = [m for m in tf.getmembers() if m.isfile()]
        root = members[0].name.split("/")[0] if members else ""
        names = {m.name for m in members}
        pkg_dir = next((d for d in pkg_dirs if f"{root}/{d}/__init__.py" in names), None)
        if not pkg_dir:
            return None
        prefix = f"{root}/{pkg_dir}/"
        own_root = pkg_dir.split("/")[-1]
        for m in sorted((m for m in members if m.name.startswith(prefix) and m.name.endswith(".py")), key=lambda m: m.name):
            rel = m.name[len(prefix):]
            parts = rel[:-3].split("/")
            if any(p.startswith("_") and p != "__init__" for p in parts) or "tests" in parts or "test" in parts:
                skipped += 1
                continue
            mod = ".".join([own_root] + [p for p in parts if p != "__init__"])
            src = tf.extractfile(m).read().decode("utf-8", "replace")
            try:
                tree = ast.parse(src)
            except SyntaxError:
                skipped += 1
                continue
            modules += 1
            table = import_table(tree, own_root)
            exported = set()
            for node in tree.body:
                if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == "__all__" for t in node.targets):
                    try:
                        exported = set(ast.literal_eval(node.value))
                    except Exception:
                        pass
            path = m.name[len(root) + 1:]
            for node in tree.body:
                names_, kind, sig, doc = [], None, None, None
                if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    names_, kind, sig, doc = [node.name], "function", A2.py_signature(node), ast.get_docstring(node)
                elif isinstance(node, ast.ClassDef):
                    bases = ", ".join(ast.unparse(b) for b in node.bases)
                    names_, kind, sig, doc = [node.name], "class", f"class {node.name}({bases})"[:400], ast.get_docstring(node)
                    for sub in node.body:
                        if isinstance(sub, (ast.FunctionDef, ast.AsyncFunctionDef)) and not sub.name.startswith("_"):
                            symbols.append(dict(qualified_name=f"{mod}.{node.name}.{sub.name}", kind="method", signature=A2.py_signature(sub), module=mod, is_public=not node.name.startswith("_"), deprecated=any("deprecat" in ast.unparse(d).lower() for d in sub.decorator_list),
                                                docstring_head=(ast.get_docstring(sub) or "").split("\n")[0][:200] or None, path=path, lineno=sub.lineno, exported_by=None, uses_external=None))
                elif isinstance(node, (ast.Assign, ast.AnnAssign)):
                    targets = node.targets if isinstance(node, ast.Assign) else [node.target]
                    names_ = [t.id for t in targets if isinstance(t, ast.Name)]
                    kind = "constant" if names_ and all(n.isupper() for n in names_) else "variable"
                    sig = ast.unparse(node)[:200]
                elif isinstance(node, ast.ImportFrom) and parts[-1] == "__init__":
                    # re-exports in a package __init__: `from x import Y` listed in __all__ is public API of the package
                    for a in node.names:
                        nm = a.asname or a.name
                        if nm in exported:
                            origin = ("." * node.level) + (node.module or "")
                            symbols.append(dict(qualified_name=f"{mod}.{nm}", kind="reexport", signature=f"from {origin} import {a.name}"[:200], module=mod, is_public=True, deprecated=False, docstring_head=None, path=path, lineno=node.lineno, exported_by="__all__",
                                                uses_external=[f"{node.module}.{a.name}"] if node.level == 0 and node.module and node.module.split(".")[0] in EXTERNAL_ROOTS and node.module.split(".")[0] != own_root else None))
                    continue
                if not names_ or names_ == ["__all__"]:
                    continue
                uses = uses_of(node, table) if kind in ("function", "class") else None
                for nm in names_:
                    if nm.startswith("_") and nm not in exported:
                        continue
                    symbols.append(dict(qualified_name=f"{mod}.{nm}", kind=kind, signature=sig, module=mod, is_public=True, deprecated=bool(isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)) and any("deprecat" in ast.unparse(d).lower() for d in node.decorator_list)),
                                        docstring_head=(doc or "").split("\n")[0][:200] or None, path=path, lineno=node.lineno, exported_by="__all__" if nm in exported else None, uses_external=uses or None))
    # one unit per name: overloads (typing.overload, property pairs, conditional redefinitions) collapse into an `overloads` list
    merged, order = {}, []
    for s in symbols:
        k = s["qualified_name"]
        if k not in merged:
            merged[k] = dict(s, _sigs=[s["signature"]] if s["signature"] else [])
            order.append(k)
        else:
            if s["signature"] and s["signature"] not in merged[k]["_sigs"]:
                merged[k]["_sigs"].append(s["signature"])
            merged[k]["deprecated"] = merged[k]["deprecated"] or s["deprecated"]
            if s.get("uses_external"):
                merged[k]["uses_external"] = sorted(set((merged[k].get("uses_external") or []) + s["uses_external"]))
            if merged[k]["kind"] == "reexport" and s["kind"] != "reexport":
                merged[k].update({f: s[f] for f in ("kind", "signature", "docstring_head", "lineno")})
    out = []
    for k in order:
        s = merged[k]
        sigs = s.pop("_sigs")
        if len(sigs) > 1:
            s["overloads"] = sigs
            s["overload_count"] = len(sigs)
            s["signature"] = " || ".join(sorted(sigs))[:1200]
        if s["kind"] == "reexport":
            s["kind"] = "variable"
            s["reexport"] = True
        out.append(s)
    out.sort(key=lambda s: (0 if s["exported_by"] else 1, {"class": 0, "function": 1, "constant": 2, "type": 2, "method": 3, "variable": 4}.get(s["kind"], 5), s["module"], s["lineno"]))
    total = len(out)
    return {"repository": repo, "release_tag": tag, "package": pkg_dir.split("/")[-1], "parser": "python-ast/2 (loop3_acquire.parse_surface3)", "parser_scope": pkg_dir, "modules_parsed": modules, "files_skipped": skipped, "symbol_count": total,
            "public_symbol_count": sum(1 for s in out if s["is_public"]), "exported_count": sum(1 for s in out if s["exported_by"]), "overloaded_names": sum(1 for s in out if s.get("overloads")), "over_cap": total > cap, "cap": cap,
            "all_names": [[s["qualified_name"], s["kind"]] for s in out], "symbols": out[:cap]}


def release_dates(repo):
    path = os.path.join(RUN3, f"releases-{repo.replace('/', '-')}.json")
    if not os.path.exists(path):
        rels = []
        for p in range(1, 12):
            f = http(f"https://api.github.com/repos/{repo}/releases?per_page=100&page={p}", accept=GITHUB_ACCEPT, github=True)
            page = json.loads(f["body"]) if f["status"] == 200 else []
            rels += [{"tag_name": r["tag_name"], "published_at": r["published_at"], "prerelease": r["prerelease"]} for r in page]
            if len(page) < 100:
                break
        write_json(path, rels)
    return {r["tag_name"]: r for r in json.load(open(path, encoding="utf-8"))}


def acquire_surfaces(only):
    for sw, spec in SURFACES.items():
        if only and sw not in only:
            continue
        rels = release_dates(spec["repo"])
        tags = spec["tags"]
        if isinstance(tags, str):
            pref = tags.split(":", 1)[1]
            tags = sorted((t for t, r in rels.items() if t.startswith(pref) and not r["prerelease"]), key=lambda t: [int(x) for x in re.findall(r"\d+", t)])
        for tag in tags:
            key = f"surface3-{sw}-{re.sub(r'[^0-9a-zA-Z.]+', '-', tag)}"
            released = (rels.get(tag) or {}).get("published_at")
            src = dict(key=key, kind="api_surface", role="system", fmt="archive", url=f"https://api.github.com/repos/{spec['repo']}/tarball/{tag}", title=f"{spec['repo']} {spec.get('software', sw)} public API surface at {tag} ({(spec['note'] + ', ') if spec.get('note') else ''}python-ast/2)", publisher=spec["repo"].split("/")[0],
                       software=spec.get("software", sw), repository=spec["repo"], release_tag=tag, released_on=released[:10] if released else None, parser="python-ast/2", package=spec["dirs"][0].split("/")[-1], derived_from="GitHub tag tarball (R7)", cap=CAP, loop=3)
            doc = ensure_document3(src)
            if one(f"select 1 from content.document_version v join content.document_representation r on r.document_version_id=v.id where v.document_id={q(doc)} and r.representation_class='structural_extraction'"):
                continue
            requested_at = now_iso()
            tar_path = os.path.join(TARBALLS, key + ".tar.gz")
            if os.path.exists(tar_path):
                fetched = {"status": 200, "final_url": src["url"], "body": open(tar_path, "rb").read(), "elapsed_ms": 0}
            else:
                fetched = http(src["url"], github=True, timeout=600)
                if fetched["status"] == 200:
                    open(tar_path, "wb").write(fetched["body"])
            ok = fetched["status"] == 200 and len(fetched["body"]) > 1000
            A.MEDIA_BY_FMT["archive"] = "application/gzip"
            f_id, cap_id, sha, art = A.register_capture(src, fetched["body"] if ok else b"", fetched, ORIGIN + " (GitHub tag tarball, R7)", requested_at, "archive", outcome="captured" if ok else "failed")
            row = {"key": key, "url": src["url"], "status": fetched["status"], "fetched_at": requested_at, "bytes": len(fetched["body"]), "outcome": "captured" if ok else "failed", "document_id": doc, "software": sw, "tag": tag}
            if not ok:
                append_jsonl(LEDGER, row)
                log(f"{key}: failed {fetched.get('error')}")
                continue
            ver, _ = A.add_version(doc, cap_id, sha, art, "archive", f"tag-{tag}-{sha[:8]}")
            surface = parse_surface3(tar_path, spec["repo"], tag, spec["dirs"])
            del fetched
            if surface is None:
                append_jsonl(LEDGER, dict(row, outcome="no_package_dir"))
                log(f"{key}: package directory not found in tarball (tried {spec['dirs']})")
                continue
            surface["tarball_sha256"] = sha
            surface["released_on"] = src["released_on"]
            body = json.dumps(surface, ensure_ascii=False, indent=0).encode("utf-8")
            jpath = save(key, body, "json")
            dsha = sha256_bytes(body)
            dpath = f"{TENANT}/sha256/{dsha}"
            dart = one(f"select id from orchestration.artifact where tenant_id={q(TENANT)} and storage_bucket='lab-sources' and object_path={q(dpath)}") or str(uuid.uuid4())
            sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
                    values ({q(dart)}, {q(TENANT)}, 'canonical_source_projection', 1, {q(dsha)}, 'source_captures', 'lab-sources', {q(dpath)}, 'application/json', {len(body)}, 'available', now()) on conflict do nothing;
                    insert into content.document_representation(id, tenant_id, document_version_id, artifact_id, representation_kind, representation_class, media_type, content_sha256, acceptance_state, source_native_byte_identical, grammar_version)
                    values ({q(str(uuid.uuid4()))}, {q(TENANT)}, {q(ver)}, {q(dart)}, 'json', 'structural_extraction', 'application/json', {q(dsha)}, 'accepted', false, 'build08-grammar/3')""")
            row.update({"sha256": sha, "version_id": ver, "derived_sha256": dsha, "symbol_count": surface["symbol_count"], "kept": len(surface["symbols"]), "over_cap": surface["over_cap"], "modules": surface["modules_parsed"], "overloaded": surface["overloaded_names"], "file": os.path.basename(jpath), "package_dir": surface["parser_scope"]})
            append_jsonl(LEDGER, row)
            log(f"{key}: {surface['symbol_count']} symbols ({surface['exported_count']} exported, {surface['modules_parsed']} modules, overloaded {surface['overloaded_names']}, over_cap={surface['over_cap']}, dir {surface['parser_scope']})")


# ------------------------------------------------------------------ capability manifests at custody level C1
CAPABILITIES = [
    *[dict(key=f"skill-dcode-{n}", kind="agent_skill_manifest", entity_kind="agent_skill", repo="langchain-ai/deepagents", ref="deepagents==0.7.35", path=f"libs/code/deepagents_code/built_in_skills/{n}", name=n, shipped_with="Deep Agents Code (deepagents_code built_in_skills)") for n in ("remember", "skill-creator", "deepagents-plugin-discovery", "deepagents-thread-inspector")],
    dict(key="plugin-langsmith-tracing", kind="agent_plugin_manifest", entity_kind="agent_plugin", repo="langchain-ai/langsmith-claude-code-plugins", ref="HEAD", path="plugins/langsmith-tracing", name="langsmith-tracing", marketplace=".claude-plugin/marketplace.json", harnesses=["claude-code"]),
    dict(key="plugin-langchain-mcp", kind="agent_plugin_manifest", entity_kind="agent_plugin", repo="langchain-ai/langchain-plugins", ref="HEAD", path="plugins/langchain-mcp", name="langchain-mcp", marketplace=".claude-plugin/marketplace.json", harnesses=["deep-agents-code", "claude-code", "codex"], extra_files=["README.md"]),
    dict(key="plugin-langsmith-mcp", kind="agent_plugin_manifest", entity_kind="agent_plugin", repo="langchain-ai/langchain-plugins", ref="HEAD", path="plugins/langsmith-mcp", name="langsmith-mcp", marketplace=".claude-plugin/marketplace.json", harnesses=["deep-agents-code", "claude-code", "codex"], extra_files=["README.md"]),
]
MCP_SERVER = dict(key="mcp-github-server-readme", kind="mcp_server_manifest", role="first_party", fmt="markdown", title="github/github-mcp-server tool manifest (README.md at a release tag)", publisher="GitHub", repository="github/github-mcp-server",
                  identifier_scheme="mcp_registry", identifier_value="io.github.github/github-mcp-server", custody_level="C1", server="io.github.github/github-mcp-server", loop=3, tags=["v1.14.0", "v2.1.0"])
TEXT_EXT = (".md", ".json", ".yaml", ".yml", ".toml", ".txt")


def git_blob_id(body):
    return hashlib.sha1(b"blob " + str(len(body)).encode() + b"\0" + body).hexdigest()


def file_role(rel, kind, mode):
    base = rel.split("/")[-1]
    if base in ("SKILL.md", "plugin.json") or rel.endswith(".claude-plugin/plugin.json") or rel.endswith(".codex-plugin/plugin.json"):
        return "entry"
    if rel.startswith("binary/") or base.endswith((".tar.xz", ".exe")) or "darwin" in base or "linux" in base:
        return "binary"
    if base.endswith(".md"):
        return "instructions"
    if base.endswith((".json", ".yaml", ".yml", ".toml")) or base.startswith("."):
        return "config"
    if base.endswith((".py", ".sh", ".js", ".mjs", ".ts")) or mode == "100755":
        return "cli" if rel.startswith(("bin/", "hooks/")) and mode == "100755" else "script"
    return "asset" if base.endswith((".png", ".jpg", ".svg", ".gif")) else "other"


def acquire_capabilities(only):
    trees, registered = {}, {}
    for cap in CAPABILITIES:
        if only and cap["key"] not in only:
            continue
        repo, ref = cap["repo"], cap["ref"]
        if (repo, ref) not in trees:
            c = http(f"https://api.github.com/repos/{repo}/commits/{ref}", accept=GITHUB_ACCEPT, github=True)
            record_fetch_only(f"https://api.github.com/repos/{repo}/commits/{ref}", c, "commit_lookup", "resolve the ref to a commit sha (pin)")
            commit = json.loads(c["body"])
            t_url = f"https://api.github.com/repos/{repo}/git/trees/{commit['sha']}?recursive=1"
            t = http(t_url, accept=GITHUB_ACCEPT, github=True, timeout=180)
            trees[(repo, ref)] = (commit["sha"], commit["commit"]["committer"]["date"], t_url, t)
        commit_sha, commit_date, t_url, t = trees[(repo, ref)]
        ident = f"{repo}#{cap['path']}"
        src = dict(key=cap["key"], kind=cap["kind"], role="first_party", fmt="json", url=t_url, title=f"Capability manifest: {cap['name']} ({ident})", publisher=repo.split("/")[0], repository=repo, ref=ref, commit=commit_sha, commit_date=commit_date, bundle_path=cap["path"],
                   identifier_scheme="github", identifier_value=ident, custody_level="C1", custody_decision={"actor": "loop-3 selection (pre-approved by John 2026-11-10)", "reason": "trial capability item; manifest and entry files only", "at": "2026-11-10"},
                   capability_name=cap["name"], entity_kind=cap["entity_kind"], shipped_with=cap.get("shipped_with"), harnesses=cap.get("harnesses"), marketplace=cap.get("marketplace"), loop=3)
        doc = ensure_document3(src)
        if one(f"select 1 from content.document_version v join content.document_representation r on r.document_version_id=v.id where v.document_id={q(doc)} and r.representation_class='structural_extraction'"):
            continue
        requested_at = now_iso()
        ok = t["status"] == 200
        if (repo, ref) not in registered:  # one HTTP fetch of the tree = one acquisition.fetch row, shared by the capabilities of that repository
            registered[(repo, ref)] = A.register_capture(src, t["body"] if ok else b"", t, ORIGIN + " (GitHub git trees API at a pinned commit)", requested_at, "json", outcome="captured" if ok else "failed")
        f_id, cap_id, sha, art = registered[(repo, ref)]
        if not ok:
            log(f"{cap['key']}: tree fetch failed {t.get('error')}")
            continue
        save(cap["key"] + "-tree", t["body"], "json")
        ver, _ = A.add_version(doc, cap_id, sha, art, "json", f"commit-{commit_sha[:10]}")
        tree = json.loads(t["body"])
        entries = [e for e in tree["tree"] if e["path"].startswith(cap["path"] + "/") and e["type"] in ("blob", "commit")]
        files, manifest_rows = {}, []
        wanted = [cap["marketplace"]] if cap.get("marketplace") else []
        wanted += cap.get("extra_files") or []
        for e in entries:
            rel = e["path"][len(cap["path"]) + 1:]
            mode = e["mode"]
            role = file_role(rel, cap["kind"], mode)
            manifest_rows.append({"path": rel, "size": e.get("size"), "mode": mode, "executable": mode == "100755", "symlink": mode == "120000", "git_blob_id": e["sha"], "role": role})
        for e in entries + [x for x in tree["tree"] if x["path"] in wanted]:
            inside = e["path"].startswith(cap["path"] + "/")
            rel = e["path"][len(cap["path"]) + 1:] if inside else "../" + e["path"]
            role = file_role(rel, cap["kind"], e["mode"]) if inside else "config"
            if e["mode"] == "120000" or (e.get("size") or 0) > 200_000 or not (role in ("entry", "instructions", "config") and (rel.endswith(TEXT_EXT) or rel.split("/")[-1].startswith("."))):
                continue
            raw_url = f"https://raw.githubusercontent.com/{repo}/{commit_sha}/{e['path']}"
            f = http(raw_url, timeout=60)
            record_fetch_only(raw_url, f, "bundle_file", f"C1 entry/config file of {ident}")
            if f["status"] != 200:
                continue
            body = f["body"]
            verified = git_blob_id(body) == e["sha"]
            files[rel] = {"sha256": sha256_bytes(body), "git_blob_id": e["sha"], "verified_against_tree": verified, "text": body.decode("utf-8", "replace")}
            for r in manifest_rows:
                if r["path"] == rel:
                    r["sha256"] = files[rel]["sha256"]
        derived = {"identifier": {"scheme": "github", "value": ident}, "repository": repo, "ref": ref, "commit": commit_sha, "commit_date": commit_date, "path": cap["path"], "custody_level": "C1", "capability": cap["name"], "entity_kind": cap["entity_kind"],
                   "tree": manifest_rows, "files": files, "bytes_total": sum(r.get("size") or 0 for r in manifest_rows), "bytes_fetched": sum(len(v["text"].encode()) for k, v in files.items() if not k.startswith("../"))}
        body = json.dumps(derived, ensure_ascii=False, indent=0).encode("utf-8")
        jpath = save(cap["key"], body, "json")
        dsha = sha256_bytes(body)
        dpath = f"{TENANT}/sha256/{dsha}"
        dart = one(f"select id from orchestration.artifact where tenant_id={q(TENANT)} and storage_bucket='lab-sources' and object_path={q(dpath)}") or str(uuid.uuid4())
        sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
                values ({q(dart)}, {q(TENANT)}, 'canonical_source_projection', 1, {q(dsha)}, 'source_captures', 'lab-sources', {q(dpath)}, 'application/json', {len(body)}, 'available', now()) on conflict do nothing;
                insert into content.document_representation(id, tenant_id, document_version_id, artifact_id, representation_kind, representation_class, media_type, content_sha256, acceptance_state, source_native_byte_identical, grammar_version)
                values ({q(str(uuid.uuid4()))}, {q(TENANT)}, {q(ver)}, {q(dart)}, 'json', 'structural_extraction', 'application/json', {q(dsha)}, 'accepted', false, 'build08-grammar/3')""")
        append_jsonl(LEDGER, {"key": cap["key"], "identifier": ident, "commit": commit_sha, "document_id": doc, "version_id": ver, "files_in_bundle": len(manifest_rows), "files_fetched": len(files), "all_verified": all(v["verified_against_tree"] for v in files.values()), "bytes_total": derived["bytes_total"], "bytes_fetched": derived["bytes_fetched"], "file": os.path.basename(jpath)})
        log(f"{cap['key']}: {len(manifest_rows)} files in bundle ({derived['bytes_total']} bytes), {len(files)} fetched ({derived['bytes_fetched']} bytes), blob ids verified={all(v['verified_against_tree'] for v in files.values())}")
    # MCP server: README tool manifest at two release tags = two versions of one document
    if not only or MCP_SERVER["key"] in only:
        m = MCP_SERVER
        base = {k: v for k, v in m.items() if k != "tags"}
        base["url"] = f"https://raw.githubusercontent.com/{m['repository']}/{m['tags'][-1]}/README.md"
        doc = ensure_document3(base)
        for i, tag in enumerate(m["tags"]):
            label = f"tag-{tag}"
            if one(f"select 1 from content.document_version where document_id={q(doc)} and version_label like {q(label + '%')}"):
                continue
            url = f"https://raw.githubusercontent.com/{m['repository']}/{tag}/README.md"
            requested_at = now_iso()
            f = http(url, timeout=120)
            ok = f["status"] == 200
            prior_capture, prior_sha, prior_ver = prior_of(doc)
            f_id, cap_id, sha, art = A.register_capture(dict(base, url=url), f["body"] if ok else b"", f, ORIGIN + f" (README at release tag {tag})", requested_at, "markdown", outcome="captured" if ok else "failed", prior_capture=prior_capture)
            if not ok:
                log(f"{m['key']} {tag}: failed")
                continue
            save(f"{m['key']}-{tag}", f["body"], "markdown")
            ver, _ = A.add_version(doc, cap_id, sha, art, "markdown", f"{label}-{sha[:8]}")
            if prior_capture:
                sql(f"""insert into content.refresh_check(tenant_id, document_id, prior_version_id, fetch_id, outcome, content_sha256, new_version_id) values ({q(TENANT)}, {q(doc)}, {q(prior_ver)}, {q(f_id)}, 'changed', {q(sha)}, {q(ver)})""")
            append_jsonl(LEDGER, {"key": m["key"], "tag": tag, "url": url, "status": f["status"], "sha256": sha, "bytes": len(f["body"]), "document_id": doc, "version_id": ver})
            log(f"{m['key']} {tag}: {len(f['body'])} bytes")
            time.sleep(1.1)  # captured_at orders the versions


def main():
    args = [a for a in sys.argv[1:]]
    stages = [a for a in args if a in ("web", "surfaces", "capabilities")] or ["web", "surfaces", "capabilities"]
    only = set(a for a in args if a not in ("web", "surfaces", "capabilities"))
    if "web" in stages:
        acquire_web(only)
    if "surfaces" in stages:
        acquire_surfaces(only)
    if "capabilities" in stages:
        acquire_capabilities(only)
    write_json(os.path.join(RUN3, f"spend-acquire-{'-'.join(stages)}.json"), C.SPEND)
    log("acquisition done: " + ",".join(stages))


if __name__ == "__main__":
    main()
