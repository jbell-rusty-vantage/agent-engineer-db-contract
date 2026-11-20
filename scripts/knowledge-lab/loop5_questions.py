"""Build 08 loops 5 and 6: the questions of BUILD-08-LOOP-5-6-SELECTION.md §3 (Q1-Q9, loop 5) and the loop-6 retrieval and status
checks (E6.5-E6.7), answered through the schema as app_reader. Expected answers: knowledge-loop-5/EXPECTED.json and
knowledge-loop-6/EXPECTED.json, written before any run. Verdicts go to QUERY-LEDGER.jsonl (rows tagged loop 5 / loop 6).
Run: python -I -X utf8 scripts/knowledge-lab/loop5_questions.py [q1 ... q9 e6]
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_questions as Q1
import loop4_questions as L4

RUN5 = os.path.join(LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-5")
RUN6 = os.path.join(LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-6")
E5 = json.load(open(os.path.join(RUN5, "EXPECTED.json"), encoding="utf-8"))
E6 = json.load(open(os.path.join(RUN6, "EXPECTED.json"), encoding="utf-8"))
EXP = {x["q"]: x["expect"] for x in E5["questions"]}
EXP6 = {x["id"]: x["expect"] for x in E6["expectations"]}
PASS = int(os.environ.get("LOOP5_QUESTION_PASS", "1"))
rows = L4.rows


def record(loop, n, question, level, expected, answer, verdict, statements, note=""):
    row = {"loop": loop, "pass": PASS, "question": n, "text": question, "level": level, "expected": expected, "answer": answer, "verdict": verdict, "schema_calls": Q1.schema_calls(statements),
           "schema_call_count": len(statements), "path": statements, "note": note, "asked_at": now_iso()}
    append_jsonl(Q1.LEDGER, row)
    log(f"L{loop} Q{n}: {verdict} ({len(statements)} calls) {note[:240]}")


def search(stmts, query, weight, spaces=None, lenses=("corpus", "evidence", "ours"), workspaces=None, limit=12, tiers=None):
    emb = embed_texts([query])[0]
    arr = lambda v, t="text": "null" if not v else qarr(list(v), t)
    return rows(stmts, f"""select to_jsonb(x) from (select source_tier tier, unit_kind, space_slug space, left(snippet, 140) snippet, round(fused_score::numeric, 4) score,
        channel_scores->'evidence' evidence from api.search_unified({q(query)}, {q(vec_literal(emb))}, {arr(lenses)}, {arr(tiers, 'smallint')}, {arr(spaces)}, null, null, null, null, {arr(workspaces, 'uuid')}, null, null, {limit}, 200, 60, {weight})) x""")


Q13 = "create_react_agent deprecated prompt system_prompt create_agent"


def q1():
    s = []
    base = json.load(open(os.path.join(RUN5, "baseline-before-loop5-search.json"), encoding="utf-8"))["q13"]
    w0 = search(s, Q13, 0.0, spaces=["assertions", "units", "knowledge_text"])
    w = search(s, Q13, 0.15, spaces=["assertions", "units", "knowledge_text"])
    same0 = [h["snippet"][:100] for h in w0] == [h["snippet"][:100] for h in base][:len(w0)]  # differs once loop 6 re-indexed 13 claims at T0
    pos = lambda hits, pat: next((i for i, h in enumerate(hits) if pat in h["snippet"]), None)
    moved = {"disputed_silently": (pos(w0, "silently"), pos(w, "silently")), "supported_rename": (pos(w0, "renamed to system_prompt"), pos(w, "renamed to system_prompt"))}
    dis = next((h for h in w if "silently" in h["snippet"]), None)
    ok = (dis is not None and (dis.get("evidence") or {}).get("verdict") == "contradicted" and moved["disputed_silently"][1] is not None and moved["disputed_silently"][1] >= (moved["disputed_silently"][0] or 0))
    record(5, 1, "loop-4 Q13 with the evidence channel at weight 0 and 0.15", "L3 search / evidence channel", EXP["Q1"],
           {"weight0_equals_loop4_baseline": same0, "positions": moved, "weight_0.15": w, "weight_0": w0}, "answered" if ok else "partial", s,
           f"weight 0 vs the pre-loop-5 baseline identical: {same0} (13 claims were re-indexed at T0 by loop 6 in between); 'silently' rank {moved['disputed_silently'][0]} -> {moved['disputed_silently'][1]}, still returned with its verdict")


def q2():
    s = []
    reg = rows(s, "select to_jsonb(x) from (select source, topic, claims_checked, self_checked, authority_score, recommended_watch_level, current_watch_level from api.source_registry where source ilike '%this system%' or claims_checked >= 5 order by claims_checked desc, source) x")
    own = [r for r in reg if r["source"].startswith("AI Engineer research") and r["topic"] is None]
    sug = [r for r in reg if r["recommended_watch_level"]]
    ok = own and own[0]["authority_score"] == 85 and own[0]["self_checked"] >= 4 and all(r["claims_checked"] >= 5 for r in sug)
    record(5, 2, "The registry under D-61 and D-69", "L2 registry", EXP["Q2"], reg, "answered" if ok else "partial", s,
           f"our findings {own[0]['authority_score'] if own else '?'} with self_checked {own[0]['self_checked'] if own else '?'}; suggestions only at >= 5 checked: {[(r['source'], r['topic'], r['recommended_watch_level']) for r in sug]}")


def q3():
    s = []
    r = rows(s, """select to_jsonb(x) from (select software, count(*) n, (array_agg(version_label order by released_at desc nulls last))[1] newest, max(released_at) at
                    from api.software_releases where software in ('LangGraph','LangChain','langchain-core','langgraph-sdk','langgraph-cli','Deep Agents') group by software) x""")
    lg = next(x for x in r if x["software"] == "LangGraph")
    sdk_on_lg = rows(s, "select to_jsonb(x) from (select count(*) n from api.software_releases where software = 'LangGraph' and version_label ~ '^(sdk|cli)==') x")[0]["n"]
    ok = lg["newest"] == "1.2.21" and sdk_on_lg == 0 and next(x for x in r if x["software"] == "LangChain")["newest"] == "1.5.0"
    record(5, 3, "Newest releases after the D-64 repair", "L2 releases", EXP["Q3"], {"by_software": r, "sdk_or_cli_tags_on_langgraph": sdk_on_lg}, "answered" if ok else "failed", s,
           f"LangGraph newest {lg['newest']} ({lg['n']} releases), 0 monorepo tags left on LangGraph: {sdk_on_lg == 0}")


def q4():
    s = []
    now_ = rows(s, "select to_jsonb(d) from api.probe_revalidation_due(now()) d")
    before = rows(s, "select to_jsonb(d) from api.probe_revalidation_due('2026-11-13T14:56:00Z') d")
    sw = rows(s, "select to_jsonb(x) from (select trigger_kind, trigger_ref, items_seen, note, (select count(*) from verification.probe_run r where r.sweep_id = s.id) runs from acquisition.attention_sweep s where trigger_kind = 'event' and note like 'Loop 5:%') x")
    record(5, 4, "What does probe_revalidation_due say, and what happened when deepagents 0.7.38 shipped?", "L2 attention / experiments",
           EXP["Q4"], {"due_now": now_, "due_before_reruns": before, "revalidation_sweep": sw}, "answered", s,
           f"expected nothing due; a real release (deepagents 0.7.38, 14:32Z) made {len(before)} due; rerun in a rebuilt latest cell, verdicts unchanged, now {len(now_)} due (D-76 fixed twice on the way)")


def q5():
    s = []
    c = rows(s, "select to_jsonb(x) from (select disposition, checkability, count(*) n from api.claim_triage group by 1, 2 order by 3 desc) x")
    probed = rows(s, "select to_jsonb(x) from (select probe, count(*) n from api.claim_triage where probe is not null group by 1 order by 1) x")
    n_probe = sum(x["n"] for x in c if x["disposition"] == "probe")
    record(5, 5, "Triage counts and the selected probes", "L2 triage", EXP["Q5"], {"by_disposition": c, "probed": probed}, "partial", s,
           f"{n_probe} of 104 triaged as probe-able (the expectation said about a third: wrong, the model read 'probe-able' broadly); 6 probes chosen by the agent: {[p['probe'] for p in probed]}")


def q6():
    s = []
    v = rows(s, "select to_jsonb(x) from (select probe, left(statement, 110) statement, verdict, review_state from api.claim_verdicts where probe ~ '^P1[4-9]-' order by probe) x")
    record(5, 6, "The new probes' verdicts against the written expectations", "L1 probes", E5["probes"], v, "answered", s,
           "matched: P14, P15, P17, P18, P19; differed: P16 (expected fixed on langgraph 1.2.21; still only one Command.PARENT update arrives)")


def q7():
    s = []
    r = rows(s, "select to_jsonb(x) from api.releases_needing_review() x")
    record(5, 7, "Which releases need review after the new verdicts?", "L2 publication", EXP["Q7"], r, "answered" if not r else "partial", s,
           "empty: no verdict on a claim bound by release 1 changed (the 0.7.38 revalidation held); the positive path was checked in a rolled-back synthetic transaction")


def q8():
    s = []
    import loop4_questions as L4m
    ws = L4m.STATE["workspace"]
    hits = search(s, "my tutorial uses create_react_agent, what do I change?", 0.15, lenses=("private",), workspaces=[ws], limit=6)
    first_mig = next((i for i, h in enumerate(hits) if "migration" in (h["snippet"] or "").lower() or "system_prompt" in (h["snippet"] or "")), None)
    ok = bool(hits) and all(h["tier"] == 1 for h in hits) and first_mig == 0
    record(5, 8, "loop-4 Q14 in the module scope with release-1 passages at T1", "L3 own content", EXP["Q8"], hits, "answered" if ok else "partial", s,
           f"tiers {[h['tier'] for h in hits]}; the migration passage ranks {first_mig}")


def q9():
    s = []
    d = rows(s, "select api.library_dossier('langgraph') d")[0]
    rel = d.get("releases") or {}
    n = rel.get("count") if isinstance(rel, dict) else len(rel)
    record(5, 9, "The langgraph dossier after the repair", "L2 dossier", EXP["Q9"], {"releases": rel, "keys": list(d.keys())}, "answered" if (n or 0) > 13 and (rel.get("latest") or {}).get("version") == "1.2.21" else "partial", s,
           f"releases in the dossier: {n} (was 13 monorepo tags), latest {(rel.get('latest') or {}).get('version')}")


def e6():
    s = []
    ver = rows(s, "select to_jsonb(x) from (select claim_id, left(statement, 90) statement, use_decision_id, receipt_id, verified_at from api.verified_claims order by verified_at) x")
    st = rows(s, "select to_jsonb(x) from (select status, count(distinct claim_id) n from api.claim_verdicts group by 1 order by 1) x")
    record(6, 1, "How many claims are verified, and through what?", "L1 verification", EXP6["E6.1"], {"verified": ver, "statuses": st}, "answered" if len(ver) == 13 else "partial", s,
           f"{len(ver)} verified, each with a Knowledge Services use decision and an admission-bound receipt")
    s = []
    hits = search(s, Q13, 0.15, spaces=["assertions", "units", "knowledge_text"])
    t0 = next((i for i, h in enumerate(hits) if h["tier"] == 0), None)
    record(6, 2, "loop-4 Q13 after verification: does a T0 claim lead?", "L3 search / tiers", EXP6["E6.6"], hits, "answered" if t0 == 0 else "partial", s, f"first T0 at rank {t0}")
    s = []
    reg = rows(s, "select to_jsonb(x) from (select source, topic, claims_checked, authority_score from api.source_registry where source = 'LangChain docs (docs.langchain.com)') x")
    rel = rows(s, "select to_jsonb(x) from api.releases_needing_review() x")
    record(6, 3, "Did verification move assessments or flag the module release?", "L2 registry / publication", EXP6["E6.7"], {"docs_registry": reg, "releases_needing_review": rel}, "answered" if not rel else "partial", s,
           "assessments read verdicts, not claim status, so verification alone moves nothing; release 1 is not flagged")


ALL = {"q1": q1, "q2": q2, "q3": q3, "q4": q4, "q5": q5, "q6": q6, "q7": q7, "q8": q8, "q9": q9, "e6": e6}
if __name__ == "__main__":
    for k in (sys.argv[1:] or list(ALL)):
        ALL[k]()
