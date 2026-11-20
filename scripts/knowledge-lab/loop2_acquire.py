"""Build 08 knowledge loop 2, stage A: acquire the approved selection (reviews/BUILD-08-LOOP-2-SELECTION.md §9.1) with honest provenance.

Same ledger as loop 1 (acquisition.fetch -> artifact -> source_capture -> document/version/representation). New in loop 2:
- GitHub tag tarballs are fetched as archives and a DERIVED representation (the parsed public API surface, R3) is attached to the
  same document version (representation_class 'derived', grammar build08-grammar/2); the tree itself is never a document.
- JS-only leaderboards are scraped through the Firecrawl API (credits recorded on the fetch row); everything else is plain HTTPS.
- PDFs, CSVs, zips and JSON APIs are captured as-is; their grammars run in loop2_parse.
Run: python -I -X utf8 scripts/knowledge-lab/loop2_acquire.py [keys ...] ; second pass: ... --refresh [keys ...]
"""
import json, os, re, sys, uuid, tarfile, ast, io, time, urllib.request, urllib.error
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_acquire as A

SOURCES2 = os.path.join(C.LAB, "sources", "2026-11-09")
RUN2 = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-2")
# downloaded tarballs are untrusted data: kept outside the repository and the lab tree (override with LOOP2_TARBALL_DIR)
TARBALLS = os.environ.get("LOOP2_TARBALL_DIR") or os.path.join(os.environ.get("TEMP") or os.environ.get("TMPDIR") or "/tmp", "aieng-loop2-tarballs")
for d in (SOURCES2, RUN2, TARBALLS):
    os.makedirs(d, exist_ok=True)
A.SOURCES_DIR = C.SOURCES_DIR = SOURCES2
A.RUN_DIR = C.RUN_DIR = RUN2
A.MEDIA_BY_FMT.update({"pdf": "application/pdf", "tabular": "text/csv", "archive": "application/zip", "text": "text/plain", "code": "text/x-python"})
A.REPRESENTATION_KIND.update({"pdf": "pdf", "tabular": "table", "archive": "source_native", "text": "plain_text", "code": "code"})
EXT = {"markdown": ".md", "html": ".html", "json": ".json", "pdf": ".pdf", "tabular": ".csv", "archive": ".zip", "text": ".txt", "code": ".tar.gz", "unknown": ".bin"}
GITHUB_ACCEPT = "application/vnd.github+json"
ORIGIN = "native harness fetch, Build 08 knowledge loop 2 (claude-code session 2026-11-09)"

def secret(name, file):
    if not os.path.exists(file):
        return None
    for line in open(file, encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line and line.split("=", 1)[0].strip() == name:
            return line.split("=", 1)[1].strip().strip('"').strip("'")
    return None

# credentials are read by name from the environment or the BellLabs .secrets files (never printed, never committed)
SECRETS_DIR = os.environ.get("BELLLABS_SECRETS_DIR") or os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "..", ".secrets"))
GITHUB_TOKEN = os.environ.get("MC_GITHUB_READONLY_TOKEN") or secret("MC_GITHUB_READONLY_TOKEN", os.path.join(SECRETS_DIR, "github.env"))
FIRECRAWL_KEY = os.environ.get("FIRECRAWL_API_KEY") or secret("FIRECRAWL_API_KEY", os.path.join(SECRETS_DIR, "tools.env"))

