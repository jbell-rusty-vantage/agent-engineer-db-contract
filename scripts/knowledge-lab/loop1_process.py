"""Build 08 knowledge loop 1, stages B-J: census -> typed units -> entities -> facts/claims (cheap path, L1 candidates) -> digests -> diff -> projections -> embeddings.

Run after loop1_acquire.py: python -I -X utf8 scripts/knowledge-lab/loop1_process.py [stage ...]
Stages: census units entities facts claims digests diff projections embed (default: all, in order). Idempotent per stable key.
"""
import json, os, re, sys, uuid, collections, datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_parse as P

TRACKS = {"Harness Engineering", "Context Engineering", "Evals", "Search & Retrieval"}
TRACK_CONCEPT = {"Harness Engineering": "harness-engineering", "Context Engineering": "context-engineering", "Evals": "evals", "Search & Retrieval": "search-and-retrieval"}
ORG = {"openai": ("OpenAI", "frontier_lab", "https://openai.com"), "anthropic": ("Anthropic", "frontier_lab", "https://www.anthropic.com"), "google": ("Google", "frontier_lab", "https://ai.google.dev"), "deepseek": ("DeepSeek", "model_provider", "https://www.deepseek.com"),
       "langchain": ("LangChain", "tooling_vendor", "https://www.langchain.com"), "modelcontextprotocol": ("Model Context Protocol", "nonprofit", "https://modelcontextprotocol.io"), "github": ("GitHub", "tooling_vendor", "https://github.com"), "ai-engineer": ("AI Engineer", "event_organizer", "https://ai.engineer")}
SOFTWARE = {"langgraph": ("LangGraph", "langchain", "langchain-ai/langgraph", "pypi", "langgraph", "agent framework (graph runtime)", "https://docs.langchain.com/oss/python/langgraph/overview"),
            "openai-agents-python": ("OpenAI Agents SDK (Python)", "openai", "openai/openai-agents-python", "pypi", "openai-agents", "agent framework", "https://openai.github.io/openai-agents-python/"),
            "mcp-python-sdk": ("MCP Python SDK", "modelcontextprotocol", "modelcontextprotocol/python-sdk", "pypi", "mcp", "protocol sdk", "https://py.sdk.modelcontextprotocol.io/")}
CONCEPTS = [("harness-engineering", "Harness engineering", "harness", "advanced"), ("context-engineering", "Context engineering", "context", "intermediate"), ("evals", "Evals", "eval", "intermediate"), ("search-and-retrieval", "Search and retrieval", "rag", "intermediate"),
            ("rag", "Retrieval-augmented generation", "rag", "beginner"), ("mcp", "Model Context Protocol", "mcp", "beginner"), ("sandboxes", "Sandboxes", "sandbox", "intermediate"), ("durable-execution", "Durable execution", "workflow", "intermediate"),
            ("checkpointing", "Checkpointing and persistence", "memory", "intermediate"), ("agent-orchestration", "Agent orchestration", "agent_pattern", "beginner"), ("tool-use", "Tool use", "tool", "beginner"), ("coding-agents", "Coding agents", "agent_pattern", "intermediate"),
            ("prompt-caching", "Prompt caching", "context", "intermediate"), ("idempotency", "Idempotent retries", "workflow", "beginner"), ("curation", "Curation and judgment (anti-slop)", "other", "advanced"), ("computer-use", "Computer use", "agent_pattern", "intermediate")]
RECEIPT = None


def receipt():
    global RECEIPT
    if RECEIPT is None:
        RECEIPT = native_receipt("entities", {"stage": "entities"})
    return RECEIPT


def slugify(s):
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", s.lower())).strip("-")[:80]


# ------------------------------------------------------------------ inventory of versions and their files
def versions():
    rows = sql_json(f"""select json_build_object('key', d.attributes->>'key', 'kind', d.document_type_code, 'role', d.source_role_code, 'document_id', d.id, 'version_id', v.id, 'label', v.version_label, 'format', v.format_code, 'sha', v.manifest_sha256,
      'representation_id', r.id, 'capture_id', vc.source_capture_id, 'captured_at', c.captured_at, 'title', d.canonical_title, 'attrs', d.attributes, 'work_entity_id', d.work_entity_id)
      from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id
      join content.document_version_source_capture vc on vc.document_version_id = v.id join evidence.source_capture c on c.id = vc.source_capture_id
      where d.tenant_id = {q(TENANT)} order by d.attributes->>'key', c.captured_at""")
    files = {}
    for d in (BUILD07_SOURCES, SOURCES_DIR):
        for f in os.listdir(d):
            p = os.path.join(d, f)
            if os.path.isfile(p) and not f.endswith(".json") or f.endswith(".json"):
                files[sha256_bytes(open(p, "rb").read())] = p
    for v in rows:
        v["path"] = files.get(v["sha"])
    return [v for v in rows if v["path"]]


def load_text(v):
    raw = open(v["path"], "rb").read()
    text = raw.decode("utf-8", "replace")
    data = None
    if v["format"] == "json":
        data = json.loads(raw)
    if v["format"] == "html":
        text = P.html_to_text(text)
    return text, data


# ------------------------------------------------------------------ stage B census
def stage_census(vs):
    n = 0
    for v in vs:
        if one(f"select 1 from content.structure_census where representation_id={q(v['representation_id'])} and census_version='build08-census/1'"):
            continue
        text, _ = load_text(v)
        counts, sigs = P.census(text, v["format"] if v["format"] != "unknown" else "text")
        sql(f"""insert into content.structure_census(tenant_id, representation_id, census_version, format_code, counts, signatures, language, digest)
                values ({q(TENANT)}, {q(v['representation_id'])}, 'build08-census/1', {q(v['format'])}, {q(counts)}, {q(sigs)}, 'en', {q(sha256_text(json.dumps(counts, sort_keys=True)))})""")
        n += 1
    log(f"census rows written: {n}")


# ------------------------------------------------------------------ stage C typed units
def parse_version(v):
    text, data = load_text(v)
    units, tables, lines, offs = ([], [], [], [])
    if v["format"] != "json":
        units, tables, lines, offs = P.universal_markdown(text, v["kind"])
    kind = v["kind"]
    key = v["key"]
    grammar = []
    if kind == "pricing_page":
        grammar = P.grammar_gemini(text, offs, "google") if key.startswith("gemini") else P.grammar_pricing(units, tables, lines, offs, key)
    elif kind == "product_page" and v["attrs"].get("model_hint"):
        grammar = P.grammar_model_page(units, text, offs, v["attrs"]["model_hint"])
    elif kind == "product_page":
        grammar = P.grammar_anthropic_overview(tables, lines, offs)
    elif kind == "aie_talk" and v["format"] == "markdown":
        grammar = P.grammar_talk(text, units, offs)
    elif kind == "aie_talk" and key == "wf2026-sessions":
        grammar = P.grammar_sessions(data, TRACKS)
    elif kind == "aie_talk" and key == "wf2026-speakers":
        names = set()
        sess = json.load(open(os.path.join(SOURCES_DIR, "wf2026-sessions.json"), encoding="utf-8"))
        for s in sess["sessions"]:
            if s.get("track") in TRACKS:
                names.update(s.get("speakers") or [])
        grammar = P.grammar_speakers(data, names)
    elif kind in ("framework_docs_page", "repository_readme"):
        grammar = P.grammar_docs(units, kind)
    elif kind == "github_release":
        grammar = P.grammar_releases(data)
    elif kind == "release_notes":
        grammar = P.grammar_docs(units, "framework_docs_page")
        grammar.append(dict(kind="release_entry", key="rel:v1", parent=None, attrs={"version": "1.0", "title": "LangGraph v1", "breaking": True, "url": "https://docs.langchain.com/oss/python/releases/langgraph-v1", "released_on": None}, text=text[:2000], logical="release_entry:1.0", start=0, end=len(text), selector={"kind": "text_quote", "exact": "What's new in LangGraph v1"}, roles={"release": ["1.0"], "software": ["langgraph"]}))
    elif kind == "registry_listing_page":
        grammar = P.grammar_repo_record(data)
    elif kind in ("official_blog_post", "news_article", "analysis_post"):
        grammar = P.grammar_post(units, published_at=("2026-10-27" if key.startswith("technology") else None), byline=v["attrs"].get("publisher"))
    elif kind == "unclassified":
        grammar = P.grammar_ics(text)
    # drop universal units that a grammar unit replaces (same text span) to keep trees small: keep sections/tables/code/links + grammar
    keep_universal = [u for u in units if u["kind"] in ("section", "table", "code_block", "link", "metadata_field") or (u["kind"] in ("paragraph", "list_item") and kind in ("framework_docs_page", "repository_readme", "release_notes", "aie_talk") and False)]
    return keep_universal + grammar, text


