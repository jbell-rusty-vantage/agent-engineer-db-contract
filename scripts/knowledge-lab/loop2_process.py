"""Build 08 knowledge loop 2, stages B-J for the loop-2 documents: census -> typed units (loop-2 grammars) -> entities (benchmarks,
compute devices/offerings, repositories/releases/symbols, APIs, protocol versions, registry listings, advisories, papers) -> facts
(benchmark_score, offering_price, offering_limit, events, relationships, status streams) -> claims + guidance items -> digests -> diff ->
projections -> embeddings. Reuses the loop-1 helpers (lab_common, loop1_process) where they are generic.

Run after loop2_acquire.py: python -I -X utf8 scripts/knowledge-lab/loop2_process.py [stage ...]
Stages: census units entities facts claims guidance digests diff projections embed (default: all, in order). Idempotent per stable key.
"""
import json, os, re, sys, uuid, collections, datetime, io, zipfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_parse as P1
import loop1_process as L1
import loop2_parse as G
import loop2_parse_shapes as S
from loop2_acquire import MANIFEST, SOURCES2, RUN2, SURFACE_REPOS

L1.SOURCES_DIR = SOURCES2
L1.RUN_DIR = RUN2
C.RUN_DIR = RUN2
GRAMMAR = "build08-grammar/2"
BY_KEY = {m["key"]: m for m in MANIFEST}
STATS = collections.defaultdict(dict)
L1.EMBED_KINDS |= {"leaderboard_row", "api_symbol", "endpoint", "advisory", "registry_listing", "paper_section", "metric_definition", "schema_component", "change_item", "docs_section", "readme_section", "code_example", "spec_field", "table_row", "metadata_field"}
L1.TIER_BY_ROLE.update({"academic": 2, "system": 2})
_index_item = L1.index_item


def index_item_capped(space, target_kind, target_id, text, lens, tier, content_kind, **kw):
    """vector_item.search_text has a btree exact-match index (max ~2.7 KB per row): long units are indexed by their first 2,000 characters."""
    return _index_item(space, target_kind, target_id, (text or "")[:2000], lens, tier, content_kind, **kw)


L1.index_item = index_item_capped

ORG2 = {"nvidia": ("NVIDIA", "enterprise", "https://www.nvidia.com"), "microsoft": ("Microsoft", "cloud", "https://azure.microsoft.com"), "lambda": ("Lambda", "cloud", "https://lambda.com"), "runpod": ("RunPod", "cloud", "https://www.runpod.io"), "coreweave": ("CoreWeave", "cloud", "https://www.coreweave.com"),
        "modal": ("Modal", "cloud", "https://modal.com"), "e2b": ("E2B", "tooling_vendor", "https://e2b.dev"), "vercel": ("Vercel", "cloud", "https://vercel.com"), "azure": ("Microsoft", "cloud", "https://azure.microsoft.com"), "epoch-ai": ("Epoch AI", "academic", "https://epoch.ai"), "mlcommons": ("MLCommons", "nonprofit", "https://mlcommons.org"),
        "scale-ai": ("Scale AI", "tooling_vendor", "https://scale.com"), "arc-prize-foundation": ("ARC Prize Foundation", "nonprofit", "https://arcprize.org"), "swe-bench-team": ("SWE-bench team", "academic", "https://www.swebench.com"), "harbor-laude": ("Harbor / Laude Institute", "academic", "https://www.tbench.ai"), "xlang-lab": ("XLANG Lab (HKU)", "academic", "https://osworld-v2.xlang.ai"),
        "artificial-analysis": ("Artificial Analysis", "tooling_vendor", "https://artificialanalysis.ai"), "owasp": ("OWASP GenAI Security Project", "nonprofit", "https://genai.owasp.org"), "mit-csail": ("MIT CSAIL", "academic", "https://www.csail.mit.edu"), "amd": ("AMD", "enterprise", "https://www.amd.com"), "google": ("Google", "frontier_lab", "https://ai.google.dev")}
BOARD_ORG = {"swe-bench": "swe-bench-team", "terminal-bench": "harbor-laude", "arc-agi": "arc-prize-foundation", "epoch-benchmarking-hub": "epoch-ai", "swe-bench-pro-public": "scale-ai", "osworld": "xlang-lab", "arena-text": None, "mlperf-inference-v6.1": "mlcommons"}
BENCH_META = {  # base benchmark -> (organizer slug, metric, score_type, agentic, domain)
    "swe-bench": ("swe-bench-team", "% resolved", "accuracy", True, "software engineering"), "terminal-bench": ("harbor-laude", "resolution rate", "accuracy", True, "terminal tasks"), "arc-agi": ("arc-prize-foundation", "score", "accuracy", False, "abstraction"),
    "swe-bench-pro": ("scale-ai", "resolution rate", "accuracy", True, "software engineering"), "osworld": ("xlang-lab", "binary / partial reward", "accuracy", True, "computer use"), "mlperf-inference": ("mlcommons", "throughput", "throughput", False, "serving hardware"),
    "gpqa-diamond": ("epoch-ai", "accuracy", "accuracy", False, "science QA"), "frontiermath": ("epoch-ai", "accuracy", "accuracy", False, "mathematics"), "frontierswe": (None, "score", "accuracy", True, "software engineering"), "frontiercode": (None, "main score", "accuracy", True, "coding"), "undobench": (None, "conditional recovery success rate", "accuracy", True, "agent recovery"),
    "math-500": (None, "accuracy", "accuracy", False, "mathematics"), "gsm8k": (None, "accuracy", "accuracy", False, "mathematics"), "ifeval": (None, "accuracy", "accuracy", False, "instruction following"), "minatar-breakout": (None, "return", "score", False, "reinforcement learning")}
DEVICE_FAMILY = [(r"GB300", "nvidia-gb300", "NVIDIA GB300"), (r"GB200", "nvidia-gb200", "NVIDIA GB200"), (r"B300", "nvidia-b300", "NVIDIA B300"), (r"B200", "nvidia-b200", "NVIDIA B200"), (r"H200", "nvidia-h200", "NVIDIA H200"), (r"H100", "nvidia-h100", "NVIDIA H100"), (r"GH200", "nvidia-gh200", "NVIDIA GH200"), (r"A100", "nvidia-a100", "NVIDIA A100"), (r"L40S", "nvidia-l40s", "NVIDIA L40S"), (r"L40\b", "nvidia-l40", "NVIDIA L40"),
                 (r"RTX ?PRO ?6000", "nvidia-rtx-pro-6000", "NVIDIA RTX PRO 6000"), (r"A10G", "nvidia-a10g", "NVIDIA A10G"), (r"MI355X", "amd-mi355x", "AMD Instinct MI355X"), (r"MI350X", "amd-mi350x", "AMD Instinct MI350X"), (r"MI300X", "amd-mi300x", "AMD Instinct MI300X"), (r"Ironwood|TPU v7", "google-tpu-v7-ironwood", "Google TPU v7 (Ironwood)"), (r"Trillium|TPU v6e", "google-tpu-v6e-trillium", "Google TPU v6e (Trillium)")]
RECEIPT = None


def receipt():
    global RECEIPT
    if RECEIPT is None:
        RECEIPT = native_receipt("loop2-entities", {"stage": "entities", "loop": 2})
    return RECEIPT


L1.receipt = receipt
slugify = L1.slugify
ensure_entity = L1.ensure_entity
ensure_work = L1.ensure_work
add_role = L1.add_role
flush_roles = L1.flush_roles
nodes_of = L1.nodes_of
role_entity = L1.role_entity
MEDIA = {"markdown": "text/markdown", "html": "text/html", "json": "application/json", "unknown": "text/calendar", "pdf": "application/pdf", "archive": "application/zip", "tabular": "text/csv", "text": "text/plain", "code": "text/x-python"}