# key, kind, role, fmt, url, title, publisher, extra. tool: http (default) | firecrawl | github_tarball
MANIFEST = [
    # ---------------- RV07 leaderboards, cards, measured performance
    dict(key="swebench-board", kind="leaderboard_page", role="event_organizer", fmt="markdown", tool="firecrawl", url="https://www.swebench.com/", title="SWE-bench leaderboards (swebench.com)", publisher="SWE-bench team", board="swe-bench", organizer="SWE-bench team (Princeton / Stanford)"),
    dict(key="tbench-board", kind="leaderboard_page", role="event_organizer", fmt="markdown", tool="firecrawl", url="https://www.tbench.ai/leaderboard", title="Terminal-Bench leaderboard (tbench.ai)", publisher="Harbor / Laude Institute", board="terminal-bench", organizer="Harbor / Laude Institute", refresh=True),
    dict(key="arcprize-board", kind="leaderboard_page", role="event_organizer", fmt="html", url="https://arcprize.org/leaderboard", title="ARC Prize leaderboard", publisher="ARC Prize Foundation", board="arc-agi", organizer="ARC Prize Foundation", refresh=True),
    dict(key="epoch-benchmarks", kind="leaderboard_page", role="third_party_editorial", fmt="archive", url="https://epoch.ai/data/benchmark_data.zip", title="Epoch AI Benchmarking Hub data (CSV zip)", publisher="Epoch AI", board="epoch-benchmarking-hub", refresh=True),
    dict(key="seal-swebench-pro", kind="leaderboard_page", role="event_organizer", fmt="html", url="https://labs.scale.com/leaderboard/swe_bench_pro_public", title="Scale SEAL: SWE-Bench Pro (public)", publisher="Scale AI", board="swe-bench-pro-public", organizer="Scale AI"),
    dict(key="osworld-board", kind="leaderboard_page", role="event_organizer", fmt="markdown", tool="firecrawl", url="https://osworld-v2.xlang.ai/", title="OSWorld 2.x leaderboard", publisher="XLANG Lab", board="osworld", organizer="XLANG Lab (HKU)"),
    dict(key="arena-text", kind="leaderboard_page", role="third_party_editorial", fmt="html", url="https://arena.ai/leaderboard/text", title="Arena text leaderboard", publisher="Arena Intelligence", board="arena-text"),
    dict(key="aa-methodology", kind="official_docs_page", role="third_party_editorial", fmt="html", url="https://artificialanalysis.ai/methodology/intelligence-benchmarking", title="Artificial Analysis Intelligence Index methodology", publisher="Artificial Analysis"),
    dict(key="anthropic-opus-5-5", kind="official_blog_post", role="first_party", fmt="html", url="https://www.anthropic.com/news/claude-opus-5-5", title="Introducing Claude Opus 5.5", publisher="Anthropic", org="anthropic", model_hint="claude-opus-5.5", ingestion_level="P2"),
    dict(key="gemini-4-carbon-eval", kind="model_card", role="first_party", fmt="pdf", url="https://storage.googleapis.com/deepmind-media/gemini/gemini_4_carbon_model_evaluation.pdf", title="Gemini 4 Carbon Model evaluation", publisher="Google DeepMind", org="google", model_hint="gemini-4-carbon", ingestion_level="P2"),
    dict(key="mlperf-v61", kind="leaderboard_page", role="event_organizer", fmt="tabular", url="https://raw.githubusercontent.com/mlcommons/inference_results_v6.1/main/summary.csv", title="MLPerf Inference v6.1 datacenter results (summary.csv)", publisher="MLCommons", board="mlperf-inference-v6.1", organizer="MLCommons"),
    # ---------------- RV05 compute
    dict(key="nvidia-h100", kind="product_page", role="first_party", fmt="html", url="https://www.nvidia.com/en-us/data-center/h100/", title="NVIDIA H100 Tensor Core GPU", publisher="NVIDIA", org="nvidia", device="h100"),
    dict(key="nvidia-h200", kind="product_page", role="first_party", fmt="html", url="https://www.nvidia.com/en-us/data-center/h200/", title="NVIDIA H200 Tensor Core GPU", publisher="NVIDIA", org="nvidia", device="h200"),
    dict(key="nvidia-gb200-nvl72", kind="product_page", role="first_party", fmt="html", url="https://www.nvidia.com/en-us/data-center/gb200-nvl72/", title="NVIDIA GB200 NVL72", publisher="NVIDIA", org="nvidia", device="gb200-nvl72"),
    dict(key="epoch-ml-hardware", kind="research_report", role="third_party_editorial", fmt="tabular", url="https://epoch.ai/data/ml_hardware.csv", title="Epoch AI: data on machine learning hardware (CSV)", publisher="Epoch AI"),
    dict(key="azure-nd-h100", kind="pricing_page", role="first_party", fmt="json", url="https://prices.azure.com/api/retail/prices?$filter=armSkuName%20eq%20%27Standard_ND96isr_H100_v5%27%20and%20priceType%20eq%20%27Consumption%27", title="Azure Retail Prices: Standard_ND96isr_H100_v5", publisher="Microsoft Azure", org="microsoft", provider="azure", accept="application/json", refresh=True),
    dict(key="lambda-pricing", kind="pricing_page", role="first_party", fmt="html", url="https://lambda.com/pricing", title="Lambda GPU cloud pricing", publisher="Lambda", org="lambda", provider="lambda", refresh=True),
    dict(key="runpod-pricing", kind="pricing_page", role="first_party", fmt="html", url="https://www.runpod.io/pricing", title="RunPod GPU pricing", publisher="RunPod", org="runpod", provider="runpod", refresh=True),
    dict(key="coreweave-pricing", kind="pricing_page", role="first_party", fmt="html", url="https://www.coreweave.com/pricing", title="CoreWeave pricing", publisher="CoreWeave", org="coreweave", provider="coreweave"),
    dict(key="modal-pricing", kind="pricing_page", role="first_party", fmt="html", url="https://modal.com/pricing", title="Modal pricing", publisher="Modal", org="modal", provider="modal"),
    dict(key="e2b-pricing", kind="pricing_page", role="first_party", fmt="html", url="https://e2b.dev/pricing", title="E2B pricing", publisher="E2B", org="e2b", provider="e2b"),
    dict(key="vercel-sandbox-pricing", kind="pricing_page", role="first_party", fmt="markdown", url="https://vercel.com/docs/vercel-sandbox/pricing", title="Vercel Sandbox pricing", publisher="Vercel", org="vercel", provider="vercel"),
    # ---------------- RV04 repositories (R1–R7), APIs, protocol, registry, advisories
    dict(key="deepagents-releases", kind="github_release", role="first_party", fmt="json", url="https://api.github.com/repos/langchain-ai/deepagents/releases?per_page=100", title="langchain-ai/deepagents releases", publisher="LangChain", accept=GITHUB_ACCEPT, software="deepagents", tag_prefix="deepagents=="),
    dict(key="deepagents-repo-record", kind="registry_listing_page", role="registry", fmt="json", url="https://api.github.com/repos/langchain-ai/deepagents", title="GitHub repository record: langchain-ai/deepagents", publisher="GitHub", accept=GITHUB_ACCEPT, software="deepagents"),
    dict(key="deepagents-readme", kind="repository_readme", role="first_party", fmt="markdown", url="https://raw.githubusercontent.com/langchain-ai/deepagents/main/README.md", title="langchain-ai/deepagents README", publisher="LangChain", software="deepagents"),
    # api surfaces (tarballs): tags resolved at run time (latest + oldest known); see surfaces()
    dict(key="openai-openapi", kind="openapi_spec", role="first_party", fmt="json", url="https://raw.githubusercontent.com/openai/openai-openapi/main/openapi.json", title="OpenAI OpenAPI specification (openapi.json)", publisher="OpenAI", org="openai", refresh=True, timeout=240),
    dict(key="mcp-schema-2026-07-28", kind="api_reference", role="first_party", fmt="json", url="https://raw.githubusercontent.com/modelcontextprotocol/modelcontextprotocol/main/schema/2026-07-28/schema.json", title="MCP specification schema 2026-07-28", publisher="Model Context Protocol", org="modelcontextprotocol", protocol_version="2026-07-28"),
    dict(key="mcp-schema-2025-11-25", kind="api_reference", role="first_party", fmt="json", url="https://raw.githubusercontent.com/modelcontextprotocol/modelcontextprotocol/main/schema/2025-11-25/schema.json", title="MCP specification schema 2025-11-25", publisher="Model Context Protocol", org="modelcontextprotocol", protocol_version="2025-11-25"),
    dict(key="mcp-changelog-2026-07-28", kind="changelog", role="first_party", fmt="markdown", url="https://modelcontextprotocol.io/specification/2026-07-28/changelog.md", title="MCP specification changelog 2026-07-28", publisher="Model Context Protocol", org="modelcontextprotocol", protocol_version="2026-07-28"),
    dict(key="mcp-changelog-2025-11-25", kind="changelog", role="first_party", fmt="markdown", url="https://modelcontextprotocol.io/specification/2025-11-25/changelog.md", title="MCP specification changelog 2025-11-25", publisher="Model Context Protocol", org="modelcontextprotocol", protocol_version="2025-11-25"),
    dict(key="mcp-versioning", kind="official_docs_page", role="first_party", fmt="markdown", url="https://modelcontextprotocol.io/specification/versioning.md", title="MCP specification versioning", publisher="Model Context Protocol", org="modelcontextprotocol"),
    dict(key="mcp-registry-github", kind="registry_listing_page", role="registry", fmt="json", url="https://registry.modelcontextprotocol.io/v0/servers?limit=100&version=latest&search=github", title="MCP Registry: servers matching 'github'", publisher="Model Context Protocol", accept="application/json", registry="mcp-registry", refresh=True),
    dict(key="mcp-registry-postgres", kind="registry_listing_page", role="registry", fmt="json", url="https://registry.modelcontextprotocol.io/v0/servers?limit=100&version=latest&search=postgres", title="MCP Registry: servers matching 'postgres'", publisher="Model Context Protocol", accept="application/json", registry="mcp-registry"),
    dict(key="mcp-registry-langchain", kind="registry_listing_page", role="registry", fmt="json", url="https://registry.modelcontextprotocol.io/v0/servers?limit=100&version=latest&search=langchain", title="MCP Registry: servers matching 'langchain'", publisher="Model Context Protocol", accept="application/json", registry="mcp-registry"),
    dict(key="ghsa-langgraph", kind="security_advisory_page", role="registry", fmt="json", url="https://api.github.com/advisories?ecosystem=pip&affects=langgraph&per_page=100", title="GitHub Advisory Database: pip/langgraph", publisher="GitHub", accept=GITHUB_ACCEPT, package="langgraph", software="langgraph"),
    dict(key="ghsa-mcp", kind="security_advisory_page", role="registry", fmt="json", url="https://api.github.com/advisories?ecosystem=pip&affects=mcp&per_page=100", title="GitHub Advisory Database: pip/mcp", publisher="GitHub", accept=GITHUB_ACCEPT, package="mcp", software="mcp-python-sdk"),
    dict(key="ghsa-deepagents", kind="security_advisory_page", role="registry", fmt="json", url="https://api.github.com/advisories?ecosystem=pip&affects=deepagents&per_page=100", title="GitHub Advisory Database: pip/deepagents", publisher="GitHub", accept=GITHUB_ACCEPT, package="deepagents", software="deepagents"),
    dict(key="deepagents-reference-docs", kind="framework_docs_page", role="first_party", fmt="html", url="https://reference.langchain.com/python/deepagents/", title="Deep Agents Python API reference (index)", publisher="LangChain", software="deepagents"),
    dict(key="deepagents-overview-docs", kind="framework_docs_page", role="first_party", fmt="markdown", url="https://docs.langchain.com/oss/python/deepagents/overview.md", title="Deep Agents overview (docs)", publisher="LangChain", software="deepagents"),
    dict(key="pypi-deepagents", kind="package_version_page", role="registry", fmt="json", url="https://pypi.org/pypi/deepagents/json", title="PyPI: deepagents", publisher="PyPI", accept="application/json", software="deepagents", timeout=180),
    # ---------------- papers (P1 default; PA-4 P2 owner-selected) and guidance sources
    dict(key="paper-undobench", kind="arxiv_paper", role="academic", fmt="pdf", url="https://arxiv.org/pdf/2610.05622", title="UndoBench: Separating Task Competence from Recovery Capability in Tool-Using AI Agents", publisher="arXiv", arxiv_id="2610.05622", ingestion_level="P1", authors=["Dolly Sah", "Tanmay Sah", "Harshul Jain", "Tanya Sah"], published_on="2026-10-04", code_url="https://github.com/tradertanmay/undobench", talk_key="talk-coding-agent-undo"),
    dict(key="paper-evoundo", kind="arxiv_paper", role="academic", fmt="pdf", url="https://arxiv.org/pdf/2608.28363", title="EvoUndo: Recoverability-Constrained Self-Evolution for LLM Agent Harnesses", publisher="arXiv", arxiv_id="2608.28363", ingestion_level="P1", authors=["Tanmay Sah", "Dolly Sah", "Harshul Jain", "Tanya Sah"], published_on="2026-08-28", talk_key="talk-coding-agent-undo"),
    dict(key="weight-space-programming", kind="tech_report", role="academic", fmt="html", url="https://rikiyat.github.io/blog/weight-space-programming/", title="Sparks of Weight-Space Programming: LLMs can natively read & write neural network weights", publisher="MIT CSAIL (authors' blog)", ingestion_level="P2", authors=["Rikiya Takehi", "Jayden Teoh", "Alex Zhang", "Omar Khattab"], published_on="2026-11-02", code_url="https://github.com/RikiyaT/lm_understand-logs", publication_form="blog", promotion={"actor": "John (owner)", "reason": "owner-selected weight-editing paper, confirmed 2026-11-09", "at": "2026-11-09"}),
    dict(key="owasp-agentic-top10", kind="tech_report", role="third_party_editorial", fmt="pdf", url="https://genai.owasp.org/download/52117/?tmstv=1765059207", title="OWASP Top 10 for Agentic Applications for 2026", publisher="OWASP GenAI Security Project", guidance=True),
    dict(key="anthropic-multiagent", kind="official_blog_post", role="first_party", fmt="html", url="https://www.anthropic.com/research/multiagent-systems", title="Patterns and problems in emerging multiagent systems", publisher="Anthropic", org="anthropic", guidance=True, published_on="2026-08-13"),
]

