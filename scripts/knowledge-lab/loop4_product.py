"""Build 08 knowledge loop 4, product side (lab disposable-aieng-build04 only): the design interview and the course module.

interview: an author account (lab fixture standing in for John's author seat; it never approves anything on his behalf) creates a
  workspace and an `interview` thread through the product command API. Owner turns quote John's own words from the 2026-11-12/13
  session verbatim; agent turns summarise the proposals and carry a context snapshot of the knowledge-base retrieval actually run
  against the lab at recording time. Probes and attention policies of loop 4 are then linked to the thread.
module: the module "From create_react_agent to create_agent and Deep Agents: migrating with evidence" and its activity, authored
  through create_work with bindings to concepts, libraries, the probe-judged claims and the probe-run locators, plus runtime
  requirements; passages indexed with index_passages. No release is frozen: that needs John's human release review.
Run: python -I -X utf8 scripts/knowledge-lab/loop4_product.py interview | module
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
TOKENS = os.path.join(RUN4, ".session-tokens.json")


def state():
    return json.load(open(STATE, encoding="utf-8")) if os.path.exists(STATE) else {}


def author():
    st = state()
    if os.path.exists(TOKENS) and st.get("author_id"):
        tok = json.load(open(TOKENS, encoding="utf-8"))
        u = L.User.__new__(L.User)
        u.label, u.id, u.token, u.client_token = "b08author4", st["author_id"], tok["author"], None
        return u
    u = L.User("b08author4")
    L.ok(L.worker("set_account_profile", {"principal_id": u.id, "age_band": "adult", "jurisdiction": "US", "established_by": "admin", "eligibility": "eligible"}))
    write_json(TOKENS, {"author": u.token})
    st.update(author_id=u.id)
    write_json(STATE, st)
    return u


def workspace(u):
    st = state()
    if not st.get("workspace"):
        st["workspace"] = L.ok(u.cmd(None, "create_workspace", {"name": "Build 08 loop 4 course workspace"}))["workspaceId"]
        write_json(STATE, st)
    return st["workspace"]


def retrieval_snapshot(query, spaces=("assertions", "units", "digests")):
    vec = embed_texts([query])[0]
    rows = sql_json(f"""select json_build_object('tier', h.source_tier, 'lens', h.lens, 'kind', h.content_kind, 'doc_type', h.document_type_code, 'unit_kind', h.unit_kind, 'snippet', left(h.snippet, 220))
                         from api.search_unified({q(query)}, {q(vec_literal(vec))}, p_space_slugs => {qarr(list(spaces))}, p_limit => 8) h""")
    return {"schema": "aieng.context.v1", "kind": "knowledge_retrieval", "query": query, "taken_at": now_iso(), "note": "retrieved from the lab knowledge base when this interview was recorded (2026-11-13)", "hits": rows, "items": []}


OWNER_TURNS = [  # verbatim from John's messages in the 2026-11-12/13 session
    "we need to have some type of authority / expertise / \"something like that\" ranking of the sources, people, the entities and places we get data from.",
    "Wouldn't a research-powered education platform be running real experiments on the libraries (or platforms, etc) that they include in their knowledge base and courses ? I could imagine visiting a course platform and within a course or generally I go through reports full of evaluations, run traces, code snippets, release dates and statements, unresolved and open issues etc about a library.",
    "Does this mean we go to github issues ? Does this mean we check out posts ? Shouldn't I go get a reddit api key or something like that for further ingestion of even anonymous actors or psuedo-anonymous, or real people talking about these things.",
    "Doesn't this point to \"source intelligence\" or more so \"source attention allocation rules\"?",
    "Loop 4's subject matter ushers in the human pipeline participiation needs fully I believe now. You'll need to take into account mission control's missions connections to the knowledge and how it could provide the underlying missions that will \"watch, however often, however deep, on whatever budget\". I am envisioning deep interview sessions, supplemented by current knowledge base retrieval to produce the experiments (in this context and more).",
    "Prototype all that has been proposed and additionally create a course module for the langchain-langgraph-deepagents ecosystem that utilizes it. GO!",
]
AGENT_TURNS = [
    ("Three separate things: a source registry (who said it, how good they are on this topic, as components and a track record), attention allocation rules (what we watch, how often, how deep, on what budget) and experiments (probes that test a claim against a version matrix). Authority decides what we believe; attention decides what we look at. Community evidence never becomes a fact without a first-party locator or one of our probes.",
     "authority ranking of sources for LangChain v1 migration"),
    ("Proposed probes P1 to P13 for the create_react_agent to create_agent migration: the deprecation warning, prompt vs system_prompt, streaming node names, the prebuilt and the new keywords, Pydantic state, legacy imports, where the docs link goes, three reported bugs, a dependency conflict, the agentmail token figure and two release facts. Cells are dates: what a tutorial-follower got that day.",
     "create_react_agent deprecated create_agent prompt system_prompt"),
    ("Channels: GitHub issues on the vendor and dependent repositories first, the LangChain forum and Hacker News next; Reddit and X registered at W0 (commercial API terms not reviewed, noise). Pseudonymous people are kept as handles with the platform's own role label, never enriched.",
     "langgraph 1.0 breaking change dependent project issue"),
    ("Watch missions in Mission Control run the due policies: api.attention_due(as_of) lists what is due by cadence or by a release event; the mission sweeps within its budget, fan-out and depth limits and writes sweeps, captures and probe reruns back. Interviews like this one design the probes and policies and are linked to them.",
     "deepagents release subagent issue"),
]


def stage_interview():
    u = author()
    ws = workspace(u)
    st = state()
    if st.get("thread"):
        log(f"interview exists: {st['thread']}")
        return
    title = "Loop 4 design interview: source intelligence, attention and experiments (2026-11-12/13)"
    th = one(f"select id from conversation.thread where workspace_id={q(ws)} and title={q(title)}") or L.ok(u.cmd(ws, "create_thread", {"title": title, "purpose": "interview", "mode": "elicit", "visibility": "workspace"}))["threadId"]
    done = int(one(f"select count(*) from conversation.message where thread_id={q(th)}"))  # resume after a partial run
    order = [("user", 0), ("user", 1), ("user", 2), ("user", 3), ("assistant", 0), ("assistant", 1), ("assistant", 2), ("user", 4), ("assistant", 3), ("user", 5)]
    for role, i in order[done:]:
        if role == "user":
            L.ok(u.cmd(ws, "append_message", {"thread_id": th, "role": "user", "content": {"text": OWNER_TURNS[i], "speaker": "John (owner), quoted verbatim from the session", "recorded_by": "agent:claude-code"}}))
        else:
            text, query = AGENT_TURNS[i]
            L.ok(u.cmd(ws, "append_message", {"thread_id": th, "role": "assistant", "agent_identity": "claude-code (Build 08 loop 4)", "content": {"text": text}, "context": retrieval_snapshot(query)}))
    st["thread"] = th
    write_json(STATE, st)
    sql(f"update verification.probe set designed_in_thread_id = {q(th)} where designed_in_thread_id is null")
    sql(f"update acquisition.attention_policy set designed_in_thread_id = {q(th)} where designed_in_thread_id is null")
    log(f"interview thread {th}: {len(order)} messages; outputs linked: {one(f'select count(*) from api.interview_outputs({q(th)})')}")


# ====================================================================================================== module
def matrix_table():
    def cell(p, c):
        r = one(f"select outcome || '|' || (observations->'checks')::text from api.probe_matrix({q(p)}) where cell_label = {q(c)}")
        return json.loads(r.split("|", 1)[1]) if r else None
    D0, D1, D2, D3 = "D0-2025-10-16", "D1-2025-10-18", "D2-2026-04-23", "D3-latest"
    rows = [("Deprecation warning on `langgraph.prebuilt.create_react_agent` (P1)", lambda c: (lambda x: "warns: `LangGraphDeprecatedSinceV10`, names `create_agent`" if x and x.get("deprecation_warning") else "no warning")(cell("P1-crea-deprecation", c))),
            ("`create_agent(..., prompt=...)` (P2)", lambda c: (lambda x: "no `create_agent` yet" if x and x.get("create_agent_exists") is False else ("`TypeError` (loud)" if x and x.get("prompt_kwarg_rejected") else "accepted"))(cell("P2-create-agent-prompt-kwarg", c))),
            ("Name of the model node in `stream_mode=\"updates\"` (P3)", lambda c: (lambda x: f"prebuilt `{x.get('prebuilt_model_node')}`" + (f", `create_agent` `{x.get('create_agent_model_node')}`" if x.get("create_agent_model_node") else "") if x else "")(cell("P3-stream-node-name", c))),
            ("Prebuilt with `system_prompt=` / `middleware=` (P4)", lambda c: (lambda x: "both `TypeError`" if x and x.get("system_prompt_rejected") and x.get("middleware_rejected") else "accepted")(cell("P4-crea-new-kwargs", c))),
            ("Pydantic `state_schema` with an invalid value (P5)", lambda c: (lambda x: ("prebuilt: `ValidationError`" + ("; `create_agent`: accepted, **not validated**" if x.get("create_agent_validates") is False else "")) if x else "")(cell("P5-pydantic-state", c))),
            ("`langchain.hub`, `AgentExecutor` (P6)", lambda c: (lambda x: "import from `langchain`" if x and x.get("langchain_hub_imports") else "only from `langchain_classic`")(cell("P6-legacy-imports", c))),
            ("Stale `structured_response` on the next turn (P8)", lambda c: (lambda x: "not run" if x is None else ("**stale** (returns the previous turn's answer)" if x.get("stale_turn2") else "fresh"))(cell("P8-stale-structured-response", c)))]
    head = "| What | 2025-10-16 (`langgraph` 0.6.10, `langchain` 0.3.27) | 2025-10-18 (1.0.0) | 2026-04-23 (`langgraph` 1.1.9, `langchain` 1.2.15) | 2026-11-13 (`langgraph` 1.2.21, `langchain` 1.5.0) |\n| --- | --- | --- | --- | --- |\n"
    return head + "\n".join(f"| {name} | " + " | ".join(f(c) or "not run" for c in (D0, D1, D2, D3)) + " |" for name, f in rows)


def sources_table():
    rows = sql_rows("""select source, source_kind, coalesce(topic, 'all topics'), claims_checked, confirmed, qualified, refuted, authority_score, recommended_watch_level, coalesce(current_watch_level, '-')
                         from api.source_registry where method = 'derived' and claims_checked > 0 order by authority_score desc, claims_checked desc limit 14""")
    return "| Source | Kind | Topic | Checked | Confirmed | Qualified | Refuted | Score | Suggested watch | Current watch |\n| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n" + "\n".join("| " + " | ".join(r) + " |" for r in rows)


def event_issues():
    rows = sql_rows("""select d.canonical_title, so.canonical_url, d.attributes->>'thread_state' from content.document d join evidence.source so on so.id = d.canonical_source_id
                        join acquisition.fetch f on f.request_url = so.canonical_url join acquisition.attention_sweep s on s.id = f.sweep_id
                        where s.trigger_kind = 'event' and d.document_type_code = 'issue_thread' group by 1, 2, 3 order by 1""")
    return "\n".join(f"- [{t}]({u}) ({st}): claim candidates only, not probed" for t, u, st in rows) or "- none selected"


MODULE_MD = """# From `create_react_agent` to `create_agent` and Deep Agents: migrating with evidence