def locator_for(v, node, selector_kind="table"):
    """loop-1 locator helper with the loop-2 media types (pdf, archive, csv)."""
    lid = one(f"select id from evidence.locator where tenant_id={q(TENANT)} and capture_id={q(v['capture_id'])} and selector->>'node_id'={q(node['id'])}")
    if lid:
        return lid
    lid = str(uuid.uuid4())
    sel = dict(node["selector"] or {})
    sel["node_id"] = node["id"]
    sel["logical_key"] = node["logical_key"]
    sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params, start_ms, end_ms)
            values ({q(lid)}, {q(TENANT)}, {q(v['capture_id'])}, {q(MEDIA.get(v['format'], 'application/octet-stream'))}, {q(sel)}, {q(selector_kind)}, {q(sha256_text(node['text'] or ''))}, {q((node['text'] or '')[:500])}, 'build08-grammar', '2', {q({'unit_kind': node['unit_kind']})}, {q(node.get('start_ms'))}, {q(node.get('end_ms'))})""")
    return lid
extraction_run_for = L1.extraction_run_for
make_claim = L1.make_claim
mapping_id = L1.mapping_id


def device_family(text):
    for pat, slug, name in DEVICE_FAMILY:
        if re.search(pat, text or "", re.I):
            return slug, name
    return None, None


def bench_split(label):
    """'Terminal-Bench 4.1' -> ('terminal-bench', 'Terminal-Bench', '4.1'); 'SWE-bench Verified' -> ('swe-bench', 'SWE-bench', 'Verified'); 'OSWorld v2026.08.08' -> ('osworld', 'OSWorld', 'v2026.08.08')."""
    s = re.sub(r"\s+", " ", (label or "").strip())
    m = re.match(r"^(.*?)[\s:]+(v?\d{4}\.\d\d\.\d\d|v?\d+(?:\.\d+)+|Verified|Lite|Pro(?: \(public\))?|Multimodal|Multilingual|Diamond|Hard|2\.\d|\(public\)|v\d)$", s)
    if m and m.group(1):
        base, ver = m.group(1).strip(" -"), m.group(2)
    else:
        base, ver = s, None
    base = re.sub(r"\s*\(.*\)$", "", base).strip()
    bslug = slugify(base.lower().replace("bench ", "bench-"))
    if bslug.startswith("swe-bench-pro"):
        bslug = "swe-bench-pro"
    if bslug in ("terminal-bench", "terminalbench", "terminal-bench-4-0"):
        bslug = "terminal-bench"
    if re.match(r"^frontiermath", bslug):
        bslug, base = "frontiermath", "FrontierMath"
    if re.match(r"^arc-agi", bslug) or bslug in ("arc-ai2",):
        pass
    return bslug, base, ver


def model_subject(name, org_hint=None):
    """Leaderboard/eval subject -> ai_model_version entity (loop-1 resolver with light normalisation)."""
    n = re.sub(r"\s*\((max|xhigh|high|medium|low|thinking|none|minimal)\)\s*$", "", name, flags=re.I).strip()
    n = re.sub(r"(?<=[a-z])(max|xhigh|high|medium|low)$", "", n)
    if re.match(r"^(opus|sonnet|haiku|fable|mythos)\b", n, re.I):
        n = "Claude " + n
    n = re.sub(r"^claude[- ](\d(?:\.\d)?)[- ](opus|sonnet|haiku)$", lambda m: f"Claude {m.group(2).title()} {m.group(1)}", n, flags=re.I)
    prov = (org_hint or "unknown").lower()
    prov = {"anthropic": "anthropic", "openai": "openai", "google": "google", "google deepmind": "google", "deepseek": "deepseek"}.get(prov, slugify(prov) or "unknown")
    if prov not in L1.ORG and prov not in ORG2:
        ensure_entity("organization", prov, org_hint or "Unknown developer", {"org_kind": "other"})
    ver_id, fam_id, dev, vname = L1.model_version_for(n, prov)
    return ver_id, fam_id, dev, vname


# ------------------------------------------------------------------ inventory and text loading
def versions():
    """All loop-2 document versions; a version whose capture bytes are not on disk (capture 1 of a refreshed document whose file was
    overwritten by capture 2 before filenames carried the sha) keeps path None: DB-only stages (entities, facts, diff) still see it."""
    rows = sql_json(f"""select json_build_object('key', d.attributes->>'key', 'kind', d.document_type_code, 'role', d.source_role_code, 'document_id', d.id, 'version_id', v.id, 'label', v.version_label, 'format', v.format_code, 'sha', v.manifest_sha256,
      'representation_id', r.id, 'capture_id', vc.source_capture_id, 'captured_at', c.captured_at, 'title', d.canonical_title, 'attrs', d.attributes, 'work_entity_id', d.work_entity_id, 'rep_class', r.representation_class)
      from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id
      join content.document_version_source_capture vc on vc.document_version_id = v.id join evidence.source_capture c on c.id = vc.source_capture_id
      where d.tenant_id = {q(TENANT)} and d.created_at > '2026-11-09T18:00:00Z' order by d.attributes->>'key', c.captured_at""")
    files = {}
    for f in os.listdir(SOURCES2):
        p = os.path.join(SOURCES2, f)
        if os.path.isfile(p):
            files[sha256_bytes(open(p, "rb").read())] = p
    out = []
    for v in rows:
        if not ((v.get("attrs") or {}).get("key") in BY_KEY or (v.get("attrs") or {}).get("repository")):
            continue
        rep_sha = one(f"select content_sha256 from content.document_representation where id={q(v['representation_id'])}")
        v["path"] = files.get(rep_sha) or files.get(v["sha"])
        if v["kind"] == "api_surface" and v["rep_class"] != "structural_extraction":
            continue  # the archive representation of a surface document is never parsed; the derived json is
        out.append(v)
    return out


def load_text2(v):
    raw = open(v["path"], "rb").read()
    fmt = v["format"]
    data = None
    text = ""
    if fmt == "json" or v["path"].endswith(".json"):
        data = json.loads(raw)
        text = raw.decode("utf-8", "replace")[:200000]
    elif fmt == "pdf":
        text = "\n".join(G.pdf_text(raw))
    elif fmt == "archive":
        text = ""
    elif fmt == "html":
        text = P1.html_to_text(raw.decode("utf-8", "replace"))
    else:
        text = raw.decode("utf-8", "replace")
    return text, data, raw


def pdf_markdownish(pages):
    """PDF text -> pseudo-markdown: short title-case / numbered lines become headings so universal_markdown yields sections and paragraphs."""
    out = []
    for pg in pages:
        for l in pg.splitlines():
            s = l.strip()
            if not s:
                out.append("")
                continue
            if len(s) < 80 and (re.match(r"^(ASI\d{2}:|\d{1,2}(\.\d+)*\s+[A-Z]|[A-Z][A-Za-z &/\-]{3,60}$)", s) and not s.endswith(".")) and not re.search(r"\b(et al|Page \d)\b", s):
                out.append("## " + s)
            else:
                out.append(s)
    return "\n".join(out)


# ------------------------------------------------------------------ stage B census (loop-1 helper with loop-2 text loading)
def stage_census(vs):
    n = 0
    for v in vs:
        if one(f"select 1 from content.structure_census where representation_id={q(v['representation_id'])} and census_version='build08-census/2'"):
            continue
        if not v.get("path"):
            continue
        text, data, raw = load_text2(v)
        fmt = v["format"] if v["format"] in ("markdown", "html", "json") else "text"
        counts, sigs = P1.census(text if text else json.dumps(data)[:100000] if data else "", fmt)
        counts["bytes"] = len(raw)
        if v["format"] == "archive":
            try:
                counts["zip_members"] = len(zipfile.ZipFile(io.BytesIO(raw)).namelist())
            except Exception:
                counts["zip_members"] = None
        sql(f"""insert into content.structure_census(tenant_id, representation_id, census_version, format_code, counts, signatures, language, digest)
                values ({q(TENANT)}, {q(v['representation_id'])}, 'build08-census/2', {q(v['format'])}, {q(counts)}, {q(sigs)}, 'en', {q(sha256_text(json.dumps(counts, sort_keys=True)))})""")
        n += 1
    log(f"census rows written: {n}")


# ------------------------------------------------------------------ stage C typed units (loop-2 grammars)
def parse2(v):
    key = (v["attrs"] or {}).get("key")
    src = BY_KEY.get(key, {})
    kind = v["kind"]
    text, data, raw = load_text2(v)
    st = STATS[key or v["document_id"]]
    units, tables, lines, offs = ([], [], [], [])
    grammar = []
    if kind == "api_surface":
        return G.grammar_api_surface(data, st), text
    if v["format"] in ("markdown", "html", "pdf", "text", "tabular") and text:
        md_text = pdf_markdownish(G.pdf_text(raw)) if v["format"] == "pdf" and kind in ("tech_report", "model_card") else text
        units, tables, lines, offs = P1.universal_markdown(md_text, kind)
        if v["format"] == "pdf" and kind in ("tech_report", "model_card"):
            text = md_text
    if kind == "leaderboard_page":
        board = src.get("board")
        if board == "epoch-benchmarking-hub":
            grammar = S.grammar_epoch_zip_v2(raw, st)
        elif board == "mlperf-inference-v6.1":
            grammar = G.grammar_mlperf_csv(text, st)
        elif board == "swe-bench-pro-public":
            grammar = S.grammar_seal_text(text, st)
        else:
            grammar = G.grammar_leaderboard(units, tables, lines, offs, board, st)
    elif kind == "official_docs_page":
        grammar = P1.grammar_docs(units, "framework_docs_page")
        if key == "aa-methodology":
            grammar += S.grammar_metric_definitions(tables, lines, offs, st)
        if key == "mcp-versioning":
            m = re.search(r"current protocol version is\s*\**(\d{4}-\d\d-\d\d)", text)
            if m:
                grammar.append(dict(kind="metadata_field", key="meta:current_protocol_version", parent=None, attrs={"key": "current_protocol_version", "value": m.group(1)}, text=m.group(0), logical="metadata_field:current_protocol_version", start=m.start(), end=m.end(), selector={"kind": "text_quote", "exact": m.group(0)}, roles={}))
    elif kind == "official_blog_post":
        grammar = P1.grammar_post(units, published_at=src.get("published_on"), byline=src.get("publisher"))
        if key == "anthropic-opus-5-5":
            grammar += G.grammar_eval_tables(units, tables, lines, offs, st)
    elif kind == "model_card":
        grammar = G.grammar_eval_tables(units, tables, lines, offs, st)  # the results table of this PDF is an image: 0 rows expected, recorded
    elif kind == "tech_report":
        if key == "weight-space-programming":
            grammar = G.grammar_eval_tables(units, tables, lines, offs, st)
        grammar += P1.grammar_post(units, published_at=src.get("published_on"), byline=src.get("publisher")) if key != "owasp-agentic-top10" else []
    elif kind == "product_page":
        grammar = G.grammar_spec_page(units, tables, lines, offs, src.get("device") or "device", st)
    elif kind == "research_report":
        grammar = G.grammar_epoch_hardware_csv(text, st)
    elif kind == "pricing_page":
        prov = src.get("provider")
        if v["format"] == "json":
            grammar = G.grammar_azure_prices(data, st)
        else:
            if prov == "runpod":
                grammar = S.grammar_runpod_sentences(text, st)
            elif prov == "coreweave":
                grammar = S.grammar_coreweave_html(raw.decode("utf-8", "replace"), st)
            elif prov == "modal":
                grammar = S.grammar_modal_text(text, st) + G.grammar_compute_pricing(units, tables, lines, offs, prov, st)
            elif prov == "e2b":
                grammar = S.grammar_e2b_tables(tables, lines, offs, st) + [u for u in G.grammar_compute_pricing(units, tables, lines, offs, prov, st) if u["kind"] == "metadata_field"]
            elif prov == "vercel":
                grammar = S.grammar_sandbox_table(tables, lines, offs, prov, st) + [u for u in G.grammar_compute_pricing(units, tables, lines, offs, prov, st) if u["kind"] == "metadata_field"]
            else:
                grammar = G.grammar_compute_pricing(units, tables, lines, offs, prov, st)
    elif kind == "github_release":
        prefix = src.get("tag_prefix") or ""
        rel = [r for r in (data or []) if (r.get("tag_name") or "").startswith(prefix)]
        for r in rel:
            r["tag_name_full"] = r["tag_name"]
            r["tag_name"] = r["tag_name"].replace(prefix, "")
        grammar = P1.grammar_releases(rel)
        st["releases"] = len(rel)
    elif kind == "registry_listing_page":
        grammar = G.grammar_registry(data, src.get("registry"), st) if src.get("registry") else P1.grammar_repo_record(data)
    elif kind == "repository_readme":
        grammar = P1.grammar_docs(units, "repository_readme")
    elif kind == "openapi_spec":
        grammar = G.grammar_openapi(data, st)
    elif kind == "api_reference":
        grammar = G.grammar_json_schema(data, src.get("protocol_version"), st)
    elif kind == "changelog":
        grammar = G.grammar_changelog_protocol(units, text, src.get("protocol_version"), st)
    elif kind == "security_advisory_page":
        grammar = G.grammar_ghsa(data, src.get("package"), st)
    elif kind == "framework_docs_page":
        grammar = P1.grammar_docs(units, kind)
    elif kind == "package_version_page":
        grammar = G.grammar_pypi(data, st)
    elif kind == "arxiv_paper":
        pages = G.pdf_text(raw)
        grammar, text = G.grammar_paper_pdf(pages, src.get("ingestion_level") or "P1", st)
        units = []
    keep_universal = [u for u in units if u["kind"] in ("section", "table", "code_block", "link", "metadata_field") and not (u["kind"] == "table" and kind in ("leaderboard_page",))]
    if kind in ("tech_report", "official_blog_post") and key in ("owasp-agentic-top10", "anthropic-multiagent"):
        keep_universal += [u for u in units if u["kind"] in ("paragraph", "list_item") and len(u["text"]) > 40]
    st["units"] = len(keep_universal) + len(grammar)
    return keep_universal + grammar, text


def stage_units(vs):
    total = 0
    for v in vs:
        if not v.get("path") or one(f"select 1 from content.document_node where representation_id={q(v['representation_id'])} limit 1"):
            continue
        try:
            units, text = parse2(v)
        except Exception as e:
            log(f"units: {v['key']} PARSE ERROR {e!r}")
            STATS[v["key"]]["error"] = repr(e)[:300]
            continue
        if not units:
            log(f"units: {v['key']}: 0 units (census only)")
            continue
        ids = {}
        rows = []
        ordinal_by_parent = collections.Counter()
        seen = collections.Counter()
        for u in units:
            seen[u["key"]] += 1
            if seen[u["key"]] > 1:
                u["key"] = f"{u['key']}#{seen[u['key']]}"
            ids[u["key"]] = str(uuid.uuid4())
        for u in units:
            parent_id = ids.get(u.get("parent")) if u.get("parent") else None
            ordinal_by_parent[u.get("parent")] += 1
            ordinal = ordinal_by_parent[u.get("parent")]
            txt = (u.get("text") or "")[:8000]
            rows.append(f"""({q(TENANT)}, {q(ids[u['key']])}, {q(v['representation_id'])}, {q(parent_id)}, {ordinal}, {q(u['key'][:200])}, {q(u['kind'])}, 1, {q({k: val for k, val in (u.get('attrs') or {}).items() if val is not None})}, {q((u.get('logical') or '')[:500] or None)}, {q(GRAMMAR)}, {q(txt)},
                {q(u.get('selector') or {'kind': 'character_position', 'start': u.get('start'), 'end': u.get('end')})}, {q(u.get('start'))}, {q(u.get('end'))}, {q(u.get('start_ms'))}, {q(u.get('end_ms'))}, {q(sha256_text(txt))})""")
        for i in range(0, len(rows), 150):
            sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, start_offset, end_offset, start_ms, end_ms, normalized_content_sha256)
                    values {','.join(rows[i:i + 150])}""")
        total += len(rows)
        log(f"units: {v['key']} {v['label']}: {len(rows)} nodes")
    write_json(os.path.join(RUN2, "parse-stats.json"), STATS)
    log(f"units total: {total}")


