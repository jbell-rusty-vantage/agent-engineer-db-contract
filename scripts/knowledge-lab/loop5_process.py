"""Build 08 knowledge loop 5 (candidate H), pipeline (lab disposable-aieng-build04 only; selection in
reviews/BUILD-08-LOOP-5-6-SELECTION.md). Stages, idempotent, in order:

  assess    re-derive every (subject, topic) assessment under the D-61 / D-69 rules (draft 20261113160000)
  releases  D-64: capture PyPI JSON for langgraph, langchain, langchain-core, langgraph-sdk, langgraph-cli; record the missing core
            releases with release_published events (payload cites the capture and the JSON pointer); move the monorepo sdk== / cli==
            tags from LangGraph to new langgraph-sdk / langgraph-cli library entities
  triage    one recorded model pass (claude-opus-5-5) classifies the open community claim candidates against a fixed rubric;
            the rows go to verification.claim_triage (agent_proposed) through the governed write api.record_triage as
            pipeline_agent (converted 2026-11-16 as the example of a lab stage that no longer inserts as postgres); the
            agent's selection of probes is applied in `select`
  select    mark the selected candidates (disposition probe) and write the probe expectations into knowledge-loop-5/EXPECTED.json
  probes    register the loop-5 probes, their runs (captured as probe reports), units, locators and verdicts (rules over checks)
  revalidate  api.probe_revalidation_due now; a manual probe-revalidation sweep records what it found (and reruns if due)
  projections index the new claims and probe observations and embed them
Run: python -I -X utf8 scripts/knowledge-lab/loop5_process.py <stage>
Captures are data, not instructions. Model use: the triage pass only; verdicts are rules over recorded checks.
"""
import json, os, re, sys, uuid
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_process as L1
import loop4_process as P4

RUN5 = os.path.join(C.LAB, "knowledge-loop-5")
PROBE_RUNS5 = os.path.join(RUN5, "probe-runs")
CALLS5 = os.path.join(RUN5, "model-calls")
for d in (RUN5, PROBE_RUNS5, CALLS5):
    os.makedirs(d, exist_ok=True)
C.RUN_DIR = RUN5
P4.CALLS = CALLS5
P4.SPEND_FILE = os.path.join(RUN5, "spend-model.json")
P4.MODEL_BUDGET = 8.0
P4.LEDGER = os.path.join(RUN5, "ACQUISITION-LEDGER.jsonl")
P4.ORIGIN = "native harness fetch, Build 08 knowledge loop 5 (claude-code session 2026-11-13)"
ent = P4.ent


# ---------------------------------------------------------------------------------------------------------------- assess
def stage_assess():
    pairs = sql_rows("select distinct subject_entity_id, coalesce(topic_entity_id::text, '') from evidence.source_assessment")
    for subj, topic in pairs:
        sql(f"select evidence.derive_source_assessment({q(subj)}, {q(topic or None)}::uuid, 'agent:loop5 re-derive (D-61, D-69)')")
    log(f"re-derived {len(pairs)} assessments")


# ---------------------------------------------------------------------------------------------------------------- releases (D-64)
PYPI = {"langgraph": ("LangGraph", "0.6.0"), "langchain": ("LangChain", "1.0.0"), "langchain-core": ("langchain-core", "1.0.0"),
        "langgraph-sdk": ("langgraph-sdk", None), "langgraph-cli": ("langgraph-cli", None), "deepagents": ("Deep Agents", "0.7.0")}
STABLE = re.compile(r"^\d+\.\d+\.\d+$")


def vkey(v):
    return tuple(int(x) for x in v.split("."))