def stage_units(vs):
    total = 0
    for v in vs:
        if one(f"select 1 from content.document_node where representation_id={q(v['representation_id'])} limit 1"):
            continue
        units, text = parse_version(v)
        if not units:
            continue
        ids = {}
        rows = []
        ordinal_by_parent = collections.Counter()
        seen = collections.Counter()
        for u in units:  # stable_local_key is unique per representation; a repeated key gets a numbered suffix
            seen[u["key"]] += 1
            if seen[u["key"]] > 1:
                u["key"] = f"{u['key']}#{seen[u['key']]}"
            ids[u["key"]] = str(uuid.uuid4())
        for u in units:
            parent_id = ids.get(u.get("parent")) if u.get("parent") else None
            ordinal_by_parent[u.get("parent")] += 1
            ordinal = ordinal_by_parent[u.get("parent")]
            txt = (u.get("text") or "")[:8000]
            rows.append(f"""({q(TENANT)}, {q(ids[u['key']])}, {q(v['representation_id'])}, {q(parent_id)}, {ordinal}, {q(u['key'])}, {q(u['kind'])}, 1, {q({k: val for k, val in (u.get('attrs') or {}).items() if val is not None})}, {q(u.get('logical'))}, 'build08-grammar/1', {q(txt)},
                {q(u.get('selector') or {'kind': 'character_position', 'start': u.get('start'), 'end': u.get('end')})}, {q(u.get('start'))}, {q(u.get('end'))}, {q(u.get('start_ms'))}, {q(u.get('end_ms'))}, {q(sha256_text(txt))})""")
        for i in range(0, len(rows), 200):
            sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, start_offset, end_offset, start_ms, end_ms, normalized_content_sha256)
                    values {','.join(rows[i:i + 200])}""")
        total += len(rows)
        log(f"units: {v['key']} {v['label']}: {len(rows)} nodes")
    log(f"units total: {total}")


# ------------------------------------------------------------------ stage D entities (catalog) and their relationships
ENTITY_CACHE = {}
ROLE_ROWS = []


def flush_roles():
    """unit_entity_role inserts are collected and written in batches (one docker exec per 400 rows)."""
    global ROLE_ROWS
    for i in range(0, len(ROLE_ROWS), 400):
        sql("insert into content.unit_entity_role(tenant_id, node_id, entity_id, role, method, confidence) values " + ",".join(ROLE_ROWS[i:i + 400]) + " on conflict do nothing")
    ROLE_ROWS = []


def add_role(node_id, entity_id, role, method="mapping", confidence=1.0):
    ROLE_ROWS.append(f"({q(TENANT)}, {q(node_id)}, {q(entity_id)}, {q(role)}, {q(method)}, {confidence})")
    if len(ROLE_ROWS) >= 400:
        flush_roles()


def ensure_entity(kind, slug, name, attrs=None, aliases=(), identifiers=()):
    attrs = {k: v for k, v in (attrs or {}).items() if v is not None}  # attribute schemas type their fields; absent beats null
    if (kind, slug) in ENTITY_CACHE and not attrs:
        return ENTITY_CACHE[(kind, slug)]
    eid = ENTITY_CACHE.get((kind, slug)) or one(f"select id from catalog.entity where tenant_id={q(TENANT)} and kind={q(kind)} and slug={q(slug)}")
    if eid and (kind, slug) in ENTITY_CACHE:
        return eid  # attributes were merged on first sight in this run; later identical calls are no-ops
    ENTITY_CACHE[(kind, slug)] = eid
    if not eid:
        eid = str(uuid.uuid4())
        sql(f"""insert into catalog.entity(id, tenant_id, kind, display_name, slug, lifecycle, created_by_receipt_id, attributes)
                values ({q(eid)}, {q(TENANT)}, {q(kind)}, {q(name)}, {q(slug)}, 'active', {q(receipt())}, {q(attrs or {})})""")
        ENTITY_CACHE[(kind, slug)] = eid
        for a in set(aliases) | {name}:
            sql(f"insert into catalog.entity_alias(tenant_id, entity_id, alias, alias_normalized, alias_kind) values ({q(TENANT)}, {q(eid)}, {q(a)}, {q(a.lower())}, 'name') on conflict do nothing", allow_error=True)
        for scheme, value in identifiers:
            sql(f"insert into catalog.entity_identifier(tenant_id, entity_id, scheme, value) values ({q(TENANT)}, {q(eid)}, {q(scheme)}, {q(value)}) on conflict do nothing", allow_error=True)
    elif attrs:
        sql(f"update catalog.entity set attributes = attributes || {q(attrs)}, updated_at = now() where id={q(eid)}")
    ENTITY_CACHE[(kind, slug)] = eid
    return eid


def ensure_work(eid, kind, title, **kw):
    if one(f"select 1 from catalog.work where id={q(eid)}"):
        return
    sql(f"""insert into catalog.work(id, tenant_id, kind, title, subtitle, abstract, canonical_url, published_at, language, duration_ms, venue_entity_id, attributes)
            values ({q(eid)}, {q(TENANT)}, {q(kind)}, {q(title)}, {q(kw.get('subtitle'))}, {q(kw.get('abstract'))}, {q(kw.get('canonical_url'))}, {q(kw.get('published_at'))}, 'en', {q(kw.get('duration_ms'))}, {q(kw.get('venue'))}, {q(kw.get('attributes') or {})})""")


MODEL_FAMILY = [
    (re.compile(r"^(gpt-\d(?:\.\d)?)[- ]?(sol|terra|luna|astra)", re.I), lambda m: (f"{m.group(1).upper()} {m.group(2).title()}", m.group(1).upper(), "openai")),
    (re.compile(r"^claude[- ](fable|mythos|opus|sonnet|haiku)[- ](\d(?:\.\d)?)", re.I), lambda m: (f"Claude {m.group(1).title()} {m.group(2)}", f"Claude {m.group(1).title()}", "anthropic")),
    (re.compile(r"^gemini[- ](\d(?:\.\d)?)[- ]?(.*)$", re.I), lambda m: (f"Gemini {m.group(1)} {m.group(2).strip()}".strip(), f"Gemini {m.group(1)}", "google")),
    (re.compile(r"^deepseek[- ]?(.*)$", re.I), lambda m: (f"DeepSeek {m.group(1).strip()}".strip(), "DeepSeek", "deepseek")),
]


def model_version_for(offering_name, provider_slug):
    """Resolve an offering/model label to (version entity id, model family id, developer slug); creates them."""
    name = re.sub(r"\s+", " ", offering_name).strip()
    for pat, fn in MODEL_FAMILY:
        m = pat.match(name)
        if m:
            vname, fam, dev = fn(m)
            break
    else:
        vname, fam, dev = name, name.split(" ")[0], provider_slug
    fam_id = ensure_entity("ai_model", slugify(fam), fam, {"model_family": fam})
    ver_id = ensure_entity("ai_model_version", slugify(vname), vname, {"version_label": vname, "provider_model_id": name.lower().replace(" ", "-")}, aliases=[name], identifiers=[(dev + "_model_id", name.lower().replace(" ", "-"))])
    return ver_id, fam_id, dev, vname


def stage_entities(vs):
    b = Batch("entities-and-relationships", {"stage": "entities"})
    done_nodes = {r[0] for r in sql_rows(f"select distinct node_id from content.unit_entity_role where tenant_id={q(TENANT)}")}
    orgs = {k: ensure_entity("organization", k, v[0], {"org_kind": v[1], "website_url": v[2]}) for k, v in ORG.items()}
    concepts = {slug: ensure_entity("concept", slug, name, {"component": comp, "level": level}) for slug, name, comp, level in CONCEPTS}
    series = ensure_entity("event_series", "ai-engineer", "AI Engineer conference series", {"series_kind": "conference", "website_url": "https://ai.engineer"})
    b.add(f"select temporal.assert_relationship('organized_by', {q(series)}, {q(orgs['ai-engineer'])});")
    sess = json.load(open(os.path.join(SOURCES_DIR, "wf2026-sessions.json"), encoding="utf-8"))
    wf = ensure_entity("industry_event", "worldsfair-2026", "AI Engineer World's Fair 2026", {"edition_label": "2026", "starts_on": "2026-06-29", "ends_on": "2026-07-02", "city": "San Francisco", "country": "US", "website_url": sess.get("website"), "tracks": sorted({s.get("track") for s in sess["sessions"] if s.get("track")})})
    b.add(f"select temporal.assert_relationship('edition_of', {q(wf)}, {q(series)});")
    b.add(f"select temporal.assert_relationship('organized_by', {q(wf)}, {q(orgs['ai-engineer'])});")
    events = {"AI Engineer World's Fair 2026": wf}
    # software, repositories, releases
    software = {}
    for slug, (name, dev, repo, eco, pkg, cat, docs) in SOFTWARE.items():
        lib = ensure_entity("library", slug, name, {"ecosystem": eco, "package_name": pkg, "category": cat, "docs_url": docs, "repository_url": "https://github.com/" + repo}, identifiers=[("pypi", pkg)])
        owner, rname = repo.split("/")
        rep = ensure_entity("repository", slugify(repo), repo, {"host": "github.com", "owner": owner, "name": rname}, identifiers=[("github_full_name", repo)])
        software[slug] = (lib, rep)
        b.add(f"select temporal.assert_relationship('backed_by_repository', {q(lib)}, {q(rep)});")
        b.add(f"select temporal.assert_relationship('develops', {q(orgs[dev])}, {q(lib)}, tstzrange('2024-01-01', null, '[)'), p_extent => temporal.make_extent('since 2024 (first-party docs, year precision)', 'year'));")
        b.add(f"select temporal.assert_relationship('instance_of_concept', {q(lib)}, {q(concepts['agent-orchestration'])});")
    b.add(f"select temporal.assert_relationship('implements_protocol', {q(software['mcp-python-sdk'][0])}, {q(ensure_entity('ai_protocol_version', 'mcp-2025-11', 'MCP specification 2025-11', {}))}, tstzrange('2025-11-01', null, '[)'));") if False else None
    # releases from github release units
    rel_units = sql_json(f"""select json_build_object('id', n.id, 'attrs', n.attributes, 'key', d.attributes->>'key', 'software', d.attributes->>'software') from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                             where n.tenant_id={q(TENANT)} and n.unit_kind='release_entry' and d.attributes->>'software' is not null""")
    releases = {}
    for u in rel_units:
        lib, rep = software[u["software"]]
        ver = u["attrs"].get("version") or "unknown"
        rid = ensure_entity("library_release", slugify(u["software"] + "-" + ver), f"{SOFTWARE[u['software']][0]} {ver}", {"version_label": ver, "released_on": u["attrs"].get("released_on"), "release_url": u["attrs"].get("url"), "breaking": bool(u["attrs"].get("breaking")), "highlights": [], "prerelease": bool(u["attrs"].get("prerelease"))})
        releases[(u["software"], ver)] = rid
        b.add(f"select temporal.assert_relationship('version_of', {q(rid)}, {q(lib)});")
        if u['id'] not in done_nodes: add_role(u['id'], rid, 'release', 'mapping', 1.0); add_role(u['id'], lib, 'software', 'mapping', 1.0)
    # models/offerings from price rows and spec fields
    pr = sql_json(f"""select json_build_object('id', n.id, 'attrs', n.attributes, 'key', d.attributes->>'key', 'org', d.attributes->>'org', 'kind', n.unit_kind) from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                      where n.tenant_id={q(TENANT)} and n.unit_kind in ('price_row','spec_field') and d.document_type_code in ('pricing_page','product_page')""")
    offerings = {}
    for u in pr:
        prov = u["org"] or u["key"].split("-")[0]
        label = u["attrs"].get("offering") if u["kind"] == "price_row" else None
        if u["kind"] == "spec_field":
            label = (u["attrs"].get("model_hint") or None)
            lk = one(f"select logical_key from content.document_node where id={q(u['id'])}") or ""
            label = lk.split(":", 1)[1].split("|")[0] if ":" in lk else label
        if not label or len(label) > 60 or label.lower() in ("model", "models", "text", "metric", "feature"):
            continue
        ver_id, fam_id, dev, vname = model_version_for(label, prov)
        if (ver_id, fam_id) not in offerings:
            b.add(f"select temporal.assert_relationship('version_of', {q(ver_id)}, {q(fam_id)});")
            b.add(f"select temporal.assert_relationship('develops', {q(orgs.get(dev, orgs[prov]))}, {q(fam_id)}, tstzrange('2023-01-01', null, '[)'), p_extent => temporal.make_extent('since 2023 (vendor pages, year precision)', 'year'));")
        off_key = f"{prov}:{label.lower().replace(' ', '-')}"
        if off_key not in offerings:
            off_id = ensure_entity("model_offering", slugify(off_key), f"{vname} on {ORG[prov][0]} API", {"offering_key": label.lower().replace(" ", "-"), "provider_model_id": label, "tier": "standard"}, aliases=[label])
            offerings[off_key] = off_id
            b.add(f"select temporal.assert_relationship('offered_as', {q(ver_id)}, {q(off_id)});")
            b.add(f"select temporal.assert_relationship('offered_by', {q(off_id)}, {q(orgs[prov])});")
        offerings[(ver_id, fam_id)] = True
        role = "offering" if u["kind"] == "price_row" else "model"
        target = offerings[off_key] if role == "offering" else ver_id
        if u['id'] not in done_nodes: add_role(u['id'], target, role, 'mapping', 1.0)
        if role == 'offering':
            if u['id'] not in done_nodes: add_role(u['id'], orgs[prov], 'provider', 'mapping', 1.0)
    # talks, speakers, events from talk headers (pages + sessions.json)
    th = sql_json(f"""select json_build_object('id', n.id, 'attrs', n.attributes, 'key', d.attributes->>'key', 'doc', d.id, 'text', n.inline_text, 'version_id', v.id) from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                      where n.tenant_id={q(TENANT)} and n.unit_kind='talk_header'""")
    speakers_meta = {}
    for u in sql_json(f"select json_build_object('attrs', attributes) from content.document_node where tenant_id={q(TENANT)} and unit_kind='metadata_field' and attributes->>'key'='speaker'"):
        val = u["attrs"]["value"]
        speakers_meta[val["name"]] = val
    for u in th:
        a = u["attrs"]
        ev_name = a.get("event")
        ev_id = events.get(ev_name)
        if ev_name and not ev_id:
            year = re.search(r"(20\d\d)", ev_name)
            ev_id = ensure_entity("industry_event", slugify(ev_name), ev_name, {"edition_label": year.group(1) if year else None})
            events[ev_name] = ev_id
            b.add(f"select temporal.assert_relationship('edition_of', {q(ev_id)}, {q(series)});")
            b.add(f"select temporal.assert_relationship('organized_by', {q(ev_id)}, {q(orgs['ai-engineer'])});")
        tslug = slugify((a.get("session_id") or "") + "-" + (a.get("title") or ""))[:80]
        talk_id = ensure_entity("talk", tslug, a.get("title") or "untitled talk", {"talk_kind": "talk", "track": a.get("track"), "video_url": a.get("video_url"), "session_id": a.get("session_id"), "edition": ev_name}, identifiers=([("youtube_video_id", a["session_id"])] if a.get("video_url") else []))
        ensure_work(talk_id, "talk", a.get("title") or "untitled talk", canonical_url=a.get("video_url"), venue=ev_id, attributes={"track": a.get("track"), "day": a.get("day"), "time": a.get("time"), "room": a.get("room")})
        if not one(f"select 1 from content.document where id={q(u['doc'])} and work_entity_id is not null") and u["key"].startswith("talk-"):
            sql(f"update content.document set work_entity_id={q(talk_id)} where id={q(u['doc'])}", allow_error=True)
        if ev_id:
            b.add(f"select temporal.assert_relationship('presented_at', {q(talk_id)}, {q(ev_id)});")
        if a.get("track") in TRACK_CONCEPT:
            b.add(f"select temporal.assert_relationship('about', {q(talk_id)}, {q(concepts[TRACK_CONCEPT[a['track']]])});")
        for sp in a.get("speakers") or []:
            pid = ensure_entity("person", slugify(sp), sp, {"affiliation_text": (speakers_meta.get(sp) or {}).get("company") or a.get("affiliation"), "title": (speakers_meta.get(sp) or {}).get("role"), "profile_url": (speakers_meta.get(sp) or {}).get("linkedin")})
            b.add(f"select temporal.assert_relationship('presented_by', {q(talk_id)}, {q(pid)});")
            comp = (speakers_meta.get(sp) or {}).get("company") or a.get("affiliation")
            if comp:
                oid = ensure_entity("organization", slugify(comp), comp, {"org_kind": "other"})
                when = a.get("event") and re.search(r"(20\d\d)", a["event"])
                start = f"{when.group(1)}-01-01" if when else "2025-01-01"
                b.add(f"select temporal.assert_relationship('employed_by', {q(pid)}, {q(oid)}, tstzrange({q(start)}, null, '[)'), p_extent => temporal.make_extent({q('as of the talk edition ' + start[:4])}, 'year'));")
            if u['id'] not in done_nodes: add_role(u['id'], pid, 'speaker', 'mapping', 1.0)
        if ev_id:
            if u['id'] not in done_nodes: add_role(u['id'], ev_id, 'event', 'mapping', 1.0)
        # resources of this talk page -> has_code / cites
        for ru in sql_json(f"select json_build_object('id', id, 'attrs', attributes) from content.document_node where tenant_id={q(TENANT)} and unit_kind='talk_resource' and representation_id=(select representation_id from content.document_node where id={q(u['id'])})"):
            href = ru["attrs"]["href"]
            if ru["attrs"].get("resource_kind") == "repository":
                m = re.search(r"github\.com/([^/]+)/([^/#?]+)", href)
                if m:
                    full = f"{m.group(1)}/{m.group(2)}"
                    rep = ensure_entity("repository", slugify(full), full, {"host": "github.com", "owner": m.group(1), "name": m.group(2)}, identifiers=[("github_full_name", full)])
                    b.add(f"select temporal.assert_relationship('has_code', {q(talk_id)}, {q(rep)});")
                    add_role(ru['id'], rep, 'references', 'mapping', 1.0)
            elif ru["attrs"].get("resource_kind") == "paper":
                pid2 = ensure_entity("paper", slugify(ru["attrs"].get("text") or href)[:60], ru["attrs"].get("text") or href, {"arxiv_id": (re.search(r"arxiv\.org/abs/([\d.]+)", href) or [None, None])[1]})
                ensure_work(pid2, "paper", ru["attrs"].get("text") or href, canonical_url=href)
                b.add(f"select temporal.assert_relationship('about', {q(talk_id)}, {q(pid2)});")
                add_role(ru['id'], pid2, 'references', 'mapping', 1.0)
    # docs/readme sections -> software role; code examples -> software
    for u in sql_json(f"""select json_build_object('id', n.id, 'software', d.attributes->>'software', 'kind', n.unit_kind) from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                          where n.tenant_id={q(TENANT)} and n.unit_kind in ('docs_section','readme_section','code_example','change_item','metadata_field') and d.attributes->>'software' is not null"""):
        lib, rep = software[u["software"]]
        if u['id'] not in done_nodes: add_role(u['id'], lib, 'software', 'mapping', 0.9)
    b.add(f"select temporal.assert_relationship('about', {q(ensure_entity('library','langgraph','LangGraph'))}, {q(concepts['durable-execution'])});") if False else None
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(software['langgraph'][0])}, {q(concepts['durable-execution'])});")
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(software['langgraph'][0])}, {q(concepts['checkpointing'])});")
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(software['mcp-python-sdk'][0])}, {q(concepts['mcp'])});")
    b.add(f"select temporal.assert_relationship('instance_of_concept', {q(software['openai-agents-python'][0])}, {q(concepts['tool-use'])});")
    flush_roles()
    out = b.commit()
    log(f"entities committed (knowledge_seq {out.splitlines()[-1] if out else '-'}); entities={one(f'select count(*) from catalog.entity')} relationships={one('select count(*) from catalog.relationship')}")
    write_json(os.path.join(RUN_DIR, "entities-summary.json"), {"by_kind": dict(sql_rows(f"select kind, count(*) from catalog.entity where tenant_id={q(TENANT)} group by kind order by 1")), "relationships": dict(sql_rows("select kind, count(*) from catalog.relationship group by kind order by 1"))})


# ------------------------------------------------------------------ stage E facts: cheap path for first-party structured units
def locator_for(v, node, selector_kind="table"):
    """evidence.locator anchored on the capture of the version; one per node."""
    lid = one(f"select id from evidence.locator where tenant_id={q(TENANT)} and capture_id={q(v['capture_id'])} and selector->>'node_id'={q(node['id'])}")
    if lid:
        return lid
    lid = str(uuid.uuid4())
    sel = dict(node["selector"] or {})
    sel["node_id"] = node["id"]
    sel["logical_key"] = node["logical_key"]
    media = {"markdown": "text/markdown", "html": "text/html", "json": "application/json", "unknown": "text/calendar"}[v["format"]]
    sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params, start_ms, end_ms)
            values ({q(lid)}, {q(TENANT)}, {q(v['capture_id'])}, {q(media)}, {q(sel)}, {q(selector_kind)}, {q(sha256_text(node['text'] or ''))}, {q((node['text'] or '')[:500])}, 'build08-grammar', '1', {q({'unit_kind': node['unit_kind']})}, {q(node.get('start_ms'))}, {q(node.get('end_ms'))})""")
    return lid


