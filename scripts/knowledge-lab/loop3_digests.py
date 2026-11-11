"""Build 08 knowledge loop 3: model-written structured digests and unverified claim candidates (owner refinements 2a).

What the model writes, code checks:
- every digest item must cite unit ids that exist in the document (items without a valid anchor are dropped and counted);
- a claim candidate's quote must be found verbatim (whitespace-normalised) in one transcript segment, which fixes its timecode;
- a docs quote used in a comparison must be found verbatim in the docs section it is attributed to;
- every claim stays `proposed`; a mismatch is recorded as "appears inconsistent with" through evidence.claim_conflict, never as a verdict.
Model: claude-opus-5-5 through the Anthropic Python SDK; key ANTHROPIC_PRODUCER_API_KEY read by name; hard stop at MODEL_BUDGET_USD.

Stages: talks  docs  releases  compare  claims   (run in this order; each is idempotent)
Run: python -I -X utf8 scripts/knowledge-lab/loop3_digests.py [stage ...]
"""
import json, os, re, sys, uuid, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_process as L1
import loop3_process as P3
from loop3_acquire import RUN3

MODEL = "claude-opus-5-5"
PRICE_IN, PRICE_OUT = 4.0, 20.0  # USD per million tokens (Claude API reference, cached 2026-11-03)
MODEL_BUDGET_USD = 12.0
CALLS_DIR = os.path.join(RUN3, "model-calls")
SPEND_FILE = os.path.join(RUN3, "spend-model.json")
os.makedirs(CALLS_DIR, exist_ok=True)
PRODUCER = f"{MODEL} via loop3_digests.py (anchors, quotes and timecodes validated in code)"
LANGUAGE_RULE = ("Language rule, strictly: describe what a source says, never whether it is right. Use 'the speaker states', 'the page states', 'candidate', 'not verified', "
                 "'appears consistent with', 'appears inconsistent with'. Never write 'confirmed', 'true', 'false', 'correct', 'wrong', 'debunked', 'proves'.")
SECTION_DIGEST_PAGES = {"oss/python/deepagents/subagents", "oss/python/langchain/middleware/built-in", "oss/python/deepagents/skills", "oss/python/deepagents/customization", "oss/python/deepagents/going-to-production", "oss/python/migrate/langchain-v1"}
_client = None
_fallbacks = True


def spend():
    return json.load(open(SPEND_FILE)) if os.path.exists(SPEND_FILE) else {"model": MODEL, "calls": 0, "input_tokens": 0, "output_tokens": 0, "usd": 0.0, "refusals": 0, "by_label": {}}


def call_model(label, system, user, max_tokens=16000):
    """One request; returns the parsed JSON object. The raw response text is kept under knowledge-loop-3/model-calls/ (lab tree, not committed)."""
    global _client, _fallbacks
    cache = os.path.join(CALLS_DIR, re.sub(r"[^a-zA-Z0-9_.-]+", "_", label) + ".json")
    if os.path.exists(cache):
        return json.load(open(cache, encoding="utf-8"))["parsed"]
    sp = spend()
    if sp["usd"] >= MODEL_BUDGET_USD:
        raise RuntimeError(f"model budget reached: {sp['usd']:.2f} USD")
    import anthropic
    if _client is None:
        _client = anthropic.Anthropic(api_key=load_secret("ANTHROPIC_PRODUCER_API_KEY"), max_retries=3, timeout=900.0)
    kwargs = dict(model=MODEL, max_tokens=max_tokens, system=system, messages=[{"role": "user", "content": user}])
    for attempt in range(2):
        try:
            extra = dict(extra_headers={"anthropic-beta": "server-side-fallback-2026-07-01"}, extra_body={"fallbacks": "default"}) if _fallbacks else {}
            with _client.messages.stream(**kwargs, **extra) as stream:
                msg = stream.get_final_message()
            break
        except anthropic.BadRequestError as e:
            if _fallbacks and attempt == 0:
                _fallbacks = False  # the installed SDK / account does not accept the server-side fallback parameter: continue without it
                log(f"model: fallbacks parameter rejected ({str(e)[:120]}); continuing without it")
                continue
            raise
    text = "".join(b.text for b in msg.content if getattr(b, "type", None) == "text")
    usage = msg.usage
    tin = (usage.input_tokens or 0) + (getattr(usage, "cache_creation_input_tokens", 0) or 0) + (getattr(usage, "cache_read_input_tokens", 0) or 0)
    tout = usage.output_tokens or 0
    sp = spend()
    sp["calls"] += 1
    sp["input_tokens"] += tin
    sp["output_tokens"] += tout
    sp["usd"] = round(sp["usd"] + tin * PRICE_IN / 1e6 + tout * PRICE_OUT / 1e6, 4)
    sp["by_label"][label] = {"in": tin, "out": tout, "stop": msg.stop_reason, "model": msg.model}
    if msg.stop_reason == "refusal":
        sp["refusals"] += 1
    write_json(SPEND_FILE, sp)
    if msg.stop_reason == "refusal":
        raise RuntimeError(f"{label}: the model declined the request")
    m = re.search(r"\{.*\}", text, re.S)
    parsed = json.loads(m.group(0)) if m else None
    if parsed is None:
        raise RuntimeError(f"{label}: no JSON object in the response ({msg.stop_reason})")
    write_json(cache, {"label": label, "model": msg.model, "stop_reason": msg.stop_reason, "usage": {"in": tin, "out": tout}, "text": text, "parsed": parsed})
    log(f"model {label}: in {tin} out {tout} tokens, total USD {sp['usd']:.2f}")
    return parsed


