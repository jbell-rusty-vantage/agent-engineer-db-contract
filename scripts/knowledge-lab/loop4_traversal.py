"""Build 08 loop 4: traversal re-check on the regenerated workspace: T1-T16 (loops 1-3) and four new questions for the loop-4 surfaces
(source registry, attention due-list, probe verdicts, library dossier). A question passes when a page naming the relation/function is
reached in <= 4 reads. Rows tagged loop 4.
Run after the workspace build: python -I -X utf8 scripts/knowledge-lab/loop4_traversal.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import append_jsonl, now_iso, log
import loop1_traversal as T
import loop2_traversal as T2
import loop3_traversal as T3

NEW = [
    ("T17", "Which sources are trustworthy on a library, with their track record of checked claims?", ["source", "registry", "assessment", "track"], r"api\.(source_registry|source_track_record)"),
    ("T18", "Which watch policies are due now, by cadence or by a release event, for a Mission Control watch mission?", ["attention", "due", "watch", "policy"], r"api\.(attention_due|attention_policies)"),
    ("T19", "What did a probe observe in each version cell, and what verdict did it give each claim?", ["probe", "verdict", "matrix", "claim"], r"api\.(probe_matrix|claim_verdicts|probes)"),
    ("T20", "Give me the report on a library: releases, open community claims, probes and ranked sources", ["library", "dossier", "report", "community"], r"api\.(library_dossier|community_claims)"),
]


def main():
    index = T.load_index()
    for tid, question, keywords, target in T.QUESTIONS + T2.NEW + T3.NEW + NEW:
        reads = ["START_HERE.md", "search/index.json (rg)"]
        hits = T.search(index, keywords)
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
        verdict = "answered" if reached and len(reads) <= 4 else ("partial" if reached else "unanswerable")
        append_jsonl(T.LEDGER, {"loop": 4, "question": tid, "text": question, "level": "workspace traversal", "expected": target, "answer": {"reached": reached, "reads": reads, "top_hits": [h["id"] for h in hits[:5]]},
                                "verdict": verdict, "schema_calls": [], "schema_call_count": len(reads), "path": reads, "note": f"{len(reads)} reads", "asked_at": now_iso()})
        log(f"{tid}: {verdict} in {len(reads)} reads -> {reached}")


if __name__ == "__main__":
    main()