def extraction_run_for(v):
    rid = one(f"select id from evidence.extraction_run where tenant_id={q(TENANT)} and representation_id={q(v['representation_id'])} and extractor_identity='build08-grammar'")
    if rid:
        return rid
    rid = str(uuid.uuid4())
    sql(f"""insert into evidence.extraction_run(id, tenant_id, representation_id, extractor_identity, extractor_version, parameters, input_digest)
            values ({q(rid)}, {q(TENANT)}, {q(v['representation_id'])}, 'build08-grammar', '1', {q({'grammar': 'build08-grammar/1', 'path': 'deterministic mapping'})}, {q(v['sha'])})""")
    return rid


def make_claim(rcpt, statement, claim_type, structured, subject_ids, locator_id, run_id, node, mapping_id, status="proposed", confidence=1.0):
    cid = one(f"select id from evidence.claim where tenant_id={q(TENANT)} and statement={q(statement)}")
    if cid:
        return cid
    cid = str(uuid.uuid4())
    sql(f"""insert into evidence.claim(id, tenant_id, claim_type, statement, structured, status, composite, producer_origin_digest, created_by_receipt_id)
            values ({q(cid)}, {q(TENANT)}, {q(claim_type)}, {q(statement)}, {q(structured)}, {q(status)}, false, {q('sha256:' + sha256_text('build08-loop1:' + statement))}, {q(rcpt)});
            insert into evidence.extraction_record(tenant_id, extraction_run_id, record_kind, payload, locator_id, claim_id, confidence, document_node_id, mapping_id)
            values ({q(TENANT)}, {q(run_id)}, {q(node['unit_kind'])}, {q(node['attributes'])}, {q(locator_id)}, {q(cid)}, {confidence}, {q(node['id'])}, {q(mapping_id)});
            insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role) values ({q(TENANT)}, {q(cid)}, {q(locator_id)}, 'supports') on conflict do nothing;""")
    for sid, role in subject_ids:
        sql(f"insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role) values ({q(TENANT)}, {q(cid)}, {q(sid)}, {q(role)}) on conflict do nothing", allow_error=True)
    return cid


