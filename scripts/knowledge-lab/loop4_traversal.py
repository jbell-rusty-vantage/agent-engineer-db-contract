"""Build 08 loop 4: traversal re-check on the regenerated workspace: T1-T16 (loops 1-3) and four new questions for the loop-4 surfaces
(source registry, attention due-list, probe verdicts, library dossier). A question passes when a page naming the relation/function is
reached in <= 4 reads. Rows tagged loop 4.
Extended 2026-11-16 (contract 0.7.0): T21-T29 for the verified-knowledge and source-intelligence guidance (verified claims, one claim
with its evidence and verdicts, conflicts, restatements, triage, source trust, the three due lists, what a release affects, attention
policies). Rows tagged with the batch they belong to.
Run after the workspace build: python -I -X utf8 scripts/knowledge-lab/loop4_traversal.py
The ledger is the review workspace's QUERY-LEDGER.jsonl; set KNOWLEDGE_LAB_QUERY_LEDGER to write the rows somewhere else.
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

VERIFIED = [
    ("T21", "What is verified about LangGraph: which claims passed a Knowledge Services admission?", ["verified", "claims", "admission"], r"api\.verified_claims"),
    ("T22", "For one claim, what evidence and probe verdict stand behind it, and what did the probe observe in each cell?", ["one claim", "evidence", "verdict"], r"api\.(claim_verdicts|probe_matrix)"),
    ("T23", "Why is a claim disputed: which other statement conflicts with it, and has the conflict been reconciled?", ["disputed", "conflict", "reconciliation"], r"api\.claim_conflicts"),
    ("T24", "A claim was restated: what was the attribution-framed original, and what did the restatement qualify or drop?", ["restated", "restatement", "original"], r"api\.claim_restatements"),
    ("T25", "How much do we trust a source on a topic, and which checked claims is that based on?", ["trust", "source", "topic", "track record"], r"api\.(source_registry|source_track_record)"),
    ("T26", "What is due now: sources to sweep, probes to rerun, releases of ours to review?", ["due", "probes to rerun", "releases to review"], r"api\.(attention_due|probe_revalidation_due|releases_needing_review)"),
    ("T27", "A new library release shipped: which of our modules, probes and frozen releases does it affect?", ["release", "affect", "probes", "modules"], r"api\.(modules_affected_by_release|probe_revalidation_due)"),
    ("T28", "Which claim candidates were judged not checkable or duplicates before any probe ran?", ["triage", "checkable", "disposition"], r"(api|verification)\.claim_triage"),
    ("T29", "Which attention policies exist, at which watch level, and when did each last sweep?", ["attention", "watch level", "sweep"], r"api\.attention_policies|acquisition\.attention_(policy|sweep)"),
]


def main():
    index = T.load_index()
    ledger = os.environ.get("KNOWLEDGE_LAB_QUERY_LEDGER", T.LEDGER)
    failed = 0
    for tid, question, keywords, target in T.QUESTIONS + T2.NEW + T3.NEW + NEW + VERIFIED:
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
        batch = "verified-knowledge-guidance-2026-11-16" if (tid, question, keywords, target) in VERIFIED else 4
        failed += verdict != "answered"
        append_jsonl(ledger, {"loop": batch, "question": tid, "text": question, "level": "workspace traversal", "expected": target, "answer": {"reached": reached, "reads": reads, "top_hits": [h["id"] for h in hits[:5]]},
                                "verdict": verdict, "schema_calls": [], "schema_call_count": len(reads), "path": reads, "note": f"{len(reads)} reads", "asked_at": now_iso()})
        log(f"{tid}: {verdict} in {len(reads)} reads -> {reached}")
    log(f"traversal: {len(T.QUESTIONS + T2.NEW + T3.NEW + NEW + VERIFIED) - failed} answered in four reads or fewer, {failed} not; ledger {ledger}")
    return failed


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
