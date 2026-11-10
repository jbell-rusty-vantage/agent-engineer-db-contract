"""Build 08 loop 2: traversal re-check on the regenerated workspace: report B's eight questions (loop 1) plus four new ones for the
loop-2 surfaces (benchmark -> leaderboard edition; device -> cheapest offering; symbol -> docs page -> module; advisory -> affected release).
A question passes when a page naming the operation/relation/function is reached in <= 4 reads. Rows tagged loop 2 go to QUERY-LEDGER.jsonl.
Run after `npm run workspace:build`: python -I -X utf8 scripts/knowledge-lab/loop2_traversal.py
"""
import json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import append_jsonl, now_iso, log
import loop1_traversal as T

NEW = [
    ("T9", "Which benchmark versions do we hold and how do I see what changed on a leaderboard between two captures?", ["benchmark", "leaderboard", "edition"], r"api\.(benchmarks|leaderboard_diff|benchmark_scores)"),
    ("T10", "What is the cheapest on-demand H100 across providers right now, with the claim behind the price?", ["cheapest", "compute", "offering"], r"api\.(cheapest_compute|compute_offerings)"),
    ("T11", "Which public symbols changed between two releases of a repository, and which docs page explains a symbol?", ["symbol", "release", "docs"], r"api\.(symbol_changes|api_symbols)|content\.unit_link"),
    ("T12", "Which advisories affect a library version, with the first patched version?", ["advisory", "affected", "version"], r"api\.(advisories_for|advisories)"),
]


def main():
    index = T.load_index()
    start = open(os.path.join(T.WS, "START_HERE.md"), encoding="utf-8").read()
    results = []
    for tid, question, keywords, target in T.QUESTIONS + NEW:
        reads = ["START_HERE.md"]
        hits = T.search(index, keywords)
        reads.append("search/index.json (rg)")
        reached = None
        for h in hits[:3]:
            page = h.get("path")
            if not page:
                continue
            reads.append(page)
            p = os.path.join(T.WS, page.split("#")[0])
            text = open(p, encoding="utf-8").read() if os.path.exists(p) else ""
            if re.search(target, h["id"]) or re.search(target, h.get("qualified_name", "")) or re.search(target, text):
                reached = h["id"]
                break
        router_hit = bool(re.search(target.replace("op:", "").split("|")[0].split("(")[0].replace("\\", ""), start))
        verdict = "answered" if reached and len(reads) <= 4 else ("partial" if reached else "unanswerable")
        row = {"loop": 2, "question": tid, "text": question, "level": "workspace traversal", "expected": target, "answer": {"reached": reached, "reads": reads, "router_names_target": router_hit, "top_hits": [h["id"] for h in hits[:5]]},
               "verdict": verdict, "delta": None if verdict == "answered" else "D-W: search index needs the missing alias/summary", "schema_calls": [], "schema_call_count": len(reads), "path": reads, "note": f"{len(reads)} reads", "asked_at": now_iso()}
        results.append(row)
        append_jsonl(T.LEDGER, row)
        log(f"{tid}: {verdict} in {len(reads)} reads -> {reached}")
    return results


if __name__ == "__main__":
    main()
