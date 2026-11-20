"""Build 08 loop 6 (candidate F), AIDB side (lab disposable-aieng-build04 only): the evidence pack that Knowledge Services verifies,
and the readback after its admission run.

pack     every claim whose current probe verdict is human_confirmed `directly_supported` from a deterministic probe (executed,
         static_docs, resolution, registry_check; never live_model) and whose status is `proposed` is offered for admission. For each:
         the statement and its sha256, the probe and verdict, and every run of the verdict's cells with the captured output bytes
         (path, sha256 = evidence.source_capture.content_sha256) and verbatim quotes taken from those bytes (the observation keys
         the verdict relied on). Not offered, with the reason: qualified verdicts (the verified statement would have to be the
         qualified one), contradicted (already disputed), not reproduced, unverifiable, live arms. Writes
         knowledge-loop-6/admission-pack.json; the Knowledge Services harness reads it.
readback after the harness: api.verified_claims, claim statuses, receipts and admissions; writes knowledge-loop-6/readback.json.
Run: python -I -X utf8 scripts/knowledge-lab/loop6_admission.py pack | readback
"""
import glob, hashlib, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa

RUN6 = os.environ.get("ADMISSION_RUN_DIR") or os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-6")   # loop 7 (J) passes knowledge-loop-7
os.makedirs(RUN6, exist_ok=True)
CAPTURES = os.path.join(C.LAB, "sources")   # every dated capture folder (loop-4 and loop-5 probe outputs)
DETERMINISTIC = ("executed", "static_docs", "resolution", "registry_check")


def capture_file(sha):
    hits = [p for p in glob.glob(os.path.join(CAPTURES, "*", f"*-{sha[:12]}*")) if hashlib.sha256(open(p, "rb").read()).hexdigest() == sha]
    return hits[0] if hits else None


def cell_span(text, label):
    """The cell's region in a probe report, the same span the Knowledge Services harness uses (`{"cell": "<label>"` to the next cell)."""
    marker = '{"cell": ' + json.dumps(label)
    s = text.find(marker)
    if s < 0:
        return text   # a single-cell capture (loop 4)
    n = text.find('{"cell": ', s + len(marker))
    return text[s:] if n < 0 else text[s:n]


def quotes_for(text, observed, label=None):
    """Verbatim quotes from the capture bytes that locate one range inside the cell: loop 7 prefers the whole `checks` object the
    verdict relied on; otherwise single `"key": value` fragments that occur once in the cell."""
    region = cell_span(text, label) if label else text
    out = []
    if isinstance(observed, dict) and observed:
        whole = '"checks": ' + json.dumps(observed, sort_keys=True, ensure_ascii=False)
        if region.count(whole) == 1:
            return [whole]
    for k, v in (observed or {}).items():
        if isinstance(v, (bool, int, float, str)) or v is None:
            frag = f'"{k}": {json.dumps(v, ensure_ascii=False)}'
            if region.count(frag) == 1:   # the harness refuses QUOTE_NOT_UNIQUE_IN_CELL
                out.append(frag)
    return out


CONFIRMATIONS = {
    "restated": {"instrument": "written answer, 2026-11-15: John confirmed the 14 restated claims (D-80) in chat",
                 "rationale": "John confirmed this restated claim and its probe support (written answer in chat, 2026-11-15; D-80 restatements)."},
    "2026-11-13": {"instrument": "written instruction, matrix row 2A, 2026-11-13: loop-4 verdicts accepted as proposed",
                   "rationale": "John accepted the loop-4 verdicts as proposed (matrix row 2A, written instruction, 2026-11-13)."},
    "2026-11-15": {"instrument": "written answers, matrix row 2A, 2026-11-15: loop-5 verdicts (P14-P19) accepted as proposed",
                   "rationale": "John accepted the 13 loop-5 verdicts as proposed (matrix row 2A, written answers in chat, 2026-11-15)."},
}


def confirmation_for(decided_by):
    for day, c in CONFIRMATIONS.items():   # "restated" first: its decided_by also carries the date
        if day in (decided_by or ""):
            return c | {"decided_by": decided_by}
    raise SystemExit(f"no recorded owner confirmation matches decided_by={decided_by!r}")