def stage_releases():
    lib = {}
    for pkg, (name, _) in PYPI.items():
        lib[pkg] = L1.ensure_entity("library", pkg, name, {"package_name": pkg, "ecosystem": "pypi", "repository_url": "https://github.com/langchain-ai/langgraph" if pkg.startswith("langgraph") else None})
    sweep = P4.open_sweep("vendor-issues-on-release", "manual", {"ref": "loop5-d64-release-repair", "delta": "D-64"}, "D-64 release data repair: PyPI JSON for the LangGraph / LangChain core lines and the monorepo SDK and CLI")
    batch = Batch("loop5-d64-releases", {"loop": 5, "delta": "D-64"})
    added, moved = [], []
    for pkg, (name, floor) in PYPI.items():
        src = dict(key=f"pypi-{pkg}-l5", kind="package_version_page", role="registry", fmt="json", url=f"https://pypi.org/pypi/{pkg}/json", title=f"PyPI: {pkg} (loop 5)", publisher="PyPI", channel="pypi", software=pkg, accept="application/json")
        fetched = http_get(src["url"], accept="application/json")
        if fetched["status"] != 200:
            log(f"{pkg}: HTTP {fetched['status']}")
            continue
        doc, ver = P4.capture(src, fetched["body"], fetched, sweep)
        cap = one(f"select vc.source_capture_id from content.document_version v join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} order by v.created_at desc limit 1")
        data = json.loads(fetched["body"])
        have = {r[0] for r in sql_rows(f"select e.attributes->>'version_label' from catalog.entity e join catalog.relationship r on r.from_entity_id=e.id and r.kind='version_of' and r.k_to is null where e.kind='library_release' and r.to_entity_id={q(lib[pkg])}")}
        if floor is None:
            continue
        for v, files in data["releases"].items():
            if not files or not STABLE.match(v) or vkey(v) < vkey(floor) or v in have:
                continue
            up = min(f["upload_time_iso_8601"] for f in files)
            rid = L1.ensure_entity("library_release", L1.slugify(f"{pkg}-{v}"), f"{name} {v}", {"version_label": v, "released_on": up[:10], "tag": f"{pkg}=={v}", "prerelease": False, "breaking": v.endswith(".0.0"),
                                                                                       "highlights": [], "release_url": f"https://pypi.org/project/{pkg}/{v}/", "registry_capture_id": cap, "registry_pointer": f"/releases/{v}/0/upload_time_iso_8601"})
            batch.add(f"select temporal.assert_relationship('version_of', {q(rid)}, {q(lib[pkg])});")
            batch.add(f"select temporal.assert_event('release_published', {q(rid)}, tstzrange({q(up)}, ({q(up)})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q(pkg + '==' + v)}, null, null, {q({'version': v, 'source': 'pypi', 'capture_id': cap, 'pointer': f'/releases/{v}/0/upload_time_iso_8601'})});")
            added.append(f"{pkg} {v}")
    # the monorepo tags: sdk==x / cli==x are releases of langgraph-sdk / langgraph-cli, not of LangGraph
    for rid, label in sql_rows(f"""select e.id, e.attributes->>'version_label' from catalog.entity e join catalog.relationship r on r.from_entity_id=e.id and r.kind='version_of' and r.k_to is null
                                   where e.kind='library_release' and r.to_entity_id={q(ent('library', 'langgraph'))} and (e.attributes->>'version_label') ~ '^(sdk|cli)=='"""):
        target = lib["langgraph-sdk" if label.startswith("sdk==") else "langgraph-cli"]
        batch.add(f"update catalog.relationship set k_to = temporal.current_k() where kind='version_of' and from_entity_id={q(rid)} and to_entity_id={q(ent('library', 'langgraph'))} and k_to is null;")
        batch.add(f"select temporal.assert_relationship('version_of', {q(rid)}, {q(target)});")
        moved.append(label)
    out = batch.commit()
    P4.close_sweep(sweep, len(PYPI), len(PYPI), len(PYPI), {"note": "registry pages, no selection"})
    write_json(os.path.join(RUN5, "d64-release-repair.json"), {"added": added, "moved": moved, "batch": str(out)[:300]})
    log(f"releases added {len(added)}, monorepo tags moved {len(moved)}")


# ---------------------------------------------------------------------------------------------------------------- triage
SYSTEM_TRIAGE = (
    "You triage claim candidates extracted from developer community threads about LangChain / LangGraph / Deep Agents, for a research team that "
    "tests claims with short deterministic Python scripts run in pinned environments (fake chat models, no network, no API keys), or by checking "
    "official docs pages or the PyPI registry. For EACH candidate return one object: {\"n\": <index>, \"disposition\": probe|docs_check|registry_check|"
    "not_checkable|duplicate|out_of_scope, \"checkability\": deterministic_local|needs_live_model|needs_external_service|historical_only|not_applicable, "
    "\"duplicate_of\": <index or null>, \"version_bounded\": true|false, \"probe_sketch\": <one sentence: what a script would do and observe, or null>, "
    "\"reason\": <one short sentence>}. Rules: probe = a library behaviour a small script with a fake model can observe today (errors, parameters, "
    "message types, state keys, namespaces, imports); needs_live_model when the behaviour depends on a real model's choices; needs_external_service "
    "for databases, cloud, LangSmith, FastAPI servers; historical_only when it is about an old version only and no longer installable; not_checkable for "
    "advice, opinions, experiences, intentions, questions. Never judge whether a claim is true. Return JSON {\"triage\": [...]} only.")