def nodes_of(v, kinds):
    return sql_json(f"""select json_build_object('id', n.id, 'unit_kind', n.unit_kind, 'attributes', n.attributes, 'logical_key', n.logical_key, 'text', n.inline_text, 'selector', n.selector, 'start_ms', n.start_ms, 'end_ms', n.end_ms, 'stable_local_key', n.stable_local_key)
                        from content.document_node n where n.representation_id={q(v['representation_id'])} and n.unit_kind = any({qarr(kinds)}) order by n.ordinal""")


def role_entity(node_id, role):
    return one(f"select entity_id from content.unit_entity_role where node_id={q(node_id)} and role={q(role)} limit 1")


def mapping_id(unit_kind, doc_type, target_kind, stream=None, event=None, rel=None):
    return one(f"select id from content.unit_assertion_mapping where unit_kind={q(unit_kind)} and (document_type_code={q(doc_type)} or document_type_code is null) and target_kind={q(target_kind)} and stream_kind is not distinct from {q(stream)} and event_kind is not distinct from {q(event)} and relationship_kind is not distinct from {q(rel)} order by document_type_code nulls last limit 1")


def stage_facts(vs):
    """Per first-party version: price rows -> offering_price segments; spec fields -> model streams; release entries -> events; repo records -> counts."""
    by_doc = collections.defaultdict(list)
    for v in vs:
        by_doc[v["key"]].append(v)
    for key, versions_ in by_doc.items():
        versions_.sort(key=lambda x: x["captured_at"])
        prev_rows = {}
        for v in versions_:
            if one(f"select 1 from temporal.knowledge_batch where summary->>'label' = {q('facts-' + key + '-' + v['label'])}"):
                # already admitted; rebuild prev_rows for the diff of the next capture
                for n in nodes_of(v, ["price_row"]):
                    prev_rows[n["logical_key"]] = n["attributes"].get("amount")
                continue
            b = Batch(f"facts-{key}-{v['label']}", {"document": key, "version": v["label"]})
            run_id = extraction_run_for(v)
            rcpt = native_receipt(f"claims-{key}-{v['label']}", {"document": key})
            captured = v["captured_at"]
            n_price = n_spec = n_rel = n_meta = 0
            seen_slots = {}
            ambiguous = []
            if v["kind"] in ("pricing_page", "product_page") and v["role"] == "first_party":
                mid = mapping_id("price_row", v["kind"], "stream", stream="offering_price")
                for n in nodes_of(v, ["price_row"]):
                    a = n["attributes"]
                    off = role_entity(n["id"], "offering")
                    if not off or a.get("amount") is None:
                        continue
                    if n["logical_key"] in prev_rows and prev_rows[n["logical_key"]] == a["amount"]:
                        continue  # unchanged since the prior capture: the prior segment stays current
                    scope = f"{a['meter']}|{a.get('tier') or 'standard'}|{a.get('context_band') or ''}|{a.get('condition') or ''}"
                    slot = (off, scope)
                    if slot in seen_slots:
                        if seen_slots[slot] != a["amount"]:
                            ambiguous.append((n["logical_key"], seen_slots[slot], a["amount"]))  # same offering+slot, different value in one capture: kept out of facts, reported
                        continue
                    seen_slots[slot] = a["amount"]
                    loc = locator_for(v, n, "table" if (n["selector"] or {}).get("kind") == "table" else "text_quote")
                    statement = f"{a['offering']} {a['meter'].replace('_', ' ')} ({a.get('tier') or 'standard'}{', ' + a['context_band'] + ' context' if a.get('context_band') else ''}{', ' + a['condition'] if a.get('condition') else ''}) costs {a['currency']} {a['amount']} {a['unit'].replace('USD_', '').replace('_', ' ')} as stated by the vendor on {captured[:10]}"
                    cid = make_claim(rcpt, statement, "measurement", {"subject": off, "meter": a["meter"], "amount": a["amount"], "currency": a["currency"], "unit": a["unit"], "tier": a.get("tier"), "context_band": a.get("context_band"), "condition": a.get("condition"), "path": "deterministic_first_party", "act": 3}, [(off, "subject")], loc, run_id, n, mid)
                    b.add(f"""with s as (select temporal.assert_state({q(off)}, 'offering_price', tstzrange({q(captured)}, null, '[)'), {q(scope)}, null, {a['amount']}, 'USD', {q(a['unit'])}, null, {q({k: v for k, v in {'meter': a['meter'], 'tier': a.get('tier') or 'standard', 'context_band': a.get('context_band'), 'condition': a.get('condition'), 'source_role': 'first_party'}.items() if v is not None})}, null, {q(cid)}, 'observation_bounded') id)
                             insert into evidence.segment_support(tenant_id, segment_id, claim_id, locator_id, role, k_from) select {q(TENANT)}, s.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from s on conflict do nothing;""")
                    n_price += 1
                    prev_rows[n["logical_key"]] = a["amount"]
                for n in nodes_of(v, ["spec_field"]):
                    a = n["attributes"]
                    model = role_entity(n["id"], "model")
                    if not model:
                        continue
                    f = a.get("field")
                    loc = locator_for(v, n, "text_quote")
                    statement = f"{n['text'][:200]} (stated on the vendor page captured {captured[:10]})"
                    if f in ("context_window", "max_output_tokens") and isinstance(a.get("value"), int):
                        sk = "model_context_window" if f == "context_window" else "model_max_output_tokens"
                        cid = make_claim(rcpt, statement, "capability", {"subject": model, "field": f, "value": a["value"], "path": "deterministic_first_party"}, [(model, "subject")], loc, run_id, n, mapping_id("spec_field", "product_page", "stream", stream=sk))
                        b.add(f"""with s as (select temporal.assert_state({q(model)}, {q(sk)}, tstzrange({q(captured)}, null, '[)'), '', null, {a['value']}, null, 'tokens', null, '{{}}'::jsonb, null, {q(cid)}, 'observation_bounded') id)
                                 insert into evidence.segment_support(tenant_id, segment_id, claim_id, locator_id, role, k_from) select {q(TENANT)}, s.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from s on conflict do nothing;""")
                        n_spec += 1
                    elif f == "knowledge_cutoff" and a.get("value"):
                        cid = make_claim(rcpt, statement, "capability", {"subject": model, "field": f, "value": a["value"]}, [(model, "subject")], loc, run_id, n, mapping_id("spec_field", "product_page", "stream", stream="model_knowledge_cutoff"))
                        b.add(f"""with s as (select temporal.assert_state({q(model)}, 'model_knowledge_cutoff', tstzrange({q(captured)}, null, '[)'), '', null, null, null, null, null, {q({'cutoff_on': str(a['value'])})}, null, {q(cid)}, 'observation_bounded') id)
                                 insert into evidence.segment_support(tenant_id, segment_id, claim_id, locator_id, role, k_from) select {q(TENANT)}, s.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from s on conflict do nothing;""")
                        n_spec += 1
                    elif f in ("tool_use", "reasoning") or (f == "input_modalities" and isinstance(a.get("value"), list)):
                        caps = {f: "supported"} if f in ("tool_use", "reasoning") else {"vision": "supported" if any("image" in x for x in a["value"]) else "unsupported", "audio": "supported" if any("audio" in x for x in a["value"]) else "unsupported"}
                        for cap, status in caps.items():
                            cid = make_claim(rcpt, f"{statement} [{cap}={status}]", "capability", {"subject": model, "capability": cap, "status": status}, [(model, "subject")], loc, run_id, n, mapping_id("spec_field", "product_page", "stream", stream="model_capability"))
                            b.add(f"""with s as (select temporal.assert_state({q(model)}, 'model_capability', tstzrange({q(captured)}, null, '[)'), {q(cap)}, {q(status)}, null, null, null, null, '{{}}'::jsonb, null, {q(cid)}, 'observation_bounded') id)
                                     insert into evidence.segment_support(tenant_id, segment_id, claim_id, locator_id, role, k_from) select {q(TENANT)}, s.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from s on conflict do nothing;""")
                            n_spec += 1
                        if f == "input_modalities":
                            sql(f"update catalog.entity set attributes = attributes || {q({'modalities': a['value']})} where id={q(model)}")
            if v["kind"] in ("github_release", "release_notes"):
                mid = mapping_id("release_entry", v["kind"], "event", event="release_published")
                for n in nodes_of(v, ["release_entry"]):
                    a = n["attributes"]
                    rel = role_entity(n["id"], "release")
                    if not rel or not a.get("released_on"):
                        continue
                    loc = locator_for(v, n, "json_pointer" if v["format"] == "json" else "text_quote")
                    statement = f"{a.get('title') or a['version']} ({a['version']}) was published on {a['released_on']}{' with breaking changes' if a.get('breaking') else ''}"
                    cid = make_claim(rcpt, statement, "event", {"subject": rel, "version": a["version"], "released_on": a["released_on"], "breaking": a.get("breaking"), "url": a.get("url")}, [(rel, "subject")], loc, run_id, n, mid)
                    highlights = [c["text"][:160] for c in sql_json(f"select json_build_object('text', inline_text) from content.document_node where parent_id={q(n['id'])} and unit_kind='change_item' order by ordinal limit 6")]
                    sql(f"update catalog.entity set attributes = attributes || {q({'highlights': highlights})} where id={q(rel)}")
                    b.add(f"""with e as (select temporal.assert_event('release_published', {q(rel)}, tstzrange({q(a['released_on'])}, ({q(a['released_on'])})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q(a['version'])}, null, {q(cid)}, {q({'version': a['version'], 'breaking': bool(a.get('breaking')), 'url': a.get('url'), 'highlights': highlights, 'prerelease': a.get('prerelease')})}) id)
                             insert into evidence.segment_support(tenant_id, event_occurrence_id, claim_id, locator_id, role, k_from) select {q(TENANT)}, e.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from e on conflict do nothing;""")
                    n_rel += 1
            if v["kind"] == "registry_listing_page":
                rep = one(f"select e.id from catalog.entity e where e.kind='repository' and e.slug={q(slugify(SOFTWARE[v['attrs']['software']][2]))}")
                for n in nodes_of(v, ["metadata_field"]):
                    a = n["attributes"]
                    sk = {"stargazers_count": "repository_stars", "forks_count": "repository_forks", "open_issues_count": "repository_open_issues"}.get(a.get("key"))
                    if a.get("key") == "license_spdx" and rep:
                        loc = locator_for(v, n, "json_pointer")
                        cid = make_claim(rcpt, f"{v['attrs']['software']} repository license is {a['value']} (GitHub API record {captured[:10]})", "attribute", {"subject": rep, "spdx": a["value"]}, [(rep, "subject")], loc, run_id, n, None)
                        b.add(f"select temporal.assert_state({q(rep)}, 'library_license', tstzrange({q(captured)}, null, '[)'), '', null, null, null, null, null, {q({'license_code': a['value'], 'spdx': a['value']})}, null, {q(cid)}, 'observation_bounded');")
                        n_meta += 1
                    if sk and rep:
                        loc = locator_for(v, n, "json_pointer")
                        cid = make_claim(rcpt, f"{v['attrs']['software']} repository {a['key']} = {a['value']} on {captured[:10]} (GitHub API)", "measurement", {"subject": rep, "field": a["key"], "value": a["value"]}, [(rep, "subject")], loc, run_id, n, None)
                        b.add(f"select temporal.assert_state({q(rep)}, {q(sk)}, tstzrange({q(captured)}, null, '[)'), '', null, {a['value']}, null, 'count', null, '{{}}'::jsonb, null, {q(cid)}, 'observation_bounded');")
                        n_meta += 1
            out = b.commit()
            if ambiguous:
                append_jsonl(os.path.join(RUN_DIR, "ambiguous-price-rows.jsonl"), {"document": key, "version": v["label"], "rows": ambiguous})
            if out:
                log(f"facts {key} {v['label']}: price={n_price} spec={n_spec} releases={n_rel} meta={n_meta} ambiguous_rows={len(ambiguous)} -> knowledge_seq {out.splitlines()[-1]}")