*Module (Build 08 loop 4 lab draft, evidence as of 2026-11-13). Every statement below is tied to a probe run, a first-party page or a community thread in the knowledge base; the tables are generated from it. Nothing here is "verified" in the platform's sense yet: that needs a Knowledge Services verification run (see the last section).*

## 1. Three things are called `create_react_agent`

1. `langchain.agents.create_react_agent(llm, tools, prompt: BasePromptTemplate, ...)`: the old text-ReAct agent of LangChain 0.x. Since 1.0 it lives in `langchain_classic.agents`.
2. `langgraph.prebuilt.create_react_agent(model, tools, *, prompt=...)`: the one most tutorials use. Deprecated in LangGraph 1.0 in favour of `langchain.agents.create_agent`; it still runs today and warns.
3. During the LangChain 1.0 alphas the new factory was briefly called `create_react_agent` too; the release notes record `rename create_react_agent -> create_agent (#32789)` before `v1.0.0a3`.

One trap is in the docs themselves: on the LangGraph v1 migration and release pages, the `create_react_agent` link points to the **langchain-classic** reference, which documents function 1, not the deprecated prebuilt 2 (probe P7; the two signatures differ).

## 2. What we measured

Each column is the environment `uv pip install --exclude-newer <date>` resolved that day: what a learner who followed a tutorial written then would have installed. A deterministic fake chat model, so no model spend and the same result every run.