def candidates():
    return sql_json("""select to_jsonb(x) from (select cc.claim_id, cc.statement, cc.quote, cc.claim_type, cc.channel_slug, cc.thread, cc.thread_state, cc.stated_at, cc.subjects
                         from api.community_claims cc where cc.verdict is null order by cc.channel_slug, cc.thread, cc.claim_id) x""")


def stage_triage():
    cands = candidates()
    material = "\n".join(f"[{i}] ({c['claim_type']}; {c['channel_slug']}; thread '{c['thread'][:90]}', {c['thread_state']}, {c['stated_at']}; subjects {','.join(c['subjects'] or [])}) "
                         f"{c['statement']} | quote: \"{c['quote']}\"" for i, c in enumerate(cands))
    parsed = P4.call_model("triage-loop5", SYSTEM_TRIAGE, f"{len(cands)} candidates:\n{material}", max_tokens=20000)
    rows = {t["n"]: t for t in parsed.get("triage", []) if isinstance(t.get("n"), int)}
    write_json(os.path.join(RUN5, "triage-candidates.json"), cands)
    n = 0
    for i, c in enumerate(cands):
        t = rows.get(i)
        if not t or one(f"select 1 from verification.claim_triage where claim_id={q(c['claim_id'])}"):
            continue
        comps = {"module_subject": bool(set(c["subjects"] or []) & {"langchain", "langgraph", "deepagents"}), "version_bounded": bool(t.get("version_bounded")),
                 "open_thread": c["thread_state"] in ("open",), "deterministic_local": t.get("checkability") == "deterministic_local", "probe_sketch": t.get("probe_sketch")}
        prio = 40 * comps["deterministic_local"] + 20 * comps["module_subject"] + 15 * comps["version_bounded"] + 10 * comps["open_thread"] + (15 if t.get("disposition") == "probe" else 0)
        dup = cands[t["duplicate_of"]]["claim_id"] if isinstance(t.get("duplicate_of"), int) and 0 <= t["duplicate_of"] < len(cands) and t.get("disposition") == "duplicate" else None
        disp = t.get("disposition") if t.get("disposition") in ("probe", "docs_check", "registry_check", "not_checkable", "duplicate", "out_of_scope") else "not_checkable"
        chk = t.get("checkability") if t.get("checkability") in ("deterministic_local", "needs_live_model", "needs_external_service", "historical_only", "not_applicable") else "not_applicable"
        if disp == "duplicate" and not dup:   # the rubric named no candidate it duplicates: the governed write refuses a duplicate of nothing
            disp = "not_checkable"
        # the governed write: validated, idempotent per claim, agent_proposed, with a receipt naming the role and this label
        governed("record_triage", {"p_idempotency_key": f"loop5-triage:{c['claim_id']}", "p_claim_id": c["claim_id"], "p_disposition": disp, "p_checkability": chk,
                                   "p_rationale": t.get("reason") or "no reason given by the triage rubric", "p_priority": prio, "p_components": comps,
                                   "p_duplicate_of_claim_id": dup},
                 role="pipeline_agent", actor={"label": "model:claude-opus-5-5 triage rubric (loop 5)"})
        n += 1
    log(f"triage rows written: {n} of {len(cands)} candidates")