def norm(s):
    return re.sub(r"\s+", " ", (s or "").replace("’", "'").replace("“", '"').replace("”", '"')).strip().lower()


def entity_keys():
    ent = json.load(open(os.path.join(RUN3, "entity-keys.json"), encoding="utf-8"))
    names = {r[0]: r[1] for r in sql_rows(f"select id, display_name from catalog.entity where id = any({qarr([v for v in ent.values() if v], 'uuid')})")}
    return {k: (v, names.get(v, k)) for k, v in ent.items() if v}


def new_digest(version_id, scope, scope_node=None):
    gid = str(uuid.uuid4())
    sql(f"""insert into content.document_digest(id, tenant_id, document_version_id, scope, scope_node_id, digest_schema_version, producer_identity, producer_kind, lifecycle)
            values ({q(gid)}, {q(TENANT)}, {q(version_id)}, {q(scope)}, {q(scope_node)}, 'aieng.digest.v2', {q(PRODUCER)}, 'model', 'active')""")
    return gid


def add_items(gid, items):
    """items: (kind, text, payload, node_ids, entity_id, claim_id, unit_change_id)"""
    start = int(one(f"select coalesce(max(ordinal) + 1, 0) from content.digest_item where digest_id={q(gid)}"))
    for i, (kind, text, payload, nodes, ent, claim, chg) in enumerate(items):
        sql(f"insert into content.digest_item(tenant_id, digest_id, ordinal, item_kind, text, payload, node_ids, entity_id, claim_id, unit_change_id, confidence) values ({q(TENANT)}, {q(gid)}, {start + i}, {q(kind)}, {q(text)}, {q(payload)}, {qarr(nodes, 'uuid')}, {q(ent)}, {q(claim)}, {q(chg)}, 0.8)")
    return len(items)


def has_model_digest(version_id):
    return one(f"select 1 from content.document_digest where document_version_id={q(version_id)} and producer_kind='model' and lifecycle='active' limit 1")


STATS = collections.Counter()


def checked_items(raw_items, idmap, allowed, default="key_point", restrict=None):
    out = []
    for it in raw_items or []:
        kind = it.get("kind") if it.get("kind") in allowed else default
        anchors = [idmap[a] for a in it.get("anchors") or [] if a in idmap and (restrict is None or a in restrict)]
        text = (it.get("text") or "").strip()
        if not text or not anchors:
            STATS["items_dropped_no_valid_anchor"] += 1
            continue
        STATS["items_kept"] += 1
        STATS["anchors_invalid"] += len(it.get("anchors") or []) - len(anchors)
        out.append((kind, text[:900], {"anchors_cited": it.get("anchors")}, anchors, None, None, None))
    return out


def entity_items(raw, ent, idmap, doc_id):
    out = []
    for er in raw or []:
        k = er.get("entity")
        if k not in ent:
            STATS["entity_roles_unresolved"] += 1
            append_jsonl(os.path.join(RUN3, "unresolved-entities.jsonl"), {"document_id": doc_id, "entity": k, "role": er.get("role")})
            continue
        anchors = [idmap[a] for a in er.get("anchors") or [] if a in idmap]
        role = er.get("role") if er.get("role") in ("introduces", "demonstrates", "compares", "criticises", "recommends", "uses", "explains", "mentions") else "mentions"
        level = "primary" if er.get("level") == "primary" else "secondary"
        out.append(("entity_role", f"{ent[k][1]}: {role}. {(er.get('text') or '').strip()}"[:700], {"role": role, "level": level, "entity_key": k}, anchors, ent[k][0], None, None))
        P3.about_doc(doc_id, ent[k][0], level, "extraction", 0.8)
        STATS["entity_roles"] += 1
    return out


