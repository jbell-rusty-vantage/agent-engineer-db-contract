"""Build 08 loop 8 (candidate G): the AI Engineer side of the knowledge-loop watch mission that Mission Control runs on Deep Agents.
Approved by John 2026-11-15 ("complete them both now. J and G. I approve."). Lab disposable-aieng-build04 only.

Each command is what one Mission Control tool calls (tests/fixtures/aieng_watch_tools.py in platform/mission-control). Every write
carries the Mission Control invocation that caused it: the operation intent has origin_kind `mission_invocation` with mc_mission_id,
mc_run_id, mc_operation_id, mc_operation_attempt, mc_execution_generation and mc_lane; sweeps and probe runs have origin_kind `mission`
and the AI Engineer mission row (orchestration.mission) whose budget bounds the work across runs.

  releases  --mission S --invocation J   PyPI JSON for the watched libraries, captured under a mission sweep (vendor-issues-on-release);
                                        stable releases newer than the catalog are recorded (version_of + release_published)
  due       --mission S --invocation J   api.attention_due() and api.probe_revalidation_due() (read only)
  rerun     --mission S --invocation J   the due deterministic probes in a rebuilt latest cell, registered under a mission sweep
                                        (probe-revalidation); verdict rules recomputed; a changed verdict is a new agent_proposed row
  admit     --mission S --invocation J   the admission pack; when it has proposed claims, the Knowledge Services harness (subprocess)
  status    --mission S [--run R]        the mission's sweeps (read only), for the verifier
Budget: before any write, spend = sum(attention_sweep.spend_usd) of the mission; spend >= orchestration.mission.budget_cost_usd records a
`budget_stopped` sweep and does nothing else. Output: one JSON object on stdout.
"""
import argparse, glob, json, os, subprocess, sys, uuid
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_process as L1
import loop4_process as P4
import loop4_probes as R
import loop5_process as P5

RUN8 = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-8")
os.makedirs(RUN8, exist_ok=True)
PLAN4 = {k: v[0] for k, v in R.PLAN.items()}   # the loop-4 probe scripts, before a rerun narrows R.PLAN
R.OUT = os.path.join(RUN8, "probe-runs")
os.makedirs(R.OUT, exist_ok=True)
WATCHED = {"langgraph": ("LangGraph", "0.6.0"), "langchain": ("LangChain", "1.0.0"), "langchain-core": ("langchain-core", "1.0.0"), "deepagents": ("Deep Agents", "0.7.0")}
LOOP5_PLAN = {"P14": "p14_checkpoint_ns.py", "P15": "p15_invalid_tool_calls.py", "P16": "p16_command_parent.py", "P17": "p17_mustache_escaping.py",
              "P18": "p18_example_selector.py", "P19": "p19_subagent_context.py"}
KS = os.path.normpath(os.path.join(C.LAB, "..", "..", "knowledge-services"))
OUT = {}


def mission_row(slug):
    rows = sql_json(f"select to_jsonb(m) from orchestration.mission m where m.slug = {q(slug)}")
    if not rows:
        raise SystemExit(f"no AI Engineer mission {slug}")
    return rows[0]


def spent(mid):
    return float(one(f"select coalesce(sum(spend_usd), 0) from acquisition.attention_sweep where mission_id = {q(mid)}") or 0)


def mission_receipt(label, payload, m, inv):
    digest = "sha256:" + sha256_text(label + json.dumps(payload, sort_keys=True) + json.dumps(inv, sort_keys=True))
    intent, receipt = str(uuid.uuid4()), str(uuid.uuid4())
    sql(f"""insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, approval_state, mission_id,
                                                      origin_digest, origin_kind, mc_mission_id, mc_run_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane)
            values ({q(intent)}, {q(TENANT)}, 'knowledge_ingestion', 1, {q(dict(payload, label=label, mission=m['slug']))}, '[]'::jsonb, {q('b08-l8-' + label + '-' + intent[:8])}, 'approved',
                    {q(m['id'])}, {q(digest)}, 'mission_invocation', {q(inv['mc_mission_id'])}, {q(inv['mc_run_id'])}, {q(inv['mc_operation_id'])},
                    {int(inv['mc_operation_attempt'])}, {int(inv['mc_execution_generation'])}, {q(inv['mc_lane'])});
            insert into orchestration.operation_receipt(id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
            values ({q(receipt)}, {q(intent)}, 'knowledge-lab/loop8-watch', '[]'::jsonb, 'applied', {q({'label': label})}, '[]'::jsonb, false, {q(digest)})""")
    return receipt