# ---------------------------------------------------------------------------------------------------------------- probes (P14-P19)
CL = {"e438": "e438c12b-3fcb-46a1-9e3f-98ca0ba896e6", "3f32": "3f32e433-7516-41fa-9856-f42641392b39", "f68e": "f68ed948-c1ac-4f01-93c3-b95167c91fd9",
      "173b": "173bbf5c-aba8-4b48-bbc2-2738fdf811b1", "937e": "937ef76c-6a00-49b3-b44f-6ce17aa83517", "7a14": "7a14f69c-c242-4bd5-a921-3ab88bfa67c1",
      "28a3": "28a30bff-283f-4f9e-a37d-efc75971c598", "b613": "b6133009-dab5-4b3c-a4bf-71cc443ef816", "1a5b": "1a5b70c6-e7e5-4f97-8b96-1996b3a3ab83",
      "26b9": "26b950e1-c809-4fda-8d8d-bb96b6557134", "a7c3": "a7c3b8d9-d9eb-41be-9333-c4bacc06d33a", "c6f6": "c6f643af-c431-4ff0-a9a1-a04885b894ec",
      "f10d": "f10d0649-14b1-4959-96c8-a6627b56de3c"}
PROBES5 = {  # probe: (slug, title, hypothesis, subjects, script, claim keys)
    "P14": ("checkpoint-ns", "Checkpoint namespaces of a supervisor and its sub-agent", "a sub-agent invoked inside a tool writes under the task path namespace; a root checkpoint_ns in the config is not stored", ["langchain", "langgraph"], "p14_checkpoint_ns.py", ["e438", "3f32"]),
    "P15": ("invalid-tool-calls", "create_agent and invalid tool calls", "the loop ends when only invalid_tool_calls are present; newer releases send an error ToolMessage for an invalid call on the next request", ["langchain"], "p15_invalid_tool_calls.py", ["173b", "f68e"]),
    "P16": ("command-parent-two-tools", "Two Command.PARENT results in one model turn", "only one of two Command.PARENT updates reaches the parent graph before the fix, both after", ["langgraph", "langchain"], "p16_command_parent.py", ["937e"]),
    "P17": ("prompt-template-escaping", "Prompt template formats and HTML escaping", "mustache escapes HTML, triple mustache and f-strings do not", ["langchain-core"], "p17_mustache_escaping.py", ["7a14", "28a3", "b613"]),
    "P18": ("example-selector-state", "LengthBasedExampleSelector after a failed add_example", "a failed add_example leaves examples and lengths out of step; select_examples then raises IndexError; aadd_example is the same", ["langchain-core"], "p18_example_selector.py", ["1a5b", "26b9", "a7c3"]),
    "P19": ("subagent-context", "What a Deep Agents subagent receives and returns", "the subagent sees only the task description as a human message; the parent receives only its last message", ["deepagents"], "p19_subagent_context.py", ["c6f6", "f10d"]),
}