# ------------------------------------------------------------------ stage D entities
def ensure_org(slug):
    if slug in ORG2:
        name, kind, url = ORG2[slug]
        return ensure_entity("organization", slug, name, {"org_kind": kind, "website_url": url})
    if slug in L1.ORG:
        name, kind, url = L1.ORG[slug]
        return ensure_entity("organization", slug, name, {"org_kind": kind, "website_url": url})
    return ensure_entity("organization", slug, slug, {"org_kind": "other"})


def ensure_benchmark(label, b):
    """benchmark + benchmark_version entities for a label; returns (benchmark_id, version_id or None)."""
    bslug, base, ver = bench_split(label)
    meta = BENCH_META.get(bslug) or (None, None, "accuracy", None, None)
    attrs = {"organizer": ORG2.get(meta[0], (None,))[0] if meta[0] else None, "metric": meta[1], "score_type": meta[2], "agentic": meta[3], "domain": meta[4]}
    bid = ensure_entity("benchmark", bslug, base, {k: v for k, v in attrs.items() if v is not None})
    if meta[0]:
        b.add(f"select temporal.assert_relationship('organized_by', {q(bid)}, {q(ensure_org(meta[0]))});") if False else None
    vid = None
    if ver:
        vid = ensure_entity("benchmark_version", slugify(f"{bslug}-{ver}"), f"{base} {ver}", {"version_label": ver})
        b.add(f"select temporal.assert_relationship('version_of', {q(vid)}, {q(bid)});")
    return bid, vid


