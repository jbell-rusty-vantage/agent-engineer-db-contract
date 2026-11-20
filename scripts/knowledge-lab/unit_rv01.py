"""Build 09, unit RV01 prototype (packet r1) on the lab disposable-aieng-build04 only.

Stages, run one at a time:  python unit_rv01.py <stage>
  acquire    fetch the real public sources, register captures, documents, versions and units
  world      the world events: package split-out, rename, new steward (cases 2, 3, 5)
  identity   our mistakes: adopt the loop-5 move, split a mixed record, merge duplicates, undo one (cases 1a, 1b, 4a, 4b)
  prices     one pricing page at two real dates, and one planted misreading that is corrected (case 6)
  proposals  three proposals by this session's agent (case 7)
  questions  the 14 questions and 11 checks of the packet, written to RESULTS.json beside EXPECTED.json
  accept     what John's acceptance answers set in motion (the endorsed identity proposal and its merge)

Everything is written through the governed functions where one exists. Anything synthetic says so in its payload.
"""
import html as htmllib, json, os, re, sys, uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_acquire as A

UNIT = os.path.join(C.LAB, "unit-RV01")
SRC = os.path.join(UNIT, "sources")
STATE = os.path.join(UNIT, "state.json")
LEDGER = os.path.join(UNIT, "ACQUISITION-LEDGER.jsonl")
ORIGIN = "native harness fetch, Build 09 unit RV01 (claude-code session 2026-11-19)"
GRAMMAR = "build09-rv01/1"
ACTOR = {"label": "claude-fable-5-2 unit RV01 session"}
os.makedirs(SRC, exist_ok=True)

PRICING_URL = "https://platform.claude.com/docs/en/about-claude/pricing.md"
SOURCES = [
    dict(key="lc-v1-migration", url="https://docs.langchain.com/oss/python/migrate/langchain-v1.md", title="LangChain v1 migration guide (Python)", kind="framework_docs_page", role="first_party", fmt="markdown", publisher="LangChain"),
    dict(key="pypi-langchain-classic", url="https://pypi.org/pypi/langchain-classic/json", title="PyPI: langchain-classic (unit RV01)", kind="package_version_page", role="registry", fmt="json", publisher="PyPI"),
    dict(key="pypi-langchain-1-0-0", url="https://pypi.org/pypi/langchain/1.0.0/json", title="PyPI: langchain 1.0.0 (unit RV01)", kind="package_version_page", role="registry", fmt="json", publisher="PyPI"),
    dict(key="claude-agent-sdk-migration", url="https://code.claude.com/docs/en/agent-sdk/migration-guide.md", title="Claude Agent SDK migration guide", kind="official_docs_page", role="first_party", fmt="markdown", publisher="Anthropic"),
    dict(key="pypi-claude-agent-sdk", url="https://pypi.org/pypi/claude-agent-sdk/json", title="PyPI: claude-agent-sdk (unit RV01)", kind="package_version_page", role="registry", fmt="json", publisher="PyPI"),
    dict(key="pypi-claude-code-sdk", url="https://pypi.org/pypi/claude-code-sdk/json", title="PyPI: claude-code-sdk (unit RV01)", kind="package_version_page", role="registry", fmt="json", publisher="PyPI"),
    dict(key="npm-claude-agent-sdk", url="https://registry.npmjs.org/@anthropic-ai/claude-agent-sdk/latest", title="npm: @anthropic-ai/claude-agent-sdk latest (unit RV01)", kind="package_version_page", role="registry", fmt="json", publisher="npm"),
    dict(key="anthropic-mcp-donation", url="https://www.anthropic.com/news/donating-the-model-context-protocol-and-establishing-of-the-agentic-ai-foundation", title="Anthropic: Donating the Model Context Protocol and establishing the Agentic AI Foundation", kind="official_blog_post", role="first_party", fmt="html", publisher="Anthropic"),
    dict(key="mcp-blog-aaif", url="https://blog.modelcontextprotocol.io/posts/2025-12-09-mcp-joins-agentic-ai-foundation/", title="MCP blog: MCP joins the Agentic AI Foundation", kind="official_blog_post", role="first_party", fmt="html", publisher="Model Context Protocol"),
    dict(key="infoq-aaif", url="https://www.infoq.com/news/2025/12/agentic-ai-foundation", title="InfoQ: Agentic AI Foundation (news)", kind="news_article", role="third_party_editorial", fmt="html", publisher="InfoQ"),
    dict(key="newstack-aaif", url="https://thenewstack.io/anthropic-donates-the-mcp-protocol-to-the-agentic-ai-foundation/", title="The New Stack: Anthropic donates the MCP protocol to the Agentic AI Foundation", kind="news_article", role="third_party_editorial", fmt="html", publisher="The New Stack"),
    dict(key="anthropic-pricing-today", url=PRICING_URL, title="Anthropic model pricing", kind="pricing_page", role="first_party", fmt="markdown", publisher="Anthropic"),
]
EXT = {"json": ".json", "markdown": ".md", "html": ".html"}