# ------------------------------------------------------------------ talks
def talk_material(v):
    segs = P3.nodes_of(v, ["transcript_segment"])
    chapters = sorted([n for n in P3.nodes_of(v, ["talk_writeup"]) if n.get("start_ms") is not None], key=lambda n: n["start_ms"])
    idmap, seg_by_id = {}, {}
    for s in segs:
        sid = f"S{s['start_ms'] // 1000}"
        idmap[sid] = s["id"]
        seg_by_id[sid] = s
    chap = []
    for i, c in enumerate(chapters):
        end = chapters[i + 1]["start_ms"] if i + 1 < len(chapters) else 10 ** 9
        members = [sid for sid, s in seg_by_id.items() if c["start_ms"] <= s["start_ms"] < end]
        chap.append({"id": f"W{i + 1}", "node": c, "segments": members, "t0": c["start_ms"]})
    return segs, chap, idmap, seg_by_id


def stage_talks(vs):
    ent = entity_keys()
    for v in vs:
        if v["kind"] != "aie_talk" or has_model_digest(v["version_id"]):
            continue
        segs, chap, idmap, seg_by_id = talk_material(v)
        speaker = sql_rows(f"select e.display_name from catalog.relationship r join catalog.entity e on e.id = r.to_entity_id where r.kind='presented_by' and r.from_entity_id = api.document_work({q(v['document_id'])})")
        speaker = speaker[0][0] if speaker else "the speaker"
        body = [f"TALK: {v['title']}\nSPEAKER: {speaker} (LangChain). EVENT: AI Engineer World's Fair 2026.\n", "CHAPTERS (the chapter text is the organizer's editorial write-up, not the speaker's words):"]
        for c in chap:
            body.append(f"\n[{c['id']}] {c['node']['attributes'].get('heading')} (starts {c['t0'] // 1000}s; transcript segments {c['segments'][0] if c['segments'] else '-'} .. {c['segments'][-1] if c['segments'] else '-'})\n{(c['node']['text'] or '')[:1800]}")
        body.append("\nTRANSCRIPT (the speaker's words; the id is the start time in seconds):")
        for sid, s in seg_by_id.items():
            body.append(f"[{sid}] {s['text']}")
        body.append("\nENTITY LIST (use only these keys in entity_roles and claims.about):\n" + "\n".join(f"{k} = {n}" for k, (_, n) in sorted(ent.items())))
        system = ("You write structured, source-anchored digests of conference talks for a technical knowledge base. Every statement you write must be traceable to transcript segment ids. "
                  + LANGUAGE_RULE + " Return one JSON object and nothing else.")
        user = "\n".join(body) + """

Return JSON with exactly these keys:
{"document_items": [5 to 10 items that say what this talk is and why it matters. Each: {"kind": "key_point" | "recommendation" | "limitation" | "open_question", "text": "one or two sentences", "anchors": ["S<id>", ...]}],
 "chapters": [one entry per chapter id: {"chapter": "W<n>", "items": [2 to 4 items, same shape; anchors must be transcript segments of that chapter]}],
 "entity_roles": [the few entities this talk is ABOUT (not every mention): {"entity": "<key>", "role": "introduces" | "demonstrates" | "compares" | "criticises" | "recommends" | "uses" | "mentions", "level": "primary" | "secondary", "text": "one sentence on how the talk treats it", "anchors": ["S<id>"]}],
 "unlisted_entities": ["names the talk treats as important that are not in the entity list"],
 "claims": [12 to 20 candidates taken ONLY from the transcript: {"mode": "assertion" (the speaker states something about how things are, a result, a number) | "recommendation" (the speaker says what to do), "segment": "S<id>", "quote": "8 to 40 consecutive words copied exactly from that one segment", "statement": "The speaker states that ... / The speaker recommends ...", "about": ["<entity key>", ...], "surface_hints": ["2 to 5 word search phrases for library documentation this concerns, e.g. 'deep agents memory', 'subagents', 'summarization middleware'"]}]}
A recommendation item says what the speaker recommends doing; keep it separate from what the speaker asserts. Prefer claims that concern agent libraries, harnesses, memory, traces, skills, middleware, evaluation or models."""
        res = call_model(f"talk-{v['key']}", system, user)
        gid = new_digest(v["version_id"], "document")
        n = add_items(gid, checked_items(res.get("document_items"), idmap, {"key_point", "recommendation", "limitation", "open_question"}))
        n += add_items(gid, entity_items(res.get("entity_roles"), ent, idmap, v["document_id"]))
        add_items(gid, [("limitation", "The ai.engineer transcript has no speaker labels; statements are attributed to the single listed presenter. Chapter texts are the organizer's write-up; claim candidates are taken from the transcript only. Nothing in this digest is verified.", {}, [], None, None, None)])
        for c in chap:
            entry = next((x for x in res.get("chapters") or [] if x.get("chapter") == c["id"]), None)
            items = checked_items((entry or {}).get("items"), idmap, {"key_point", "recommendation", "limitation", "open_question"}, restrict=set(c["segments"]))
            if items:
                sg = new_digest(v["version_id"], "section", c["node"]["id"])
                n += add_items(sg, items)
        write_json(os.path.join(RUN3, f"claims-raw-{v['key']}.json"), {"speaker": speaker, "claims": res.get("claims") or [], "unlisted_entities": res.get("unlisted_entities") or []})
        log(f"talk digest {v['key']}: {n} items; claim candidates proposed by the model: {len(res.get('claims') or [])}; unlisted entities: {res.get('unlisted_entities')}")
    write_json(os.path.join(RUN3, "digest-stats-talks.json"), dict(STATS))


