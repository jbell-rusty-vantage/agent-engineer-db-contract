"""Build 08 loop 3: traversal re-check on the regenerated workspace: T1-T8 (loop 1), T9-T12 (loop 2; T9 has its router line now) and four
new questions for the loop-3 surfaces (symbol history, talks about a concept with timecodes, capability manifests, claim candidates and
the docs they concern). A question passes when a page naming the relation/function is reached in <= 4 reads. Rows tagged loop 3.
Run after the workspace build: python -I -X utf8 scripts/knowledge-lab/loop3_traversal.py
"""
import json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import append_jsonl, now_iso, log
import loop1_traversal as T
import loop2_traversal as T2

NEW = [
    ("T13", "In which release did a public API symbol first appear, and which docs sections explain it?", ["symbol", "history", "release", "docs"], r"api\.(symbol_history|symbol_docs)"),
    ("T14", "Which talks are about a concept, and at which timecode does each discuss it (digest items and passages)?", ["talks", "about", "digest", "timecode"], r"api\.(talks_about|digest_items|digest_item_passages)"),
    ("T15", "Which tools does an MCP server expose, which files does a skill bundle contain, and at which custody level do we hold it?", ["mcp", "tools", "bundle", "custody"], r"api\.(mcp_tools|bundle_files|capabilities)"),
    ("T16", "What does a speaker state in a talk, and which library docs does that claim candidate concern?", ["claim", "speaker", "surfaces", "consistency"], r"api\.(claim_surfaces|claim_candidates)"),
]


def main():
    index = T.load_index()
    start = open(os.path.join(T.WS, "START_HERE.md"), encoding="utf-8").read()
    for tid, question, keywords, target in T.QUESTIONS + T2.NEW + NEW:
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
        verdict = "answered" if reached and len(reads) <= 4 else ("partial" if reached else "unanswerable")
        row = {"loop": 3, "question": tid, "text": question, "level": "workspace traversal", "expected": target, "answer": {"reached": reached, "reads": reads, "top_hits": [h["id"] for h in hits[:5]]},
               "verdict": verdict, "delta": None if verdict == "answered" else "D-W: the search index needs an alias or a task page for this question", "schema_calls": [], "schema_call_count": len(reads), "path": reads, "note": f"{len(reads)} reads", "asked_at": now_iso()}
        append_jsonl(T.LEDGER, row)
        log(f"{tid}: {verdict} in {len(reads)} reads -> {reached}")


if __name__ == "__main__":
    main()