# ------------------------------------------------------------------ stage F claim candidates (L1 path) and the conflict case
def stage_claims(vs):
    rcpt = native_receipt("claim-candidates", {"stage": "claims"})
    n_c = n_conf = 0
    models = {r[0].lower(): r[1] for r in sql_rows(f"select display_name, id from catalog.entity where kind='ai_model_version' and tenant_id={q(TENANT)}")}
    aliases = {r[0].lower(): r[1] for r in sql_rows(f"select a.alias, a.entity_id from catalog.entity_alias a join catalog.entity e on e.id=a.entity_id where e.kind='ai_model_version'")}
    for v in vs:
        if v["kind"] not in ("official_blog_post", "news_article", "analysis_post", "aie_talk", "framework_docs_page") or v["format"] == "json":
            continue
        run_id = extraction_run_for(v)
        if v["kind"] in ("official_blog_post", "news_article", "analysis_post"):
            mid = mapping_id("post_paragraph", None, "claim_candidate")
            for n in nodes_of(v, ["post_paragraph"]):
                a = n["attributes"]
                if not a.get("price_mentions"):
                    continue
                loc = locator_for(v, n, "text_quote")
                for pm in a["price_mentions"]:
                    subject = None
                    cands = []
                    for mname in pm.get("models") or a.get("model_mentions") or []:
                        key = mname.lower().replace("gpt-6.1sol", "gpt-6.1 sol")
                        eid = models.get(key) or aliases.get(key) or aliases.get(key.replace(" ", "-"))
                        if eid:
                            cands.append(eid)
                    if len(set(cands)) == 1:
                        subject = cands[0]
                    statement = f"{v['attrs'].get('publisher')} states: {n['text'][:220]} [{pm['meter']} ${pm['amount']}]"
                    structured = {"amount": pm["amount"], "meter": pm["meter"], "currency": "USD", "unit": "USD_per_1M_tokens", "subject_candidates": sorted(set(cands)), "subject_resolved": subject is not None, "source_role": v["role"], "path": "L1_candidate", "act": 3, "learned_at": captured_of(v)}
                    # compare with the first-party current price of the resolved subject's offerings before writing (claims are append-only)
                    fp = None
                    if subject:
                        fp = sql_rows(f"""select s.amount, s.primary_claim_id from temporal.segment s join temporal.stream st on st.id=s.stream_id
                                          where st.kind='offering_price' and st.subject_entity_id in (select api.related({q(subject)}, 'offered_as', 'outgoing')) and s.payload->>'meter'={q(pm['meter'])} and coalesce(s.payload->>'tier','standard')='standard' and coalesce(s.payload->>'context_band','short') in ('short','') and s.k_to is null and s.valid_during @> now() limit 1""")
                        if fp and fp[0][0] and abs(float(fp[0][0]) - float(pm["amount"])) <= 1e-9:
                            structured["agrees_with_first_party_claim"] = fp[0][1]
                    cid = make_claim(rcpt, statement, "measurement", structured, [(subject, "subject")] if subject else [], loc, run_id, n, mid, confidence=0.6 if subject else 0.3)
                    n_c += 1
                    if fp and fp[0][0] and abs(float(fp[0][0]) - float(pm["amount"])) > 1e-9 and not one(f"select 1 from evidence.claim_conflict where claim_b_id={q(cid)}"):
                        sql(f"insert into evidence.claim_conflict(claim_a_id, claim_b_id, conflict_kind, detected_by) values ({q(fp[0][1])}, {q(cid)}, 'measurement', 'build08-loop1 deterministic compare (first-party segment vs restatement): value disagreement')")
                        n_conf += 1
        if v["kind"] == "aie_talk":
            mid_w = mapping_id("talk_writeup", "aie_talk", "claim_candidate")
            talk = one(f"select work_entity_id from content.document where id={q(v['document_id'])}")
            speakers = [r[0] for r in sql_rows(f"select e.display_name from catalog.relationship r join catalog.entity e on e.id=r.to_entity_id where r.kind='presented_by' and r.from_entity_id={q(talk)}")] if talk else []
            for n in nodes_of(v, ["talk_writeup"]):
                a = n["attributes"]
                loc = locator_for(v, n, "text_quote")
                statement = f"{', '.join(speakers) or 'The talk'} ({v['title']}) frames: {a.get('heading')}"
                cid = make_claim(rcpt, statement, "recommendation", {"subject": talk, "speakers": speakers, "heading": a.get("heading"), "t0_ms": a.get("t0_ms"), "path": "L1_candidate", "attribution": "talk write-up heading; speaker attribution is to the listed presenters (no speaker labels in the transcript)", "act": 3}, [(talk, "subject")] if talk else [], loc, run_id, n, mid_w, confidence=0.5)
                n_c += 1
    log(f"claim candidates: {n_c}, conflicts kept: {n_conf}")
    # the search-result excerpt of the blocked community post: recorded as a candidate with an ambiguous subject (not a capture of the page)
    if not one("select 1 from evidence.claim where statement like 'reddit r/OpenAI (search excerpt) states:%'"):
        sol = models.get("gpt-6.1 sol")
        sql(f"""insert into evidence.claim(tenant_id, claim_type, statement, structured, status, composite, producer_origin_digest, created_by_receipt_id)
                values ({q(TENANT)}, 'measurement', 'reddit r/OpenAI (search excerpt) states: New Sol API pricing - $4 per million input tokens and $20 per million output tokens',
                {q({'amount_input': 4, 'amount_output': 20, 'currency': 'USD', 'unit': 'USD_per_1M_tokens', 'subject_candidates': [models.get('gpt-6.1 sol'), models.get('gpt-6 sol'), models.get('gpt-5.6 sol')], 'subject_resolved': False, 'source_role': 'community', 'path': 'L1_candidate', 'provenance': 'firecrawl_search excerpt 2026-11-09; page fetch 403 and not scrapeable; no capture, no locator', 'act': 3})},
                'disputed', false, {q('sha256:' + sha256_text('reddit-sol-excerpt'))}, {q(rcpt)})""")
        if sol:
            fp = one(f"select s.primary_claim_id from temporal.segment s join temporal.stream st on st.id=s.stream_id where st.kind='offering_price' and st.subject_entity_id in (select api.related({q(sol)}, 'offered_as', 'outgoing')) and s.payload->>'meter'='input_tokens' and coalesce(s.payload->>'tier','standard')='standard' and s.k_to is null and s.valid_during @> now() limit 1")
            cid = one("select id from evidence.claim where statement like 'reddit r/OpenAI (search excerpt) states:%'")
            if fp:
                sql(f"insert into evidence.claim_conflict(claim_a_id, claim_b_id, conflict_kind, detected_by) values ({q(fp)}, {q(cid)}, 'scope_mismatch', 'build08-loop1: subject ambiguous, value disagreement; Sol is ambiguous (GPT-6.1 Sol $2 vs GPT-5.6 Sol $4); kept disputed, no reconciliation')")
                log("recorded the ambiguous-subject community conflict (kept disputed)")


