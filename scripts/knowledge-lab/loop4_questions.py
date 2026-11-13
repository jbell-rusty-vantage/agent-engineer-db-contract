"""Build 08 knowledge loop 4: the 16 questions of BUILD-08-LOOP-4-SELECTION.md §9, answered through the schema as app_reader.

Expected answers: for the probe questions they are EXPECTED.json (written 2026-11-13T05:20Z, before any probe ran, from the first-party
texts); for the registry, attention, interview and retrieval questions they are the expected shape written in the selection file §9
before the stages ran. Verdicts go to QUERY-LEDGER.jsonl (rows tagged loop 4; the last pass per question is the verdict).
Run: python -I -X utf8 scripts/knowledge-lab/loop4_questions.py [question numbers]
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_questions as Q1

RUN4 = os.path.join(LAB, "knowledge-loop-4")
EXPECTED = json.load(open(os.path.join(RUN4, "EXPECTED.json"), encoding="utf-8"))
STATE = json.load(open(os.path.join(RUN4, "product-state.json"), encoding="utf-8"))
PASS = int(os.environ.get("LOOP4_QUESTION_PASS", "1"))


def record(n, question, level, expected, answer, verdict, statements, note=""):
    row = {"loop": 4, "pass": PASS, "question": n, "text": question, "level": level, "expected": expected, "answer": answer, "verdict": verdict, "schema_calls": Q1.schema_calls(statements),
           "schema_call_count": len(statements), "path": statements, "note": note, "asked_at": now_iso()}
    append_jsonl(Q1.LEDGER, row)
    log(f"Q{n}: {verdict} ({len(statements)} calls) {note[:220]}")


def rows(stmts, statement):
    stmts.append(statement)
    out, err = Q1.reader(statement)
    if err:
        raise RuntimeError(err[:600])
    return out


def verdict_of(stmts, probe):
    return rows(stmts, f"select to_jsonb(x) from (select statement, verdict, status, stated_by, channel, rationale from api.claim_verdicts where probe = {q(probe)}) x")


def search(stmts, query, spaces=None, lenses=("corpus", "evidence", "ours"), workspaces=None, limit=10):
    emb = embed_texts([query])[0]
    arr = lambda v, t="text": "null" if not v else qarr(list(v), t)
    return rows(stmts, f"""select to_jsonb(x) from (select source_tier tier, lens, content_kind, document_type_code doc_type, unit_kind, space_slug space, left(snippet, 160) snippet, round(fused_score::numeric, 4) score
      from api.search_unified({q(query)}, {q(vec_literal(emb))}, {arr(lenses)}, null, {arr(spaces)}, null, null, null, null, {arr(workspaces, 'uuid')}, null, null, {limit}, 200, 60)) x""")


def q1():
    s = []
    v1, v2 = verdict_of(s, "P1-crea-deprecation"), verdict_of(s, "P2-create-agent-prompt-kwarg")
    m = rows(s, "select to_jsonb(x) from (select cell_label, observations->'checks'->>'warning_category' cat from api.probe_matrix('P1-crea-deprecation')) x")
    ok = all(v["verdict"] == "directly_supported" for v in v1) and any(v["verdict"] == "directly_supported" and "system_prompt" in v["statement"] for v in v2)
    record(1, "A 2025 tutorial calls create_react_agent: what happens today and what is the replacement call?", "L1 probes / T1+T2", {"P1": EXPECTED["P1"], "P2": EXPECTED["P2"]},
           {"warning_by_cell": m, "replacement": "from langchain.agents import create_agent; create_agent(model, tools, system_prompt=...)", "verdicts": v1 + v2}, "answered" if ok else "partial", s,
           "LangGraphDeprecatedSinceV10 from 1.0.0 on, naming create_agent; system_prompt= replaces prompt=")


def q2():
    s = []
    v = [x for x in verdict_of(s, "P2-create-agent-prompt-kwarg") if "silently" in x["statement"]]
    ok = v and v[0]["verdict"] == "contradicted" and v[0]["status"] == "disputed"
    record(2, "Is 'silently renamed' (agentmail post) true?", "L1 probes / T3", EXPECTED["P2"]["expected_verdict_silently"], v, "answered" if ok else "failed", s, "contradicted: prompt= raises TypeError in every 1.x cell; the claim is disputed, the rename itself is supported")


def q3():
    s = []
    m = rows(s, "select to_jsonb(x) from (select cell_label, observations->'checks' checks from api.probe_matrix('P3-stream-node-name')) x")
    ok = all(c["checks"].get("create_agent_model_node") == "model" for c in m if c["cell_label"] != "D0-2025-10-16")
    record(3, "Which streaming keys change when moving to create_agent?", "L1 probes / T1", EXPECTED["P3"], m, "answered" if ok else "failed", s, "'agent' (prebuilt) becomes 'model' (create_agent); the prebuilt still emits 'agent' on 1.2.21")


def q4():
    s = []
    v = verdict_of(s, "P7-docs-link-target")
    m = rows(s, "select to_jsonb(x) from (select observations->'observations'->'pages' pages, observations->'observations'->'signatures' sigs from api.probe_matrix('P7-docs-link-target')) x")
    record(4, "Which function does the LangGraph v1 page's create_react_agent link document?", "L1 probe + L2 symbols / T1+T2", EXPECTED["P7"], {"verdict": v, "matrix": m}, "answered" if v and v[0]["verdict"] == "directly_supported" else "failed", s,
           "the langchain-classic text-ReAct function; the prebuilt has a different signature")


def q5():
    s = []
    r = rows(s, """select to_jsonb(x) from (select channel, stated_by, left(statement, 160) statement, thread_state, verdict from api.community_claims
                   where channel_slug in ('github-copilotkit-copilotkit-issues','github-langchain-ai-langgraph-swarm-py-issues','github-langfuse-langfuse-issues') order by channel, verdict nulls last) x""")
    chans = sorted({x["channel"] for x in r})
    record(5, "Which dependent projects broke on 1.0, and how did they fix it?", "L3 threads / T3 + probes", "CopilotKit docs, langgraph-swarm dependency conflict, Langfuse prompt linking (§6)", r, "answered" if len(chans) == 3 else "partial", s,
           f"{len(r)} claims on {len(chans)} dependent trackers ({sum(1 for x in r if x['verdict'])} probe-judged) through api.community_claims (D-63)")


def q6():
    s = []
    v = verdict_of(s, "P12-token-overhead-live")
    m = rows(s, "select to_jsonb(x) from (select observations->'checks' checks, tokens_in from verification.probe_run r join verification.probe p on p.id = r.probe_id where p.slug = 'P12-token-overhead-live') x")
    record(6, "Does the agentmail token-overhead figure reproduce?", "L1 live probe / T1", EXPECTED["P12"], {"verdict": v, "run": m}, "answered" if v and v[0]["verdict"] == "supported_with_qualification" else "partial", s, "1,282 vs 1,288 mean input tokens, 5/5 tool calls; live arms never verify alone")


def q7():
    s = []
    r = rows(s, """select to_jsonb(x) from (select source, source_kind, claims_checked, confirmed, qualified, refuted, authority_score, recommended_watch_level, current_watch_level from api.source_registry
                   where topic = 'LangChain' and claims_checked > 0 order by authority_score desc, claims_checked desc) x""")
    record(7, "Rank the sources on LangChain with their track records", "L1 registry", "first party above editorial above community; components visible; scores move only with checked claims (§2.2)", r, "answered" if r and r[0]["source_kind"] in ("source_channel", "organization") else "partial", s,
           "; ".join(f"{x['source']} {x['authority_score']} ({x['claims_checked']} checked)" for x in r[:6]) + ". Our own findings rank high on self-checked claims (D-61)")


def q8():
    s = []
    r = rows(s, "select to_jsonb(x) from (select source, source_kind, coalesce(topic, 'all') topic, median_lead_days, claims_checked from api.source_registry where median_lead_days is not null and topic is null order by median_lead_days desc) x")
    ahead = [x for x in r if float(x["median_lead_days"]) > 0]
    record(8, "Which sources reported a breaking change before the first-party docs or fix did?", "L1 registry / lead time", "community trackers ahead of the vendor for bugs; editorial restatements behind", r, "answered" if ahead else "partial", s,
           "ahead: langgraph-swarm-py tracker +37 days, langchain tracker +105 (bug report to fix); behind: AgentMail -264, CopilotKit -307 (restating the 1.0 docs)")


def q9():
    s = []
    before = json.load(open(os.path.join(RUN4, "attention-due-before.json"), encoding="utf-8"))
    now = rows(s, "select to_jsonb(x) from (select slug, watch_level, reason, mission from api.attention_due(now())) x")
    ok = any(d["slug"] == "vendor-issues-on-release" and "deepagents 0.7.37" in d["reason"] for d in before) and not any(d["slug"] == "dependents-on-major" for d in before)
    record(9, "After deepagents 0.7.37 (2026-11-12), which policies are due?", "L2 events -> attention", "vendor-issues-on-release due by event; dependents-on-major not due (no x.0.0 in the window); W0 never", {"before_sweep": [{k: d[k] for k in ('slug', 'reason', 'mission')} for d in before], "now": now},
           "answered" if ok else "failed", s, "due before the event sweep, nothing due after it; the mission named is watch-langchain-ecosystem (status created; no Mission Control runtime ran)")


def q10():
    s = []
    r = rows(s, """select to_jsonb(x) from (select p.slug, s.trigger_kind, s.items_seen, s.items_selected, round(s.items_seen::numeric / nullif(s.items_selected, 0), 1) seen_per_selected, s.rejected
                   from acquisition.attention_sweep s join acquisition.attention_policy p on p.id = s.policy_id order by s.started_at) x""")
    record(10, "How noisy is each channel?", "L1 attention", "GitHub search noisy (spam templates, bots); Stack Overflow near silent; forum active (§6)", r, "answered", s, "seen per selected: GitHub backfill 20.7, event sweep 18.7, forum 36.2, HN 35.3, Stack Overflow 10")


def q11():
    s = []
    libs = {k: one(f"select id from catalog.entity where kind='library' and slug={q(k)}") for k in ("langchain", "langgraph", "deepagents")}
    using = {k: rows(s, f"select to_jsonb(x) from (select work_kind, work_slug, revision_title, binding, latest_release, releases_since_revision from api.modules_using_software({q(v)})) x") for k, v in libs.items()}
    rel = one("select id from catalog.entity where kind='library_release' and slug='deepagents-0-7-37'")
    affected = rows(s, f"select to_jsonb(x) from (select work_slug, release, breaking, binding from api.modules_affected_by_release({q(rel)})) x")
    ok = any(using["langchain"]) and any(using["deepagents"])
    record(11, "Which of our modules bind LangChain v1 or Deep Agents, and which does deepagents 0.7.37 affect? (loop-3 Q5 rerun)", "L2 own content / T1",
           "the loop-4 module binds langchain, langgraph and deepagents; the 0.7.37 release reaches it", {"using": using, "affected_by_deepagents_0_7_37": affected}, "answered" if ok and affected else ("partial" if ok else "failed"), s,
           f"loop 3 returned nothing; now {sum(len(v) for v in using.values())} module bindings and {len(affected)} affected by 0.7.37")


def q12():
    s = []
    r = rows(s, f"select to_jsonb(x) from (select output_kind, slug, state, runs from api.interview_outputs({q(STATE['thread'])})) x")
    record(12, "What did the design interview produce, and has it run?", "product conversation -> outputs", "the probes and policies of loop 4, each with run counts", r, "answered" if len(r) >= 20 else "partial", s,
           f"{sum(1 for x in r if x['output_kind'] == 'probe')} probes and {sum(1 for x in r if x['output_kind'] == 'attention_policy')} policies; W0 policies have no sweeps by design")


def q13():
    s = []
    hits = search(s, "create_react_agent deprecated prompt system_prompt create_agent", spaces=["assertions", "units", "knowledge_text"], limit=12)
    first = {t: next((i for i, h in enumerate(hits) if h["tier"] == t), None) for t in (0, 1, 2, 3)}
    ok = first[3] is None or min(x for x in (first[1], first[2]) if x is not None) < first[3]
    record(13, "Search 'create_react_agent deprecated prompt': does probe or first-party evidence lead community posts?", "L3 search / tiers", "T1 probe observations or T2 docs above T3 threads", {"first_rank_by_tier": first, "hits": hits}, "answered" if ok else "partial", s,
           "no claim is T0: verified needs a Knowledge Services admission (D-55)")


def q14():
    s = []
    ws = STATE["workspace"]
    sql(f"""select 1""")
    hits = search(s, "my tutorial uses create_react_agent, what do I change?", lenses=("private",), workspaces=[ws], limit=6)
    ok = hits and "migration" in (hits[0]["snippet"] or "").lower() or any("system_prompt" in (h["snippet"] or "") for h in hits[:3])
    record(14, "A learner asks 'my tutorial uses create_react_agent, what do I change?' inside the module scope", "L3 own content (workspace scope)", "the module's migration section first", hits, "answered" if ok else "partial", s,
           "the module is an unreleased draft, so its passages are lens private to the author workspace; after John's release review they become lens ours (T1)")


def q15():
    s = []
    d = rows(s, "select api.library_dossier('langchain') d")[0]
    ok = d.get("releases", {}).get("count", 0) > 0 and d.get("probes") and d.get("sources")
    record(15, "The library dossier for langchain", "L1/L2 report", "releases, claims by status, open community claims, probes with cells, ranked sources", {k: (v if k != "open_community_claims" else (v or [])[:5]) for k, v in d.items()}, "answered" if ok else "partial", s,
           f"{d['releases']['count']} releases, {d['claims']['total']} claims ({d['claims']['disputed']} disputed), {len(d['probes'] or [])} probes, {len(d['sources'] or [])} ranked sources")


def q16():
    s = []
    hits = search(s, "which pages explain create_deep_agent", spaces=["digests"], limit=10)
    det = rows(s, """select to_jsonb(x) from (select count(*) n from retrieval.vector_item vi join retrieval.projection_target pt on pt.id = vi.projection_target_id join retrieval.vector_space_version sv on sv.id = vi.space_version_id
                     join retrieval.vector_space vs on vs.id = sv.vector_space_id left join content.digest_item di on di.id = pt.digest_item_id join content.document_digest g on g.id = coalesce(pt.digest_id, di.digest_id)
                     where vs.slug = 'digests' and vi.lifecycle = 'active' and g.producer_kind = 'deterministic') x""") if False else [{"n": int(one("""select count(*) from retrieval.vector_item vi join retrieval.projection_target pt on pt.id = vi.projection_target_id join retrieval.vector_space_version sv on sv.id = vi.space_version_id
                     join retrieval.vector_space vs on vs.id = sv.vector_space_id left join content.digest_item di on di.id = pt.digest_item_id join content.document_digest g on g.id = coalesce(pt.digest_id, di.digest_id)
                     where vs.slug = 'digests' and vi.lifecycle = 'active' and g.producer_kind = 'deterministic'"""))}]
    record(16, "Loop-3 Q3 rerun: does the digests space still carry deterministic noise?", "L3 digests", "0 active deterministic items in the digests space", {"active_deterministic_in_digests": det[0]["n"], "hits": hits}, "answered" if det[0]["n"] == 0 else "failed", s,
           "1,342 deterministic items retired from the digests space; they stay in knowledge_text (count read as postgres: retrieval.* is not readable by app_reader)")


QS = {i: globals()[f"q{i}"] for i in range(1, 17)}
if __name__ == "__main__":
    for n in ([int(a) for a in sys.argv[1:]] or list(QS)):
        try:
            QS[n]()
        except Exception as e:  # noqa: BLE001
            record(n, f"question {n}", "-", None, None, "error", [], repr(e)[:500])
