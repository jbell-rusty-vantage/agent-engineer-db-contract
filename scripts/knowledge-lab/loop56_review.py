"""Build 08 loops 5 and 6, owner review (lab disposable-aieng-build04 only), recorded on John's written answers of 2026-11-15.

John answered the loop-5/6 decision matrix (NEXT-SESSION-BUILD-08-AFTER-LOOP-6 section 1) with 1A-9A and chose "J then G" for the
next batch. This script records what that review changes in the lab, and nothing else:

  record     writes the matrix answers to knowledge-loop-5/owner-review-2026-11-15.json (no database write).
  verdicts   row 2A: each current agent_proposed verdict of probes P14-P19 gets a human_confirmed row that supersedes it
             (append-only). Stops unless exactly 13 are found, so a revalidation verdict on another probe is never swept in.
  preview    row 9A: the exposure of the activity's head revision at each audience ceiling (read only).
  release    row 9A: a human release_review of the activity's exact closure, recorded through the product command API on the web
             surface under the lab author account b08author4, stating that it was made on John's written answer in the
             2026-11-15 session; then freeze_release. The activity is its own work, outside module release 1.

Order: record, then (with the lab running) verdicts, preview, release. Each lab step is idempotent and refuses to repeat itself.
Checkpoint the lab before the first database write (see the loop-4 review for the pg_dump recipe).
Run: python -I -X utf8 scripts/knowledge-lab/loop56_review.py record | verdicts | preview | release
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "product-lab"))
os.environ.setdefault("PRODUCT_LAB_WORKDIR", r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\lab")
import lab_common as C
from lab_common import *  # noqa

RUN4 = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-4")
RUN5 = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-5")
STATE = os.path.join(RUN4, "product-state.json")
REVIEW = os.path.join(RUN5, "owner-review-2026-11-15.json")
LOOP5_PROBES = ("P14", "P15", "P16", "P17", "P18", "P19")
EXPECTED_VERDICTS = 13
DECIDED_BY = "human:john (written answers 2026-11-15, loop-5/6 matrix 2A; recorded by the session agent)"
INSTRUCTION = ("Recorded under the lab author account b08author4 on John's written answer in the 2026-11-15 session (Build 08 loop-5/6 "
               "review, matrix row 9A): \"Release it: released as its own piece of work, under a human release review recorded on your "
               "instruction, the same way as the module. The learner exercise then ships with the module.\"")
CEILING = "named"   # the same ceiling as module release 1: invited learners, no public publication

MATRIX = [
    {"row": 1, "item": "Loop-5 determination, counts, Q1-Q9 (7 answered, 2 partial: Q5, Q8)", "answer": "A", "disposition": "accepted"},
    {"row": 2, "item": "The 13 verdicts of probes P14-P19", "answer": "A", "disposition": "accepted as proposed; human_confirmed"},
    {"row": 3, "item": "The triage of 104 candidates and the six probe selections", "answer": "A",
     "disposition": "six selections accepted; the other rows stay agent_proposed until probed (a working queue, not a judgment)"},
    {"row": 4, "item": "langchain issue tracker: suggested W2 vs current W3", "answer": "A", "disposition": "keep W3"},
    {"row": 5, "item": "D-62 evidence weight 0.15", "answer": "A", "disposition": "accepted"},
    {"row": 6, "item": "D-72 receipts target the existing claim; D-74 payload binding", "answer": "A", "disposition": "accepted; fixed for later batches"},
    {"row": 7, "item": "The 13 verified claims and the lab test seal key", "answer": "A",
     "disposition": "accepted for the lab; release-grade keys come with RV21"},
    {"row": 8, "item": "Promoted DDL 20261113150000 and 20261113160000", "answer": "A",
     "disposition": "accepted; P = A for RV10, RV12, RV13 in these scopes; H = A scoped to loops 5-6 for RV04, RV09, RV10, RV12, RV13, RV14, RV22"},
    {"row": 9, "item": "The module's activity (outside release 1)", "answer": "A", "disposition": "release it as its own work under a human release review"},
]
NEXT_BATCH = {"choice": "J then G", "meaning": "prepare J (second admission batch and retrieval polish) to ride with G (Mission Control runs the "
              "knowledge loop on Deep Agents); stop at the reviewable approval point", "approved_to_execute": False}


def review_log():
    if os.path.exists(REVIEW):
        return json.load(open(REVIEW, encoding="utf-8"))
    return {"reviewer": "John", "how": "answered in chat, 2026-11-15 session", "matrix": MATRIX, "next_batch": NEXT_BATCH, "recorded": {}}


def save_review(r):
    write_json(REVIEW, r)


def record():
    r = review_log()
    r.setdefault("at", now_iso())
    save_review(r)
    log(f"review written: {REVIEW}")


def confirm_verdicts():
    r = review_log()
    if r["recorded"].get("verdicts_human_confirmed"):
        log("already recorded")
        return
    like = " or ".join(f"p.slug like {q(p + '-%')}" for p in LOOP5_PROBES)
    rows = sql_json(f"""select to_jsonb(v) || jsonb_build_object('slug', p.slug) from verification.probe_verdict v
                          join verification.probe p on p.id = v.probe_id
                         where v.review_state = 'agent_proposed' and ({like})
                           and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)
                         order by p.slug, v.decided_at""")
    if len(rows) != EXPECTED_VERDICTS:
        raise SystemExit(f"expected {EXPECTED_VERDICTS} open P14-P19 verdicts, found {len(rows)}: stop and reconcile with section 24.5")
    made = []
    for v in rows:
        nid = one(f"""insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, supersedes_id)
                      values ({q(v['tenant_id'])}, {q(v['claim_id'])}, {q(v['probe_id'])}, {q(v['verdict'])}::evidence.support_verdict, {q(v['cells'])},
                              {q(v['rationale'] + ' | Human confirmation: John accepted the 13 loop-5 verdicts as proposed (matrix row 2A, written answer, 2026-11-15).')},
                              {q(DECIDED_BY)}, 'human_confirmed', {q(v['id'])})
                      returning id""")
        made.append({"probe": v["slug"], "claim_id": v["claim_id"], "verdict": v["verdict"], "superseded": v["id"], "confirmed": nid})
    r["recorded"]["verdicts_human_confirmed"] = {"count": len(made), "rows": made, "at": now_iso()}
    save_review(r)
    log(f"{len(made)} verdicts human_confirmed")


def _author():
    import loop4_review as R4   # reuses its GoTrue admin sign-in for the lab author account
    return R4.signin()


def preview():
    import run_lab as L
    u, st = _author()
    ws, root = st["workspace"], st["activity"]["revisionId"]
    out = {}
    for ceiling in ("workspace", "named", "public"):
        ex = L.ok(u.read(ws, "preview_exposure", {"root_revision_id": root, "ceiling": ceiling}))
        out[ceiling] = {"closure_sha256": ex["closure_sha256"], "items": len(ex["items"]), "blockers": [b["item_key"] for b in ex["blockers"]],
                        "withheld": [i["item_key"] for i in ex["items"] if i["disposition"] == "withheld"],
                        "dispositions": sorted({i["disposition"] for i in ex["items"]})}
    write_json(os.path.join(RUN5, "activity-exposure-preview.json"), out)
    print(json.dumps(out, indent=1))


def release():
    import run_lab as L
    u, st = _author()
    ws, root, work = st["workspace"], st["activity"]["revisionId"], st["activity"]["workId"]
    if st.get("activity_release"):
        log(f"already released: {st['activity_release']}")
        return
    ex = L.ok(u.read(ws, "preview_exposure", {"root_revision_id": root, "ceiling": CEILING}))
    if ex["blockers"]:
        raise SystemExit(f"exposure blockers at {CEILING}: {[b['item_key'] for b in ex['blockers']]} (stop: needs an owner disposition)")
    review = {"reviewType": "release_review", "decision": "approve", "closure_sha256": ex["closure_sha256"], "ceiling": CEILING, "audience": CEILING,
              "reviewer_of_record": "John (owner), by written answer", "recorded_by": "b08author4 (lab author account)", "note": INSTRUCTION}
    ev = L.ok(u.cmd(ws, "review_revision", {"work_id": work, "revision_id": root, "review": review}))["eventId"]
    rel = L.ok(u.cmd(ws, "freeze_release", {"root_revision_id": root, "ceiling": CEILING, "approval_event_id": ev}))
    st["activity_release"] = {"releaseId": rel["releaseId"], "releaseNo": rel["releaseNo"], "approvalEventId": ev, "ceiling": CEILING,
                              "closure_sha256": ex["closure_sha256"], "manifestArtifactId": rel["manifestArtifactId"], "at": now_iso()}
    write_json(STATE, st)
    r = review_log()
    r["recorded"]["activity_release"] = st["activity_release"] | {"instruction": INSTRUCTION}
    save_review(r)
    log(f"activity release {rel['releaseNo']} frozen: {rel['releaseId']} (event {ev}, ceiling {CEILING})")


if __name__ == "__main__":
    {"record": record, "verdicts": confirm_verdicts, "preview": preview, "release": release}[sys.argv[1]]()