def captured_of(v):
    return v["captured_at"]


# ------------------------------------------------------------------ stage G digests (deterministic, anchored)
def stage_digests(vs):
    n = 0
    for v in vs:
        if one(f"select 1 from content.document_digest where document_version_id={q(v['version_id'])}"):
            continue
        gid = str(uuid.uuid4())
        sql(f"insert into content.document_digest(id, tenant_id, document_version_id, scope, digest_schema_version, producer_identity, producer_kind, lifecycle) values ({q(gid)}, {q(TENANT)}, {q(v['version_id'])}, 'document', 'aieng.digest.v1', 'build08-digest/1 (deterministic)', 'deterministic', 'active')")
        items = []
        secs = nodes_of(v, ["section"])
        for s in [x for x in secs if x["attributes"].get("level", 9) <= 2][:8]:
            first = (s["text"].split("\n", 1) + [""])[1].strip().split("\n")[0][:300]
            items.append(("key_point", f"{s['attributes']['heading']}: {first}" if first else s["attributes"]["heading"], {"heading": s["attributes"]["heading"]}, [s["id"]], None, None, None))
        for r in sql_rows(f"""select r.entity_id, e.display_name, r.role, count(*), min(r.node_id::text) from content.unit_entity_role r join content.document_node n on n.id=r.node_id join catalog.entity e on e.id=r.entity_id where n.representation_id={q(v['representation_id'])} group by 1,2,3 order by 4 desc limit 12"""):
            items.append(("entity_role", f"{r[1]} appears as {r[2]} in {r[3]} units", {"role": r[2], "units": int(r[3])}, [r[4]], r[0], None, None))
        for r in sql_rows(f"""select c.id, c.statement, x.document_node_id from evidence.claim c join evidence.extraction_record x on x.claim_id=c.id join content.document_node n on n.id=x.document_node_id where n.representation_id={q(v['representation_id'])} order by n.ordinal limit 15"""):
            items.append(("assertion_ref", r[1][:300], {"path": "see claim.structured.path"}, [r[2]], None, r[0], None))
        for r in sql_rows(f"""select id, change_kind, logical_key, changed_attributes::text, coalesce(to_node_id, from_node_id)::text from content.unit_change where to_version_id={q(v['version_id'])} order by detected_at limit 20"""):
            items.append(("change", f"{r[1]}: {r[2]} {r[3][:200]}", {"change_kind": r[1], "logical_key": r[2]}, [r[4]], None, None, r[0]))
        if v["kind"] == "aie_talk" and v["format"] == "markdown":
            for s in nodes_of(v, ["talk_writeup"])[:6]:
                items.append(("research_direction", f"Direction framed by the speaker(s): {s['attributes'].get('heading')} (claim candidate, not a fact)", {"t0_ms": s["attributes"].get("t0_ms")}, [s["id"]], None, None, None))
            items.append(("limitation", "The ai.engineer transcript has no speaker labels; statements are attributed to the talk's listed presenters, never to an individual turn.", {}, [], None, None, None))
        if v["kind"] == "unclassified":
            items.append(("open_question", "Kind unclassified: census shows machine blocks (iCal VEVENT); promotion candidate for a calendar_feed kind once it recurs across sources.", {}, [], None, None, None))
        for i, (kind, text, payload, nodes, ent, claim, chg) in enumerate(items):
            sql(f"insert into content.digest_item(tenant_id, digest_id, ordinal, item_kind, text, payload, node_ids, entity_id, claim_id, unit_change_id, confidence) values ({q(TENANT)}, {q(gid)}, {i}, {q(kind)}, {q(text)}, {q(payload)}, {qarr(nodes, 'uuid')}, {q(ent)}, {q(claim)}, {q(chg)}, 1.0)")
        n += len(items)
    log(f"digest items written: {n}")


