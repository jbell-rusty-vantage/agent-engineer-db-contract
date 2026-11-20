"""Build 09, unit RV01 prototype: the cases (stages world, identity, prices, proposals). Run through unit_rv01.py."""
import json, os, re, uuid

from lab_common import *  # noqa
from unit_rv01 import SRC, ACTOR, load_state, save_state, receipt


# ---------------------------------------------------------------------------------------------------------------- helpers
def ent(kind, slug):
    return one(f"select id from catalog.entity where tenant_id={q(TENANT)} and kind={q(kind)} and slug={q(slug)}")


def ensure_entity(kind, slug, name, attrs=None, identifiers=()):
    eid = ent(kind, slug)
    if not eid:
        eid = str(uuid.uuid4())
        sql(f"""insert into catalog.entity(id, tenant_id, kind, display_name, slug, lifecycle, created_by_receipt_id, attributes)
                values ({q(eid)}, {q(TENANT)}, {q(kind)}, {q(name)}, {q(slug)}, 'active', {q(receipt('entity-' + slug))}, {q({k: v for k, v in (attrs or {}).items() if v is not None})})""")
    for scheme, value in identifiers:
        sql(f"insert into catalog.entity_identifier(tenant_id, entity_id, scheme, value) values ({q(TENANT)}, {q(eid)}, {q(scheme)}, {q(value)}) on conflict do nothing")
    return eid


def node_with(cap, needle=None, pointer=None, regex=None):
    """The unit of a captured version that holds the quote (or the JSON pointer, or matches the pattern)."""
    cond = f"n.stable_local_key = {q(pointer)}" if pointer else (f"n.inline_text ~ {q(regex)}" if regex else f"position({q(needle)} in n.inline_text) > 0")
    r = sql_rows(f"select n.id, replace(n.inline_text, E'\\n', ' ') from content.document_node n where n.representation_id = {q(cap['representation_id'])} and {cond} order by n.ordinal limit 1")
    if not r:
        raise RuntimeError(f"no unit holds: {needle or pointer or regex}")
    return r[0][0], r[0][1]


def ensure_short_unit(cap, pattern, key):
    """A short line of the captured page (a date line) that the paragraph splitter dropped: add it as a metadata unit, verbatim."""
    if sql_rows(f"select 1 from content.document_node n where n.representation_id = {q(cap['representation_id'])} and n.inline_text ~ {q(pattern)} limit 1"):
        return
    import html as htmllib
    raw = open(os.path.join(SRC, cap["file"]), encoding="utf-8", errors="replace").read()
    raw = re.sub(r"(?is)<(script|style|noscript|svg|head)\b.*?</\1>", " ", raw)
    text = htmllib.unescape(re.sub(r"(?s)<[^>]+>", "\n", raw))
    line = next((re.sub(r"\s+", " ", ln).strip() for ln in text.splitlines() if re.search(pattern, ln)), None)
    if not line:
        raise RuntimeError(f"the captured page does not hold {pattern}")
    n = one(f"select coalesce(max(ordinal), 0) + 1 from content.document_node where representation_id = {q(cap['representation_id'])}")
    sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, normalized_content_sha256)
            values ({q(TENANT)}, {q(str(uuid.uuid4()))}, {q(cap['representation_id'])}, null, {n}, {q(key)}, 'metadata_field', 1, {q({'key': key, 'value': line})}, {q(key)}, 'build09-rv01/1', {q(line)}, {q({'kind': 'text_block'})}, {q(sha256_text(line))})""")


def claim(st, key, ctype, statement, cap_key, quote=None, pointer=None, regex=None, subjects=(), stated_by=()):
    """One sourced claim through the governed write api.record_claim as pipeline_agent. Returns (claim_id, locator_id)."""
    if key in st.get("claims", {}):
        return st["claims"][key]["claim_id"], st["claims"][key]["locator_id"]
    cap = st["captures"][cap_key]
    node, text = node_with(cap, quote, pointer, regex)
    if regex and not quote:
        quote = re.search(regex, text).group(0)
    anchor = {"capture_id": cap["capture_id"], "node_id": node, "role": "supports"}
    if pointer:
        anchor.update(selector_kind="json_pointer", pointer=pointer.split("#")[0])
    else:
        anchor["quote"] = quote
    res = governed("record_claim", {"p_idempotency_key": "rv01-claim-" + key, "p_claim_type": ctype, "p_statement": statement, "p_evidence": [anchor],
                                    "p_subjects": [{"entity_id": e, "role": r} for e, r in subjects], "p_attributions": [{"entity_id": e, "role": "stated_by"} for e in stated_by]},
                   role="pipeline_agent", actor=ACTOR)
    loc = (res.get("locator_ids") or [None])[0] or one(f"select locator_id from evidence.claim_evidence_link where claim_id = {q(res['claim_id'])} limit 1")
    st.setdefault("claims", {})[key] = {"claim_id": res["claim_id"], "locator_id": loc, "statement": statement, "source": cap_key, "reused": res.get("reused")}
    save_state(st)
    return res["claim_id"], loc


def run_batch(st, label, statements, payload=None):
    """One knowledge batch: begin, the statements, commit with a receipt. Skips a label that already ran. Returns stdout lines."""
    if label in st.get("batches", {}):
        return st["batches"][label]["out"]
    body = "\n".join(statements)
    digest = sha256_text(body)
    rc = receipt(label)
    out, _ = sql(f"""begin;