def open_sweep(policy, trigger, ref, note, m, inv):
    sid = str(uuid.uuid4())
    ref = dict(ref, mc_run_id=inv["mc_run_id"], mc_operation_id=inv["mc_operation_id"], mc_mission_id=inv["mc_mission_id"])
    sql(f"""insert into acquisition.attention_sweep(id, policy_id, trigger_kind, trigger_ref, mission_id, origin_kind, note, receipt_id)
            values ({q(sid)}, {q(P4.policy_id(policy))}, {q(trigger)}, {q(ref)}, {q(m['id'])}, 'mission', {q(note)}, {q(mission_receipt('sweep-' + policy, {'trigger': trigger}, m, inv))})""")
    return sid


def start_mission(m, inv):
    if m["status"] == "created":
        sql(f"""update orchestration.mission set status = 'running', started_at = coalesce(started_at, now()) where id = {q(m['id'])};
                insert into orchestration.mission_event(mission_id, from_status, to_status, actor, reason, payload)
                values ({q(m['id'])}, 'created', 'running', {q('mission-control:' + inv['mc_run_id'])}, 'first watch tick run by Mission Control (Deep Agents lane)', {q(inv)})""")


def budget_gate(m, inv, policy, trigger):
    s, b = spent(m["id"]), (float(m["budget_cost_usd"]) if m.get("budget_cost_usd") is not None else None)
    if b is not None and s >= b:
        sid = open_sweep(policy, trigger, {"budget_usd": b, "spent_usd": s}, f"budget stop: spent {s} of {b} USD across this mission's runs", m, inv)
        P4.close_sweep(sid, 0, 0, 0, {"budget": f"spent {s} >= budget {b}"}, outcome="budget_stopped")
        OUT.update(budget_stopped=True, sweep=sid, spent_usd=s, budget_usd=b)
        return False
    OUT.update(budget_stopped=False, spent_usd=s, budget_usd=b)
    return True


def cmd_releases(m, inv):
    if not budget_gate(m, inv, "vendor-issues-on-release", "schedule"):
        return
    start_mission(m, inv)
    lib = {pkg: L1.ensure_entity("library", pkg, name, {"package_name": pkg, "ecosystem": "pypi"}) for pkg, (name, _) in WATCHED.items()}
    sweep = open_sweep("vendor-issues-on-release", "schedule", {"ref": "loop8-watch-registry"}, "Loop 8 watch tick: PyPI registry pages of the watched libraries", m, inv)
    batch = Batch("loop8-watch-releases", {"loop": 8})
    added, fetched_n = [], 0
    for pkg, (name, floor) in WATCHED.items():
        src = dict(key=f"pypi-{pkg}-l8", kind="package_version_page", role="registry", fmt="json", url=f"https://pypi.org/pypi/{pkg}/json", title=f"PyPI: {pkg} (loop 8 watch)",
                   publisher="PyPI", channel="pypi", software=pkg, accept="application/json")
        f = http_get(src["url"], accept="application/json")
        if f["status"] != 200:
            continue
        fetched_n += 1
        doc, ver = P4.capture(src, f["body"], f, sweep)
        cap = one(f"select vc.source_capture_id from content.document_version v join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} order by v.created_at desc limit 1")
        data = json.loads(f["body"])
        have = {r[0] for r in sql_rows(f"select e.attributes->>'version_label' from catalog.entity e join catalog.relationship r on r.from_entity_id=e.id and r.kind='version_of' and r.k_to is null where e.kind='library_release' and r.to_entity_id={q(lib[pkg])}")}
        for v, files in data["releases"].items():
            if not files or not P5.STABLE.match(v) or P5.vkey(v) < P5.vkey(floor) or v in have:
                continue
            up = min(x["upload_time_iso_8601"] for x in files)
            rid = L1.ensure_entity("library_release", L1.slugify(f"{pkg}-{v}"), f"{name} {v}", {"version_label": v, "released_on": up[:10], "tag": f"{pkg}=={v}", "prerelease": False, "breaking": v.endswith(".0.0"),
                                                                                       "highlights": [], "release_url": f"https://pypi.org/project/{pkg}/{v}/", "registry_capture_id": cap, "registry_pointer": f"/releases/{v}/0/upload_time_iso_8601"})
            batch.add(f"select temporal.assert_relationship('version_of', {q(rid)}, {q(lib[pkg])});")
            batch.add(f"select temporal.assert_event('release_published', {q(rid)}, tstzrange({q(up)}, ({q(up)})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q(pkg + '==' + v)}, null, null, {q({'version': v, 'source': 'pypi', 'capture_id': cap, 'pointer': f'/releases/{v}/0/upload_time_iso_8601'})});")
            added.append({"library": pkg, "version": v, "released_at": up})
    if added:
        batch.commit()
    P4.close_sweep(sweep, len(WATCHED), fetched_n, fetched_n, {"note": "registry pages, no selection"})
    OUT.update(sweep=sweep, fetched=fetched_n, releases_added=added)