# ------------------------------------------------------------------ stage H diff (unit-level, by logical key) between the two captures of a document
def stage_diff(vs):
    by_doc = collections.defaultdict(list)
    for v in vs:
        by_doc[v["key"]].append(v)
    total = 0
    for key, versions_ in by_doc.items():
        if len(versions_) < 2:
            continue
        versions_.sort(key=lambda x: x["captured_at"])
        old, new = versions_[-2], versions_[-1]
        if one(f"select 1 from content.unit_change where to_version_id={q(new['version_id'])} limit 1"):
            continue
        rc = one(f"select id from content.refresh_check where new_version_id={q(new['version_id'])}")
        a = {n["logical_key"]: n for n in nodes_of(old, ["price_row", "section", "spec_field", "release_entry"]) if n["logical_key"]}
        b2 = {n["logical_key"]: n for n in nodes_of(new, ["price_row", "section", "spec_field", "release_entry"]) if n["logical_key"]}
        changes = []
        for lk, n in b2.items():
            if lk not in a:
                changes.append(("added", lk, n["unit_kind"], None, n["id"], {"to": n["attributes"]}))
            else:
                o = a[lk]
                if n["unit_kind"] == "price_row" and o["attributes"].get("amount") != n["attributes"].get("amount"):
                    changes.append(("attribute_changed", lk, n["unit_kind"], o["id"], n["id"], {"amount": {"from": o["attributes"].get("amount"), "to": n["attributes"].get("amount")}}))
                elif n["unit_kind"] != "price_row" and sha256_text(o["text"] or "") != sha256_text(n["text"] or ""):
                    changes.append(("text_changed", lk, n["unit_kind"], o["id"], n["id"], {"text_sha_from": sha256_text(o["text"] or "")[:12], "text_sha_to": sha256_text(n["text"] or "")[:12]}))
        for lk, o in a.items():
            if lk not in b2:
                changes.append(("removed", lk, o["unit_kind"], o["id"], None, {"from": o["attributes"]}))
        for kind, lk, uk, fn, tn, changed in changes:
            sql(f"insert into content.unit_change(tenant_id, document_id, logical_key, unit_kind, from_version_id, to_version_id, from_node_id, to_node_id, change_kind, changed_attributes, refresh_check_id, update_proposal_state) values ({q(TENANT)}, {q(new['document_id'])}, {q(lk)}, {q(uk)}, {q(old['version_id'])}, {q(new['version_id'])}, {q(fn)}, {q(tn)}, {q(kind)}, {q(changed)}, {q(rc)}, {q('applied' if kind == 'attribute_changed' and uk == 'price_row' else 'none')})")
        total += len(changes)
        c = collections.Counter(x[0] for x in changes)
        log(f"diff {key}: {dict(c)} (units old={len(a)} new={len(b2)})")
    log(f"unit changes: {total}")


# ------------------------------------------------------------------ stage I projections: units, digests, entity cards, assertions -> both layouts
TIER_BY_ROLE = {"first_party": 2, "filer": 2, "academic": 2, "event_organizer": 2, "registry": 2, "third_party_editorial": 3, "community": 3, "own": 1, "system": 1, "unknown": 3}
EMBED_KINDS = {"section", "plan_section", "price_row", "release_entry", "spec_field", "talk_writeup", "transcript_segment", "slide", "docs_section", "code_example", "readme_section", "post_paragraph", "talk_header", "model_card_section", "eval_row", "change_item"}