SURFACE_REPOS = {  # software slug -> (owner/repo, package dir inside the tarball, tag filter regex, parser scope)
    "deepagents": ("langchain-ai/deepagents", "libs/deepagents/deepagents", r"^deepagents==", "package: libs/deepagents/deepagents (all modules)"),
    "langgraph": ("langchain-ai/langgraph", "libs/langgraph/langgraph", r"^\d+\.\d+\.\d+$", "namespace package: libs/langgraph/langgraph subpackages"),
    "openai-agents-python": ("openai/openai-agents-python", "src/agents", r"^v\d+\.\d+\.\d+$", "package: src/agents (all modules)"),
}


def http(url, accept=None, timeout=90, github=False):
    headers = {"User-Agent": C.USER_AGENT}
    if accept:
        headers["Accept"] = accept
    if github and GITHUB_TOKEN:
        headers["Authorization"] = "Bearer " + GITHUB_TOKEN
        headers["X-GitHub-Api-Version"] = "2022-11-28"
    req = urllib.request.Request(url, headers=headers)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            body = r.read()
            C.SPEND["http_fetches"] += 1
            return {"status": r.status, "final_url": r.geturl(), "media_type": (r.headers.get("content-type") or "").split(";")[0].strip(), "body": body, "elapsed_ms": int((time.time() - t0) * 1000)}
    except urllib.error.HTTPError as e:
        return {"status": e.code, "final_url": url, "media_type": None, "body": e.read() if e.fp else b"", "elapsed_ms": int((time.time() - t0) * 1000), "error": str(e)}
    except Exception as e:  # timeouts, TLS
        return {"status": 0, "final_url": url, "media_type": None, "body": b"", "elapsed_ms": int((time.time() - t0) * 1000), "error": repr(e)}