def all_nodes(kinds, keys=None):
    where = f"n.unit_kind = any({qarr(kinds)})" + (f" and d.attributes->>'key' = any({qarr(keys)})" if keys else "")
    return sql_json(f"""select json_build_object('id', n.id, 'unit_kind', n.unit_kind, 'attrs', n.attributes, 'logical_key', n.logical_key, 'text', n.inline_text, 'key', d.attributes->>'key', 'doc_attrs', d.attributes, 'document_id', d.id, 'version_id', v.id, 'representation_id', r.id, 'kind', d.document_type_code, 'role', d.source_role_code, 'title', d.canonical_title)
                        from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                        where n.tenant_id={q(TENANT)} and n.grammar_version={q(GRAMMAR)} and {where} order by d.attributes->>'key', n.ordinal""")


def stage_entities(vs):
    b = Batch("loop2-entities-and-relationships", {"stage": "entities", "loop": 2})
    done_nodes = {r[0] for r in sql_rows(f"select distinct node_id from content.unit_entity_role where tenant_id={q(TENANT)}")}
    orgs = {k: ensure_org(k) for k in list(ORG2)}
    orgs.update({k: ensure_org(k) for k in L1.ORG})
    concepts = {r[1]: r[0] for r in sql_rows(f"select id, slug from catalog.entity where kind='concept' and tenant_id={q(TENANT)}")}
    for slug, name, comp, level in [("memory", "Agent memory", "memory", "intermediate"), ("security", "Agent security", "other", "intermediate"), ("benchmarks", "Benchmarks and leaderboards", "eval", "beginner"), ("compute", "Compute and hardware", "infrastructure", "beginner"), ("recovery", "Failure recovery and undo", "workflow", "advanced"), ("weight-editing", "Weight editing and weight-space programming", "other", "advanced"), ("continual-learning", "Continual learning", "other", "advanced")]:
        if slug not in concepts:
            concepts[slug] = ensure_entity("concept", slug, name, {"component": comp, "level": level})
    # --- RV07: benchmarks, versions, subjects, leaderboards
    boards = {}
    for n in all_nodes(["leaderboard_row", "eval_row"]):
        new_node = n["id"] not in done_nodes
        a = n["attrs"]
        label = a.get("benchmark_version") or a.get("benchmark")
        bid, vid = ensure_benchmark(label, b)
        if new_node:
            add_role(n["id"], vid or bid, "benchmark")
        subj_name = a.get("subject_name") or a.get("model")
        if n["unit_kind"] == "leaderboard_row" and n["key"] == "mlperf-v61":
            sysid = ensure_entity("compute_device", slugify("system-" + subj_name)[:80], subj_name, {"device_class": "system", "vendor": a.get("organization")})
            if new_node:
                add_role(n["id"], sysid, "subject")
                add_role(n["id"], sysid, "system")
            if a.get("organization"):
                oid = ensure_entity("organization", slugify(a["organization"]), a["organization"], {"org_kind": "other"})
                if new_node:
                    add_role(n["id"], oid, "publisher")
                b.add(f"select temporal.assert_relationship('manufactures', {q(oid)}, {q(sysid)});")
            fam, fname = device_family(a.get("accelerator") or "")
            if fam:
                did = ensure_entity("compute_device", fam, fname, {"device_class": "gpu", "vendor": fname.split(" ")[0]})
                if new_node:
                    add_role(n["id"], did, "device")
        elif subj_name:
            if a.get("model") and n["unit_kind"] == "eval_row" and n["key"] == "weight-space-programming":
                base_model = re.sub(r"\s*\(.*\)$", "", subj_name)
                ver_id, fam_id, dev, vname = model_subject(base_model, "Alibaba")
            else:
                ver_id, fam_id, dev, vname = model_subject(subj_name, a.get("organization") or n["doc_attrs"].get("org"))
            if new_node:
                add_role(n["id"], ver_id, "subject" if n["unit_kind"] == "leaderboard_row" else "model")
            if (ver_id, "vo") not in boards:
                b.add(f"select temporal.assert_relationship('version_of', {q(ver_id)}, {q(fam_id)});")
                boards[(ver_id, "vo")] = True
        if a.get("harness") and new_node:
            hid = ensure_entity("product", slugify(a["harness"])[:80], a["harness"], {"product_kind": "agent_harness"})
            add_role(n["id"], hid, "harness")
        board = n["doc_attrs"].get("board") or BY_KEY.get(n["key"], {}).get("board")
        if board and n["unit_kind"] == "leaderboard_row" and new_node:
            org_slug = BOARD_ORG.get(board)
            if org_slug:
                add_role(n["id"], orgs[org_slug], "publisher")
    # every benchmark_version is a version_of its benchmark, whatever run first created it
    for r in sql_json(f"select json_build_object('id', id, 'name', display_name) from catalog.entity where kind='benchmark_version' and tenant_id={q(TENANT)}"):
        bid, vid = ensure_benchmark(r["name"], b)
        if vid and vid != r["id"]:
            b.add(f"select temporal.assert_relationship('version_of', {q(r['id'])}, {q(bid)});")
    # leaderboard rows -> ranking.leaderboard / edition / entries (one edition per captured version; primary score only)
    for v in vs:
        if v["kind"] != "leaderboard_page":
            continue
        board = v["attrs"].get("board") or BY_KEY.get(v["key"], {}).get("board")
        if board in ("epoch-benchmarking-hub", "mlperf-inference-v6.1", "arena-text") or not board:
            continue
        rows = nodes_of(v, ["leaderboard_row"])
        if not rows:
            continue
        lb = one(f"select id from ranking.leaderboard where tenant_id={q(TENANT)} and slug={q(board)}")
        if not lb:
            lb = str(uuid.uuid4())
            bid, vid = ensure_benchmark(rows[0]["attributes"].get("benchmark_version") or rows[0]["attributes"].get("benchmark"), b)
            sql(f"""insert into ranking.leaderboard(id, tenant_id, slug, title, definition, description, publisher_entity_id, benchmark_version_id, source_url, methodology)
                    values ({q(lb)}, {q(TENANT)}, {q(board)}, {q(v['title'])}, {q({'metric': 'benchmark_score', 'cohort_rule': 'rows as published by the organizer at capture'})}, {q('Captured organizer leaderboard; one edition per capture')}, {q(orgs.get(BOARD_ORG.get(board)))}, {q(vid)}, {q(BY_KEY[v['key']]['url'])}, {q({'source': 'organizer page', 'reported_by': 'organizer'})})""")
        if one(f"select 1 from ranking.leaderboard_edition where leaderboard_id={q(lb)} and capture_id={q(v['capture_id'])}"):
            continue
        ed = str(uuid.uuid4())
        edno = int(one(f"select coalesce(max(edition_no),0)+1 from ranking.leaderboard_edition where leaderboard_id={q(lb)}"))
        members = []
        entries = []
        seen_rank = set()
        for n in rows:
            a = n["attributes"]
            subj = role_entity(n["id"], "subject")
            if not subj or a.get("rank") in seen_rank or a.get("rank") is None:
                continue
            seen_rank.add(a["rank"])
            members.append(subj)
            entries.append(f"({q(TENANT)}, {q(ed)}, {int(a['rank'])}, {q(subj)}, {a['score']}, {q(a.get('unit'))}, {q({'source': 'organizer row'})}, '{{}}'::uuid[], {q({k: a.get(k) for k in ('harness', 'reported_by', 'effort', 'tool_mode', 'run_date', 'cost_usd', 'benchmark_version') if a.get(k) is not None})}, {q(a.get('subject_name'))}, {q(n['id'])})")
        board_date = None
        if rows[0]["attributes"].get("run_date") and board in ("swe-bench",):
            board_date = None
        sql(f"""insert into ranking.leaderboard_edition(id, leaderboard_id, edition_no, published_at, tenant_id, knowledge_seq, cohort, capture_id, observed_at, board_date)
                values ({q(ed)}, {q(lb)}, {edno}, {q(v['captured_at'])}, {q(TENANT)}, temporal.current_k(), {q(members)}, {q(v['capture_id'])}, {q(v['captured_at'])}, {q(board_date)})""")
        for i in range(0, len(entries), 100):
            sql("insert into ranking.leaderboard_entry(tenant_id, edition_id, rank, entity_id, score, unit, explanation, source_segment_ids, conditions, subject_label, node_id) values " + ",".join(entries[i:i + 100]))
        log(f"leaderboard {board}: edition {edno} with {len(entries)} entries")
    # metric definitions -> benchmark attributes
    for n in all_nodes(["metric_definition"]):
        a = n["attrs"]
        bid, vid = ensure_benchmark(a.get("name"), b)
        sql(f"update catalog.entity set attributes = attributes || {q({k2: v2 for k2, v2 in {'metric': a.get('formula'), 'scoring': a.get('formula'), 'task_count_note': a.get('scale'), 'description': a.get('description')}.items() if v2})} where id={q(bid)}")
        if n["id"] not in done_nodes:
            add_role(n["id"], vid or bid, "benchmark")
    # --- RV05: devices (spec pages + Epoch hardware), offerings (price rows), providers
    variants = collections.defaultdict(dict)
    for n in all_nodes(["spec_field"]):
        a = n["attrs"]
        fam, fname = device_family(a.get("variant") or n["doc_attrs"].get("device") or "")
        if not fam:
            continue
        variants[fam][a["variant"]] = variants[fam].get(a["variant"], {})
        field = a["field"]
        label = (a.get("label") or "").lower()
        if re.search(r"nvlink|pcie|interconnect", label):
            field = "interconnect"
        elif re.search(r"bandwidth", label):
            field = "memory_bandwidth_tbps"  # stored units predate the grammar fix that orders bandwidth before memory
        elif field == "memory_bandwidth_tbps" and not re.search(r"bandwidth", label):
            continue
        numeric = field in ("memory_gb", "memory_bandwidth_tbps", "bf16_tflops", "fp8_tflops", "fp4_pflops", "tdp_w", "interconnect_gbps", "gpus_per_system")
        if numeric and not isinstance(a["value"], (int, float)):
            continue
        if field == "memory_bandwidth_tbps" and isinstance(a["value"], (int, float)) and a["value"] > 100:
            a["value"] = a["value"] / 1000  # GB/s stated as a bare number
        variants[fam][a["variant"]][field] = a["value"]
        if a.get("sparse") is not None:
            variants[fam][a["variant"]]["sparse_figures"] = a["sparse"]
    for fam, vars_ in variants.items():
        fname = next(nm for pat, slug, nm in DEVICE_FAMILY if slug == fam)
        primary = next((vv for k, vv in vars_.items() if re.search(r"SXM|NVL72", k)), next(iter(vars_.values())))
        attrs = {"vendor": fname.split(" ")[0], "device_class": "system" if "NVL72" in fname or "GB" in fname else "gpu", "variants": vars_, "spec_url": next((m["url"] for m in MANIFEST if m.get("device") and fam.endswith(m["device"].split("-")[0])), None)}
        for f in ("memory_gb", "memory_bandwidth_tbps", "bf16_tflops", "fp8_tflops", "fp4_pflops", "tdp_w", "interconnect", "form_factor", "sparse_figures", "gpus_per_system"):
            if f in primary:
                attrs[f] = primary[f]
        did = ensure_entity("compute_device", fam, fname, {"device_class": attrs["device_class"], "vendor": attrs["vendor"]})
        sql(f"update catalog.entity set attributes = (attributes - 'memory_gb' - 'memory_bandwidth_tbps' - 'bf16_tflops' - 'fp8_tflops' - 'fp4_pflops' - 'tdp_w' - 'interconnect' - 'form_factor' - 'gpus_per_system') || {q({k: v for k, v in attrs.items() if v is not None})}, updated_at = now() where id={q(did)}")
        b.add(f"select temporal.assert_relationship('manufactures', {q(orgs['nvidia'])}, {q(did)});")
    for n in all_nodes(["spec_field"]):
        if n["id"] in done_nodes:
            continue
        fam, fname = device_family(n["attrs"].get("variant") or "")
        if fam:
            add_role(n["id"], ensure_entity("compute_device", fam, fname), "device")
    for n in all_nodes(["table_row"], ["epoch-ml-hardware"]):
        fam, fname = device_family(n["attrs"].get("row_key") or "")
        if not fam:
            continue
        cells = dict(c.split("=", 1) for c in n["attrs"].get("cells") or [] if "=" in c)
        rel = cells.get("Release date")
        did = ensure_entity("compute_device", fam, fname, {k: v for k, v in {"released_on": rel, "epoch_name": n["attrs"].get("row_key")}.items() if v})
        if n["id"] not in done_nodes:
            add_role(n["id"], did, "subject")  # table_row's role vocabulary is {subject}
    offerings = {}
    for n in all_nodes(["price_row"], [m["key"] for m in MANIFEST if m.get("provider")]):
        a = n["attrs"]
        prov = n["doc_attrs"].get("provider")
        off_key = a["offering"]
        if off_key not in offerings:
            is_sandbox = off_key.endswith(":sandbox") or a.get("meter") in ("vcpu_second", "gib_second", "vcpu_hour", "gib_hour", "creations_per_million", "snapshot_storage_month", "drive_storage_month", "data_transfer_gb", "drive_reads", "drive_writes", "disk_gib_second")
            cls = "sandbox" if is_sandbox else ("serverless_gpu" if prov == "modal" else "instance_type")
            fam, fname = device_family(a.get("device") or off_key)
            attrs = {"offering_class": cls, "provider_slug": prov, "sku": off_key.split(":", 1)[1][:80], "gpu_count": a.get("gpu_count") if not is_sandbox else None, "gpu_device_slug": fam, "pricing_url": BY_KEY[n["key"]]["url"], "billing_granularity": "per_second" if prov in ("modal", "e2b", "runpod") else "per_hour"}
            oid = ensure_entity("compute_offering", slugify(off_key)[:80], f"{ORG2.get(prov, (prov,))[0]}: {off_key.split(':', 1)[1]}", {k: v for k, v in attrs.items() if v is not None})
            offerings[off_key] = oid
            b.add(f"select temporal.assert_relationship('provides_compute', {q(orgs[prov])}, {q(oid)});")
            if fam:
                did = ensure_entity("compute_device", fam, fname, {"device_class": "gpu", "vendor": fname.split(" ")[0]})
                b.add(f"select temporal.assert_relationship('runs_on', {q(oid)}, {q(did)});")
        if n["id"] not in done_nodes:
            add_role(n["id"], offerings[off_key], "offering")
            add_role(n["id"], orgs[prov], "provider")
            fam, fname = device_family(a.get("device") or "")
            if fam:
                add_role(n["id"], ensure_entity("compute_device", fam, fname), "device")
    for n in all_nodes(["metadata_field"], ["e2b-pricing", "vercel-sandbox-pricing", "modal-pricing"]):
        prov = n["doc_attrs"].get("provider")
        oid = offerings.get(f"{prov}:sandbox") or ensure_entity("compute_offering", slugify(f"{prov}:sandbox"), f"{ORG2[prov][0]}: sandbox", {"offering_class": "sandbox", "provider_slug": prov})
        offerings[f"{prov}:sandbox"] = oid
        if n["id"] not in done_nodes:
            add_role(n["id"], oid, "offering") if False else None
    # --- RV04: deepagents library/repo/releases, symbols, docs, APIs, protocol, registry, advisories
    da_lib = ensure_entity("library", "deepagents", "Deep Agents", {"ecosystem": "pypi", "package_name": "deepagents", "category": "agent harness", "docs_url": "https://docs.langchain.com/oss/python/deepagents/overview", "repository_url": "https://github.com/langchain-ai/deepagents"}, identifiers=[("pypi", "deepagents")])
    da_repo = ensure_entity("repository", "langchain-ai-deepagents", "langchain-ai/deepagents", {"host": "github.com", "owner": "langchain-ai", "name": "deepagents"}, identifiers=[("github_full_name", "langchain-ai/deepagents")])
    b.add(f"select temporal.assert_relationship('backed_by_repository', {q(da_lib)}, {q(da_repo)});")
    b.add(f"select temporal.assert_relationship('develops', {q(orgs['langchain'])}, {q(da_lib)}, tstzrange('2025-01-01', null, '[)'), p_extent => temporal.make_extent('since 2025 (first-party docs, year precision)', 'year'));")
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(da_lib)}, {q(concepts['agent-orchestration'])});")
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(da_lib)}, {q(concepts['harness-engineering'])});")
    libs = {"deepagents": da_lib, "langgraph": ensure_entity("library", "langgraph", "LangGraph"), "openai-agents-python": ensure_entity("library", "openai-agents-python", "OpenAI Agents SDK (Python)"), "mcp-python-sdk": ensure_entity("library", "mcp-python-sdk", "MCP Python SDK")}
    for n in all_nodes(["release_entry"], ["deepagents-releases"]):
        a = n["attrs"]
        rid = ensure_entity("library_release", slugify("deepagents-" + a["version"]), f"Deep Agents {a['version']}", {"version_label": a["version"], "released_on": a.get("released_on"), "release_url": a.get("url"), "breaking": bool(a.get("breaking")), "highlights": [], "prerelease": bool(a.get("prerelease")), "tag": "deepagents==" + a["version"]})
        b.add(f"select temporal.assert_relationship('version_of', {q(rid)}, {q(da_lib)});")
        if n["id"] not in done_nodes:
            add_role(n["id"], rid, "release")
            add_role(n["id"], da_lib, "software")
    for n in all_nodes(["docs_section", "readme_section", "code_example", "metadata_field"], ["deepagents-readme", "deepagents-reference-docs", "deepagents-overview-docs", "deepagents-repo-record", "pypi-deepagents"]):
        if n["id"] not in done_nodes and n["unit_kind"] != "metadata_field":
            add_role(n["id"], da_lib, "software", "mapping", 0.9)
    # pypi requires_dist -> depends_on
    for n in all_nodes(["metadata_field"], ["pypi-deepagents"]):
        a = n["attrs"]
        if a.get("key") == "requires_dist" and isinstance(a.get("value"), dict):
            dep = a["value"]["package"]
            dep_lib = ensure_entity("library", slugify(dep), dep, {"ecosystem": "pypi", "package_name": dep}, identifiers=[("pypi", dep)])
            latest = one(f"select id from catalog.entity where kind='library_release' and slug like 'deepagents-%' and tenant_id={q(TENANT)} order by (attributes->>'released_on') desc nulls last limit 1")
            if latest:
                b.add(f"select temporal.assert_relationship('depends_on', {q(latest)}, {q(dep_lib)}, null, {q(a['value'].get('spec') or '')}, 1, {q({'version_spec': a['value'].get('spec'), 'extra': a['value'].get('extra')})});")
    # api surfaces: symbol nodes -> release + software roles; release attributes from the surface json
    for v in vs:
        if v["kind"] != "api_surface":
            continue
        d = v["attrs"]
        sw, tag = d.get("software"), d.get("release_tag")
        lib = libs.get(sw)
        label = tag.replace("deepagents==", "").lstrip("v") if sw != "openai-agents-python" else tag
        rid = one(f"select e.id from catalog.entity e join catalog.relationship r on r.from_entity_id=e.id and r.kind='version_of' and r.to_entity_id={q(lib)} where e.kind='library_release' and e.attributes->>'version_label'={q(label)} limit 1") if lib else None
        if not rid and lib:
            rid = ensure_entity("library_release", slugify(f"{sw}-{label}"), f"{sw} {label}", {"version_label": label, "tag": tag})
            b.add(f"select temporal.assert_relationship('version_of', {q(rid)}, {q(lib)});")
        if not v.get("path"):
            continue
        surface = json.load(open(v["path"], encoding="utf-8"))
        sql(f"update catalog.entity set attributes = attributes || {q({'tag': tag, 'source_tarball_sha256': surface.get('tarball_sha256'), 'symbol_count': surface.get('symbol_count'), 'public_symbol_count': surface.get('public_symbol_count'), 'over_cap': surface.get('over_cap'), 'parser': surface.get('parser'), 'parser_scope': surface.get('parser_scope')})} where id={q(rid)}")
        for n in nodes_of(v, ["api_symbol"]):
            if n["id"] in done_nodes:
                continue
            add_role(n["id"], rid, "release")
            if lib:
                add_role(n["id"], lib, "software")
    # R4: docs sections document symbols (unit_link) on the latest deepagents surface
    latest_surface = next((v for v in vs if v["kind"] == "api_surface" and v["attrs"].get("software") == "deepagents" and "0.7.35" in (v["attrs"].get("release_tag") or "")), None)
    if latest_surface and not one("select 1 from content.unit_link where kind='documents' limit 1"):
        syms = {n["attributes"]["qualified_name"].rsplit(".", 1)[-1]: n["id"] for n in nodes_of(latest_surface, ["api_symbol"]) if n["attributes"].get("kind") in ("class", "function")}
        links = []
        for n in all_nodes(["docs_section", "readme_section", "code_example"], ["deepagents-readme", "deepagents-reference-docs", "deepagents-overview-docs"]):
            text = (n["attrs"].get("heading") or "") + " " + (n["text"] or "")
            for name, sid in syms.items():
                if len(name) > 3 and re.search(r"(?<![A-Za-z0-9_])" + re.escape(name) + r"(?![A-Za-z0-9_])", text):
                    links.append(f"({q(TENANT)}, {q(n['id'])}, {q(sid)}, 'documents', 'name_match', 0.8)")
        for i in range(0, len(links), 300):
            sql("insert into content.unit_link(tenant_id, from_node_id, to_node_id, kind, method, confidence) values " + ",".join(links[i:i + 300]) + " on conflict do nothing")
        log(f"unit_link documents: {len(links)}")
    # OpenAI API product + version from the spec
    api_prod = ensure_entity("product", "openai-api", "OpenAI API", {"product_kind": "api"})
    b.add(f"select temporal.assert_relationship('develops', {q(orgs['openai'])}, {q(api_prod)}, tstzrange('2020-06-01', null, '[)'), p_extent => temporal.make_extent('since the public API launch (2020, year precision)', 'year'));")
    for v in vs:
        if v["kind"] != "openapi_spec":
            continue
        info = next((n for n in nodes_of(v, ["metadata_field"]) if n["attributes"].get("key") == "info"), None)
        ver = (info["attributes"]["value"].get("version") if info else None) or "unknown"
        pv = ensure_entity("product_version", slugify("openai-api-" + ver), f"OpenAI API spec {ver}", {"version_label": ver, "spec_paths": (info["attributes"]["value"].get("paths") if info else None)})
        b.add(f"select temporal.assert_relationship('version_of', {q(pv)}, {q(api_prod)});")
        for n in nodes_of(v, ["endpoint"]):
            if n["id"] not in done_nodes:
                add_role(n["id"], api_prod, "api")
                add_role(n["id"], pv, "product_version")
                add_role(n["id"], orgs["openai"], "provider")
    # MCP protocol versions
    mcp = ensure_entity("ai_protocol", "mcp", "Model Context Protocol", {"website_url": "https://modelcontextprotocol.io"})
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(mcp)}, {q(concepts['mcp'])});")
    current = one(f"select n.attributes->>'value' from content.document_node n where n.unit_kind='metadata_field' and n.attributes->>'key'='current_protocol_version' and n.tenant_id={q(TENANT)} limit 1")
    if not current and os.path.exists(os.path.join(SOURCES2, "mcp-versioning.md")):
        m = re.search(r"current" + chr(92) + "**" + chr(92) + "s*protocol version is" + chr(92) + "s*" + chr(92) + "[?" + chr(92) + "**(" + chr(92) + "d{4}-" + chr(92) + "d" + chr(92) + "d-" + chr(92) + "d" + chr(92) + "d)", open(os.path.join(SOURCES2, "mcp-versioning.md"), encoding="utf-8").read())
        current = m.group(1) if m else None
    pvs = {}
    for ver in ("2026-07-28", "2025-11-25"):
        pvs[ver] = ensure_entity("ai_protocol_version", f"mcp-{ver}", f"MCP {ver}", {"version_label": ver, "released_on": ver, "changelog_url": f"https://modelcontextprotocol.io/specification/{ver}/changelog", "schema_url": f"https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/{ver}/schema.json", "status": "current" if ver == current else "final"})
        b.add(f"select temporal.assert_relationship('version_of', {q(pvs[ver])}, {q(mcp)});")
    for n in all_nodes(["schema_component", "change_item", "release_entry"], ["mcp-schema-2026-07-28", "mcp-schema-2025-11-25", "mcp-changelog-2026-07-28", "mcp-changelog-2025-11-25"]):
        ver = n["doc_attrs"].get("protocol_version")
        if n["id"] not in done_nodes and ver in pvs:
            add_role(n["id"], pvs[ver], "protocol_version" if n["unit_kind"] == "schema_component" else ("release" if n["unit_kind"] == "release_entry" else "software"))
    # registry listings -> mcp_server entities, registry entity, listed_in
    reg = ensure_entity("registry", "mcp-registry", "Official MCP Registry", {"registry_kind": "mcp_servers", "api_url": "https://registry.modelcontextprotocol.io/v0/servers", "website_url": "https://registry.modelcontextprotocol.io"})
    for n in all_nodes(["registry_listing"]):
        a = n["attrs"]
        sid = ensure_entity("mcp_server", slugify(a["name"])[:80], a["name"], {k2: v2 for k2, v2 in {"transport": a.get("transports"), "hosting": "remote" if "streamable-http" in (a.get("transports") or []) or "sse" in (a.get("transports") or []) else ("local" if a.get("transports") else "unknown"), "description": a.get("description"), "registry_name": a["name"], "namespace": a.get("namespace"), "first_party_inferred": a.get("first_party_inferred"), "registry_status": a.get("registry_status"), "repository_url": a.get("repository_url"), "website_url": a.get("website_url"), "latest_version": a.get("version"), "package_identifiers": a.get("package_identifiers")}.items() if v2 not in (None, [])})
        if n["id"] not in done_nodes:
            add_role(n["id"], sid, "server")
            add_role(n["id"], reg, "registry")
        b.add(f"select temporal.assert_relationship('instance_of_concept', {q(sid)}, {q(concepts['mcp'])});")
    # advisories -> security_advisory entities
    for n in all_nodes(["advisory"]):
        a = n["attrs"]
        aid = ensure_entity("security_advisory", slugify(a["ghsa_id"]), a["ghsa_id"], {k2: v2 for k2, v2 in a.items() if k2 in ("ghsa_id", "cve_id", "severity", "summary", "url", "published_at", "updated_at", "ecosystem", "package", "affected_range", "fixed_version", "cwe")}, identifiers=[("ghsa", a["ghsa_id"])] + ([("cve", a["cve_id"])] if a.get("cve_id") else []))
        sw = {"langgraph": "langgraph", "mcp": "mcp-python-sdk", "deepagents": "deepagents"}.get(n["doc_attrs"].get("package"))
        if n["id"] not in done_nodes:
            add_role(n["id"], aid, "advisory")
            if sw:
                add_role(n["id"], libs[sw], "software")
        b.add(f"select temporal.assert_relationship('instance_of_concept', {q(aid)}, {q(concepts['security'])});")
    # --- papers: work entities, authors, code, talk links, references (P0)
    talk = one(f"select e.id from catalog.entity e where e.kind='talk' and e.tenant_id={q(TENANT)} and e.slug like '%coding-agent-can%undo%' limit 1")
    for key in ("paper-undobench", "paper-evoundo", "weight-space-programming"):
        src = BY_KEY[key]
        v = next((x for x in vs if (x["attrs"] or {}).get("key") == key), None)
        pid = ensure_entity("paper", slugify(src.get("arxiv_id") or src["title"])[:60], src["title"], {k2: v2 for k2, v2 in {"arxiv_id": src.get("arxiv_id"), "published_on": src.get("published_on"), "venue": "arXiv" if src.get("arxiv_id") else "authors' blog (MIT CSAIL)", "ingestion_level": src.get("ingestion_level"), "promotion": src.get("promotion"), "publication_form": src.get("publication_form") or "preprint"}.items() if v2 is not None}, identifiers=[("arxiv", src["arxiv_id"])] if src.get("arxiv_id") else [])
        sql(f"update catalog.work set attributes = attributes || {q({k2: v2 for k2, v2 in {'arxiv_id': src.get('arxiv_id'), 'ingestion_level': src.get('ingestion_level'), 'promotion': src.get('promotion'), 'publication_form': src.get('publication_form') or 'preprint'}.items() if v2 is not None})} where id={q(pid)}", allow_error=True)
        ensure_work(pid, "paper", src["title"], canonical_url=src["url"] if not src.get("arxiv_id") else f"https://arxiv.org/abs/{src['arxiv_id']}", published_at=src.get("published_on"), abstract=(one(f"select inline_text from content.document_node n join content.document_representation r on r.id=n.representation_id join content.document_version dv on dv.id=r.document_version_id where dv.document_id={q(v['document_id'])} and n.unit_kind in ('paper_section','section') and (n.attributes->>'section_role'='abstract' or n.attributes->>'heading' ilike 'abstract%') limit 1") if v else None), attributes={"ingestion_level": src.get("ingestion_level"), "promotion": src.get("promotion")})
        if v and not one(f"select 1 from content.document_about_entity where document_id={q(v['document_id'])} and entity_id={q(pid)}"):
            sql(f"insert into content.document_about_entity(tenant_id, document_id, entity_id, role, method, confidence) values ({q(TENANT)}, {q(v['document_id'])}, {q(pid)}, 'primary', 'manual', 1.0) on conflict do nothing")
        for i, au in enumerate(src.get("authors") or []):
            per = ensure_entity("person", slugify(au), au, {"affiliation_text": "MIT CSAIL" if key == "weight-space-programming" else "Independent Researcher"})
            b.add(f"select temporal.assert_relationship('authored_by', {q(pid)}, {q(per)}, null, '', 1, {q({'author_order': i + 1})});")
            if key == "weight-space-programming":
                b.add(f"select temporal.assert_relationship('employed_by', {q(per)}, {q(orgs['mit-csail'])}, tstzrange('2026-01-01', null, '[)'), p_extent => temporal.make_extent('as of the post (2026, year precision)', 'year'));")
        if src.get("code_url"):
            m = re.search(r"github\.com/([^/]+)/([^/#?]+)", src["code_url"])
            rep = ensure_entity("repository", slugify(f"{m.group(1)}/{m.group(2)}"), f"{m.group(1)}/{m.group(2)}", {"host": "github.com", "owner": m.group(1), "name": m.group(2)}, identifiers=[("github_full_name", f"{m.group(1)}/{m.group(2)}")])
            b.add(f"select temporal.assert_relationship('has_code', {q(pid)}, {q(rep)});")
        for cslug in (["recovery", "idempotency", "durable-execution"] if "undo" in key else ["weight-editing", "continual-learning"]):
            b.add(f"select temporal.assert_relationship('about', {q(pid)}, {q(concepts[cslug])});")
        if talk and src.get("talk_key"):
            b.add(f"select temporal.assert_relationship('cites', {q(talk)}, {q(pid)}, null, 'slide link', 1, {q({'via': 'slide 16/17 of the talk page', 'speaker_authored': True})});")
            b.add(f"select temporal.assert_relationship('about', {q(talk)}, {q(pid)});")
            # unit_link: the slide node that carries the arXiv id -> the paper's abstract node
            slide = one(f"select n.id from content.document_node n where n.unit_kind='slide' and n.inline_text like {q('%' + (src.get('arxiv_id') or 'x') + '%')} and n.tenant_id={q(TENANT)} limit 1")
            absn = one(f"select n.id from content.document_node n join content.document_representation r on r.id=n.representation_id join content.document_version dv on dv.id=r.document_version_id where dv.document_id={q(v['document_id'])} and n.unit_kind='paper_section' and n.attributes->>'section_role'='abstract' limit 1") if v else None
            if slide and absn:
                sql(f"insert into content.unit_link(tenant_id, from_node_id, to_node_id, kind, method, confidence) values ({q(TENANT)}, {q(slide)}, {q(absn)}, 'cites', 'arxiv_id_match', 1.0) on conflict do nothing")
        if v:
            for n in nodes_of(v, ["paper_section", "reference", "post_paragraph", "eval_row", "section"]):
                if n["id"] not in done_nodes and n["unit_kind"] in ("paper_section", "post_paragraph", "section"):
                    add_role(n["id"], pid, "paper" if n["unit_kind"] == "paper_section" else "mentions", "mapping", 1.0) if n["unit_kind"] == "paper_section" else None
            for n in nodes_of(v, ["reference"]):
                a = n["attributes"]
                ref_id = a.get("arxiv_id") or a.get("doi")
                if not ref_id:
                    continue
                cited = ensure_entity("paper", slugify(ref_id)[:60], f"arXiv:{a['arxiv_id']}" if a.get("arxiv_id") else f"doi:{a['doi']}", {"arxiv_id": a.get("arxiv_id"), "doi": a.get("doi"), "ingestion_level": "P0"})
                ensure_work(cited, "paper", f"arXiv:{a['arxiv_id']}" if a.get("arxiv_id") else f"doi:{a['doi']}", canonical_url=a.get("url"), attributes={"ingestion_level": "P0", "title_unresolved": True, "arxiv_id": a.get("arxiv_id"), "doi": a.get("doi")})
                sql(f"update catalog.work set attributes = attributes || {q({k2: v2 for k2, v2 in {'arxiv_id': a.get('arxiv_id'), 'doi': a.get('doi')}.items() if v2})} where id={q(cited)}", allow_error=True)
                b.add(f"select temporal.assert_relationship('cites', {q(pid)}, {q(cited)});")
                if n["id"] not in done_nodes:
                    add_role(n["id"], cited, "cited")
    # benchmark for UndoBench (paper-defined)
    ub, ubv = ensure_benchmark("UndoBench v1", b)
    sql(f"update catalog.entity set attributes = attributes || {q({'organizer': 'UndoBench authors (Sah et al.)', 'canonical_url': 'https://github.com/tradertanmay/undobench', 'task_count': 36, 'description': '36 base workflows x 36 fault scenarios across 8 enterprise domains; paired trials separate task competence from recovery'})} where id={q(ub)}")
    undo = one(f"select id from catalog.entity where kind='paper' and slug={q(slugify('2610.05622'))}")
    if undo:
        b.add(f"select temporal.assert_relationship('about', {q(undo)}, {q(ub)});")
    flush_roles()
    out = b.commit()
    log(f"entities committed (knowledge_seq {out.splitlines()[-1] if out else '-'}); entities={one('select count(*) from catalog.entity')} relationships={one('select count(*) from catalog.relationship')}")
    write_json(os.path.join(RUN2, "entities-summary.json"), {"by_kind": dict(sql_rows(f"select kind, count(*) from catalog.entity where tenant_id={q(TENANT)} group by kind order by 1")), "relationships": dict(sql_rows("select kind, count(*) from catalog.relationship group by kind order by 1"))})


STAGES = {"census": stage_census, "units": stage_units, "entities": stage_entities}
ORDER = ["census", "units", "entities", "facts", "claims", "guidance", "digests", "diff", "projections", "embed"]

if __name__ == "__main__":
    wanted = sys.argv[1:] or ORDER
    vs = versions()
    log(f"{len(vs)} loop-2 versions with local files")
    import loop2_process_facts as F  # facts/claims/guidance/digests/diff live in the second module to keep files reviewable
    STAGES.update({"facts": F.stage_facts, "claims": F.stage_claims, "guidance": F.stage_guidance, "digests": F.stage_digests, "diff": F.stage_diff, "projections": lambda vs_: L1.stage_projections(vs_), "embed": lambda vs_: L1.stage_embed()})
    for st in ORDER:
        if st in wanted:
            STAGES[st](vs)