def cmd_due(m, inv):
    OUT.update(attention_due=sql_json("select to_jsonb(d) from api.attention_due(now()) d"),
               probe_revalidation_due=sql_json("select to_jsonb(d) from api.probe_revalidation_due(now()) d"))


def latest_cell_label():
    return "D5-latest-" + now_iso()[:13]


def loop5_runs(p):
    return [json.load(open(f, encoding="utf-8")) for f in sorted(glob.glob(os.path.join(P5.PROBE_RUNS5, p + "__*.json"))) if "D4-" not in f]


def register_run(p, pid, r, sweep, m, inv, reason):
    doc_src = dict(key=f"probe-report-{p}", kind="probe_report", role="own_experiment", fmt="json", url=f"urn:belllabs:probe:{p}", title=f"Probe report {p}",
                   publisher="AI Engineer research (this system)", channel="belllabs-probes", probe=p)
    body = json.dumps({"probe": p, "revalidation": {"reason": reason, "sweep": sweep, "mc_run_id": inv["mc_run_id"]}, "runs": [r]}, ensure_ascii=False, sort_keys=True, default=str).encode("utf-8")
    doc, ver = P4.capture(doc_src, body, {"status": 200, "final_url": doc_src["url"]}, sweep)
    vrow = sql_json(f"""select json_build_object('representation_id', rr.id, 'capture_id', vc.source_capture_id) from content.document_version v join content.document_representation rr on rr.document_version_id = v.id
                        join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} order by v.created_at desc limit 1""")[0]
    res = r.get("result") or {}
    checks = res.get("checks") or {}
    vers = res.get("versions") or {k: checks.get(c) for k, c in (("langgraph", "langgraph"), ("langgraph-swarm", "langgraph_swarm"), ("langchain-core", "langchain_core")) if checks.get(c)}
    txt = f"Probe {p} revalidation in cell {r['cell']} ({reason}): " + ", ".join(f"{k} {v}" for k, v in vers.items() if v) + ". Checks: " + json.dumps(res.get("checks"), ensure_ascii=False)[:1500] + f". Outcome {r['outcome']}."
    u = dict(id=str(uuid.uuid4()), key=f"run-{r['cell']}", kind="probe_observation", attrs={"probe": p, "cell": r["cell"], "outcome": r["outcome"], "resolved": vers, "observation": res.get("checks")},
             logical=f"probe:{p}:{r['cell']}", text=txt, pointer="/runs/0")
    P4.insert_nodes(dict(representation_id=vrow["representation_id"]), [u])
    loc = str(uuid.uuid4())
    sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params)
            values ({q(loc)}, {q(TENANT)}, {q(vrow['capture_id'])}, 'application/json', {q({'node_id': u['id'], 'pointer': u['pointer']})}, 'json_pointer', {q(sha256_text(txt))}, {q(txt[:500])}, 'build08-grammar', '4', '{{}}'::jsonb)""")
    sql(f"""insert into verification.probe_run(probe_id, cell_label, cell, resolved, lock_sha256, python_version, platform, started_at, ended_at, exit_code, outcome, observations, output_capture_id, output_locator_id,
                                              cost_usd, sweep_id, origin_kind, mission_id, receipt_id)
            values ({q(pid)}, {q(r['cell'])}, {q({'exclude_newer': None, 'rebuilt_for': reason})}, {q(vers)}, {q(r.get('lock_sha256'))}, {q(res.get('python'))}, {q(res.get('platform'))},
                    {q(r['started_at'])}, {q(r.get('ended_at'))}, {q(r.get('exit_code'))}, {q(r['outcome'])}, {q(dict(checks=res.get('checks')))}, {q(vrow['capture_id'])}, {q(loc)}, 0, {q(sweep)}, 'mission', {q(m['id'])},
                    {q(mission_receipt('probe-run-' + p, {'cell': r['cell']}, m, inv))})""")


def cmd_rerun(m, inv):
    if not budget_gate(m, inv, "probe-revalidation", "event"):
        return
    start_mission(m, inv)
    due = sql_json("select to_jsonb(d) from api.probe_revalidation_due(now()) d")
    if not due:
        OUT.update(due=[], note="nothing due")
        return
    probes = {}
    for d in due:
        probes.setdefault(d["probe"], d)
    live = [p for p in probes if one(f"select kind from verification.probe where slug = {q(p)}") == "live_model"]
    run_now = [p for p in probes if p not in live]
    reason = "; ".join(sorted({d["reason"] for d in due}))[:900]
    cell = latest_cell_label()
    sweep = open_sweep("probe-revalidation", "event", {"due": sorted(probes), "skipped_live": live, "cell": cell}, f"Loop 8 watch tick: revalidation after {reason[:300]}", m, inv)
    R.CELLS[cell] = {"exclude_newer": None, "packages": list(R.CELLS["D3-latest"]["packages"]), "optional": []}
    for other in [c for c in list(R.CELLS) if c != cell]:
        R.CELLS.pop(other)   # build only the new latest cell (the dated cells exist)
    R.build_envs()
    keys4 = json.load(open(os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-4", "claim-keys.json"), encoding="utf-8"))
    outcome, review, registered = {}, [], []
    for slug in run_now:
        p = slug.split("-")[0]
        pid = probes[slug]["probe_id"]
        due_cell = probes[slug]["cell_label"]
        if one(f"select kind from verification.probe where slug = {q(slug)}") == "resolution":
            # a resolution probe (P11): `uv pip compile` of the due latest cell's requirements, no cutoff, in a new latest cell
            reqs, cutoff = R.RESOLVE_CELLS.get(due_cell, (None, None))
            if reqs is None or cutoff is not None:
                outcome[p] = {"skipped": f"no latest resolution cell {due_cell}"}
                continue
            rcell = f"{due_cell.replace('D3-latest', 'D5-latest')}-{now_iso()[:13]}"
            R.RESOLVE_CELLS_SAVED = dict(R.RESOLVE_CELLS)
            R.RESOLVE_CELLS = {rcell: (reqs, None)}
            R.resolve()
            R.RESOLVE_CELLS = R.RESOLVE_CELLS_SAVED
            files = sorted(glob.glob(os.path.join(R.OUT, f"{p}__{rcell}.json")))
        else:
            script = LOOP5_PLAN.get(p) or PLAN4.get(p)
            if not script:
                outcome[p] = {"skipped": "no script"}
                continue
            R.PLAN = {p: (script, [cell])}
            R.run([p])
            files = sorted(glob.glob(os.path.join(R.OUT, f"{p}__{cell}*.json")))
        if not files:
            outcome[p] = {"skipped": "no run file"}
            continue
        r = json.load(open(files[-1], encoding="utf-8"))
        register_run(p, pid, r, sweep, m, inv, reason)
        registered.append(p)
        if p == "P11":
            swapped = [x for x in P4.runs_of(p) if x["cell"] != due_cell] + [dict(r, cell=due_cell)]
            rules = [(keys4.get(k, k), v, ra, ce) for k, v, ra, ce in P4.verdicts(p, swapped, keys4)]
        elif p in LOOP5_PLAN:
            swapped = [x for x in loop5_runs(p) if x["cell"] != "D3-latest"] + [dict(r, cell="D3-latest")]
            rules = [(P5.CL[k], v, ra, ce) for k, v, ra, ce in P5.verdicts5(p, swapped)]
        else:
            swapped = [x for x in P4.runs_of(p) if x["cell"] != "D3-latest"] + [dict(r, cell="D3-latest")]
            rules = [(keys4.get(k, k), v, ra, ce) for k, v, ra, ce in P4.verdicts(p, swapped, keys4)]
        res = (r.get("result") or {}).get("versions") or {}
        for cid, verdict, rationale, cells in rules:
            cur = sql_json(f"select to_jsonb(x) from (select id, verdict::text verdict from verification.probe_verdict v where claim_id={q(cid)} and probe_id={q(pid)} and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id) order by decided_at desc limit 1) x")
            cur = cur[0] if cur else {"id": None, "verdict": None}
            changed = cur["verdict"] != verdict
            outcome[f"{p}:{cid[:8]}"] = {"current": cur["verdict"], "revalidated": verdict, "changed": changed, "resolved": {k: res.get(k) for k in ("langgraph", "langchain", "langchain-core", "deepagents")}}
            if changed:
                sql(f"""insert into verification.probe_verdict(claim_id, probe_id, verdict, cells, rationale, decided_by, supersedes_id) values ({q(cid)}, {q(pid)}, {q(verdict)}::evidence.support_verdict, {q(cells)},
                        {q(rationale + f' (revalidated in {cell} by the watch mission, Mission Control run ' + inv['mc_run_id'] + ')')}, 'agent:loop8_watch revalidation rules (Mission Control watch mission)', {q(cur['id'])})""")
                for rs in sql_rows(f"select id from evidence.claim where atomized_from_id = {q(cid)} and structured->>'path' = 'restatement'"):
                    review.append({"restatement": rs[0], "original": cid, "probe": p, "was": cur["verdict"], "now": verdict})
    P4.close_sweep(sweep, len(probes), len(run_now), len(registered), {"live_arm_skipped": live, "registered": registered, "verdicts_changed": sum(1 for v in outcome.values() if v.get("changed")), "restatements_to_review": review})
    write_json(os.path.join(RUN8, f"revalidation-{inv['mc_run_id'][:8]}.json"), {"due": due, "cell": cell, "outcome": outcome, "review": review})
    OUT.update(sweep=sweep, cell=cell, probes_run=registered, probes_selected=run_now, skipped_live=live, outcome=outcome, restatements_to_review=review)


def cmd_admit(m, inv):
    if not budget_gate(m, inv, "probe-revalidation", "event"):
        return
    env = dict(os.environ, ADMISSION_RUN_DIR=RUN8)
    p = subprocess.run([sys.executable, "-I", "-X", "utf8", os.path.join(os.path.dirname(os.path.abspath(__file__)), "loop6_admission.py"), "pack"], capture_output=True, text=True, encoding="utf-8", env=env, timeout=600)
    pack = json.load(open(os.path.join(RUN8, "admission-pack.json"), encoding="utf-8"))
    ready = [o for o in pack["offered"] if o.get("ready")]
    OUT.update(offered=len(pack["offered"]), ready=len(ready), pack_log=p.stdout.strip()[-300:])
    if not ready:
        OUT.update(dispatched=False, note="nothing confirmed and unverified to admit")
        return
    out_dir = os.path.join(RUN8, "ks-run-" + inv["mc_run_id"][:8])
    os.makedirs(out_dir, exist_ok=True)
    h = subprocess.run(["corepack", "pnpm", "exec", "tsx", "scripts/experiments/build08-probe-admission/run.ts", "--pack", os.path.join(RUN8, "admission-pack.json"), "--out", out_dir],
                       cwd=KS, capture_output=True, text=True, encoding="utf-8", timeout=1200, shell=(os.name == "nt"))
    OUT.update(dispatched=True, harness_exit=h.returncode, harness_tail=h.stdout.strip().splitlines()[-3:] if h.stdout else h.stderr[-400:])


def cmd_status(m, run=None):
    where = f" and s.trigger_ref->>'mc_run_id' = {q(run)}" if run else ""
    OUT.update(mission=m["slug"], status=one(f"select status::text from orchestration.mission where id = {q(m['id'])}"), spent_usd=spent(m["id"]),
               sweeps=sql_json(f"""select to_jsonb(x) from (select s.id, p.slug policy, s.trigger_kind, s.origin_kind, s.outcome, s.items_seen, s.items_selected, s.spend_usd, s.trigger_ref->>'mc_run_id' mc_run_id
                                     from acquisition.attention_sweep s join acquisition.attention_policy p on p.id = s.policy_id where s.mission_id = {q(m['id'])}{where} order by s.started_at) x"""))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["releases", "due", "rerun", "admit", "status"])
    ap.add_argument("--mission", required=True)
    ap.add_argument("--invocation", default="{}")
    ap.add_argument("--run")
    a = ap.parse_args()
    m = mission_row(a.mission)
    inv = json.loads(a.invocation)
    if a.command != "status":
        need = ("mc_mission_id", "mc_run_id", "mc_operation_id", "mc_operation_attempt", "mc_execution_generation", "mc_lane")
        missing = [k for k in need if inv.get(k) in (None, "")]
        if missing:
            raise SystemExit(f"invocation is missing {missing}: every write names the Mission Control invocation that caused it")
    import io, contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        {"releases": lambda: cmd_releases(m, inv), "due": lambda: cmd_due(m, inv), "rerun": lambda: cmd_rerun(m, inv), "admit": lambda: cmd_admit(m, inv),
         "status": lambda: cmd_status(m, a.run)}[a.command]()
    OUT.setdefault("log", buf.getvalue()[-1500:])
    print(json.dumps(OUT, ensure_ascii=False, default=str))