def firecrawl(url):
    req = urllib.request.Request("https://api.firecrawl.dev/v2/scrape", data=json.dumps({"url": url, "formats": ["markdown"], "onlyMainContent": False, "waitFor": 4000}).encode(),
                                 headers={"Authorization": "Bearer " + FIRECRAWL_KEY, "Content-Type": "application/json"})
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=180) as r:
            d = json.loads(r.read())
        md = (d.get("data") or {}).get("markdown") or ""
        C.SPEND["firecrawl_credits"] += 1
        return {"status": 200 if md else 204, "final_url": url, "media_type": "text/markdown", "body": md.encode("utf-8"), "elapsed_ms": int((time.time() - t0) * 1000), "credits": 1}
    except urllib.error.HTTPError as e:
        return {"status": e.code, "final_url": url, "media_type": None, "body": b"", "elapsed_ms": int((time.time() - t0) * 1000), "error": e.read()[:300].decode("utf-8", "replace"), "credits": 1}


# ------------------------------------------------------------------ R3: public API surface from a tag tarball (python ast, no import)
def py_signature(node):
    try:
        args = ast.unparse(node.args)
    except Exception:
        args = "..."
    ret = f" -> {ast.unparse(node.returns)}" if getattr(node, "returns", None) is not None else ""
    pre = "async def " if isinstance(node, ast.AsyncFunctionDef) else "def "
    return f"{pre}{node.name}({args}){ret}"[:400]