# ------------------------------------------------------------------ docs pages
def stage_docs(vs):
    ent = entity_keys()
    for v in vs:
        if v["kind"] not in ("framework_docs_page", "official_docs_page", "release_notes") or not v["attrs"].get("digest") or has_model_digest(v["version_id"]):
            continue
        secs = P3.nodes_of(v, ["docs_section"])
        exs = P3.nodes_of(v, ["code_example"])
        idmap, lines = {}, []
        for i, s in enumerate(secs):
            idmap[f"D{i + 1}"] = s["id"]
            lines.append(f"[D{i + 1}] path: {s['attributes'].get('path')}\n{(s['text'] or '')[:2200]}")
        for i, e in enumerate(exs):
            idmap[f"E{i + 1}"] = e["id"]
            lines.append(f"[E{i + 1}] code example under '{e['attributes'].get('demonstrates')}' ({e['attributes'].get('language')}):\n{(e['text'] or '')[:500]}")
        path = v["attrs"]["docs_path"]
        want_sections = []
        if path in SECTION_DIGEST_PAGES:
            tops = [(f"D{i + 1}", s) for i, s in enumerate(secs) if (s["attributes"].get("path") or "").count("/") == 1]
            want_sections = sorted(tops, key=lambda t: -len(t[1]["text"] or ""))[:8]
        system = ("You write structured, source-anchored digests of first-party library documentation pages for a technical knowledge base. Each item must be traceable to the section or example ids given. "
                  + LANGUAGE_RULE + " Return one JSON object and nothing else.")
        user = (f"DOCS PAGE: https://docs.langchain.com/{path} (captured 2026-11-10; first-party LangChain documentation)\n\n" + "\n\n".join(lines)
                + "\n\nENTITY LIST (use only these keys):\n" + "\n".join(f"{k} = {n}" for k, (_, n) in sorted(ent.items()))
                + """

Return JSON with exactly these keys:
{"document_items": [5 to 8 items that say what this page covers and what a practitioner must know. Each: {"kind": "key_point" | "method" (how to do something, name the API) | "limitation" (a stated restriction, caveat or version note) | "recommendation" (what the page tells the reader to do), "text": "one or two sentences naming the concrete APIs, parameters or files", "anchors": ["D<n>" or "E<n>", ...]}],
 "sections": [""" + (f"one entry for each of these section ids: {', '.join(t[0] for t in want_sections)}. Each: {{\"section\": \"D<n>\", \"items\": [2 to 3 items, same shape, anchored inside that section's subtree]}}" if want_sections else "leave empty: []") + """],
 "entity_roles": [the entities this page is about: {"entity": "<key>", "role": "explains" | "demonstrates" | "compares" | "recommends" | "uses" | "mentions", "level": "primary" | "secondary", "text": "one sentence", "anchors": ["D<n>"]}],
 "lesser_known": [0 to 4 short strings: capabilities on this page that are easy to miss]}""")
        res = call_model(f"docs-{v['key']}", system, user, max_tokens=12000)
        gid = new_digest(v["version_id"], "document")
        n = add_items(gid, checked_items(res.get("document_items"), idmap, {"key_point", "method", "limitation", "recommendation"}))
        n += add_items(gid, entity_items(res.get("entity_roles"), ent, idmap, v["document_id"]))
        lk = [x for x in res.get("lesser_known") or [] if isinstance(x, str) and x.strip()]
        if lk:
            add_items(gid, [("key_point", "Lesser-known on this page (as the page states it): " + x.strip()[:400], {"lesser_known": True}, [secs[0]["id"]] if secs else [], None, None, None) for x in lk])
            n += len(lk)
        for sid, s in want_sections:
            entry = next((x for x in res.get("sections") or [] if x.get("section") == sid), None)
            prefix = s["attributes"].get("path") or ""
            subtree = {k for k, i in zip([f"D{j + 1}" for j in range(len(secs))], secs) if (i["attributes"].get("path") or "").startswith(prefix)} | {f"E{j + 1}" for j, e in enumerate(exs) if (e["attributes"].get("path") or "").startswith(prefix)}
            items = checked_items((entry or {}).get("items"), idmap, {"key_point", "method", "limitation", "recommendation"}, restrict=subtree)
            if items:
                sg = new_digest(v["version_id"], "section", s["id"])
                n += add_items(sg, items)
        log(f"docs digest {v['key']}: {n} items")
    write_json(os.path.join(RUN3, "digest-stats-docs.json"), dict(STATS))