def verdicts5(p, runs):
    ch = {r["cell"]: ((r.get("result") or {}).get("checks") or {}) for r in runs}
    cells = {c: {k: v for k, v in x.items() if not isinstance(v, (dict, list))} for c, x in ch.items()}
    D2, D3 = "D2-2026-04-23", "D3-latest"
    allc = lambda k: all(x.get(k) for x in ch.values())
    out = []
    if p == "P14":
        sep = allc("subagent_separate_ns") and allc("subagent_ns_is_task_path") and not any(x.get("subagent_ns_is_graph_id") for x in ch.values())
        out.append(("e438", "supported_with_qualification" if sep else "contradicted", "the sub-agent invoked inside the supervisor's tool writes under its own namespace, but the value is the task path (tools:<id>), not the graph id; the supervisor writes under '' (langgraph 1.0.0, 1.1.9, 1.2.21)", cells))
        out.append(("3f32", "directly_supported" if allc("root_ns_stays_empty") and not any(x.get("explicit_ns_stored") for x in ch.values()) else "contradicted", "a root invoke with checkpoint_ns='my-namespace' in the configurable config stores its checkpoints under '' in every cell", cells))
    elif p == "P15":
        out.append(("173b", "directly_supported" if allc("loop_ends_with_only_invalid") else "contradicted", "with only invalid_tool_calls the agent stops after the first model call and sends no ToolMessage (langchain 1.2.15 and 1.5.0)", cells))
        before, after = ch.get(D2, {}).get("next_request_carries_error_toolmessage"), ch.get(D3, {}).get("next_request_carries_error_toolmessage")
        out.append(("f68e", "supported_with_qualification" if (after and not before) else ("contradicted" if not after else "not_supported"),
                    "no error ToolMessage for the invalid call on 1.2.15; on 1.5.0 the next request carries 'Tool call ... with id bad1 could not be executed - arguments were malformed or truncated.'; the 1.4.3 boundary itself is not pinned, and the loop still ends when only invalid calls are present", cells))
    elif p == "P16":
        one_ = all(x.get("only_one_update_applied") for x in ch.values())
        out.append(("937e", "directly_supported" if one_ else ("supported_with_qualification" if ch.get(D2, {}).get("only_one_update_applied") else "contradicted"),
                    "only the first tool's Command.PARENT update reaches the parent on langgraph 1.1.9 and still on 1.2.21 (hits = ['a']), although the issues were closed in September 2026" if one_ else "fixed on the latest cell", cells))
    elif p == "P17":
        out.append(("7a14", "directly_supported" if allc("mustache_escapes") else "contradicted", "{{x}} renders <, >, & and \" as HTML entities in langchain-core 0.3.79, 1.3.1 and 1.8.0", cells))
        jinja = any(x.get("jinja2_available") for x in ch.values())
        out.append(("28a3", ("directly_supported" if jinja else "supported_with_qualification") if allc("f_string_unescaped") else "contradicted", "f-string inserts the value unchanged in every cell; jinja2 is not installed in the cells, so the jinja2 half is not observed", cells))
        out.append(("b613", "directly_supported" if allc("triple_unescaped") else "contradicted", "{{{x}}} renders the value unescaped in every cell (the docs half of the claim is not probed)", cells))
    elif p == "P18":
        out.append(("1a5b", "directly_supported" if allc("examples_longer_than_lengths") and allc("add_raises_keyerror") else "contradicted", "add_example raises KeyError after appending: len(examples) = len(example_text_lengths) + 1 (langchain-core 0.3.79, 1.3.1, 1.8.0)", cells))
        out.append(("26b9", "directly_supported" if allc("select_raises_indexerror") else "contradicted", "select_examples then raises IndexError in every cell", cells))
        out.append(("a7c3", "directly_supported" if allc("aadd_same") else "contradicted", "aadd_example leaves the same mismatch", cells))
    elif p == "P19":
        out.append(("c6f6", "directly_supported" if allc("sub_gets_only_description") and not any(x.get("sub_sees_parent_history") for x in ch.values()) else "contradicted", "the subagent's model sees its system prompt and one human message with the task description; the parent's 'SECRET-PARENT-CONTEXT' never reaches it (deepagents 0.5.3, 0.7.37)", cells))
        out.append(("f10d", "supported_with_qualification" if allc("parent_gets_last_message_only") else "contradicted", "the parent's ToolMessage carries only the subagent's final message ('FINAL: the answer is 7'), not its intermediate one; the 'without a checkpointer' half is not probed", cells))
    return out