{matrix}

Read across a row: the rename of `prompt` fails loudly, the node rename does not fail at all, and Pydantic state stopped being validated without any error. The quiet ones are the dangerous ones.

## 3. The migration, minimal

```python
# before: langgraph 0.6
from langgraph.prebuilt import create_react_agent
agent = create_react_agent(model, tools, prompt="You are a billing assistant.")

# after: langchain 1.x
from langchain.agents import create_agent
agent = create_agent(model, tools, system_prompt="You are a billing assistant.")
```

Checklist, in order of how quietly each one breaks:

- **Streaming consumers:** the model node is `model`, not `agent`. Code that filters updates on `"agent"` keeps running and matches nothing.
- **Pydantic state:** `create_agent` accepts a Pydantic class as `state_schema` and carries its fields, but it no longer validates them. If you relied on validation, validate in a middleware or in your tools.
- **Prompt:** `prompt=` raises `TypeError`; use `system_prompt=` (dynamic prompts move to middleware).
- **Legacy imports:** `langchain.hub` and `langchain.agents.AgentExecutor` exist only in `langchain_classic` from 1.0 on.
- **Do not half-migrate:** the deprecated prebuilt rejects `system_prompt=` and `middleware=`.

## 4. Dependency traps

- **Mixed majors without an error.** On 2025-10-28, `langgraph>=1.0` plus an unpinned `langgraph-swarm` resolved to `langgraph` 1.0.1 with `langchain-core` 0.3.79: the resolver silently backtracked to `langgraph-swarm` 0.0.13. With the reporter's pins (`langgraph-swarm>=0.0.14`) it was unsatisfiable, as reported in langgraph-swarm-py #106; `langgraph-swarm` 0.1.0 (2025-12-04) fixed it (probe P11).
- **Pre-releases pulled in.** On 2025-10-16, adding `deepagents` to the same install pulled `langchain` 1.0.0rc1 and `langgraph` 1.0.0a4 (probe P0b).
- Lesson: pin the LangChain packages to the same major, and read the resolved versions, not only the exit code.