# ------------------------------------------------------------------ releases: what changed
RELEASES = [("langchain-ai/deepagents", "deepagents", "0.7.35", "deepagents==0.7.34", "deepagents==0.7.35"), ("langchain-ai/deepagents", "deepagents", "0.7.34", "deepagents==0.7.33", "deepagents==0.7.34"),
            ("langchain-ai/deepagents", "deepagents", "0.7.33", "deepagents==0.7.32", "deepagents==0.7.33"), ("langchain-ai/langchain", "langchain", "1.4.10", None, "langchain==1.4.10"),
            ("langchain-ai/langchain", "langchain-core", "1.7.7", None, "langchain-core==1.7.7"), ("langchain-ai/langchain", "langchain", "1.0.0", "langchain==0.3.27", "langchain==1.0.0")]


def stage_releases(vs):
    for repo, sw, ver, prev_tag, tag in RELEASES:
        rel = one(f"select id from catalog.entity where kind='library_release' and slug={q(P3.slugify(sw + '-' + ver))}")
        entry = sql_json(f"""select json_build_object('id', n.id, 'text', n.inline_text, 'version_id', v.id, 'rep', n.representation_id) from content.unit_entity_role r join content.document_node n on n.id = r.node_id
                             join content.document_representation rp on rp.id = n.representation_id join content.document_version v on v.id = rp.document_version_id
                            where r.entity_id = {q(rel)} and r.role = 'release' and n.unit_kind = 'release_entry' order by v.created_at desc limit 1""") if rel else []
        if not entry:
            log(f"release digest {sw} {ver}: no release_entry unit with a release role (skipped)")
            continue
        e = entry[0]
        if one(f"select 1 from content.document_digest where scope_node_id={q(e['id'])} and producer_kind='model' and lifecycle='active'"):
            continue
        changes = sql_json(f"select json_build_object('id', id, 'text', inline_text, 'kind', attributes->>'kind') from content.document_node where parent_id={q(e['id'])} and unit_kind='change_item' order by ordinal")
        idmap, lines = {}, []
        for i, c in enumerate(changes[:120]):
            idmap[f"C{i + 1}"] = c["id"]
            lines.append(f"[C{i + 1}] ({c['kind']}) {c['text'][:300]}")
        sym_lines, counts = [], {}
        if prev_tag:
            sc = sql_json(f"select json_build_object('change', change, 'qn', qualified_name, 'kind', symbol_kind, 'from', signature_from, 'to', signature_to, 'from_node', from_node_id, 'to_node', to_node_id) from api.symbol_changes({q(repo)}, {q(prev_tag)}, {q(tag)})")
            counts = dict(collections.Counter(s["change"] for s in sc))
            show = [s for s in sc if s["kind"] != "method"][:70] if len(sc) > 90 else sc
            for i, s in enumerate(show):
                node = s["to_node"] or s["from_node"]
                idmap[f"Y{i + 1}"] = node
                sym_lines.append(f"[Y{i + 1}] {s['change']}: {s['qn']} ({s['kind']})" + (f" was: {(s['from'] or '')[:160]} now: {(s['to'] or '')[:160]}" if s["change"] == "signature_changed" else ""))
        system = ("You write a 'what changed' digest of one software release for a technical knowledge base. Each item must cite the change-note ids and symbol ids it summarizes. "
                  + LANGUAGE_RULE + " Return one JSON object and nothing else.")
        user = (f"RELEASE: {sw} {ver} (tag {tag}, repository {repo})\n\nRELEASE NOTES ENTRY:\n{(e['text'] or '')[:1500]}\n\nCHANGE NOTES ({len(changes)} lines; the first {len(lines)} are shown):\n" + ("\n".join(lines) or "(the release body lists no change lines)")
                + (f"\n\nPUBLIC SYMBOL CHANGES computed from the source of {prev_tag} and {tag} (counts: {counts}; {len(sym_lines)} shown):\n" + "\n".join(sym_lines) if prev_tag else "\n\n(No symbol diff: the previous release is not ingested as a surface.)")
                + """

Return JSON: {"items": [at most 5 items, most consequential first: {"text": "one or two sentences on what changed, naming symbols exactly as given", "anchors": ["C<n>" and/or "Y<n>", ...], "breaking": true | false}]}
If the notes and the symbol diff disagree, say that the two 'appear inconsistent' and cite both.""")
        res = call_model(f"release-{sw}-{ver}", system, user, max_tokens=6000)
        items = []
        for it in res.get("items") or []:
            anchors = [idmap[a] for a in it.get("anchors") or [] if a in idmap]
            if not (it.get("text") or "").strip() or not anchors:
                STATS["items_dropped_no_valid_anchor"] += 1
                continue
            items.append(("change", it["text"].strip()[:900], {"breaking": bool(it.get("breaking")), "anchors_cited": it.get("anchors"), "symbol_change_counts": counts, "compared_tags": [prev_tag, tag] if prev_tag else None}, anchors, rel, None, None))
        if items:
            gid = new_digest(e["version_id"], "section", e["id"])
            add_items(gid, items[:5])
        log(f"release digest {sw} {ver}: {len(items[:5])} items ({len(changes)} change notes, symbol changes {counts})")
    write_json(os.path.join(RUN3, "digest-stats-releases.json"), dict(STATS))