def parse_surface(tar_path, repo, tag, pkg_dir, cap=400):
    symbols = []
    modules = 0
    skipped = 0
    with tarfile.open(tar_path, "r:gz") as tf:
        members = [m for m in tf.getmembers() if m.isfile()]
        root = members[0].name.split("/")[0] if members else ""
        prefix = f"{root}/{pkg_dir}/"
        files = sorted((m for m in members if m.name.startswith(prefix) and m.name.endswith(".py")), key=lambda m: m.name)
        for m in files:
            rel = m.name[len(prefix):]
            parts = rel[:-3].split("/")
            if any(p.startswith("_") and p != "__init__" for p in parts) or "tests" in parts or "test" in parts:
                skipped += 1
                continue
            mod = ".".join([pkg_dir.split("/")[-1]] + [p for p in parts if p != "__init__"])
            src = tf.extractfile(m).read().decode("utf-8", "replace")
            try:
                tree = ast.parse(src)
            except SyntaxError:
                skipped += 1
                continue
            modules += 1
            exported = set()
            for node in tree.body:
                if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == "__all__" for t in node.targets):
                    try:
                        exported = set(ast.literal_eval(node.value))
                    except Exception:
                        pass
            for node in tree.body:
                names = []
                kind = None
                sig = None
                doc = None
                if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    names, kind, sig, doc = [node.name], "function", py_signature(node), ast.get_docstring(node)
                elif isinstance(node, ast.ClassDef):
                    bases = ", ".join(ast.unparse(b) for b in node.bases)
                    names, kind, sig, doc = [node.name], "class", f"class {node.name}({bases})"[:400], ast.get_docstring(node)
                    for sub in node.body:
                        if isinstance(sub, (ast.FunctionDef, ast.AsyncFunctionDef)) and not sub.name.startswith("_"):
                            symbols.append(dict(qualified_name=f"{mod}.{node.name}.{sub.name}", kind="method", signature=py_signature(sub), module=mod, is_public=not node.name.startswith("_"), deprecated=any("deprecat" in ast.unparse(d).lower() for d in sub.decorator_list), docstring_head=(ast.get_docstring(sub) or "").split("\n")[0][:200] or None, path=m.name[len(root) + 1:], lineno=sub.lineno, exported_by=None))
                elif isinstance(node, (ast.Assign, ast.AnnAssign)):
                    targets = node.targets if isinstance(node, ast.Assign) else [node.target]
                    names = [t.id for t in targets if isinstance(t, ast.Name)]
                    kind = "constant" if all(n.isupper() for n in names) else "variable"
                    sig = ast.unparse(node)[:200]
                if not names or names == ["__all__"]:
                    continue
                for nm in names:
                    if nm.startswith("_") and nm not in exported:
                        continue
                    symbols.append(dict(qualified_name=f"{mod}.{nm}", kind=kind, signature=sig, module=mod, is_public=True, deprecated=bool(isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)) and any("deprecat" in ast.unparse(d).lower() for d in node.decorator_list)), docstring_head=(doc or "").split("\n")[0][:200] or None, path=m.name[len(root) + 1:], lineno=node.lineno, exported_by="__all__" if nm in exported else None))
    # R6 cap: exported (__all__) names first, then classes/functions, then methods/variables, by module then line
    order = {"__all__": 0}
    symbols.sort(key=lambda s: (0 if s["exported_by"] else 1, {"class": 0, "function": 1, "constant": 2, "type": 2, "method": 3, "variable": 4}.get(s["kind"], 5), s["module"], s["lineno"]))
    total = len(symbols)
    over = total > cap
    kept = symbols[:cap]
    return {"repository": repo, "release_tag": tag, "package": pkg_dir.split("/")[-1], "parser": "python-ast/1 (loop2_acquire.parse_surface)", "parser_scope": pkg_dir, "modules_parsed": modules, "files_skipped": skipped, "symbol_count": total, "public_symbol_count": sum(1 for s in symbols if s["is_public"]), "exported_count": sum(1 for s in symbols if s["exported_by"]), "over_cap": over, "cap": cap, "symbols": kept}