def pack():
    rows = sql_json("""select to_jsonb(x) from (
      select v.id verdict_id, v.claim_id, v.verdict::text verdict, v.review_state, v.cells, v.rationale, v.decided_by, p.id probe_id, p.slug probe, p.kind probe_kind,
             p.script_path, p.script_sha256, c.statement, c.structured->'polarity' polarity,
             exists (select 1 from evidence.claim r where r.atomized_from_id = c.id and r.structured->>'path' = 'restatement') restated, c.claim_type::text claim_type, c.status::text status,
             (select cv.stated_by from api.claim_verdicts cv where cv.claim_id = c.id limit 1) stated_by,
             (select cv.channel from api.claim_verdicts cv where cv.claim_id = c.id limit 1) channel
        from verification.probe_verdict v join verification.probe p on p.id = v.probe_id join evidence.claim c on c.id = v.claim_id
       where not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)
       order by p.slug, c.statement) x""")
    offered, not_offered = [], []
    for r in rows:
        reason = None
        if r["review_state"] != "human_confirmed": reason = "verdict not human-confirmed"
        elif r["probe_kind"] not in DETERMINISTIC: reason = "live arm: never verifies alone"
        elif r["verdict"] == "supported_with_qualification": reason = "qualified: the verified statement would have to carry the qualification"
        elif r["verdict"] != "directly_supported": reason = f"verdict {r['verdict']}"
        elif r["status"] != "proposed": reason = f"claim status {r['status']}"
        elif r["restated"]: reason = "attribution-framed (D-80): its restatement is offered instead"
        if reason:
            not_offered.append({"claim_id": r["claim_id"], "probe": r["probe"], "verdict": r["verdict"], "status": r["status"], "statement": r["statement"], "reason": reason})
            continue
        runs = sql_json(f"""select to_jsonb(x) from (select distinct on (pr.cell_label) pr.id run_id, pr.cell_label, pr.outcome, pr.resolved, pr.lock_sha256, pr.started_at,
                                  sc.id capture_id, sc.content_sha256, sc.media_type, sc.request_url, pr.output_locator_id locator_id
                             from verification.probe_run pr join evidence.source_capture sc on sc.id = pr.output_capture_id
                            where pr.probe_id = {q(r['probe_id'])} and pr.cell_label = any({qarr(list(r['cells'].keys()))})
                            order by pr.cell_label, pr.started_at desc) x""")
        evidence = []
        for run in runs:
            path = capture_file(run["content_sha256"])
            text = open(path, encoding="utf-8").read() if path else ""
            qs = quotes_for(text, r["cells"].get(run["cell_label"]), run["cell_label"])
            evidence.append(run | {"file": path, "quotes": qs})
        r["confirmation"] = confirmation_for(r["decided_by"])
        if r.get("polarity") is None:
            r.pop("polarity", None)
        r["statement_sha256"] = hashlib.sha256(r["statement"].encode("utf-8")).hexdigest()
        r["runs"] = evidence
        r["ready"] = all(e["file"] and e["quotes"] for e in evidence) and bool(evidence)
        offered.append(r)
    out = {"schema": "aieng.claim-admission-pack.v1", "tenant": C.TENANT, "made_at": now_iso(), "use": "knowledge_ingestion.claim_verification",
           "policy": "a deterministic probe verdict that John confirmed, over captured probe output whose bytes match the capture digest",
           "offered": offered, "not_offered": not_offered}
    write_json(os.path.join(RUN6, "admission-pack.json"), out)
    log(f"offered {len(offered)} ({sum(o['ready'] for o in offered)} ready), not offered {len(not_offered)}")
    for o in offered:
        if not o["ready"]:
            log(f"  not ready: {o['probe']} {o['statement'][:60]} {[(e['cell_label'], bool(e['file']), len(e['quotes'])) for e in o['runs']]}")


def readback():
    out = {
        "verified": sql_json("select to_jsonb(v) from api.verified_claims v order by verified_at"),
        "status": dict(sql_rows("select status::text, count(*) from evidence.claim group by 1")),
        "admissions": int(one("select count(*) from verification.use_admission")),
        "use_decisions": sql_json("select to_jsonb(x) from (select use_decision_id, disposition, revocation_epoch from knowledge_verification.use_decision) x"),
        "admitted_receipts": int(one("select count(*) from orchestration.operation_receipt where requires_admission")),
    }
    write_json(os.path.join(RUN6, "readback.json"), out)
    log(f"verified {len(out['verified'])}; statuses {out['status']}; admissions {out['admissions']}; decisions {len(out['use_decisions'])}")


if __name__ == "__main__":
    {"pack": pack, "readback": readback}[sys.argv[1]]()