def index_item(space, target_kind, target_id, text, lens, tier, content_kind, **kw):
    args = {"p_entity_id": kw.get("entity_id"), "p_secondary_entity_ids": kw.get("secondary") or [], "p_document_type_code": kw.get("document_type_code"), "p_unit_kind": kw.get("unit_kind"), "p_document_id": kw.get("document_id"), "p_document_version_id": kw.get("document_version_id"),
            "p_source_role_code": kw.get("source_role_code"), "p_valid_during": kw.get("valid_during"), "p_knowledge_seq": kw.get("knowledge_seq"), "p_workspace_id": None, "p_language": "en", "p_observed_at": kw.get("observed_at"), "p_start_ms": kw.get("start_ms"), "p_end_ms": kw.get("end_ms"), "p_contextual_prefix": kw.get("prefix") or "", "p_assurance_rank": kw.get("assurance_rank")}
    named = ", ".join(f"{k} => {qarr(v, 'uuid') if k == 'p_secondary_entity_ids' else (q(v) + '::smallint' if k == 'p_assurance_rank' and v is not None else q(v))}" for k, v in args.items() if v is not None and v != [] and v != "")
    return one(f"select retrieval.index_text_item({q(space)}, {q(target_kind)}, {q(target_id)}, {q(text)}, {q(lens)}, {q(tier) + '::smallint' if tier is not None else 'null'}, {q(content_kind)}{', ' + named if named else ''})")


def stage_projections(vs):
    counts = collections.Counter()
    for v in vs:
        tier = TIER_BY_ROLE.get(v["role"], 3)
        prefix = f"[{v['kind']} | {v['title']} | {v['captured_at'][:10]}] "
        for n in nodes_of(v, sorted(EMBED_KINDS)):
            text = (n["text"] or "").strip()
            if len(text) < 12 and n["unit_kind"] not in ("price_row", "spec_field"):
                continue
            if n["unit_kind"] == "section" and v["kind"] in ("pricing_page", "aie_talk", "product_page", "github_release"):
                continue  # grammar units carry these documents; universal sections would duplicate
            ents = [r[0] for r in sql_rows(f"select entity_id from content.unit_entity_role where node_id={q(n['id'])}")]
            kw = dict(entity_id=ents[0] if ents else None, secondary=ents[1:], document_type_code=v["kind"], unit_kind=n["unit_kind"], document_id=v["document_id"], document_version_id=v["version_id"], source_role_code=v["role"], observed_at=v["captured_at"], start_ms=n.get("start_ms"), end_ms=n.get("end_ms"), prefix=prefix)
            for space in ("units", "knowledge_text"):
                index_item(space, "unit", n["id"], text[:6000], "corpus", tier, "unit", **kw)
            counts["units"] += 1
    for r in sql_json(f"""select json_build_object('id', i.id, 'text', i.text, 'kind', i.item_kind, 'entity', i.entity_id, 'claim', i.claim_id, 'version', g.document_version_id, 'doc', dv.document_id, 'kind_code', d.document_type_code, 'role', d.source_role_code, 'title', d.canonical_title)
                          from content.digest_item i join content.document_digest g on g.id=i.digest_id join content.document_version dv on dv.id=g.document_version_id join content.document d on d.id=dv.document_id where i.tenant_id={q(TENANT)} and i.text is not null"""):
        for space in ("digests", "knowledge_text"):
            index_item(space, "digest", one(f"select digest_id from content.digest_item where id={q(r['id'])}"), f"[{r['kind']} of {r['title']}] {r['text']}", "corpus", TIER_BY_ROLE.get(r["role"], 3), "digest", entity_id=r["entity"], document_type_code=r["kind_code"], document_id=r["doc"], document_version_id=r["version"], source_role_code=r["role"])
        counts["digest_items"] += 1
    for r in sql_json(f"""select json_build_object('id', e.id, 'kind', e.kind, 'name', e.display_name, 'attrs', e.attributes, 'summary', e.summary) from catalog.entity e where e.tenant_id={q(TENANT)} and e.lifecycle='active'"""):
        rels = sql_rows(f"select rk.code, x.display_name from catalog.relationship r join taxonomy.relationship_kind rk on rk.code=r.kind join catalog.entity x on x.id = case when r.from_entity_id={q(r['id'])} then r.to_entity_id else r.from_entity_id end where (r.from_entity_id={q(r['id'])} or r.to_entity_id={q(r['id'])}) and r.k_to is null limit 25")
        card = f"{r['name']} ({r['kind'].replace('_', ' ')}). " + "; ".join(f"{k.replace('_', ' ')}: {v}" for k, v in (r["attrs"] or {}).items() if v not in (None, "", [], {}))[:900] + (". Related: " + "; ".join(f"{a} {b}" for a, b in rels) if rels else "")
        for space in ("entity_cards", "knowledge_text"):
            index_item(space, "entity", r["id"], card[:4000], "corpus", 2, "profile", entity_id=r["id"])
        counts["entity_cards"] += 1
    for r in sql_json(f"""select json_build_object('id', c.id, 'statement', c.statement, 'structured', c.structured, 'status', c.status::text, 'subject', (select entity_id from evidence.claim_subject s where s.claim_id=c.id limit 1)) from evidence.claim c where c.tenant_id={q(TENANT)}"""):
        role = (r["structured"] or {}).get("source_role", "first_party")
        tier = 0 if r["status"] == "verified" else TIER_BY_ROLE.get(role, 2)
        index_item("assertions", "claim", r["id"], f"[{r['status']} claim] {r['statement']}", "evidence", tier, "claim", entity_id=r["subject"], assurance_rank=10 if r["status"] == "proposed" else 20)
        index_item("knowledge_text", "claim", r["id"], f"[{r['status']} claim] {r['statement']}", "evidence", tier, "claim", entity_id=r["subject"], assurance_rank=10 if r["status"] == "proposed" else 20)
        counts["claims"] += 1
    log(f"projections: {dict(counts)}; vector items active = {one('select count(*) from retrieval.vector_item where lifecycle=' + q('active'))}")


# ------------------------------------------------------------------ stage J embeddings (both layouts; one call per batch)
def stage_embed():
    pending = [(r["id"], r["text"]) for r in sql_json(f"""select json_build_object('id', vi.id, 'text', vi.search_text) from retrieval.vector_item vi where vi.tenant_id={q(TENANT)} and vi.lifecycle='active' and vi.lens in ('corpus','evidence')
                           and not exists (select 1 from retrieval.vector_item_embedding_1536 e where e.vector_item_id = vi.id) order by vi.created_at""")]
    log(f"embedding {len(pending)} items")
    for i in range(0, len(pending), 96):
        chunk = pending[i:i + 96]
        vecs = embed_texts([c[1] for c in chunk])
        stmts = []
        for (vid, txt), vec in zip(chunk, vecs):
            lit = vec_literal(vec)
            stmts.append(f"select retrieval.store_embedding({q(vid)}, {q(lit)}::extensions.halfvec(1536), {q(sha256_text(lit))});")
        sql("\n".join(stmts))
        if (i // 96) % 5 == 0:
            log(f"  embedded {min(i + 96, len(pending))}/{len(pending)} tokens={SPEND['openai_embedding_tokens']} usd={SPEND['openai_embedding_usd']:.4f}")
    write_json(os.path.join(RUN_DIR, "spend-process.json"), SPEND)
    log(f"embeddings done: tokens={SPEND['openai_embedding_tokens']} usd={SPEND['openai_embedding_usd']:.4f}")


STAGES = {"census": stage_census, "units": stage_units, "entities": stage_entities, "facts": stage_facts, "claims": stage_claims, "digests": stage_digests, "diff": stage_diff, "projections": stage_projections}
ORDER = ["census", "units", "entities", "diff", "facts", "claims", "digests", "projections", "embed"]

if __name__ == "__main__":
    wanted = sys.argv[1:] or ORDER
    vs = versions()
    log(f"{len(vs)} versions with local files")
    for st in ORDER:
        if st not in wanted:
            continue
        if st == "embed":
            stage_embed()
        else:
            STAGES[st](vs)