def surface_targets():
    """(software, repo, tag) pairs: the latest tag today plus the oldest release the lab already knows (or the oldest fetched)."""
    out = []
    # deepagents: from the releases JSON captured in this run
    rel_path = os.path.join(SOURCES2, "deepagents-releases.json")
    if os.path.exists(rel_path):
        tags = [r["tag_name"] for r in json.load(open(rel_path, encoding="utf-8")) if re.match(r"^deepagents==\d", r["tag_name"]) and not r.get("prerelease")]
        if tags:
            out.append(("deepagents", "langchain-ai/deepagents", tags[0]))
            if len(tags) > 1:
                out.append(("deepagents", "langchain-ai/deepagents", tags[-1]))
    for sw, (repo, pkg, pat, scope) in SURFACE_REPOS.items():
        if sw == "deepagents":
            continue
        labels = [r[0] for r in sql_rows(f"select e.attributes->>'version_label' from catalog.entity e join catalog.relationship r on r.from_entity_id=e.id and r.kind='version_of' join catalog.entity l on l.id=r.to_entity_id where e.kind='library_release' and l.slug={q(sw)} and e.tenant_id={q(TENANT)}")]
        labels = [l for l in labels if l and re.match(pat, l)]
        if not labels:
            continue
        key = lambda s: [int(x) for x in re.findall(r"\d+", s)]
        labels.sort(key=key)
        oldest = labels[0]
        latest = {"langgraph": "1.2.20", "openai-agents-python": "v0.24.0"}[sw]  # verified live 2026-11-09 (selection file §3)
        out.append((sw, repo, latest))
        out.append((sw, repo, oldest))
    return out