## 5. Deep Agents sits on top of `create_agent`

`create_deep_agent` has been public since `deepagents` 0.2.6 and `HarnessProfile` since 0.5.4 (symbol history over 93 releases, loop 3); the newest release is 0.7.37 (2026-11-12). A subagent you build yourself (`CompiledSubAgent`) hands its final answer back to the parent as a `ToolMessage` (probe P10). Whether a parent model then calls the subagent again is model behaviour: the report of an infinite loop (deepagents #2184) was closed as not planned, and a deterministic parent stops. Set a `recursion_limit` and make the subagent's last message read as a final result.

## 6. Open edges

- **Stale structured output across turns** (langchain #36957): with `response_format` and a checkpointer, turn N+1 returned turn N's answer on 1.0.0 and 1.2.15; not on 1.5.0 (probe P8). If you pin at or below 1.2.x and use both, upgrade.
- **HITL middleware with `ainvoke`** (langchain #34974, open): not reproduced in a minimal deterministic setup on 1.0.0, 1.2.15 or 1.5.0 (probe P9). That is not a refutation; the report used a real model, several tools and FastAPI. If you hit it, record your versions and a minimal reproduction.
- **New reports after the recent releases** (the event-triggered sweep after `deepagents` 0.7.33 to 0.7.37 and the latest `langchain`/`langgraph` releases):
{event_issues}

## 7. How we know, and who to trust on what

Probe verdicts so far: {verdict_summary}. The one contradiction is the claim that the prompt rename was "silent" (it raises `TypeError`). The article that made it measured honestly elsewhere: its LangGraph token figure (1,288 input tokens) reproduced at 1,282 on today's packages (probe P12, live model, 5 runs).

{sources}

The score starts from the kind of source (first party, community, editorial) and moves only with checked claims; read it together with how many claims were checked. Two cautions: the first rows are this system's own findings checked by its own probes, which is circular until someone else reproduces them; and one or two checked claims are too few to move anyone's watch level. "Verified" in the platform's sense needs a Knowledge Services verification run that admits these probe runs as evidence; none has run yet.
"""

ACTIVITY_MD = """# Activity: run the migration probes in your own environment

1. Create two environments with `uv`: `uv venv old && uv pip install --python old --exclude-newer 2025-10-17 langgraph langchain langgraph-prebuilt` and `uv venv new && uv pip install --python new langgraph langchain langchain-classic`.
2. Run probes P2 (`prompt=` against `system_prompt=`) and P3 (streaming node names) from the course repository in both.
3. Paste the JSON each probe prints.
4. In three sentences: which change fails loudly, which fails silently, and what would you add to your own code or CI to catch the silent one?

Evidence the grader looks for: both JSON outputs with their package versions, and an explanation that names the `agent` to `model` node rename as the silent change.
"""


def module_spec():
    keys = json.load(open(os.path.join(RUN4, "claim-keys.json"), encoding="utf-8"))
    concepts = {s: one(f"select id from catalog.entity where kind='concept' and slug={q(s)}") for s in ("middleware", "human-in-the-loop", "subagents", "harness-engineering", "agent-orchestration")}
    libs = {s: one(f"select id from catalog.entity where kind='library' and slug={q(s)}") for s in ("langchain", "langgraph", "deepagents", "langchain-core")}
    vs = dict(sql_rows("select verdict, count(*) from api.claim_verdicts group by 1"))
    sup = int(vs.get("directly_supported", 0)) + int(vs.get("supported_with_qualification", 0))
    summary = (f"{sup} supported ({vs.get('supported_with_qualification', 0)} of them with qualifications), {vs.get('not_supported', 0)} not reproduced, "
               f"{vs.get('unverifiable', 0)} not checkable by a deterministic probe, {vs.get('contradicted', 0)} contradicted")
    body = MODULE_MD.replace("{verdict_summary}", summary).replace("{matrix}", matrix_table()).replace("{event_issues}", event_issues()).replace("{sources}", sources_table())
    bindings = [{"local_key": f"covers-{s}", "relation": "covers", "target": {"kind": "entity", "id": i}} for s, i in concepts.items() if i]
    bindings += [{"local_key": f"uses-{s}", "relation": "uses", "target": {"kind": "entity", "id": i}} for s, i in libs.items() if i]
    for v in sql_json("select json_build_object('claim', claim_id, 'verdict', verdict, 'probe', probe) from api.claim_verdicts"):
        k = next((kk for kk, cid in keys.items() if cid == v["claim"]), None)
        rel_ = "contradicts" if v["verdict"] == "contradicted" else ("supports" if v["verdict"] in ("directly_supported", "supported_with_qualification", "partially_supported") else None)
        if k and rel_:
            bindings.append({"local_key": f"{rel_}-{k.lower()}", "relation": rel_, "target": {"kind": "claim", "id": v["claim"]}})
    for p, loc in sql_rows("select p.slug, (select r.output_locator_id from verification.probe_run r where r.probe_id = p.id order by r.started_at desc limit 1) from verification.probe p"):
        if loc:
            bindings.append({"local_key": "source-" + p.lower()[:50], "relation": "source", "target": {"kind": "locator", "id": loc}})
    runtime = [{"local_key": "lc", "kind": "package", "ecosystem": "pypi", "name": "langchain", "version_spec": ">=1.0,<2", "resolved_version": "1.5.0"},
               {"local_key": "lg", "kind": "package", "ecosystem": "pypi", "name": "langgraph", "version_spec": ">=1.0,<2", "resolved_version": "1.2.21"},
               {"local_key": "lcc", "kind": "package", "ecosystem": "pypi", "name": "langchain-classic", "version_spec": ">=1.0,<2", "resolved_version": "1.0.8"},
               {"local_key": "da", "kind": "package", "ecosystem": "pypi", "name": "deepagents", "version_spec": ">=0.7,<0.8", "resolved_version": "0.7.37"}]
    rev = {"title": "From create_react_agent to create_agent and Deep Agents: migrating with evidence",
           "body": L.body(body, {"loop": 4, "evidence_as_of": "2026-11-13", "generated_tables": ["probe matrix", "sources", "event issues"]}), "bindings": bindings, "runtime": runtime}
    return body, rev, libs, runtime


def index_module(ws, revision_id, body, old_revision=None):
    if old_revision:
        sql(f"select retrieval.retire_items_for_passages(coalesce((select array_agg(id) from library.passage where revision_id = {q(old_revision)}), '{{}}'::uuid[]))")
    sections = [x.strip() for x in ("\n" + body).split("\n## ") if x.strip()]
    L.ok(L.worker("index_passages", {"workspace_id": ws, "revision_id": revision_id, "procedure_version": "lab-md-4", "passages": [
        {"text": ("## " + x if i else x)[:4000], "locator": {"schema": "aieng.locator.v1", "block": 0, "section": i}} for i, x in enumerate(sections)]}))
    return len(sections)


def stage_module():
    u = author()
    ws = workspace(u)
    st = state()
    body, rev, libs, runtime = module_spec()
    if st.get("module"):
        head = one(f"select head_revision_id from authoring.work where id = {q(st['module']['workId'])}")
        new = L.ok(u.cmd(ws, "revise_work", {"work_id": st["module"]["workId"], "revision": rev}, head=head))
        n = index_module(ws, new["revisionId"], body, old_revision=head)
        st.setdefault("module_revisions", [st["module"]["revisionId"]]).append(new["revisionId"])
        st["module"]["revisionId"] = new["revisionId"]
        log(f"module revised: {new['revisionId']} ({len(rev['bindings'])} bindings, {n} passages; passages of {head} retired)")
    else:
        mod = L.ok(u.cmd(ws, "create_work", {"kind": "module", "slug": "create-react-agent-to-create-agent-and-deep-agents", "revision": rev}))
        act = L.ok(u.cmd(ws, "create_work", {"kind": "activity", "slug": "run-the-migration-probes", "revision": {
            "title": "Run the migration probes in your own environment", "body": L.body(ACTIVITY_MD, {"loop": 4}),
            "bindings": [{"local_key": "uses-langchain", "relation": "uses", "target": {"kind": "entity", "id": libs["langchain"]}},
                         {"local_key": "uses-langgraph", "relation": "uses", "target": {"kind": "entity", "id": libs["langgraph"]}}], "runtime": runtime[:3]}}))
        n = index_module(ws, mod["revisionId"], body)
        L.ok(L.worker("index_passages", {"workspace_id": ws, "revision_id": act["revisionId"], "procedure_version": "lab-md-4", "passages": [{"text": ACTIVITY_MD, "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
        st.update(module=mod, activity=act)
        log(f"module {mod['revisionId']} with {len(rev['bindings'])} bindings; activity {act['revisionId']}; {n} passages")
    st["bindings"] = len(rev["bindings"])
    write_json(STATE, st)
    out = os.path.join(C.LAB, "..", "10-review-workspace", "reviews", "BUILD-08-LOOP-4-MODULE.md")
    open(out, "w", encoding="utf-8", newline="\n").write(body + "\n\n---\n\n" + ACTIVITY_MD)


if __name__ == "__main__":
    {"interview": stage_interview, "module": stage_module}[sys.argv[1]]()