def load_state():
    return json.load(open(STATE, encoding="utf-8")) if os.path.exists(STATE) else {}


def save_state(s):
    write_json(STATE, s)


def receipt(label):
    return native_receipt("rv01-" + label, {"unit": "RV01", "packet": "r1"})


# ---------------------------------------------------------------------------------------------------------------- capture
def html_blocks(text):
    text = re.sub(r"(?is)<(script|style|noscript|svg|head)\b.*?</\1>", " ", text)
    text = re.sub(r"(?i)</(p|div|h[1-6]|li|tr|section|article|blockquote|br)\s*>|<br\s*/?>", "\n\n", text)
    text = htmllib.unescape(re.sub(r"(?s)<[^>]+>", " ", text))
    return [re.sub(r"[ \t\r\f\v]+", " ", b).strip() for b in re.split(r"\n\s*\n", text) if len(b.strip()) >= 40]


def md_blocks(text):
    return [b.strip() for b in re.split(r"\n\s*\n", text) if len(b.strip()) >= 20]


def ensure_document(src):
    doc = one(f"select id from content.document where tenant_id={q(TENANT)} and canonical_title={q(src['title'])} and document_type_code={q(src['kind'])}")
    if doc:
        return doc
    doc = str(uuid.uuid4())
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if src["fmt"] == "json" else "web_page")
    sql(f"""insert into content.document(id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, source_role_code, source_role_method, attributes)
            values ({q(doc)}, {q(TENANT)}, {q(src['kind'])}, {q(src['title'])}, {q(source_id)}, 'active', {q(src['role'])}, 'rule', {q({'key': src['key'], 'unit': 'RV01', 'publisher': src['publisher']})});
            insert into content.document_kind_assignment(tenant_id, document_id, document_type_code, method, confidence, rationale)
            values ({q(TENANT)}, {q(doc)}, {q(src['kind'])}, 'rule', 0.95, 'named source of packet r1, unit RV01')""")
    return doc