def register_capture2(src, body, fetched, origin_label, requested_at, fmt, outcome="captured", prior_capture=None, tool="http", credits=None):
    """Loop-2 copy of the loop-1 registration with a unique object path per fetch (artifact paths are unique per bucket)."""
    sha = sha256_bytes(body)
    media = A.MEDIA_BY_FMT.get(fmt, "application/octet-stream")
    fetch_id = str(uuid.uuid4())
    sql(f"""insert into acquisition.fetch(id, tenant_id, origin_kind, origin_label, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, credits_used, prior_capture_id, notes)
            values ({q(fetch_id)}, {q(TENANT)}, 'native_harness', {q(origin_label)}, {q(tool)}, {q('firecrawl-api/v2' if tool == 'firecrawl' else 'urllib/python3.12')}, {q(src['url'])}, {q(fetched.get('final_url'))}, {q(requested_at)}, now(), {q(fetched.get('status'))}, {q(outcome)}, {q(sha)}, {q(media)}, {len(body)}, {q(credits)}, {q(prior_capture)}, {q({'elapsed_ms': fetched.get('elapsed_ms'), 'kind': src['kind'], 'format': fmt, 'error': fetched.get('error')})})""")
    if outcome != "captured":
        return fetch_id, None, sha, None
    artifact = str(uuid.uuid4())
    object_path = f"{TENANT}/knowledge-loop-2/{src['key']}/{fetch_id[:8]}/{sha}"
    sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
            values ({q(artifact)}, {q(TENANT)}, 'source_capture', 1, {q(sha)}, 'source_captures', 'lab-sources', {q(object_path)}, {q(media)}, {len(body)}, 'available', now())""")
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if fmt == "json" else ("pdf" if fmt == "pdf" else ("repository" if fmt == "archive" and "tarball" in src["url"] else "web_page")))
    capture = str(uuid.uuid4())
    sql(f"""insert into evidence.source_capture(id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, context, acquisition_fetch_id)
            values ({q(capture)}, {q(TENANT)}, {q(source_id)}, {q(artifact)}, {q(sha)}, {q(media)}, {q(requested_at)}, 'native_harness_http', '0.2', {q(src['url'])}, {q(fetched.get('status'))}, {q({'origin': origin_label, 'final_url': fetched.get('final_url'), 'tool': tool})}, {q(fetch_id)});
            update evidence.source set capture_count = capture_count + 1, last_seen_at = now(), last_capture_id = {q(capture)} where id = {q(source_id)}""")
    return fetch_id, capture, sha, artifact

A.register_capture = register_capture2


def ensure_document2(src):
    """content.document is append-only: every attribute the pipeline needs goes in at insert time (loop-1 helper kept only key/org/software/event/model_hint/publisher)."""
    doc = one(f"select id from content.document where tenant_id={q(TENANT)} and canonical_title={q(src['title'])} and document_type_code={q(src['kind'])}")
    if doc:
        return doc
    doc = str(uuid.uuid4())
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if src["fmt"] == "json" else ("pdf" if src["fmt"] == "pdf" else ("repository" if src.get("tool") == "github_tarball" else "web_page")))
    attrs = {k: v for k, v in src.items() if k not in ("url", "title", "fmt", "tool", "accept", "timeout", "refresh", "kind", "role")}
    sql(f"""insert into content.document(id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, source_role_code, source_role_method, attributes)
            values ({q(doc)}, {q(TENANT)}, {q(src['kind'])}, {q(src['title'])}, {q(source_id)}, 'active', {q(src['role'])}, 'rule', {q(attrs)});
            insert into content.document_kind_assignment(tenant_id, document_id, document_type_code, method, confidence, rationale)
            values ({q(TENANT)}, {q(doc)}, {q(src['kind'])}, 'rule', 0.9, 'URL/publisher rule in the loop-2 manifest (BUILD-08-LOOP-2-SELECTION.md)')""")
    return doc


def acquire_surface(sw, repo, tag, ledger):
    pkg_dir, pat, scope = SURFACE_REPOS[sw][1], SURFACE_REPOS[sw][2], SURFACE_REPOS[sw][3]
    key = f"surface-{sw}-{re.sub(r'[^0-9a-zA-Z.]+', '-', tag)}"
    src = dict(key=key, kind="api_surface", role="system", fmt="archive", url=f"https://api.github.com/repos/{repo}/tarball/{tag}", title=f"{repo} public API surface at {tag}", publisher=repo.split("/")[0], software=sw, repository=repo, release_tag=tag, tag_filter=pat, parser_scope=scope)
    src.update({"parser": "python-ast/1", "package": pkg_dir.split("/")[-1], "derived_from": "GitHub tag tarball (R7)"})
    doc = ensure_document2(src)
    if one(f"select 1 from content.document_version v join content.document_representation r on r.document_version_id=v.id where v.document_id={q(doc)} and r.representation_class='structural_extraction'"):
        log(f"{key}: already derived")
        return
    requested_at = now_iso()
    tar_path = os.path.join(TARBALLS, key + ".tar.gz")
    if os.path.exists(tar_path):
        fetched = {"status": 200, "final_url": src["url"], "media_type": "application/x-gzip", "body": open(tar_path, "rb").read(), "elapsed_ms": 0}
    else:
        fetched = http(src["url"], github=True, timeout=240)
        if fetched["status"] == 200:
            open(tar_path, "wb").write(fetched["body"])
    ok = fetched["status"] == 200 and len(fetched["body"]) > 1000
    outcome = "captured" if ok else ("blocked" if fetched["status"] in (401, 403, 429) else "failed")
    A.MEDIA_BY_FMT["archive"] = "application/gzip"
    f_id, cap, sha, art = A.register_capture(src, fetched["body"] if ok else b"", fetched, ORIGIN + " (GitHub tag tarball, R7)", requested_at, "archive", outcome=outcome)
    A.MEDIA_BY_FMT["archive"] = "application/zip"
    row = {"key": key, "url": src["url"], "status": fetched["status"], "fetched_at": requested_at, "bytes": len(fetched["body"]), "outcome": outcome, "fetch_id": f_id, "capture_id": cap, "document_id": doc, "software": sw, "tag": tag}
    if not ok:
        append_jsonl(ledger, row)
        log(f"{key}: {outcome} {fetched.get('error')}")
        return
    ver, _ = A.add_version(doc, cap, sha, art, "archive", f"tag-{tag}-{sha[:8]}")
    surface = parse_surface(tar_path, repo, tag, pkg_dir)
    surface["tarball_sha256"] = sha
    body = json.dumps(surface, ensure_ascii=False, indent=0).encode("utf-8")
    jpath = os.path.join(SOURCES2, key + ".json")
    open(jpath, "wb").write(body)
    dsha = sha256_bytes(body)
    dart = str(uuid.uuid4())
    sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
            values ({q(dart)}, {q(TENANT)}, 'canonical_source_projection', 1, {q(dsha)}, 'source_captures', 'lab-sources', {q(f'{TENANT}/knowledge-loop-2/{key}/derived/{dsha}')}, 'application/json', {len(body)}, 'available', now());
            insert into content.document_representation(id, tenant_id, document_version_id, artifact_id, representation_kind, representation_class, media_type, content_sha256, acceptance_state, source_native_byte_identical, grammar_version)
            values ({q(str(uuid.uuid4()))}, {q(TENANT)}, {q(ver)}, {q(dart)}, 'json', 'structural_extraction', 'application/json', {q(dsha)}, 'accepted', false, 'build08-grammar/2')""")
    row.update({"sha256": sha, "version_id": ver, "derived_sha256": dsha, "symbol_count": surface["symbol_count"], "kept": len(surface["symbols"]), "over_cap": surface["over_cap"], "modules": surface["modules_parsed"], "file": os.path.basename(jpath)})
    append_jsonl(ledger, row)
    log(f"{key}: {surface['symbol_count']} symbols ({surface['exported_count']} exported, {surface['modules_parsed']} modules, over_cap={surface['over_cap']})")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    refresh = "--refresh" in sys.argv
    only = set(args)
    ledger = os.path.join(RUN2, "ACQUISITION-LEDGER.jsonl")
    for src in MANIFEST:
        if only and src["key"] not in only:
            continue
        if refresh and not src.get("refresh") and not only:
            continue
        doc = ensure_document2(src)
        prior = sql_rows(f"select vc.source_capture_id, c.content_sha256, vc.document_version_id from content.document_version v join content.document_version_source_capture vc on vc.document_version_id=v.id join evidence.source_capture c on c.id=vc.source_capture_id where v.document_id={q(doc)} order by c.captured_at desc limit 1")
        prior_capture, prior_sha, prior_ver = (prior[0] if prior else (None, None, None))
        if prior_capture and not refresh and not only:
            continue  # first pass is idempotent: a document with a capture is skipped unless refreshing
        requested_at = now_iso()
        if src.get("tool") == "firecrawl":
            fetched = firecrawl(src["url"])
            tool = "firecrawl"
        else:
            fetched = http(src["url"], accept=src.get("accept") or ("text/markdown" if src["fmt"] == "markdown" else None), timeout=src.get("timeout", 120), github="api.github.com" in src["url"])
            tool = "http"
        ok = fetched["status"] == 200 and len(fetched["body"]) > 0
        fmt = src["fmt"]
        if ok and fmt == "markdown" and tool == "http" and fetched["body"].lstrip()[:15].lower().startswith(b"<!doctype html"):
            fmt = "html"  # the .md URL fell back to HTML
        path = os.path.join(SOURCES2, src["key"] + ("" if not prior_capture else "-" + sha256_bytes(fetched["body"])[:8]) + EXT[fmt])
        if ok:
            open(path, "wb").write(fetched["body"])  # refresh captures carry the sha in the name so capture 1 is never overwritten (D-37)
        outcome = "captured" if ok else ("blocked" if fetched["status"] in (401, 403, 429) else "failed")
        if ok and prior_sha and prior_sha == sha256_bytes(fetched["body"]):
            outcome = "unchanged"
        f_id, cap, sha, art = A.register_capture(dict(src, fmt=fmt), fetched["body"] if ok else b"", fetched, ORIGIN + (" via Firecrawl scrape API (JS-rendered page)" if tool == "firecrawl" else ""), requested_at, fmt, outcome=outcome, prior_capture=prior_capture, tool=tool, credits=fetched.get("credits"))
        ver = None
        if outcome == "captured":
            ver, _ = A.add_version(doc, cap, sha, art, fmt, f"c{2 if prior_capture else 1}-{requested_at[:10]}-{sha[:8]}", published_at=src.get("published_on"))
        if prior_capture:
            sql(f"""insert into content.refresh_check(tenant_id, document_id, prior_version_id, fetch_id, outcome, content_sha256, new_version_id)
                    values ({q(TENANT)}, {q(doc)}, {q(prior_ver)}, {q(f_id)}, {q('unchanged' if outcome == 'unchanged' else ('changed' if outcome == 'captured' else 'failed'))}, {q(sha if ok else None)}, {q(ver)})""")
        append_jsonl(ledger, {"key": src["key"], "capture": 2 if prior_capture else 1, "url": src["url"], "final_url": fetched.get("final_url"), "status": fetched["status"], "fetched_at": requested_at, "sha256": sha if ok else None, "bytes": len(fetched["body"]), "format": fmt, "tool": tool, "outcome": outcome, "fetch_id": f_id, "capture_id": cap, "version_id": ver, "document_id": doc, "file": os.path.basename(path) if ok else None, "error": fetched.get("error")})
        log(f"{src['key']}: {fetched['status']} {outcome} {len(fetched['body'])} bytes ({tool})")
    if not refresh:
        for sw, repo, tag in surface_targets():
            if only and f"surface-{sw}" not in " ".join(only) and "surfaces" not in only:
                continue
            acquire_surface(sw, repo, tag, ledger)
    write_json(os.path.join(RUN2, "spend-acquire%s.json" % ("-refresh" if refresh else "")), C.SPEND)
    log("acquisition done")


if __name__ == "__main__":
    main()
