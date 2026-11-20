"""Build 09, unit RV01 prototype: the 14 questions and 11 checks of packet r1. Writes RESULTS.json beside EXPECTED.json."""
import json, os

from lab_common import *  # noqa
from unit_rv01 import UNIT, load_state
from unit_rv01_cases import ent

SINCE = "2026-11-20T00:30:00Z"  # before the first prototype batch


def as_role(role, statement):
    """Run one statement as a bounded role; returns (stdout, error)."""
    return sql(f"begin;\nset local app.tenant_id = '{TENANT}';\nset local role {role};\n{statement};\nrollback;", tenant=False, allow_error=True)


def first_error(err):
    return (err or "").split("\n")[0].replace("ERROR:  ", "")


def stage_questions():
    st = load_state()
    e, rel, idn, pr, props = st["entities"], st["relationships"], st["identity"], st["prices"], st["proposals"]
    Q, CH = [], []

    def add(n, verdict, actual, note=""):
        Q.append({"n": n, "verdict": verdict, "actual": actual, "note": note})

    def check(n, verdict, actual, note=""):
        CH.append({"n": n, "verdict": verdict, "actual": actual, "note": note})

    # 1 what changed, and was it the world or us
    rows = sql_rows(f"select change_source, change_kind, coalesce(revision_kind,''), coalesce(correction_reason,''), count(*), count(cause_event_id) from api.changes_since({q(SINCE)}) group by 1,2,3,4 order by 1,2,3,4")
    replaced_unlabelled = one(f"select count(*) from api.changes_since({q(SINCE)}) where change_source = 'fact' and change_kind = 'replaced' and revision_kind is null")
    corrections_without_reason = one(f"select count(*) from api.changes_since({q(SINCE)}) where revision_kind = 'correction' and correction_reason is null")
    carried = one(f"select count(*) from api.changes_since({q(SINCE)}) where revision_kind = 'carried'")
    sources = {r[0] for r in rows}
    add(1, "met" if replaced_unlabelled == "0" and corrections_without_reason == "0" and carried == "0" and {"relationship", "identity"} <= sources else "missed",
        {"by_source_kind_revision_reason_count_with_cause": rows, "replaced_facts_without_a_kind": replaced_unlabelled, "corrections_without_a_reason": corrections_without_reason, "carried_rows_listed": carried})

    # 2 the 816 old replacements
    old = sql_rows("select st.kind, s.revision_kind, coalesce(s.correction_reason,''), count(*) from temporal.segment s join temporal.stream st on st.id = s.stream_id where s.replaces_segment_id is not null and s.k_from <= 270 group by 1,2,3 order by 1,2")
    doubt = sql_rows("""select e.display_name, st.scope_key, o.amount, s.amount, lower(o.valid_during)::date, lower(s.valid_during)::date from temporal.segment s join temporal.segment o on o.id = s.replaces_segment_id
                        join temporal.stream st on st.id = s.stream_id join catalog.entity e on e.id = st.subject_entity_id
                        where st.kind = 'offering_price' and s.revision_kind = 'world_change' and s.k_from <= 270 and s.amount is distinct from o.amount order by 1, 2 limit 4""")
    add(2, "missed", {"old_replacements_by_stream_kind": old, "price_rows_called_world_change_examples": doubt},
        "The rule called 333 of the 483 real replacements a world change (265 benchmark scores, 68 prices) and 150 a correction (all relationship_active); 333 more are carried pieces. "
        "I expected the opposite split. The 68 price rows start three days later than the fact they replace and several double or halve a price in that time, which reads as a second parse of the page, not a price change. "
        "The rule cannot tell a second reading from a change when the writer says nothing. "
        "After John's acceptance answer RV01-8 B (2026-11-20) the label on those 333 old rows was cleared by draft 20261119122000: they now read as replaced, kind not recorded.")

    # 3 LangGraph releases before the loop-5 repair and now
    lg = ent("library", "langgraph")
    k_fix = one(f"select max(k_to) from catalog.relationship where kind = 'version_of' and to_entity_id = {q(lg)} and k_to is not null")
    before = sql_rows(f"select e.attributes->>'version_label' from api.relationships({q(lg)}, 'version_of', now(), {int(k_fix) - 1}, 'incoming') r join catalog.entity e on e.id = r.from_entity_id order by 1")
    now_ = sql_rows(f"select e.attributes->>'version_label' from api.relationships({q(lg)}, 'version_of', now(), null, 'incoming') r join catalog.entity e on e.id = r.from_entity_id order by 1")
    tags_before = [r[0] for r in before if r[0].startswith(("sdk==", "cli=="))]
    tags_now = [r[0] for r in now_ if r[0].startswith(("sdk==", "cli=="))]
    why = sql_rows(f"""select sp.reason_code, m.action, count(*), string_agg(distinct pe.display_name, ', ') from catalog.entity_split sp join catalog.identity_move m on m.split_id = sp.id
                       join catalog.entity pe on pe.id = (m.detail->>'part')::uuid where sp.from_entity_id = {q(lg)} group by 1, 2""")
    closed = sql_rows(f"select closed_kind, closed_reason, count(*) from catalog.relationship where kind = 'version_of' and to_entity_id = {q(lg)} and k_to is not null group by 1, 2")
    add(3, "met" if len(tags_before) == 8 and not tags_now and why and why[0][0] == "mixed_record" else "missed",
        {"knowledge_seq_of_repair": k_fix, "releases_before": len(before), "tags_before": tags_before, "releases_now": len(now_), "tags_now": tags_now, "split_record": why, "closed_edges": closed})

    # 4 resolve the old name
    sdk = e["claude_agent_sdk"]
    res = sql_rows("select kind, display_name, score from api.resolve_entity('Claude Code SDK') limit 3")
    names = sql_json(f"select to_jsonb(h) from (select item_kind, world_from, world_to, details from api.entity_history({q(sdk)}) where item_kind in ('name', 'alias', 'identifier', 'event')) h")
    ev = one(f"select id from temporal.event where kind = 'renamed' and subject_entity_id = {q(sdk)}")
    why4 = json.loads(one(f"select api.change_explanation(p_event => {q(ev)})"))
    stated = why4.get("stated_reasons") or []
    add(4, "met" if res and res[0][1] == "Claude Agent SDK" and len([n for n in names if n["item_kind"] == "name"]) == 2 and stated and "Anthropic" in (stated[0].get("stated_by") or []) else "partly",
        {"resolve": res, "history": names, "rename_explained": why4})

    # 5 LangChain at 1.0
    lc, classic = e["langchain"], e["langchain_classic"]
    hist5 = sql_json(f"select to_jsonb(h) from (select item_kind, world_from, details from api.entity_history({q(lc)}) where item_kind = 'event' or details->>'kind' = 'split_from') h")
    ev5 = one(f"select id from temporal.event where kind = 'split_out' and subject_entity_id = {q(lc)}")
    why5 = json.loads(one(f"select api.change_explanation(p_event => {q(ev5)})"))
    life = sql_rows(f"select display_name, lifecycle from catalog.entity where id in ({q(lc)}, {q(classic)}) order by 1")
    maint = sql_rows(f"select s.status from temporal.segment s join temporal.stream x on x.id = s.stream_id where x.kind = 'library_maintenance' and x.subject_entity_id = {q(classic)} and s.k_to is null")
    add(5, "partly", {"history": hist5, "split_explained": why5, "lifecycle": life, "langchain_classic_maintenance_status": maint or "not asserted"},
        "Met except the maintenance status: none of the captured pages states it, so no fact was written. A fact without a captured source is not asserted."
        if not maint else "")

    # 6 who stewarded MCP, then and now, and why
    mcp = e["mcp"]
    then = sql_rows(f"select o.display_name from api.relationships({q(mcp)}, 'maintains', '2025-06-01T00:00:00Z', null, 'incoming') r join catalog.entity o on o.id = r.from_entity_id")
    today = sql_rows(f"select o.display_name from api.relationships({q(mcp)}, 'maintains', now(), null, 'incoming') r join catalog.entity o on o.id = r.from_entity_id")
    k_first = int(st["batches"]["world-mcp-transfer-as-first-learned"]["k"])
    mid_then = sql_rows(f"select o.display_name from api.relationships({q(mcp)}, 'maintains', '2025-12-15T00:00:00Z', {k_first}, 'incoming') r join catalog.entity o on o.id = r.from_entity_id")
    mid_now = sql_rows(f"select o.display_name from api.relationships({q(mcp)}, 'maintains', '2025-12-15T00:00:00Z', null, 'incoming') r join catalog.entity o on o.id = r.from_entity_id")
    why6 = json.loads(one(f"select api.change_explanation(p_relationship => {q(rel['anthropic_maintains_mcp'])})"))
    corr = sql_rows(f"select change_kind, revision_kind, correction_reason, cause_event_kind, world_from, new_value->>'status', new_value->'relationship'->>'to', subject from api.changes_since({q(SINCE)}, array['relationship_active']) where correction_reason = 'better_source'")
    ok6 = then == [["Anthropic"]] and today == [["Agentic AI Foundation"]] and (why6.get("cause_event") or {}).get("kind") == "stewardship_transferred" and why6.get("stated_reasons") and len(corr) == 2
    add(6, "met" if ok6 else "partly", {"steward_on_2025_06_01": then, "steward_today": today, "steward_on_2025_12_15_as_first_learned": mid_then, "steward_on_2025_12_15_as_known_now": mid_now,
                                         "explained": why6, "date_corrections": corr})

    # 7 Microsoft after the merge, and as known before it
    lo, wi = ent("organization", "azure"), ent("organization", "microsoft")
    k_before = int(idn["ms_before"]["k"])
    w_now = one(f"select count(*) from api.relationships({q(wi)}, null, now(), null, 'both')")
    l_then = one(f"select count(*) from api.relationships({q(lo)}, null, now(), {k_before}, 'both')")
    w_then = one(f"select count(*) from api.relationships({q(wi)}, null, now(), {k_before}, 'both')")
    edges_now = sql_rows(f"select r.kind, o.display_name from catalog.relationship r join catalog.entity o on o.id = r.to_entity_id where r.from_entity_id = {q(wi)} and r.k_to is null order by 1, 2")
    add(7, "met" if len(edges_now) == 4 and l_then == "4" and w_then == "0" and idn["ms_resolve_azure"][0][1] == "Microsoft" else "partly",
        {"winner_edges_now": edges_now, "winner_edges_visible_through_api_relationships_now": w_now, "as_known_before_merge": {"loser_edges": l_then, "winner_edges": w_then},
         "resolve_azure": idn["ms_resolve_azure"], "moves": idn["ms_merge_2"]["moves"], "loser_lifecycle": one(f"select lifecycle from catalog.entity where id = {q(lo)}")},
        "api.relationships hides an edge that carries world time when it has no active fact for the date; that is why its count can be lower than the 4 current edges." if w_now != "4" else "")

    # 8 the Qwen pair, and the rule for two records that both hold a fact (synthetic, rolled back)
    fa, fb = ent("product", "composio-swekit"), ent("product", "composio-swe-kit")  # an unmerged pair for the rolled-back checks
    conflict, cerr = sql(f"""begin; set local app.tenant_id = '{TENANT}';
        select temporal.begin_batch();
        select temporal.assert_state({q(fa)}, 'library_license', tstzrange('2026-01-01T00:00:00Z', null), p_payload => '{{"license_code": "MIT", "synthetic": true}}'::jsonb, p_temporal_basis => 'observation_bounded');
        select temporal.assert_state({q(fb)}, 'library_license', tstzrange('2026-01-01T00:00:00Z', null), p_payload => '{{"license_code": "Apache-2.0", "synthetic": true}}'::jsonb, p_temporal_basis => 'observation_bounded');
        select temporal.commit_batch({q(native_receipt('rv01-synthetic-conflict-a', {'synthetic': True}))}, 'rv01-synthetic-conflict-a-' || gen_random_uuid(), repeat('0', 64), '{{}}'::jsonb);
        select temporal.begin_batch();
        select catalog.merge_entities({q(fa)}, {q(fb)}, {q(native_receipt('rv01-synthetic-conflict-b', {'synthetic': True}))});
        select m.action || ':' || (select s.payload->>'license_code' from temporal.segment s where s.id = (m.row_key->>'id')::uuid) from catalog.identity_move m where m.table_name = 'temporal.segment';
        select 'winner keeps ' || (s.payload->>'license_code') from temporal.segment s join temporal.stream x on x.id = s.stream_id where x.subject_entity_id = {q(fb)} and x.kind = 'library_license' and s.k_to is null;
        rollback;""", tenant=False, allow_error=True)
    add(8, "partly", {"qwen_merge": idn["qwen_merge"], "qwen_moves": idn["qwen_after"]["moves"], "winner_facts_before": len(idn["qwen_before"]["winner"]["facts"]), "winner_facts_after": len(idn["qwen_after"]["winner"]["facts"]),
                      "closed_as_duplicate_in_qwen": idn["qwen_after"]["closed_as_duplicate"], "synthetic_conflict_rolled_back": (conflict or cerr or "").splitlines()[-2:]},
        "The real pair held facts on different benchmarks, so none collided: the loser's one fact, its edge and two unit links moved, and nothing was closed as a duplicate. "
        "The rule for a collision was then run on two planted licence facts inside a transaction that was rolled back: the loser's fact was closed as a duplicate and the winner kept its own. "
        "One claim link and the search index rows stayed on the loser, as logged.")

    # 9 undo
    b, a = idn["ms_before"], idn["ms_after_undo"]
    same = {side: {k: b[side][k] == a[side][k] for k in ("lifecycle", "facts", "edges", "identifiers", "aliases")} for side in ("loser", "winner")}
    hist9 = sql_rows(f"select change_kind, correction_reason, learned_at from api.changes_since({q(SINCE)}) where change_source = 'identity' and subject_entity_id = {q(lo)} order by learned_at")
    add(9, "met" if all(all(v.values()) for v in same.values()) and idn["ms_undo"]["not_reversed"] == 0 else "missed", {"same_as_before": same, "undo": idn["ms_undo"], "history": hist9})

    # 10 the price page at two dates
    add(10, "missed", {"lab_vs_today": pr["lab_vs_today"], "archived_vs_today": pr["archived_vs_today"], "archived_at": pr["archived_at"], "earlier_archive": pr.get("earlier_archive"),
                       "models_only_on_todays_page": pr["only_today"], "models_on_todays_page_not_in_lab": pr["not_in_lab"]},
        "No price of a model changed: the lab's values of 2026-11-09, today's page and the page archived on 2026-06-11 agree for every model they share, and the Wayback Machine holds no earlier copy of this URL. "
        "So no real price change could be shown. A real world change with its cause event was shown on two other facts instead: the SDK's name and the protocol's steward. "
        "What did change on the page is the model list: four models on today's page are not in the lab.")

    # 11 the planted misreading
    add(11, "met" if len(pr["planted"]) == 2 and pr["planted"][1][1:3] == ["correction", "misread"] and pr["planted"][0][5] == "true" else "missed",
        {"rows_amount_kind_reason_kfrom_kto_synthetic": pr["planted"], "retired_after_the_test": True})

    # 12 the same price again
    k_same = st["batches"]["prices-same-again"]["k"]
    listed = one(f"select count(*) from api.changes_since({q(SINCE)}) where knowledge_seq = {k_same}")
    add(12, "met" if pr["same_again"]["segments_before"] == pr["same_again"]["segments_after"] and listed == "0" else "missed", {"same_again": pr["same_again"], "rows_listed_for_that_batch": listed})

    # 13 why did the steward change, without and with proposals
    without = json.loads(one(f"select api.change_explanation(p_relationship => {q(rel['anthropic_maintains_mcp'])}, p_include_proposals => false)"))
    with_ = json.loads(one(f"select api.change_explanation(p_relationship => {q(rel['anthropic_maintains_mcp'])}, p_include_proposals => true)"))
    pp = with_.get("proposals") or []
    add(13, "met" if "proposals" not in without and len(pp) == 1 and pp[0]["authored_by_kind"] == "agent" and pp[0]["publication"] == "private" and pp[0]["ours"] else "missed",
        {"without": {"cause_event": (without.get("cause_event") or {}).get("kind"), "stated_reasons": [s["statement"] for s in without.get("stated_reasons") or []], "has_proposals_key": "proposals" in without},
         "with": [{k: p[k] for k in ("statement", "authored_by_kind", "authored_by", "review_state", "publication", "confidence")} for p in pp]})

    # 14 do the proposals appear in any existing read
    deep = ent("library", "deepagents")
    edge = one(f"select count(*) from catalog.relationship where kind = 'competes_with' and ((from_entity_id = {q(deep)} and to_entity_id = {q(sdk)}) or (from_entity_id = {q(sdk)} and to_entity_id = {q(deep)}))")
    as_claims = one("select count(*) from evidence.claim where statement ~ 'goodwill|ForgeCode and Forge Code are one product|Deep Agents and the Claude Agent SDK compete'")
    hits = one("select count(*) from api.search_knowledge('foundation so that other model vendors would keep adopting it without depending on a competitor goodwill', p_limit => 50) where snippet ~ 'goodwill'")
    in_changes = one(f"select count(*) from api.changes_since({q(SINCE)}) where new_value::text ~ 'goodwill' or old_value::text ~ 'goodwill'")
    owner = one("select count(*) from api.proposals()")
    reader, _ = as_role("app_reader", "select count(*) from api.proposals()")
    add(14, "met" if edge == "0" and as_claims == "0" and hits == "0" and in_changes == "0" and owner == "3" and reader == "0" else "missed",
        {"as_an_edge": edge, "as_claims": as_claims, "search_hits": hits, "in_change_listing": in_changes, "owner_sees": owner, "service_reader_sees": reader, "proposals": props})

    # ------------------------------------------------------------------------------------------------ checks
    check(1, "met" if "correction requires a reason" in (pr["rewrite_without_reason"] or "") else "missed", first_error(pr["rewrite_without_reason"]))
    check(2, "met" if "not_recorded is for backfill only" in (pr["not_recorded_refused"] or "") else "missed", (pr["not_recorded_refused"] or "").replace("\n", " ")[:200])
    _, e1 = sql(f"select catalog.merge_entities({q(ent('organization', 'dolly-sah'))}, {q(ent('person', 'dolly-sah'))}, null)", allow_error=True)
    g = ent("organization", "google")
    _, e2 = sql(f"select catalog.merge_entities({q(g)}, {q(g)}, null)", allow_error=True)
    _, e3 = sql(f"select catalog.merge_entities({q(lo)}, {q(g)}, null)", allow_error=True)
    errs = [first_error(x) for x in (e1, e2, e3)]
    check(3, "met" if all(errs) and len(set(errs)) == 3 else "missed", errs)
    check(4, "met" if idn["ms_merge_again"]["status"] == "already_merged" and idn["ms_merge_rows_after_again"] == "1" else "missed", {"second_call": idn["ms_merge_again"], "merge_rows": idn["ms_merge_rows_after_again"]})
    _, e5 = sql(f"""begin; set local app.tenant_id = '{TENANT}'; select temporal.begin_batch();
        select catalog.merge_entities({q(fa)}, {q(fb)}, {q(native_receipt('rv01-forced-failure', {'check': 5}))});
        select 1 / 0; commit;""", tenant=False, allow_error=True)
    after5 = sql_rows(f"select lifecycle, (select count(*) from catalog.entity_merge m where m.from_entity_id = e.id), (select open_k is null from temporal.knowledge_head limit 1) from catalog.entity e where e.id = {q(fa)}")
    check(5, "met" if "division by zero" in (e5 or "") and after5 == [["active", "0", "t"]] else "missed", {"error": first_error(e5), "loser_lifecycle_merge_rows_batch_closed": after5})
    _, e6 = as_role("pipeline_agent", f"select catalog.merge_entities({q(fa)}, {q(fb)}, null)")
    check(6, "met" if "permission denied" in (e6 or "") else "missed", first_error(e6))
    pid = props["identity"]["proposal_id"]
    _, e7a = as_role("pipeline_agent", f"select api.decide_proposal({q(pid)}, 'endorsed')")
    _, e7b = as_role("pipeline_agent", f"select api.publish_proposal({q(pid)})")
    _, e7c = as_role("pipeline_agent", f"update catalog.proposal set review_state = 'endorsed' where id = {q(pid)}")
    check(7, "partly" if all("permission denied" in (x or "") for x in (e7a, e7b, e7c)) else "missed", [first_error(x) for x in (e7a, e7b, e7c)],
          "Refused, but by the grant, with 'permission denied', not with HUMAN_REVIEW_NOT_AGENT_WRITABLE: no agent role may call the two functions or write the table, so the named error is never reached.")
    check(8, "met" if reader == "0" else "missed", {"service_reader_sees": reader, "owner_sees": owner})
    s_all = sql_rows(f"select entity_id, count(*) from api.search_knowledge('Microsoft', p_limit => 50) where entity_id in ({q(lo)}, {q(wi)}) group by 1")
    s_filter = sql_rows(f"select entity_id, count(*) from api.search_knowledge('Microsoft', p_entity_ids => array[{q(wi)}]::uuid[], p_limit => 50) group by 1")
    on_loser = one(f"select count(*) from retrieval.vector_item where entity_id = {q(lo)}")
    check(9, "met" if s_filter and all(r[0] == wi for r in s_filter) and all(r[0] == wi for r in s_all) else "missed",
          {"hits_by_entity_no_filter": s_all, "hits_by_entity_filtered_by_winner": s_filter, "index_rows_still_on_loser": on_loser, "winner": wi})
    views = sql_rows("select table_name from information_schema.views where table_schema = 'api' order by 1")
    failed = []
    for (v,) in views:
        _, err = sql(f"select count(*) from api.{v}", allow_error=True)
        if err:
            failed.append([v, first_error(err)])
    verified = one("select count(*) from api.verified_claims")
    check(10, "partly" if not failed and verified == "27" else "missed", {"api_views_read": len(views), "failed": failed, "verified_claims": verified},
          "Every api view still reads and the 27 verified claims are unchanged. No row-by-row comparison with the state before the migration was made: no baseline was saved before it.")
    check(11, "unrun", "run separately: python scripts/dev/dev_cli.py check")

    expected = json.load(open(os.path.join(UNIT, "EXPECTED.json"), encoding="utf-8"))
    for item in Q:
        x = next(i for i in expected["questions"] if i["n"] == item["n"])
        item.update(question=x["question"], expected=x["expected"])
    for item in CH:
        x = next(i for i in expected["checks"] if i["n"] == item["n"])
        item.update(check=x["check"], expected=x["expected"])
    out = {"unit": "RV01", "packet": "r1", "written": now_iso(), "lab_head": one("select max(version) from supabase_migrations.schema_migrations"), "knowledge_seq": one("select knowledge_seq from temporal.knowledge_head limit 1"),
           "questions": sorted(Q, key=lambda i: i["n"]), "checks": sorted(CH, key=lambda i: i["n"]), "spend": st.get("spend")}
    write_json(os.path.join(UNIT, "RESULTS.json"), out)
    for kind, items in (("Q", out["questions"]), ("C", out["checks"])):
        for i in items:
            log(f"{kind}{i['n']:>2} {i['verdict']:<7} {str(i.get('note', ''))[:110]}")