# ------------------------------------------------------------------ claim candidates: locate, find the surface, compare (model reading), write
def stage_compare(vs):
    ent = entity_keys()
    for v in vs:
        raw_path = os.path.join(RUN3, f"claims-raw-{v['key']}.json")
        out_path = os.path.join(RUN3, f"claims-compared-{v['key']}.json")
        if v["kind"] != "aie_talk" or not os.path.exists(raw_path) or os.path.exists(out_path):
            continue
        raw = json.load(open(raw_path, encoding="utf-8"))
        segs, chap, idmap, seg_by_id = talk_material(v)
        located, dropped = [], 0
        for c in raw["claims"]:
            qn = norm(c.get("quote"))
            sid = c.get("segment") if c.get("segment") in seg_by_id and qn and qn in norm(seg_by_id[c["segment"]]["text"]) else next((k for k, s in seg_by_id.items() if qn and qn in norm(s["text"])), None)
            if not sid or len(qn.split()) < 5:
                dropped += 1
                append_jsonl(os.path.join(RUN3, "claims-dropped.jsonl"), {"talk": v["key"], "why": "quote not found verbatim in any transcript segment", "claim": c})
                continue
            cands, seen = [], set()
            for hint in (c.get("surface_hints") or [])[:5]:
                for r in sql_json(f"""select json_build_object('id', n.id, 'heading', n.attributes->>'heading', 'path', n.attributes->>'path', 'text', left(n.inline_text, 1300), 'title', d.canonical_title, 'docs_path', d.attributes->>'docs_path')
                                     from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version dv on dv.id = r.document_version_id join content.document d on d.id = dv.document_id
                                    where d.attributes->>'loop' = '3' and d.attributes ? 'docs_path' and n.unit_kind = 'docs_section' and to_tsvector('english', coalesce(n.inline_text, '')) @@ plainto_tsquery('english', {q(hint)})
                                    order by ts_rank_cd(to_tsvector('english', coalesce(n.inline_text, '')), plainto_tsquery('english', {q(hint)})) desc limit 2"""):
                    if r["id"] not in seen and len(cands) < 5:
                        seen.add(r["id"])
                        cands.append(r)
            located.append({"i": len(located) + 1, "segment": sid, "t0_ms": seg_by_id[sid]["start_ms"], "node_id": seg_by_id[sid]["id"], "mode": "recommendation" if c.get("mode") == "recommendation" else "assertion", "quote": c["quote"].strip(), "statement": (c.get("statement") or "").strip(),
                            "about": [k for k in c.get("about") or [] if k in ent], "surface_hints": c.get("surface_hints") or [], "candidates": cands})
        blocks = []
        for c in located:
            blocks.append(f"CLAIM {c['i']} ({c['mode']}), speaker quote: \"{c['quote']}\"\nparaphrase: {c['statement']}\nCANDIDATE DOCS SECTIONS:\n" + ("\n".join(f"  [K{c['i']}.{j + 1}] {x['title']} / {x['path']}\n  {x['text']}" for j, x in enumerate(c["candidates"])) or "  (none found by search)"))
        system = ("You compare what a conference speaker states with what first-party library documentation states. You do not judge who is right and you do not use outside knowledge. "
                  + LANGUAGE_RULE + " Return one JSON object and nothing else.")
        user = ("For each claim decide which candidate docs sections actually concern the same subject, then give a reading.\n\n" + "\n\n".join(blocks) + """

Return JSON: {"readings": [one per claim: {"claim": <number>, "concerns": ["K<i>.<j>", ...] (only sections about the same subject; may be empty), "reading": "appears_consistent" | "appears_inconsistent" | "not_addressed",
 "section": "K<i>.<j>" or null, "docs_quote": "up to 40 consecutive words copied exactly from that section that the reading rests on" or null,
 "conflict_kind": "contradiction" | "scope_mismatch" | "staleness" | "definitional" or null (only for appears_inconsistent), "note": "one sentence: what the speaker states, what the page states, and how they relate"}]}
Use "not_addressed" when no candidate section speaks to the claim (most opinions and results reported from experience are not addressed by docs). Use "appears_inconsistent" only when the page states something that does not fit the speaker's statement.""")
        res = call_model(f"compare-{v['key']}", system, user, max_tokens=12000) if located else {"readings": []}
        by = {r.get("claim"): r for r in res.get("readings") or []}
        for c in located:
            r = by.get(c["i"]) or {}
            cmap = {f"K{c['i']}.{j + 1}": x for j, x in enumerate(c["candidates"])}
            c["concerns"] = [cmap[k]["id"] for k in r.get("concerns") or [] if k in cmap]
            sec = cmap.get(r.get("section"))
            dq = (r.get("docs_quote") or "").strip()
            quote_ok = bool(sec and dq and norm(dq) in norm(sec["text"]))
            reading = r.get("reading") if r.get("reading") in ("appears_consistent", "appears_inconsistent", "not_addressed") else "not_compared"
            if reading in ("appears_consistent", "appears_inconsistent") and not quote_ok:
                c["downgraded_from"] = reading  # a reading that does not rest on a verbatim docs quote is not recorded as a reading
                reading = "not_compared"
            c.update({"reading": reading, "docs_quote": dq if quote_ok else None, "docs_node": sec["id"] if quote_ok else None, "docs_title": sec["title"] if sec else None, "docs_heading": sec["path"] if sec else None,
                      "conflict_kind": r.get("conflict_kind") if r.get("conflict_kind") in ("contradiction", "scope_mismatch", "staleness", "definitional") else "scope_mismatch", "note": (r.get("note") or "").strip()})
            for x in c["candidates"]:
                x.pop("text", None)
        write_json(out_path, {"talk": v["key"], "speaker": raw["speaker"], "dropped_unlocated": dropped, "claims": located})
        log(f"compare {v['key']}: {len(located)} located ({dropped} dropped), readings {dict(collections.Counter(c['reading'] for c in located))}")