set local app.tenant_id = '{TENANT}';
select temporal.begin_batch();
{body}
select temporal.commit_batch({q(rc)}, {q('rv01-' + label + '-' + digest[:12])}, {q(digest)}, {q(dict(payload or {}, label=label, unit='RV01'))});
commit;""", tenant=False)
    lines = out.splitlines()
    st.setdefault("batches", {})[label] = {"k": lines[-1] if lines else None, "out": lines, "at": now_iso()}
    save_state(st)
    log(f"batch {label}: knowledge_seq {lines[-1] if lines else '?'}")
    return lines


def extent(text, precision, locator, earliest, latest=None):
    return f"temporal.make_extent({q(text)}, {q(precision)}, {q(locator)}, {q(earliest)}, {q(latest or earliest)}, 'UTC')"


def ev_id(kind, subject, dedupe):
    return f"(select id from temporal.event where tenant_id = {q(TENANT)} and kind = {q(kind)} and subject_entity_id = {q(subject)} and dedupe_key = {q(dedupe)})"


def occ_id(kind, subject, dedupe):
    return f"(select o.id from temporal.event_occurrence o where o.k_to is null and o.event_id = {ev_id(kind, subject, dedupe)})"


def rng(a, b=None):
    return f"tstzrange({q(a)}, {q(b)}, '[)')"


# ---------------------------------------------------------------------------------------------------------------- world events
def stage_world():
    st = load_state()
    cp = st["captures"]
    lc, mcp, anthropic = ent("library", "langchain"), ent("ai_protocol", "mcp"), ent("organization", "anthropic")
    lc_org = ent("organization", "langchain")
    classic = ensure_entity("library", "langchain-classic", "langchain-classic", {"package_name": "langchain-classic", "ecosystem": "pypi", "repository_url": "https://github.com/langchain-ai/langchain"}, [("pypi", "langchain-classic")])
    sdk = ensure_entity("library", "claude-agent-sdk", "Claude Agent SDK", {"package_name": "claude-agent-sdk", "ecosystem": "pypi", "docs_url": "https://code.claude.com/docs/en/agent-sdk/overview"},
                        [("pypi", "claude-agent-sdk"), ("pypi", "claude-code-sdk"), ("npm", "@anthropic-ai/claude-agent-sdk")])
    aaif = ensure_entity("organization", "agentic-ai-foundation", "Agentic AI Foundation", {"org_kind": "nonprofit", "website_url": "https://aaif.io"})
    lf = ensure_entity("organization", "linux-foundation", "Linux Foundation", {"org_kind": "nonprofit", "website_url": "https://www.linuxfoundation.org"})
    st["entities"] = dict(langchain=lc, mcp=mcp, anthropic=anthropic, langchain_classic=classic, claude_agent_sdk=sdk, aaif=aaif, linux_foundation=lf)
    save_state(st)

    # ---- case 2: langchain 1.0 moved legacy code out into langchain-classic
    c2a, l2a = claim(st, "lc-split", "event", "LangChain 1.0 moved legacy chains, retrievers, indexes, hub and community re-exports out of the langchain package into langchain-classic.", "lc-v1-migration",
                     quote="community re-exports moved to `langchain-classic`", subjects=[(lc, "subject"), (classic, "object")], stated_by=[lc_org])
    c2b, l2b = claim(st, "lc-split-reason", "causal", "LangChain gives the reason for the split: the langchain package was reduced so that it focuses on agents, messages, tools, chat models and embeddings.", "lc-v1-migration",
                     quote="the `langchain` package focuses on agents, messages, tools, chat models, and embeddings", subjects=[(lc, "subject")], stated_by=[lc_org])
    c2c, l2c = claim(st, "lc-1-0-0-date", "temporal", "langchain 1.0.0 was uploaded to PyPI on 2025-10-17.", "pypi-langchain-1-0-0", pointer="/urls/0/upload_time_iso_8601", subjects=[(lc, "subject")])
    t_lc = "2025-10-17T20:53:18Z"
    m = sql_rows(f"select n.id from content.document_node n where n.representation_id = {q(cp['lc-v1-migration']['representation_id'])} and n.inline_text ~* 'maintenance mode|no longer (actively )?maintained|security (fixes|updates) only' limit 1")
    st["lc_classic_maintenance_source"] = bool(m)
    run_batch(st, "world-langchain-split", [
        f"select temporal.assert_event('split_out', {q(lc)}, {rng(t_lc, '2025-10-17T20:53:19Z')}, 'actual', {q(classic)}, null, 'langchain-1.0-classic', {extent('2025-10-17T20:53:18.685717Z', 'instant', l2c, t_lc)}, {q(c2a)}, {q({'at_release': 'langchain 1.0.0', 'source': 'LangChain v1 migration guide; PyPI upload time'})});",
        f"select temporal.assert_relationship('split_from', {q(classic)}, {q(lc)}, p_claim => {q(c2a)});",
        f"select temporal.admit_support(null, {occ_id('split_out', lc, 'langchain-1.0-classic')}, {q(c2b)}, {q(l2b)}, 'explains');",
    ])

    # ---- case 3: Claude Code SDK renamed Claude Agent SDK (one entity, its name stream changes)
    c3a, l3a = claim(st, "sdk-renamed", "event", "The Claude Code SDK has been renamed to the Claude Agent SDK.", "claude-agent-sdk-migration",
                     quote="The Claude Code SDK has been renamed to the **Claude Agent SDK**", subjects=[(sdk, "subject")], stated_by=[anthropic])
    c3b, l3b = claim(st, "sdk-rename-reason", "causal", "Anthropic gives the reason for the rename: the SDK has broader capabilities for building AI agents beyond coding tasks.", "claude-agent-sdk-migration",
                     quote="This change reflects the SDK's broader capabilities for building AI agents beyond coding tasks.", subjects=[(sdk, "subject")], stated_by=[anthropic])
    c3c, l3c = claim(st, "sdk-new-first-release", "temporal", "The first release of the PyPI package claude-agent-sdk (0.0.23) was uploaded on 2025-09-28.", "pypi-claude-agent-sdk", pointer="/releases/0.0.23/0/upload_time_iso_8601", subjects=[(sdk, "subject")])
    c3d, l3d = claim(st, "sdk-old-first-release", "temporal", "The first release of the PyPI package claude-code-sdk (0.0.10) was uploaded on 2025-06-12.", "pypi-claude-code-sdk", pointer="/releases/0.0.10/0/upload_time_iso_8601", subjects=[(sdk, "subject")])
    t_old, t_new = "2025-06-12T07:30:46Z", "2025-09-28T21:54:48Z"
    run_batch(st, "world-sdk-old-name", [
        f"select temporal.assert_state({q(sdk)}, 'entity_name', {rng(t_old)}, p_payload => {q({'display_name': 'Claude Code SDK'})}, p_extent => {extent('2025-06-12T07:30:46.643425Z', 'instant', l3d, t_old)}, p_claim => {q(c3d)});"])
    run_batch(st, "world-sdk-renamed", [
        f"select temporal.assert_event('renamed', {q(sdk)}, {rng(t_new, '2025-09-28T21:54:49Z')}, 'actual', null, null, 'claude-code-sdk-to-agent-sdk', {extent('2025-09-28T21:54:48.553780Z', 'instant', l3c, t_new)}, {q(c3a)}, {q({'from': 'Claude Code SDK', 'to': 'Claude Agent SDK', 'dated_by': 'first PyPI release under the new package name'})});",
        f"select temporal.assert_state({q(sdk)}, 'entity_name', {rng(t_new)}, p_payload => {q({'display_name': 'Claude Agent SDK'})}, p_extent => {extent('2025-09-28T21:54:48.553780Z', 'instant', l3c, t_new)}, p_claim => {q(c3a)}, p_revision_kind => 'world_change', p_caused_by_event => {ev_id('renamed', sdk, 'claude-code-sdk-to-agent-sdk')});",
        f"select temporal.admit_support(null, {occ_id('renamed', sdk, 'claude-code-sdk-to-agent-sdk')}, {q(c3b)}, {q(l3b)}, 'explains');",
    ])
    sql(f"insert into catalog.entity_alias(tenant_id, entity_id, alias, alias_kind, source_claim_id) values ({q(TENANT)}, {q(sdk)}, 'Claude Code SDK', 'former_name', {q(c3a)}) on conflict do nothing")

    # ---- case 5: stewardship of the Model Context Protocol
    c5r, l5r = claim(st, "mcp-released", "temporal", "The Model Context Protocol was released in late 2024.", "infoq-aaif", quote="MCP was released in late 2024", subjects=[(mcp, "subject")])
    c5a, l5a = claim(st, "mcp-donated-infoq", "event", "InfoQ reports that Anthropic donated the Model Context Protocol to the Agentic AI Foundation.", "infoq-aaif",
                     quote="OpenAI and Anthropic have donated their AGENTS.md and Model Context Protocol projects to the Agentic AI Foundation (AAIF)", subjects=[(mcp, "subject"), (aaif, "object")])
    ensure_short_unit(cp["infoq-aaif"], "Dec 23, 2025", "published_date")
    ensure_short_unit(cp["anthropic-mcp-donation"], "Dec 9, 2025", "published_date")
    c5ad, l5ad = claim(st, "mcp-infoq-date", "temporal", "The InfoQ article on the Agentic AI Foundation is dated Dec 23, 2025.", "infoq-aaif", regex="Dec 23, 2025", subjects=[(mcp, "context")])
    c5b, l5b = claim(st, "mcp-donated-anthropic", "event", "Anthropic donated the Model Context Protocol to the Agentic AI Foundation, a directed fund under the Linux Foundation.", "anthropic-mcp-donation",
                     quote="donating the Model Context Protocol (MCP) to the Agentic AI Foundation (AAIF), a directed fund under the Linux Foundation", subjects=[(mcp, "subject"), (aaif, "object"), (lf, "context")], stated_by=[anthropic])
    c5c, l5c = claim(st, "mcp-donation-reason", "causal", "Anthropic gives the reason for the donation: its commitment that MCP remains open-source, community-driven and vendor-neutral.", "anthropic-mcp-donation",
                     quote="committed to ensuring MCP remains open-source, community-driven and vendor-neutral", subjects=[(mcp, "subject")], stated_by=[anthropic])
    c5d, l5d = claim(st, "mcp-donation-date", "temporal", "Anthropic's announcement of the donation is dated Dec 9, 2025.", "anthropic-mcp-donation", regex="Dec 9, 2025", subjects=[(mcp, "context")])
    # what we knew first: the protocol's steward since release, then (from the later article only) a transfer observed by 2025-12-23
    run_batch(st, "world-mcp-steward-anthropic", [
        f"select temporal.assert_relationship('maintains', {q(anthropic)}, {q(mcp)}, {rng('2024-10-01T00:00:00Z')}, p_extent => {extent('late 2024', 'quarter', l5r, '2024-10-01T00:00:00Z', '2024-12-31T23:59:59Z')}, p_claim => {q(c5r)});"])
    rel_a = one(f"select id from catalog.relationship where kind='maintains' and from_entity_id={q(anthropic)} and to_entity_id={q(mcp)} and k_to is null")
    x23 = extent("Dec 23, 2025", "day", l5ad, "2025-12-23T00:00:00Z", "2025-12-23T23:59:59Z")
    run_batch(st, "world-mcp-transfer-as-first-learned", [
        f"select temporal.assert_event('stewardship_transferred', {q(mcp)}, {rng('2025-12-23T00:00:00Z', '2025-12-24T00:00:00Z')}, 'actual', {q(aaif)}, null, 'mcp-to-aaif', {x23}, {q(c5a)}, {q({'date_is': 'the date of the article that reported it, not of the transfer'})});",
        f"select temporal.close_relationship({q(rel_a)}, 'world_change', null, {ev_id('stewardship_transferred', mcp, 'mcp-to-aaif')}, '2025-12-23T00:00:00Z', {x23}, {q(c5a)});",
        f"select temporal.assert_relationship('maintains', {q(aaif)}, {q(mcp)}, {rng('2025-12-23T00:00:00Z')}, p_extent => {x23}, p_claim => {q(c5a)});",
    ])
    rel_f = one(f"select id from catalog.relationship where kind='maintains' and from_entity_id={q(aaif)} and to_entity_id={q(mcp)} and k_to is null")
    # the primary source: the transfer was on 2025-12-09. A correction of the date, reason better_source
    e_tr = ev_id("stewardship_transferred", mcp, "mcp-to-aaif")
    x9 = extent("Dec 9, 2025", "day", l5d, "2025-12-09T00:00:00Z", "2025-12-09T23:59:59Z")
    run_batch(st, "world-mcp-date-corrected", [
        f"select temporal.assert_event('stewardship_transferred', {q(mcp)}, {rng('2025-12-09T00:00:00Z', '2025-12-10T00:00:00Z')}, 'actual', {q(aaif)}, null, 'mcp-to-aaif', {x9}, {q(c5b)}, {q({'date_is': 'the date of the announcement by Anthropic'})});",
        f"select temporal.assert_state(null, 'relationship_active', {rng('2025-12-09T00:00:00Z')}, p_status => 'ended', p_extent => {x9}, p_claim => {q(c5b)}, p_relationship => {q(rel_a)}, p_revision_kind => 'correction', p_correction_reason => 'better_source', p_caused_by_event => {e_tr});",
        f"select temporal.assert_state(null, 'relationship_active', {rng('2025-12-09T00:00:00Z')}, p_status => 'active', p_extent => {x9}, p_claim => {q(c5b)}, p_relationship => {q(rel_f)}, p_revision_kind => 'correction', p_correction_reason => 'better_source', p_caused_by_event => {e_tr});",
        f"select temporal.admit_support(null, {occ_id('stewardship_transferred', mcp, 'mcp-to-aaif')}, {q(c5c)}, {q(l5c)}, 'explains');",
        f"select temporal.assert_relationship('subsidiary_of', {q(aaif)}, {q(lf)}, {rng('2025-12-09T00:00:00Z')}, p_extent => {x9}, p_claim => {q(c5b)});",
    ])
    st["relationships"] = dict(anthropic_maintains_mcp=rel_a, aaif_maintains_mcp=rel_f)
    save_state(st)
    log("world stage done")


# ---------------------------------------------------------------------------------------------------------------- our mistakes on identity
def snapshot(eid):
    """What a record holds right now, for before/after comparisons."""
    return {
        "lifecycle": one(f"select lifecycle from catalog.entity where id={q(eid)}"),
        "facts": sql_rows(f"select st.kind, st.scope_key, s.valid_during::text, coalesce(s.status,''), coalesce(s.amount::text,''), s.payload::text from temporal.segment s join temporal.stream st on st.id=s.stream_id where st.subject_entity_id={q(eid)} and s.k_to is null order by 1,2,3"),
        "edges": sql_rows(f"select kind, from_entity_id, to_entity_id, qualifier from catalog.relationship where k_to is null and (from_entity_id={q(eid)} or to_entity_id={q(eid)}) order by 1,2,3"),
        "identifiers": sql_rows(f"select scheme, value from catalog.entity_identifier where entity_id={q(eid)} order by 1,2"),
        "aliases": sql_rows(f"select alias, alias_kind from catalog.entity_alias where entity_id={q(eid)} order by 1,2"),
        "references": sql_rows(f"select table_name, column_name, row_count from catalog.entity_references({q(eid)}) order by 1,2"),
    }


def moves_of(col, parent):
    return sql_rows(f"select table_name, coalesce(column_name,''), action, count(*) from catalog.identity_move where {col} = {q(parent)} group by 1,2,3 order by 1,2,3")


def stage_identity():
    st = load_state()
    idn = st.setdefault("identity", {})
    lg, sdk_lib, cli_lib = ent("library", "langgraph"), ent("library", "langgraph-sdk"), ent("library", "langgraph-cli")
    # ---- case 1a: adopt the loop-5 move of eight tags (already made by hand): give it a record and a reason
    pairs = sql_rows(f"""select c.id, o.id, o.to_entity_id, e.attributes->>'version_label' from catalog.relationship c
                         join catalog.relationship o on o.kind = 'version_of' and o.from_entity_id = c.from_entity_id and o.k_to is null and o.to_entity_id in ({q(sdk_lib)}, {q(cli_lib)})
                         join catalog.entity e on e.id = c.from_entity_id
                         where c.kind = 'version_of' and c.to_entity_id = {q(lg)} and c.k_to is not null order by 4""")
    idn["adopted_tags"] = [p[3] for p in pairs]
    parts = [{"entity_id": lib, "adopt": [{"closed": p[0], "opened": p[1]} for p in pairs if p[2] == lib]} for lib in (sdk_lib, cli_lib)]
    out = run_batch(st, "identity-adopt-langgraph-split", [
        f"select catalog.split_entity({q(lg)}, {q(parts)}, {q(receipt('split-langgraph'))}, 'mixed_record', {q('The LangGraph record held the monorepo tags sdk==x and cli==x as its own releases; they are releases of langgraph-sdk and langgraph-cli. The move was made by hand in loop 5 (2026-11-13) and is adopted here.')});"])
    idn["langgraph_split"] = json.loads(out[1]) if len(out) > 1 else None
    save_state(st)

    # ---- case 1b: a record that mixes two organizations
    g, gd = ent("organization", "google"), ent("organization", "google-deepmind")
    for slug in ("google-google-deepmind", "google-deepmind-google"):
        mix = ent("organization", slug)
        if not mix:
            continue
        if slug not in idn.get("mixed_before", {}):
            idn.setdefault("mixed_before", {})[slug] = snapshot(mix)
        out = run_batch(st, f"identity-split-{slug}", [
            f"select catalog.split_entity({q(mix)}, {q([{'entity_id': g}, {'entity_id': gd}])}, {q(receipt('split-' + slug))}, 'mixed_record', {q('The record name joins two organizations, Google and Google DeepMind. Nothing is moved by the split itself; the record is retired and points at both.')}, null, true);"])
        idn.setdefault("mixed_split", {})[slug] = json.loads(out[1]) if len(out) > 1 else None
        idn.setdefault("mixed_after", {})[slug] = snapshot(mix)
    save_state(st)

    # ---- case 4a: Microsoft twice. Merge, merge again (no change), undo, compare, merge for good
    lo, wi = ent("organization", "azure"), ent("organization", "microsoft")
    if "ms_before" not in idn:
        idn["ms_before"] = {"loser": snapshot(lo), "winner": snapshot(wi), "k": one("select knowledge_seq from temporal.knowledge_head limit 1")}
        save_state(st)
    out = run_batch(st, "identity-merge-microsoft-1", [f"select catalog.merge_entities({q(lo)}, {q(wi)}, {q(receipt('merge-ms-1'))}, 'duplicate_record', 'Two records named Microsoft; the one with slug azure holds the edges.');"])
    idn["ms_merge_1"] = json.loads(out[1])
    if "ms_after_merge" not in idn:
        idn["ms_after_merge"] = {"loser": snapshot(lo), "winner": snapshot(wi), "moves": moves_of("merge_id", idn["ms_merge_1"]["merge_id"])}
        idn["ms_resolve_azure"] = sql_rows("select kind, display_name, score from api.resolve_entity('azure') limit 3")
        again, _ = sql(f"select catalog.merge_entities({q(lo)}, {q(wi)}, null)")
        idn["ms_merge_again"] = json.loads(again)
        idn["ms_merge_rows_after_again"] = one(f"select count(*) from catalog.entity_merge where from_entity_id = {q(lo)}")
        save_state(st)
    out = run_batch(st, "identity-undo-microsoft", [f"select catalog.undo_merge({q(idn['ms_merge_1']['merge_id'])}, {q(receipt('undo-ms'))}, 'prototype check 9: undo and compare');"])
    idn["ms_undo"] = json.loads(out[1])
    if "ms_after_undo" not in idn:
        idn["ms_after_undo"] = {"loser": snapshot(lo), "winner": snapshot(wi)}
        save_state(st)
    out = run_batch(st, "identity-merge-microsoft-2", [f"select catalog.merge_entities({q(lo)}, {q(wi)}, {q(receipt('merge-ms-2'))}, 'duplicate_record', 'Two records named Microsoft; merged again after the undo check.');"])
    idn["ms_merge_2"] = json.loads(out[1])

    # ---- case 4b: the Qwen pair, facts on both sides
    ql, qw = ent("ai_model_version", "qwen-3-7-plus"), ent("ai_model_version", "qwen3-7-plus")
    if "qwen_before" not in idn:
        idn["qwen_before"] = {"loser": snapshot(ql), "winner": snapshot(qw)}
        save_state(st)
    out = run_batch(st, "identity-merge-qwen", [f"select catalog.merge_entities({q(ql)}, {q(qw)}, {q(receipt('merge-qwen'))}, 'duplicate_record', 'Qwen 3.7-Plus and Qwen3.7 Plus are one model version written two ways.');"])
    idn["qwen_merge"] = json.loads(out[1])
    idn["qwen_after"] = {"loser": snapshot(ql), "winner": snapshot(qw), "moves": moves_of("merge_id", idn["qwen_merge"]["merge_id"]),
                         "closed_as_duplicate": sql_json(f"select to_jsonb(m) from (select table_name, row_key, detail from catalog.identity_move where merge_id = {q(idn['qwen_merge']['merge_id'])} and action = 'closed_as_duplicate') m")}
    save_state(st)
    log("identity stage done")


# ---------------------------------------------------------------------------------------------------------------- prices
def price_table(path):
    """The first model table of the pricing page: model -> {input, output} in USD per million tokens."""
    out, cols = {}, None
    for line in open(path, encoding="utf-8"):
        if not line.startswith("|"):
            if out:
                break
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if cols is None:
            if cells and cells[0].lower() == "model" and any("output" in c.lower() for c in cells):
                cols = [c.lower() for c in cells]
            continue
        if set(cells[0]) <= set("-: "):
            continue
        name = re.sub(r"\s*\(\[.*$", "", cells[0]).strip()
        vals = {}
        for c, v in zip(cols[1:], cells[1:]):
            m = re.search(r"\$([0-9.]+)", v)
            if m:
                vals["input" if "input" in c else "output" if "output" in c else c] = float(m.group(1))
        if name.startswith("Claude") and "input" in vals and "output" in vals:
            out[name] = vals
    return out


def stage_prices():
    st = load_state()
    pr = st.setdefault("prices", {})
    cp = st["captures"]
    today = price_table(os.path.join(SRC, cp["anthropic-pricing-today"]["file"]))
    arch = price_table(os.path.join(SRC, cp["anthropic-pricing-archived"]["file"]))
    pr["today_models"], pr["archived_models"], pr["archived_at"] = len(today), len(arch), cp["anthropic-pricing-archived"].get("archived_at")
    pr["archived_vs_today"] = [{"model": m, "meter": k, "archived": arch[m][k], "today": today[m][k]} for m in sorted(set(arch) & set(today)) for k in ("input", "output") if arch[m][k] != today[m][k]]
    pr["only_archived"], pr["only_today"] = sorted(set(arch) - set(today)), sorted(set(today) - set(arch))
    cap_at = one(f"select to_char(captured_at at time zone 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') from evidence.source_capture where id = {q(cp['anthropic-pricing-today']['capture_id'])}")
    diffs, stmts, pr["not_in_lab"] = [], [], []
    for model, vals in sorted(today.items()):
        off = one(f"select id from catalog.entity where kind = 'model_offering' and display_name = {q(model + ' on Anthropic API')} and lifecycle = 'active' order by slug limit 1")
        if not off:
            pr["not_in_lab"].append(model)
            continue
        for meter in ("input", "output"):
            scope = f"{meter}_tokens|standard||"
            cur = sql_rows(f"""select s.amount, s.currency, s.unit, s.payload::text, lower(s.valid_during) from temporal.segment s join temporal.stream x on x.id = s.stream_id
                               where x.kind = 'offering_price' and x.subject_entity_id = {q(off)} and x.scope_key = {q(scope)} and s.k_to is null and upper_inf(s.valid_during)""")
            if not cur:
                continue
            if float(cur[0][0]) != vals[meter]:
                diffs.append({"model": model, "meter": meter, "lab": float(cur[0][0]), "lab_from": cur[0][4], "today": vals[meter]})
                stmts.append(f"select temporal.assert_state({q(off)}, 'offering_price', {rng(cap_at)}, {q(scope)}, null, {vals[meter]}, {q(cur[0][1])}, {q(cur[0][2])}, null, {q(json.loads(cur[0][3]))}, null, null, 'observation_bounded');")
    pr["lab_vs_today"] = diffs
    # the packet's fallback: when no price differs, look at an earlier archived date as well
    if not diffs and not pr["archived_vs_today"] and "earlier_archive" not in pr:
        from unit_rv01 import PRICING_URL, capture
        a = http_get("http://archive.org/wayback/available?url=" + PRICING_URL.replace("https://", "") + "&timestamp=20251115", accept="application/json")
        snap = (json.loads(a["body"]).get("archived_snapshots") or {}).get("closest") if a["status"] == 200 else None
        pr["earlier_archive"] = {"found": bool(snap and snap.get("available"))}
        if snap and snap.get("available") and snap["timestamp"][:8] != (pr["archived_at"] or "")[:10].replace("-", ""):
            ts = snap["timestamp"]
            raw_url = f"https://web.archive.org/web/{ts}id_/{PRICING_URL}"
            f = http_get(raw_url)
            if f["status"] == 200:
                at = f"{ts[0:4]}-{ts[4:6]}-{ts[6:8]}T{ts[8:10]}:{ts[10:12]}:{ts[12:14]}Z"
                c = capture(dict(key="anthropic-pricing-archived-earlier", url=raw_url, title="Anthropic model pricing", kind="pricing_page", role="first_party", fmt="markdown",
                                 publisher="Internet Archive (copy of platform.claude.com)", captured_at=at, published_at=at, archived_copy_of=PRICING_URL), f["body"], f)
                cp["anthropic-pricing-archived-earlier"] = dict(c, status=200, captured=True, url=raw_url, bytes=len(f["body"]), archived_at=at)
                old_t = price_table(os.path.join(SRC, c["file"]))
                pr["earlier_archive"].update(archived_at=at, models=len(old_t),
                    differs=[{"model": m, "meter": k, "earlier": old_t[m][k], "today": today[m][k]} for m in sorted(set(old_t) & set(today)) for k in ("input", "output") if old_t[m][k] != today[m][k]])
            else:
                pr["earlier_archive"]["status"] = f["status"]
    save_state(st)
    if stmts:
        run_batch(st, "prices-real-changes", stmts, {"source": "Anthropic model pricing, captured " + cap_at})
    # the same value asserted again: nothing may change
    probe = sql_rows("""select x.subject_entity_id, x.scope_key, s.valid_during::text, s.amount, s.currency, s.unit, s.payload::text, s.temporal_basis, e.display_name, coalesce(s.extent_id::text, ''), coalesce(s.primary_claim_id::text, ''), coalesce(s.status, '')
                        from temporal.segment s join temporal.stream x on x.id = s.stream_id join catalog.entity e on e.id = x.subject_entity_id
                        where x.kind = 'offering_price' and e.display_name ~ '^Claude (Haiku|Sonnet|Opus) [0-9.]+ on Anthropic API$' and x.scope_key = 'output_tokens|standard||' and s.k_to is null and upper_inf(s.valid_during) order by e.display_name limit 1""")[0]
    probe = list(probe) + [""] * (12 - len(probe))  # trailing empty columns are stripped from psql output
    before = one("select count(*) from temporal.segment")
    run_batch(st, "prices-same-again", [f"select temporal.assert_state({q(probe[0])}, 'offering_price', {q(probe[2])}::tstzrange, {q(probe[1])}, {q(probe[11] or None)}, {probe[3]}, {q(probe[4])}, {q(probe[5])}, null, {q(json.loads(probe[6]))}, {q(probe[9] or None)}, {q(probe[10] or None)}, {q(probe[7])});"])
    pr["same_again"] = {"offering": probe[8], "segments_before": before, "segments_after": one("select count(*) from temporal.segment")}
    # a planted misreading on a scope of its own, corrected, then retired. Synthetic and labelled so.
    scope = "output_tokens|standard||rv01-planted-misreading"
    synth = dict(json.loads(probe[6]), synthetic=True, planted_by="unit RV01 prototype", note="a planted misreading; not a real price")
    run_batch(st, "prices-planted-misreading", [f"select temporal.assert_state({q(probe[0])}, 'offering_price', {rng(cap_at)}, {q(scope)}, null, {float(probe[3]) * 10}, {q(probe[4])}, {q(probe[5])}, null, {q(synth)}, null, null, 'observation_bounded');"])
    _, err = sql(f"""begin; set local app.tenant_id = '{TENANT}'; select temporal.begin_batch();
        select temporal.assert_state({q(probe[0])}, 'offering_price', {rng(cap_at)}, {q(scope)}, null, {probe[3]}, {q(probe[4])}, {q(probe[5])}, null, {q(synth)}, null, null, 'observation_bounded'); rollback;""", tenant=False, allow_error=True)
    pr["rewrite_without_reason"] = err
    run_batch(st, "prices-misreading-corrected", [f"select temporal.assert_state({q(probe[0])}, 'offering_price', {rng(cap_at)}, {q(scope)}, null, {probe[3]}, {q(probe[4])}, {q(probe[5])}, null, {q(synth)}, null, null, 'observation_bounded', p_revision_kind => 'correction', p_correction_reason => 'misread');"])
    _, err2 = sql(f"""begin; set local app.tenant_id = '{TENANT}'; select temporal.begin_batch();
        select temporal.assert_state({q(probe[0])}, 'offering_price', {rng(cap_at)}, {q(scope)}, null, 99, {q(probe[4])}, {q(probe[5])}, null, {q(synth)}, null, null, 'observation_bounded', p_revision_kind => 'correction', p_correction_reason => 'not_recorded'); rollback;""", tenant=False, allow_error=True)
    pr["not_recorded_refused"] = err2
    pr["planted"] = sql_rows(f"""select s.amount, coalesce(s.revision_kind,''), coalesce(s.correction_reason,''), s.k_from, coalesce(s.k_to::text,''), s.payload->>'synthetic' from temporal.segment s join temporal.stream x on x.id = s.stream_id
                                 where x.subject_entity_id = {q(probe[0])} and x.scope_key = {q(scope)} order by s.k_from""")
    run_batch(st, "prices-planted-retired", [f"select temporal.close_segment(s.id) from temporal.segment s join temporal.stream x on x.id = s.stream_id where x.subject_entity_id = {q(probe[0])} and x.scope_key = {q(scope)} and s.k_to is null;"])
    save_state(st)
    log(f"prices stage done: {len(diffs)} real differences between the lab and today's page; {len(pr['archived_vs_today'])} between the archived page and today")


# ---------------------------------------------------------------------------------------------------------------- proposals
def stage_proposals():
    st = load_state()
    e, r, c = st["entities"], st["relationships"], st["claims"]
    deep = ent("library", "deepagents")
    props = st.setdefault("proposals", {})
    ev = one(f"select id from temporal.event where kind = 'stewardship_transferred' and subject_entity_id = {q(e['mcp'])} and dedupe_key = 'mcp-to-aaif'")
    calls = {
        "relationship": dict(p_kind="relationship", p_statement="Deep Agents and the Claude Agent SDK compete: both are libraries for building an agent harness around a model, with tools, subagents and a file workspace.",
            p_rationale="Both libraries are in the catalog as agent harness libraries from a model vendor's ecosystem and target the same builder. No captured source states that they compete; this is the session agent's reading of their scope.",
            p_confidence="medium", p_subject=deep, p_object=e["claude_agent_sdk"], p_relationship_kind="competes_with",
            p_basis=[{"claim_id": c["sdk-rename-reason"]["claim_id"], "role": "basis", "note": "Anthropic says the SDK is for building AI agents beyond coding"}]),
        "cause": dict(p_kind="cause", p_statement="Anthropic moved the Model Context Protocol to a foundation so that other model vendors would keep adopting it without depending on a competitor's goodwill.",
            p_rationale="The foundation was co-founded with OpenAI and Block and is supported by Google, Microsoft and AWS (Anthropic's announcement; InfoQ). A protocol owned by one vendor is a risk to the others; neutral ownership removes it. Anthropic's stated reason is neutrality and openness; the competitive motive is our inference, not a statement by any source.",
            p_confidence="medium", p_target={"relationship_id": r["anthropic_maintains_mcp"]}, p_cause_event=ev,
            p_basis=[{"claim_id": c["mcp-donated-anthropic"]["claim_id"], "role": "basis"}, {"claim_id": c["mcp-donated-infoq"]["claim_id"], "role": "basis"},
                     {"claim_id": c["mcp-donation-reason"]["claim_id"], "role": "counter", "note": "the stated reason, which does not mention competitors"}]),
        "identity": dict(p_kind="identity", p_statement="The records ForgeCode and Forge Code are one product.",
            p_rationale="The names differ by one space. Both records were created from leaderboard rows and hold no facts or edges of their own.",
            p_confidence="high", p_subject=ent("product", "forge-code"), p_object=ent("product", "forgecode")),
    }
    for key, args in calls.items():
        props[key] = governed("propose", dict(args, p_idempotency_key="rv01-proposal-" + key), role="pipeline_agent", actor=ACTOR)
    save_state(st)
    log("proposals stage done: " + ", ".join(f"{k}={v['proposal_id'][:8]}" for k, v in props.items()))
