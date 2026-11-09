"""Build 08 loop 1: report B's traversal questions, re-run on the regenerated workspace.

Report B (2026-11-08 session scratchpad) is not preserved; its eight agent questions are RECONSTRUCTED here from §12.7's
findings (product operations hidden, no op pages, stale scopes, no lens, no stemming). Each question is answered by walking the
workspace the way an agent would: START_HERE -> (MAP | search/index.json hit) -> task/op/domain page -> relation/function page.
A question passes when a page naming the operation/relation/function is reached in <= 4 reads. Writes T-rows to QUERY-LEDGER.jsonl.
"""
import json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import append_jsonl, now_iso, log

WS = r"C:\Users\Pinda\Proyectos\BellLabs\aiengineer\ai-engineer-db-contract\workspace"
LEDGER = r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\10-review-workspace\reviews\QUERY-LEDGER.jsonl"

QUESTIONS = [
    ("T1", "Which operation searches my private notes and course material, and how do I call it?", ["search", "private", "note"], r"op:search|ops/search.md"),
    ("T2", "Where is a model offering's current input-token price stored and how do I read it with its source?", ["price", "offering", "locator"], r"api\.(model_offerings|fact_locators|price_history)"),
    ("T3", "How do I find what changed on vendor pricing pages since a date, with when we learned it?", ["changed", "since", "clock"], r"api\.changes_since|content\.unit_change"),
    ("T4", "Which operation records a learner's assessment result, and which table holds it?", ["grading", "result", "assessment"], r"op:record_grading|learning\.assessment_result"),
    ("T5", "How do I get the transcript segments of a talk around a timecode?", ["talk", "timecode", "transcript"], r"api\.talk_segments|transcript_segment"),
    ("T6", "Which of our modules bind the LangGraph library and would be affected by a new release?", ["module", "release", "affected"], r"api\.modules_(affected_by_release|using_software)"),
    ("T7", "Which operation lets an agent propose a research brief, and which operation accepts it (people only)?", ["propose", "research", "accept"], r"op:(propose_research|accept_research)"),
    ("T8", "How does a captured page become typed units with a census, and which tables hold the grammar?", ["census", "unit", "grammar"], r"content\.(unit_kind|structure_census|document_node)"),
]


def load_index():
    return json.load(open(os.path.join(WS, "search", "index.json"), encoding="utf-8"))


def search(index, keywords):
    scored = []
    for e in index:
        hay = " ".join([e.get("qualified_name", ""), e.get("summary") or "", " ".join(e.get("aliases") or []), " ".join(map(str, e.get("tokens") or []))]).lower()
        score = sum(1 for k in keywords if k.lower() in hay)
        if score:
            scored.append((score, 0 if e.get("lens") in ("machinery", "legacy") else 1, e))
    scored.sort(key=lambda x: (-x[0], -x[1], x[2]["id"]))
    return [e for _, _, e in scored[:8]]


def main():
    index = load_index()
    start = open(os.path.join(WS, "START_HERE.md"), encoding="utf-8").read()
    results = []
    for tid, question, keywords, target in QUESTIONS:
        reads = ["START_HERE.md"]
        hits = search(index, keywords)
        reads.append("search/index.json (rg)")
        reached = None
        for h in hits[:3]:
            page = h.get("path")
            if not page:
                continue
            reads.append(page)
            text = open(os.path.join(WS, page.split("#")[0]), encoding="utf-8").read() if os.path.exists(os.path.join(WS, page.split("#")[0])) else ""
            if re.search(target, h["id"]) or re.search(target, h.get("qualified_name", "")) or re.search(target, text):
                reached = h["id"]
                break
        router_hit = bool(re.search(target.replace("op:", "").split("|")[0].split("(")[0], start))
        verdict = "answered" if reached and len(reads) <= 4 else ("partial" if reached else "unanswerable")
        row = {"question": tid, "text": question, "level": "workspace traversal (report B, reconstructed)", "expected": target, "answer": {"reached": reached, "reads": reads, "router_names_target": router_hit, "top_hits": [h["id"] for h in hits[:5]]},
               "verdict": verdict, "delta": None if verdict == "answered" else "D-W: search index needs the missing alias/summary", "schema_calls": [], "schema_call_count": len(reads), "path": reads, "note": f"{len(reads)} reads", "asked_at": now_iso()}
        results.append(row)
        append_jsonl(LEDGER, row)
        log(f"{tid}: {verdict} in {len(reads)} reads -> {reached}")
    return results


if __name__ == "__main__":
    main()
