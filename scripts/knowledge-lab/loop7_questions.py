"""Build 08 loop 7 (candidate J): questions answered through the schema as app_reader. Expected answers were written first in
knowledge-loop-7/EXPECTED.json. Verdicts go to QUERY-LEDGER.jsonl (rows tagged loop 7).
Run: python -I -X utf8 scripts/knowledge-lab/loop7_questions.py [q1 ... q5]
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_questions as Q1
import loop4_questions as L4

RUN7 = os.path.join(LAB, "knowledge-loop-7")
EXP = json.load(open(os.path.join(RUN7, "EXPECTED.json"), encoding="utf-8"))
rows = L4.rows
Q13 = "create_react_agent deprecated prompt system_prompt create_agent"


def record(n, question, level, expected, answer, verdict, statements, note=""):
    row = {"loop": 7, "pass": 1, "question": n, "text": question, "level": level, "expected": expected, "answer": answer, "verdict": verdict,
           "schema_calls": Q1.schema_calls(statements), "schema_call_count": len(statements), "path": statements, "note": note, "asked_at": now_iso()}
    append_jsonl(Q1.LEDGER, row)
    log(f"L7 Q{n}: {verdict} ({len(statements)} calls) {note[:260]}")


def search(stmts, query, collapse=True, spaces=None, lenses=("corpus", "evidence", "ours"), workspaces=None, limit=12, emb=None):
    emb = emb or embed_texts([query])[0]
    arr = lambda v, t="text": "null" if not v else qarr(list(v), t)
    return rows(stmts, f"""select to_jsonb(x) from (select target_kind, target_id, source_tier tier, space_slug space, left(snippet, 120) snippet, round(fused_score::numeric, 4) score,
        channel_scores->'evidence'->>'verdict' verdict, jsonb_array_length(coalesce(channel_scores->'collapsed', '[]'::jsonb)) collapsed
        from api.search_unified({q(query)}, {q(vec_literal(emb))}, {arr(lenses)}, null, {arr(spaces)}, null, null, null, null, {arr(workspaces, 'uuid')}, null, null,
                                {limit}, 200, 60, 0.15, {'true' if collapse else 'false'})) x""")


def dupes(hits):
    keys = [f"{h['target_kind']}:{h['target_id']}" for h in hits if h["target_id"]]
    return len(keys) - len(set(keys))


def q1():
    s = []
    emb = embed_texts([Q13])[0]
    off = search(s, Q13, False, spaces=["assertions", "units", "knowledge_text"], emb=emb)
    on = search(s, Q13, True, spaces=["assertions", "units", "knowledge_text"], emb=emb)
    ok = dupes(on) == 0 and dupes(off) > 0
    record(1, "D-77: loop-4 Q13 with and without collapse", "L3 search", EXP["J3_D77"], {"collapse": on, "no_collapse": off}, "answered" if ok else "partial", s,
           f"duplicate targets in the top 12: {dupes(off)} without collapse, {dupes(on)} with; first hit {on[0]['snippet'][:60] if on else None}")


def q2():
    s = []
    rs = rows(s, "select to_jsonb(x) from (select claim_id, status, qualified, probe, original_status, left(statement, 80) statement from api.claim_restatements order by probe, statement) x")
    vc = rows(s, "select count(*) from api.verified_claims")[0]
    ok = len(rs) == 14 and all(r["status"] == "verified" and r["original_status"] == "proposed" for r in rs) and vc == 27
    record(2, "D-80: the 14 restatements, their status and their originals", "L2 claims", EXP["J1_admission_batch_2"], {"restatements": rs, "verified_total": vc},
           "answered" if ok else "partial", s, f"{len(rs)} restatements, {sum(r['status'] == 'verified' for r in rs)} verified, {sum(bool(r['qualified']) for r in rs)} qualified; api.verified_claims = {vc}")


def q3():
    s = []
    hits = search(s, "two tools return Command.PARENT in one turn, only one update reaches the parent graph", True, spaces=["assertions", "knowledge_text"], limit=6)
    first = hits[0] if hits else {}
    ok = first.get("tier") == 0 and "post states" not in (first.get("snippet") or "")
    record(3, "A learner question about a restated finding", "L3 search", "the verified restatement (T0) leads; the attribution original is lower and returned once",
           hits, "answered" if ok else "partial", s, f"first hit tier {first.get('tier')}: {(first.get('snippet') or '')[:90]}")


def q4():
    s = []
    ws = L4.STATE["workspace"]
    hits = search(s, "my tutorial uses create_react_agent, what do I change?", True, lenses=("private",), workspaces=[ws], limit=6)
    first_mig = next((i for i, h in enumerate(hits) if "migration" in (h["snippet"] or "").lower()), None)
    record(4, "Q8 rerun: the module's migration section for the learner question", "L3 own content", EXP["J4_Q8"], hits, "answered" if first_mig == 0 else "partial", s,
           f"the migration passage ranks {first_mig}; module bindings are revision-level (no block_key), so the evidence channel cannot tell sections apart")


def q5():
    s = []
    n = rows(s, "select count(*) from api.claim_restatements")[0]
    record(5, "api.claim_restatements is the app_reader path", "L1 access", "readable as app_reader (base tables stay denied)", {"rows": n}, "answered" if n == 14 else "partial", s)


if __name__ == "__main__":
    for name in (sys.argv[1:] or ["q1", "q2", "q3", "q4", "q5"]):
        globals()[name]()