def stage_probes():
    runs_dir = PROBE_RUNS5
    sweep = P4.open_sweep("probe-revalidation", "manual", {"ref": "loop5-triage-probes", "probes": list(PROBES5)}, "Loop 5: six new probes selected from the triage of 104 community claim candidates")
    thread = one("select id from conversation.thread where purpose='interview' order by created_at limit 1")
    summary = {}
    for p, (slug, title, hyp, subj, script, ckeys) in PROBES5.items():
        sha = sha256_bytes(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "probes", script), "rb").read())
        runs = [json.load(open(os.path.join(runs_dir, f), encoding="utf-8")) for f in sorted(os.listdir(runs_dir)) if f.startswith(p + "__") and f.endswith(".json")]
        pid = one(f"select id from verification.probe where slug={q(p + '-' + slug)}")
        if not pid:
            pid = str(uuid.uuid4())
            subj_ids = [ent("library", s) for s in subj]
            sql(f"""insert into verification.probe(id, slug, title, hypothesis, kind, subject_entity_ids, script_path, script_sha256, environment, matrix, model_policy, budget_usd, designed_in_thread_id, designed_by)
                    values ({q(pid)}, {q(p + '-' + slug)}, {q(title)}, {q(hyp)}, 'executed', {qarr(subj_ids, 'uuid')}, {q('scripts/knowledge-lab/probes/' + script)}, {q(sha)},
                            {q({'python': '3.12', 'platform': 'Windows', 'installer': 'uv 0.12.23', 'cells': 'dates via --exclude-newer (loop-4 environments)'})},
                            {q([{'label': r['cell'], 'exclude_newer': r.get('exclude_newer')} for r in runs])}, 'fake', 0, {q(thread)}, 'agent:claude-code (loop 5, selected from the claim triage)')""")
        for k in ckeys:
            sql(f"insert into verification.probe_claim(probe_id, claim_id, expectation) values ({q(pid)}, {q(CL[k])}, {q({'expected': 'see knowledge-loop-5/EXPECTED.json'})}) on conflict do nothing")
        if not one(f"select 1 from verification.probe_run where probe_id={q(pid)}"):
            body = json.dumps({"probe": p, "slug": slug, "runs": runs}, ensure_ascii=False, sort_keys=True, default=str).encode("utf-8")
            src = dict(key=f"probe-report-{p}", kind="probe_report", role="own_experiment", fmt="json", url=f"urn:belllabs:probe:{p}-{slug}", title=f"Probe report {p}: {title}", publisher="AI Engineer research (this system)", channel="belllabs-probes", probe=p)
            doc, ver = P4.capture(src, body, {"status": 200, "final_url": src["url"]}, sweep)
            vrow = sql_json(f"""select json_build_object('representation_id', r.id, 'capture_id', vc.source_capture_id) from content.document_version v join content.document_representation r on r.document_version_id = v.id
                                join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} order by v.created_at desc limit 1""")[0]
            units = []
            for i, r in enumerate(runs):
                res = r.get("result") or {}
                vers = res.get("versions") or {}
                txt = (f"Probe {p} ({title}) in cell {r['cell']}" + (f" (packages as of {r.get('exclude_newer')})" if r.get("exclude_newer") else "") + ": " +
                       ", ".join(f"{k} {v}" for k, v in vers.items() if v) + ". Checks: " + json.dumps(res.get("checks"), ensure_ascii=False)[:1500] + f". Outcome {r['outcome']}.")
                units.append(dict(id=str(uuid.uuid4()), key=f"run-{r['cell']}", kind="probe_observation", attrs={"probe": p, "cell": r["cell"], "outcome": r["outcome"], "resolved": vers, "observation": res.get("checks")},
                                  logical=f"probe:{p}:{r['cell']}", text=txt, pointer=f"/runs/{i}"))
            P4.insert_nodes(dict(representation_id=vrow["representation_id"]), units)
            for r, u in zip(runs, units):
                loc = str(uuid.uuid4())
                sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params)
                        values ({q(loc)}, {q(TENANT)}, {q(vrow['capture_id'])}, 'application/json', {q({'node_id': u['id'], 'pointer': u['pointer']})}, 'json_pointer', {q(sha256_text(u['text']))}, {q(u['text'][:500])}, 'build08-grammar', '4', '{{}}'::jsonb)""")
                res = r.get("result") or {}
                sql(f"""insert into verification.probe_run(probe_id, cell_label, cell, resolved, lock_sha256, python_version, platform, started_at, ended_at, exit_code, outcome, observations, output_capture_id, output_locator_id, cost_usd, sweep_id, origin_kind, receipt_id)
                        values ({q(pid)}, {q(r['cell'])}, {q({'exclude_newer': r.get('exclude_newer')})}, {q(res.get('versions') or {})}, {q(r.get('lock_sha256'))}, {q(res.get('python'))}, {q(res.get('platform'))},
                                {q(r['started_at'])}, {q(r.get('ended_at'))}, {q(r.get('exit_code'))}, {q(r['outcome'])}, {q(dict(checks=res.get('checks'), observations=res.get('observations')))}, {q(vrow['capture_id'])}, {q(loc)}, 0, {q(sweep)}, 'standalone', {q(native_receipt('loop5-probe-run-' + p, {'cell': r['cell']}))})""")
                for su in subj:
                    L1.add_role(u["id"], ent("library", su), "subject", "rule", 1.0)
            L1.flush_roles()
        for ck, verdict, rationale, cells in verdicts5(p, runs):
            cid = CL[ck]
            if one(f"select 1 from verification.probe_verdict where claim_id={q(cid)} and probe_id={q(pid)}"):
                continue
            sql(f"""insert into verification.probe_verdict(claim_id, probe_id, verdict, cells, rationale, decided_by) values ({q(cid)}, {q(pid)}, {q(verdict)}::evidence.support_verdict, {q(cells)}, {q(rationale)}, 'agent:loop5_process verdict rules (code, not a model)')""")
            loc = one(f"select output_locator_id from verification.probe_run where probe_id={q(pid)} order by started_at desc limit 1")
            role = "supports" if verdict in ("directly_supported", "supported_with_qualification", "partially_supported") else ("contradicts" if verdict in ("contradicted", "not_supported") else "context")
            sql(f"insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role, support_verdict) values ({q(TENANT)}, {q(cid)}, {q(loc)}, {q(role)}, {q(verdict)}::evidence.support_verdict) on conflict do nothing")
            if verdict == "contradicted":
                sql(f"update evidence.claim set status = 'disputed', updated_at = now() where id = {q(cid)}")
            prev = one(f"select id from verification.claim_triage where claim_id={q(cid)} and not exists (select 1 from verification.claim_triage w where w.supersedes_id = claim_triage.id) order by decided_at desc limit 1")
            sql(f"""insert into verification.claim_triage(claim_id, disposition, checkability, priority, components, probe_id, rationale, decided_by, supersedes_id)
                    select claim_id, 'probe', 'deterministic_local', priority, components || {q({'selected_for': p})}, {q(pid)}, rationale || ' | selected for ' || {q(p)} || ' by the agent (loop 5)', 'agent:claude-code (loop 5 selection)', id
                      from verification.claim_triage where id = {q(prev)}""")
            summary[ck] = (p, verdict)
    P4.close_sweep(sweep, len(PROBES5), len(PROBES5), len(PROBES5), {"note": "manual: new probes from the triage"})
    write_json(os.path.join(RUN5, "verdicts-summary.json"), summary)
    for k, v in sorted(summary.items()):
        log(f"verdict {k}: {v}")


# ---------------------------------------------------------------------------------------------------------------- revalidation on release
def stage_revalidate():
    """Read the due-list, record an event-triggered probe-revalidation sweep, register the reruns made in the rebuilt latest cell
    (loop5_probes.py revalidate), recompute the verdict rules over every cell and write a new verdict only when it differs."""
    due = sql_json("select to_jsonb(d) from api.probe_revalidation_due(now()) d")
    write_json(os.path.join(RUN5, "revalidation-due.json"), due)
    if not due:
        log("nothing due")
        return
    rel = one("select release_id from api.software_releases where software = 'Deep Agents' order by released_at desc limit 1")
    sweep = P4.open_sweep("probe-revalidation", "event", {"release_id": rel, "release": "deepagents 0.7.38", "due": [d["probe"] for d in due]},
                          "Loop 5: deepagents 0.7.38 (2026-11-13T14:32Z) made P10 and P19 due; latest cell rebuilt as D4-latest-2026-11-13T15")
    keys4 = json.load(open(os.path.join(C.LAB, "knowledge-loop-4", "claim-keys.json"), encoding="utf-8"))
    outcome = {}
    for d in due:
        p = d["probe"].split("-")[0]
        pid = d["probe_id"]
        new = [json.load(open(os.path.join(PROBE_RUNS5, f), encoding="utf-8")) for f in sorted(os.listdir(PROBE_RUNS5)) if f.startswith(p + "__D4-")]
        if not new:
            continue
        r = new[-1]
        if not one(f"select 1 from verification.probe_run where probe_id={q(pid)} and cell_label={q(r['cell'])}"):
            doc = one(f"select d.id from content.document d where d.attributes->>'key' = {q('probe-report-' + p)} limit 1")
            src = dict(key=f"probe-report-{p}", kind="probe_report", role="own_experiment", fmt="json", url=f"urn:belllabs:probe:{d['probe']}", title=f"Probe report {p}", publisher="AI Engineer research (this system)", channel="belllabs-probes", probe=p)
            body = json.dumps({"probe": p, "revalidation": {"release": "deepagents 0.7.38", "sweep": sweep}, "runs": [r]}, ensure_ascii=False, sort_keys=True, default=str).encode("utf-8")
            doc, ver = P4.capture(src, body, {"status": 200, "final_url": src["url"]}, sweep)
            vrow = sql_json(f"""select json_build_object('representation_id', rr.id, 'capture_id', vc.source_capture_id) from content.document_version v join content.document_representation rr on rr.document_version_id = v.id
                                join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} order by v.created_at desc limit 1""")[0]
            res = r.get("result") or {}
            vers = res.get("versions") or {}
            txt = f"Probe {p} revalidation in cell {r['cell']} after deepagents 0.7.38: " + ", ".join(f"{k} {v}" for k, v in vers.items() if v) + ". Checks: " + json.dumps(res.get("checks"), ensure_ascii=False)[:1500] + f". Outcome {r['outcome']}."
            u = dict(id=str(uuid.uuid4()), key=f"run-{r['cell']}", kind="probe_observation", attrs={"probe": p, "cell": r["cell"], "outcome": r["outcome"], "resolved": vers, "observation": res.get("checks")}, logical=f"probe:{p}:{r['cell']}", text=txt, pointer="/runs/0")
            P4.insert_nodes(dict(representation_id=vrow["representation_id"]), [u])
            loc = str(uuid.uuid4())
            sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params)
                    values ({q(loc)}, {q(TENANT)}, {q(vrow['capture_id'])}, 'application/json', {q({'node_id': u['id'], 'pointer': u['pointer']})}, 'json_pointer', {q(sha256_text(txt))}, {q(txt[:500])}, 'build08-grammar', '4', '{{}}'::jsonb)""")
            sql(f"""insert into verification.probe_run(probe_id, cell_label, cell, resolved, lock_sha256, python_version, platform, started_at, ended_at, exit_code, outcome, observations, output_capture_id, output_locator_id, cost_usd, sweep_id, origin_kind, receipt_id)
                    values ({q(pid)}, {q(r['cell'])}, {q({'exclude_newer': None, 'rebuilt_after': 'deepagents 0.7.38'})}, {q(vers)}, {q(r.get('lock_sha256'))}, {q(res.get('python'))}, {q(res.get('platform'))},
                            {q(r['started_at'])}, {q(r.get('ended_at'))}, {q(r.get('exit_code'))}, {q(r['outcome'])}, {q(dict(checks=res.get('checks')))}, {q(vrow['capture_id'])}, {q(loc)}, 0, {q(sweep)}, 'standalone', {q(native_receipt('loop5-revalidation-' + p, {'cell': r['cell']}))})""")
        # recompute the verdict rules over the latest-cell semantics: the new cell stands in for D3
        old_runs = P4.runs_of(p) if p == "P10" else [json.load(open(os.path.join(PROBE_RUNS5, f), encoding="utf-8")) for f in sorted(os.listdir(PROBE_RUNS5)) if f.startswith(p + "__") and "D4-" not in f]
        swapped = [x for x in old_runs if x["cell"] != "D3-latest"] + [dict(r, cell="D3-latest")]
        rules = P4.verdicts(p, swapped, keys4) if p == "P10" else [(CL[k], v, ra, ce) for k, v, ra, ce in verdicts5(p, swapped)]
        for key, verdict, rationale, cells in rules:
            cid = keys4.get(key, key) if p == "P10" else key
            cur = one(f"select verdict::text from verification.probe_verdict v where claim_id={q(cid)} and probe_id={q(pid)} and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id) order by decided_at desc limit 1")
            outcome[f"{p}:{cid[:8]}"] = {"current": cur, "revalidated": verdict, "changed": cur != verdict}
            if cur != verdict:
                prev = one(f"select id from verification.probe_verdict v where claim_id={q(cid)} and probe_id={q(pid)} and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id) order by decided_at desc limit 1")
                sql(f"""insert into verification.probe_verdict(claim_id, probe_id, verdict, cells, rationale, decided_by, supersedes_id) values ({q(cid)}, {q(pid)}, {q(verdict)}::evidence.support_verdict, {q(cells)},
                        {q(rationale + ' (revalidated after deepagents 0.7.38)')}, 'agent:loop5_process revalidation rules', {q(prev)})""")
    P4.close_sweep(sweep, len(due), len(due), len(due), {"note": "event: release of a subject library", "unchanged": sum(1 for v in outcome.values() if not v["changed"])})
    write_json(os.path.join(RUN5, "revalidation-outcome.json"), outcome)
    log(f"revalidation: {outcome}")


if __name__ == "__main__":
    {"assess": stage_assess, "releases": stage_releases, "triage": stage_triage, "probes": stage_probes, "revalidate": stage_revalidate}[sys.argv[1]]()