def stage_claims(vs):
    ent = entity_keys()
    docs_versions = {}
    for v in vs:
        path = os.path.join(RUN3, f"claims-compared-{v['key']}.json")
        if v["kind"] != "aie_talk" or not os.path.exists(path):
            continue
        if one(f"select 1 from evidence.claim where structured->>'talk_key' = {q(v['key'])} limit 1"):
            continue
        data = json.load(open(path, encoding="utf-8"))
        segs, chap, idmap, seg_by_id = talk_material(v)
        talk = one(f"select api.document_work({q(v['document_id'])})")
        video = one(f"select canonical_url from catalog.work where id={q(talk)}")
        title = one(f"select title from catalog.work where id={q(talk)}")
        rcpt = native_receipt(f"loop3-talk-claims-{v['key']}", {"stage": "claims", "loop": 3, "document": v["key"]})
        run_id = L1.extraction_run_for(v)
        mid = L1.mapping_id("talk_writeup", "aie_talk", "claim_candidate")
        n_claims = n_ctx = n_conf = 0
        chapter_items = collections.defaultdict(list)
        for c in data["claims"]:
            node = seg_by_id[c["segment"]]
            mm, ss = divmod(c["t0_ms"] // 1000, 60)
            loc = L1.locator_for(v, node, "media_timecode")
            statement = f"{data['speaker']} states in the talk \"{title}\" at {mm}:{ss:02d}: \"{c['quote']}\""
            structured = {"path": "L1_candidate", "act": 3, "assertion_mode": c["mode"], "speakers": [data["speaker"]], "quote": c["quote"], "paraphrase": c["statement"], "t0_ms": c["t0_ms"], "deep_link": f"{video}&t={c['t0_ms'] // 1000}s", "talk_id": talk, "talk_key": v["key"],
                          "source_role": "first_party", "attribution": "single listed presenter; the ai.engineer transcript has no speaker labels", "verified": False, "consistency": c["reading"], "consistency_note": c["note"] or None,
                          "compared_by": f"{MODEL} model reading against captured first-party docs sections (not a verification)" if c["reading"] != "not_compared" else None, "surface_node_ids": c["concerns"], "surface_hints": c["surface_hints"], "extracted_by": PRODUCER}
            subjects = [(talk, "source")] + [(ent[k][0], "subject") for k in c["about"]]
            cid = L1.make_claim(rcpt, statement, "recommendation" if c["mode"] == "recommendation" else "other", {k: val for k, val in structured.items() if val is not None}, subjects, loc, run_id, node, mid, status="proposed", confidence=0.5)
            n_claims += 1
            for nid in set(c["concerns"] + ([c["docs_node"]] if c.get("docs_node") else [])):
                dv = docs_versions.get(nid) or sql_json(f"""select json_build_object('capture_id', vc.source_capture_id, 'format', v.format_code, 'representation_id', r.id, 'sha', v.manifest_sha256, 'node', json_build_object('id', n.id, 'selector', n.selector, 'logical_key', n.logical_key, 'text', n.inline_text, 'unit_kind', n.unit_kind, 'attributes', n.attributes, 'start_ms', null, 'end_ms', null))
                                                               from content.document_node n join content.document_representation r on r.id=n.representation_id join content.document_version v on v.id=r.document_version_id join content.document_version_source_capture vc on vc.document_version_id=v.id where n.id={q(nid)}""")[0]
                docs_versions[nid] = dv
                dloc = L1.locator_for(dv, dv["node"], "text_quote")
                sql(f"insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role) values ({q(TENANT)}, {q(cid)}, {q(dloc)}, 'context') on conflict do nothing")
                n_ctx += 1
                if c["reading"] == "appears_inconsistent" and nid == c.get("docs_node"):
                    dstmt = f"The LangChain docs page \"{c['docs_title']}\" (section {c['docs_heading']}, captured 2026-11-10) states: \"{c['docs_quote']}\""
                    drun = L1.extraction_run_for(dv)
                    dcid = L1.make_claim(rcpt, dstmt, "other", {"path": "deterministic_first_party_quote", "source_role": "first_party", "quote": c["docs_quote"], "docs_node_id": nid, "verified": False}, [(ent[k][0], "subject") for k in c["about"]], dloc, drun, dv["node"], None, status="proposed", confidence=1.0)
                    if not one(f"select 1 from evidence.claim_conflict where claim_a_id={q(dcid)} and claim_b_id={q(cid)}"):
                        sql(f"insert into evidence.claim_conflict(claim_a_id, claim_b_id, conflict_kind, detected_by) values ({q(dcid)}, {q(cid)}, {q(c['conflict_kind'])}, {q('build08-loop3 model reading (' + MODEL + '), not adjudicated: the speaker statement appears inconsistent with the docs section. ' + (c['note'] or ''))})")
                        n_conf += 1
            ch = next((x for x in reversed(chap) if x["t0"] <= c["t0_ms"]), None)
            kind = "recommendation" if c["mode"] == "recommendation" else "assertion_ref"
            text = f"Claim candidate (not verified), {mm}:{ss:02d}: {c['statement'] or 'The speaker states: ' + c['quote']}" + (f" Reading against the docs: {c['reading'].replace('_', ' ')}." if c["reading"] not in ("not_compared", "not_addressed") else "")
            chapter_items[ch["node"]["id"] if ch else None].append((kind, text[:900], {"t0_ms": c["t0_ms"], "consistency": c["reading"], "assertion_mode": c["mode"]}, [node["id"]], ent[c["about"][0]][0] if c["about"] else None, cid, None))
        for chapter_node, items in chapter_items.items():
            gid = one(f"select id from content.document_digest where document_version_id={q(v['version_id'])} and producer_kind='model' and lifecycle='active' and scope={q('section' if chapter_node else 'document')} and scope_node_id is not distinct from {q(chapter_node)} limit 1") \
                or new_digest(v["version_id"], "section" if chapter_node else "document", chapter_node)
            add_items(gid, items)
        log(f"claims {v['key']}: {n_claims} candidates written (all proposed), {n_ctx} surface links (role context), {n_conf} kept 'appears inconsistent' conflicts")


STAGES = {"talks": stage_talks, "docs": stage_docs, "releases": stage_releases, "compare": stage_compare, "claims": stage_claims}

if __name__ == "__main__":
    wanted = sys.argv[1:] or list(STAGES)
    vs = P3.versions()
    for st in STAGES:
        if st in wanted:
            STAGES[st](vs)
    sp = spend()
    log(f"model spend so far: {sp['calls']} calls, {sp['input_tokens']} in, {sp['output_tokens']} out, USD {sp['usd']:.2f}")
