"""Build 08 loop 4, owner review (lab disposable-aieng-build04 only), recorded on John's written instruction of 2026-11-13.

John answered the loop-4 decision matrix "1A 2A 3A 4A 5A 6A 7A 8A" and marked the five digest spot-check items. This script
records what that review changes in the lab, and nothing else:

  verdicts   row 2A: each current agent_proposed probe verdict gets a human_confirmed row that supersedes it (append-only).
  preview    row 7A: the exposure of the module's head revision at each audience ceiling (read only).
  release    row 7A: a human release_review of the exact closure, recorded through the product command API on the web surface
             under the lab author account b08author4 (the module's author seat), stating that it was made on John's written
             instruction in this session; then freeze_release (release 1).
  digest     row 9: John's marks for the five digest items, written to knowledge-loop-4/digest-spot-check-marks.json.

The author account's session token was deleted after loop 4; `signin` sets a fresh random password through the GoTrue admin API
of the lab stack and signs in (lab fixture only; the password is never written anywhere).
Run: python -I -X utf8 scripts/knowledge-lab/loop4_review.py verdicts | preview | release | digest
"""
import json, os, sys, uuid
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "product-lab"))
os.environ.setdefault("PRODUCT_LAB_WORKDIR", r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\11-build04-lab")
import lab_common as C
from lab_common import *  # noqa
import run_lab as L

RUN4 = os.path.join(C.LAB, "knowledge-loop-4")
STATE = os.path.join(RUN4, "product-state.json")
REVIEW = os.path.join(RUN4, "owner-review-2026-11-13.json")
INSTRUCTION = ("Recorded under the lab author account b08author4 on John's written instruction in the 2026-11-13 session "
               "(Build 08 loop-4 review, matrix row 7A): \"For row 7, I explicitly approve releasing the module: record the human "
               "release review under the lab author account, stating that it was made on my written instruction in this session, "
               "then freeze release 1.\"")
CEILING = "named"   # invited learners (John taking the module) without public publication; public publication is a separate scope


def review_log():
    return json.load(open(REVIEW, encoding="utf-8")) if os.path.exists(REVIEW) else {"matrix": "1A 2A 3A 4A 5A 6A 7A 8A", "recorded": {}}


def save_review(r):
    write_json(REVIEW, r)


def signin():
    st = json.load(open(STATE, encoding="utf-8"))
    uid = st["author_id"]
    s, b = L.http("GET", f"/auth/v1/admin/users/{uid}", token=L.SERVICE, key=L.SERVICE)
    assert s == 200, (s, b)
    email, pw = b["email"], uuid.uuid4().hex
    s, b = L.http("PUT", f"/auth/v1/admin/users/{uid}", {"password": pw}, token=L.SERVICE, key=L.SERVICE)
    assert s == 200, (s, b)
    s, b = L.http("POST", "/auth/v1/token?grant_type=password", {"email": email, "password": pw})
    assert s == 200, (s, b)
    u = L.User.__new__(L.User)
    u.label, u.id, u.email, u.token, u.client_token = "b08author4", uid, email, b["access_token"], None
    return u, st


def confirm_verdicts():
    rows = sql_json("""select to_jsonb(v) from verification.probe_verdict v
                        where v.review_state = 'agent_proposed' and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)
                        order by v.decided_at""")
    made = []
    for v in rows:
        nid = one(f"""insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, supersedes_id)
                      values ({q(v['tenant_id'])}, {q(v['claim_id'])}, {q(v['probe_id'])}, {q(v['verdict'])}::evidence.support_verdict, {q(v['cells'])},
                              {q(v['rationale'] + ' | Human confirmation: John accepted the 19 loop-4 verdicts as proposed (matrix row 2A, written instruction, 2026-11-13).')},
                              'human:john (written instruction 2026-11-13, loop-4 matrix 2A; recorded by the session agent)', 'human_confirmed', {q(v['id'])})
                      returning id""")
        made.append({"claim_id": v["claim_id"], "probe_id": v["probe_id"], "verdict": v["verdict"], "superseded": v["id"], "confirmed": nid})
    r = review_log()
    r["recorded"]["verdicts_human_confirmed"] = {"count": len(made), "rows": made, "at": now_iso()}
    save_review(r)
    log(f"{len(made)} verdicts human_confirmed")


def preview():
    u, st = signin()
    ws, root = st["workspace"], st["module"]["revisionId"]
    out = {}
    for ceiling in ("workspace", "named", "public"):
        ex = L.ok(u.read(ws, "preview_exposure", {"root_revision_id": root, "ceiling": ceiling}))
        out[ceiling] = {"closure_sha256": ex["closure_sha256"], "items": len(ex["items"]), "blockers": [b["item_key"] for b in ex["blockers"]],
                        "withheld": [i["item_key"] for i in ex["items"] if i["disposition"] == "withheld"],
                        "dispositions": sorted({i["disposition"] for i in ex["items"]})}
    write_json(os.path.join(RUN4, "release-exposure-preview.json"), out)
    print(json.dumps(out, indent=1))


def release():
    u, st = signin()
    ws, root, work = st["workspace"], st["module"]["revisionId"], st["module"]["workId"]
    if st.get("release"):
        log(f"already released: {st['release']}")
        return
    ex = L.ok(u.read(ws, "preview_exposure", {"root_revision_id": root, "ceiling": CEILING}))
    if ex["blockers"]:
        raise SystemExit(f"exposure blockers at {CEILING}: {[b['item_key'] for b in ex['blockers']]} (stop: needs an owner disposition)")
    review = {"reviewType": "release_review", "decision": "approve", "closure_sha256": ex["closure_sha256"], "ceiling": CEILING, "audience": CEILING,
              "reviewer_of_record": "John (owner), by written instruction", "recorded_by": "b08author4 (lab author account)", "note": INSTRUCTION}
    ev = L.ok(u.cmd(ws, "review_revision", {"work_id": work, "revision_id": root, "review": review}))["eventId"]
    rel = L.ok(u.cmd(ws, "freeze_release", {"root_revision_id": root, "ceiling": CEILING, "approval_event_id": ev}))
    st["release"] = {"releaseId": rel["releaseId"], "releaseNo": rel["releaseNo"], "approvalEventId": ev, "ceiling": CEILING,
                     "closure_sha256": ex["closure_sha256"], "manifestArtifactId": rel["manifestArtifactId"], "at": now_iso()}
    write_json(STATE, st)
    r = review_log()
    r["recorded"]["release"] = st["release"] | {"instruction": INSTRUCTION}
    save_review(r)
    log(f"release {rel['releaseNo']} frozen: {rel['releaseId']} (event {ev}, ceiling {CEILING})")


MARKS = [
    {"n": 1, "item_kind": "key_point", "document": "Improving Agents is a Data Mining Problem (Vivek Trivedy, LangChain)", "mark": "faithful",
     "agent_note": "the cited passages carry the goal, ship and collect-traces steps; the mine/curate/experiment steps are outside the three anchors"},
    {"n": 2, "item_kind": "limitation", "document": "Improving Agents is a Data Mining Problem (Vivek Trivedy, LangChain)", "mark": "faithful", "agent_note": None},
    {"n": 3, "item_kind": "recommendation", "document": "Improving Agents is a Data Mining Problem (Vivek Trivedy, LangChain)", "mark": "faithful", "agent_note": None},
    {"n": 4, "item_kind": "key_point", "document": "LangChain docs: oss/deepagents/code/hooks", "mark": "faithful",
     "agent_note": "the spot-check file truncates the passages; the full passages (read from the lab) state the precedence list and concurrency"},
    {"n": 5, "item_kind": "method", "document": "LangChain docs: oss/deepagents/code/hooks", "mark": "faithful",
     "agent_note": "the full passage states the 600 s / 30 s UserPromptSubmit defaults"},
]


def digest():
    write_json(os.path.join(RUN4, "digest-spot-check-marks.json"), {"reviewer": "John", "at": now_iso(), "how": "marked in chat, 2026-11-13 session", "marks": MARKS,
                                                                    "result": "5 faithful, 0 loose, 0 wrong: the provisional digest quality bar is closed as accepted"})
    r = review_log()
    r["recorded"]["digest_spot_check"] = {"faithful": 5, "loose": 0, "wrong": 0}
    save_review(r)
    log("digest marks recorded")


if __name__ == "__main__":
    {"verdicts": confirm_verdicts, "preview": preview, "release": release, "digest": digest}[sys.argv[1]]()