def write_units(src, body, rep, json_units=None):
    fmt, text = src["fmt"], body.decode("utf-8", "replace")
    if fmt == "json":
        units = [dict(key=p, kind="metadata_field", text=str(v), pointer=p) for p, v in (json_units or {}).items() if v is not None]
    else:
        blocks = md_blocks(text) if fmt == "markdown" else html_blocks(text)
        units = [dict(key=f"p{i:04d}", kind="paragraph", text=b, pointer=None) for i, b in enumerate(blocks[:400], 1)]
    rows = []
    for i, u in enumerate(units, 1):
        txt = u["text"][:12000]
        rows.append(f"""({q(TENANT)}, {q(str(uuid.uuid4()))}, {q(rep)}, null, {i}, {q(u['key'][:200])}, {q(u['kind'])}, 1, {q({'key': u['key'], 'value': u['text']} if u['kind'] == 'metadata_field' else {})}, {q(src['key'] + '#' + u['key'][:160])}, {q(GRAMMAR)}, {q(txt)},
                       {q({'kind': 'json_pointer' if u['pointer'] else 'text_block', 'pointer': u['pointer']})}, {q(sha256_text(txt))})""")
    for i in range(0, len(rows), 100):
        sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, normalized_content_sha256)
                values {','.join(rows[i:i + 100])}""")
    return len(units)


def capture(src, body, fetched, json_units=None):
    """bytes -> file, acquisition.fetch, artifact, source capture, document version, representation, units. Returns ids."""
    sha, fmt = sha256_bytes(body), src["fmt"]
    path = os.path.join(SRC, f"{src['key']}-{sha[:12]}{EXT[fmt]}")
    if not os.path.exists(path):
        open(path, "wb").write(body)
    doc = ensure_document(src)
    have = sql_rows(f"""select v.id, r.id, vc.source_capture_id from content.document_version v join content.document_representation r on r.document_version_id = v.id
                        join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} and v.manifest_sha256 = {q(sha)} limit 1""")
    if have and one(f"select count(*) from content.document_node where representation_id = {q(have[0][1])}") != "0":
        return dict(document_id=doc, version_id=have[0][0], representation_id=have[0][1], capture_id=have[0][2], sha=sha, new=False, file=os.path.basename(path))
    if have:  # a version registered by a run that stopped before its units were written
        ver, rep, cap = have[0]
        return dict(document_id=doc, version_id=ver, representation_id=rep, capture_id=cap, sha=sha, new=False, file=os.path.basename(path),
                    units=write_units(src, body, rep, json_units))
    requested_at, media = now_iso(), A.MEDIA_BY_FMT[fmt]
    fetch_id, artifact, cap = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if fmt == "json" else "web_page")
    sql(f"""insert into acquisition.fetch(id, tenant_id, origin_kind, origin_label, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, notes)
            values ({q(fetch_id)}, {q(TENANT)}, 'native_harness', {q(ORIGIN)}, 'http', 'urllib/python3.12', {q(src['url'])}, {q(fetched.get('final_url'))}, {q(requested_at)}, now(), {q(fetched.get('status'))}, 'captured', {q(sha)}, {q(media)}, {len(body)}, {q({'kind': src['kind'], 'format': fmt, 'unit': 'RV01'})});
            insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
            values ({q(artifact)}, {q(TENANT)}, 'source_capture', 1, {q(sha)}, 'source_captures', 'lab-sources', {q(TENANT + '/unit-rv01/' + src['key'] + '/' + sha)}, {q(media)}, {len(body)}, 'available', now());
            insert into evidence.source_capture(id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, context, acquisition_fetch_id)
            values ({q(cap)}, {q(TENANT)}, {q(source_id)}, {q(artifact)}, {q(sha)}, {q(media)}, {q(src.get('captured_at') or requested_at)}, 'native_harness_http', '0.9', {q(src['url'])}, {q(fetched.get('status'))}, {q({'origin': ORIGIN, 'final_url': fetched.get('final_url'), 'archived_copy_of': src.get('archived_copy_of')})}, {q(fetch_id)});
            update evidence.source set capture_count = capture_count + 1, last_seen_at = now(), last_capture_id = {q(cap)} where id = {q(source_id)}""")
    ver, _ = A.add_version(doc, cap, sha, artifact, fmt, f"rv01-{(src.get('captured_at') or requested_at)[:10]}-{sha[:8]}", published_at=src.get("published_at"))
    rep = one(f"select id from content.document_representation where document_version_id = {q(ver)}")
    n_units = write_units(src, body, rep, json_units)
    append_jsonl(LEDGER, {"key": src["key"], "url": src["url"], "sha256": sha, "bytes": len(body), "format": fmt, "fetch_id": fetch_id, "capture_id": cap, "version_id": ver, "document_id": doc, "units": n_units, "file": os.path.basename(path), "at": requested_at})
    return dict(document_id=doc, version_id=ver, representation_id=rep, capture_id=cap, sha=sha, new=True, units=n_units, file=os.path.basename(path))


def pypi_units(d):
    """The few fields of a PyPI JSON document this unit quotes."""
    out = {"/info/name": d["info"].get("name"), "/info/version": d["info"].get("version"), "/info/summary": d["info"].get("summary")}
    rel = {v: min(f["upload_time_iso_8601"] for f in files) for v, files in (d.get("releases") or {}).items() if files}
    if rel:
        first = min(rel, key=rel.get)
        last = max(rel, key=rel.get)
        out[f"/releases/{first}/0/upload_time_iso_8601"] = rel[first]
        out[f"/releases/{last}/0/upload_time_iso_8601"] = rel[last]
        out["/releases#first_version"] = first
        out["/releases#count"] = len(rel)
    for i, u in enumerate(d.get("urls") or []):
        out[f"/urls/{i}/upload_time_iso_8601"] = u.get("upload_time_iso_8601")
        break
    return out


def stage_acquire():
    st = load_state()
    st.setdefault("captures", {})
    for src in SOURCES:
        f = http_get(src["url"], accept="application/json" if src["fmt"] == "json" else None)
        if f["status"] != 200 or not f["body"]:
            log(f"{src['key']}: HTTP {f['status']} (not captured)")
            st["captures"][src["key"]] = {"status": f["status"], "captured": False}
            continue
        ju = None
        if src["fmt"] == "json":
            d = json.loads(f["body"])
            ju = pypi_units(d) if "pypi.org" in src["url"] else {"/name": d.get("name"), "/version": d.get("version"), "/description": d.get("description")}
        c = capture(src, f["body"], f, ju)
        st["captures"][src["key"]] = dict(c, status=200, captured=True, url=src["url"], bytes=len(f["body"]))
        log(f"{src['key']}: {len(f['body'])} bytes, {'new' if c['new'] else 'same bytes as before'}, units {c.get('units', '-')}")
    # the same pricing page as archived on an earlier date (Wayback Machine, raw original bytes)
    a = http_get("http://archive.org/wayback/available?url=" + PRICING_URL.replace("https://", "") + "&timestamp=20260601", accept="application/json")
    snap = (json.loads(a["body"]).get("archived_snapshots") or {}).get("closest") if a["status"] == 200 else None
    if snap and snap.get("available"):
        ts = snap["timestamp"]
        raw_url = f"https://web.archive.org/web/{ts}id_/{PRICING_URL}"
        f = http_get(raw_url)
        if f["status"] == 200:
            at = f"{ts[0:4]}-{ts[4:6]}-{ts[6:8]}T{ts[8:10]}:{ts[10:12]}:{ts[12:14]}Z"
            src = dict(key="anthropic-pricing-archived", url=raw_url, title="Anthropic model pricing", kind="pricing_page", role="first_party", fmt="markdown", publisher="Internet Archive (copy of platform.claude.com)",
                       captured_at=at, published_at=at, archived_copy_of=PRICING_URL)
            c = capture(src, f["body"], f)
            st["captures"][src["key"]] = dict(c, status=200, captured=True, url=raw_url, bytes=len(f["body"]), archived_at=at)
            log(f"anthropic-pricing-archived: snapshot {ts}, {len(f['body'])} bytes, units {c.get('units', '-')}")
        else:
            log(f"wayback raw fetch HTTP {f['status']}")
            st["captures"]["anthropic-pricing-archived"] = {"status": f["status"], "captured": False}
    else:
        log("wayback: no snapshot available")
        st["captures"]["anthropic-pricing-archived"] = {"status": a["status"], "captured": False, "note": "no snapshot"}
    st["spend"] = dict(C.SPEND)
    save_state(st)


if __name__ == "__main__":
    stage = sys.argv[1] if len(sys.argv) > 1 else ""
    fn = globals().get("stage_" + stage)
    if not fn:
        sys.modules.setdefault("unit_rv01", sys.modules["__main__"])
        import unit_rv01_cases, unit_rv01_questions, unit_rv01_accept
        fn = getattr(unit_rv01_cases, "stage_" + stage, None) or getattr(unit_rv01_questions, "stage_" + stage, None) or getattr(unit_rv01_accept, "stage_" + stage, None)
    if not fn:
        sys.exit(__doc__)
    fn()
