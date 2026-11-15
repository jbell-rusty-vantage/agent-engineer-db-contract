"""Build 08 loop 7 (candidate J), lab disposable-aieng-build04 only. Approved by John 2026-11-15 ("complete them both now. J and G.").

restate   D-80: the loop-5 claims are attribution-framed ("The post states that X"); a probe proves X, not what a post says. John
          confirmed 14 restated claims in chat on 2026-11-15 (9 direct: attribution and unprobed halves removed; 5 qualified: the
          qualification the probe showed). Each restatement is a new claim atomized from the original (atomized_from_id), with the
          original's subjects and attributions copied, and one human_confirmed directly_supported verdict over the original verdict's
          probe and cells. The originals stay proposed as attribution records. Idempotent (skips a restatement that exists).
index     search items for claims touched in loop 7: tier 0 when verified, else by source role (community 3); then embeddings.
Run: python -I -X utf8 scripts/knowledge-lab/loop7_j.py restate | index
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_process as L1

RUN7 = os.path.join(C.LAB, "knowledge-loop-7")
os.makedirs(RUN7, exist_ok=True)
DECIDED_BY = "human:john (written answer 2026-11-15, confirmed the 14 restated claims, D-80; recorded by the session agent)"

# original claim id prefix -> (restated statement, qualified, what was dropped, polarity)
AFF = lambda note: {"negative": False, "note": note}
NEG = {"negative": True}
RESTATE = {
    "3f32e433": ("Passing checkpoint_ns in the configurable config does not change where a root invoke stores checkpoints: the checkpoint_ns column holds '' (langgraph 1.0.0, 1.1.9, 1.2.21).",
                 False, "attribution", NEG),
    "173bbf5c": ("create_agent's routing from the model node exits when tool_calls is empty and does not distinguish calls placed in invalid_tool_calls.",
                 False, "attribution", NEG),
    "937ef76c": ("With create_agent, when two tools in one model turn return Command(graph=Command.PARENT, ...), only one update reaches the parent graph, including when goto is a plain string (langgraph 1.1.9 and 1.2.21).",
                 False, "attribution", None),
    "7a14f69c": ("Mustache prompt templates in langchain-core HTML-escape variable values: <, >, & and \" become HTML entities.",
                 False, "attribution; 'via _html_escape in render()' (implementation detail, not probed)", None),
    "b6133009": ("Triple mustache {{{var}}} renders the value unescaped in langchain-core mustache prompt templates.",
                 False, "attribution; 'the prompt docs do not mention this' (not probed)", None),
    "26b950e1": ("After a caught KeyError from add_example, LengthBasedExampleSelector.select_examples raises IndexError instead of returning the existing example.",
                 False, "attribution", None),
    "a7c3b8d9": ("aadd_example leaves LengthBasedExampleSelector in the same inconsistent state as add_example.",
                 False, "attribution; 'delegates to the same code path' (not probed)", None),
    "1a5b70c6": ("LengthBasedExampleSelector.add_example appends to examples before formatting the example, so a failure leaves example_text_lengths one shorter than examples.",
                 False, "attribution", None),
    "c6f643af": ("The Deep Agents task tool starts a subagent with the task description as a new human message; the parent's conversation does not reach the subagent (deepagents 0.5.3, 0.7.37).",
                 False, "attribution; 'implemented by SubAgentMiddleware' (not probed)",
                 AFF("affirmative invocation fact; 'does not reach' states what the new message excludes")),
    "e438c12b": ("A sub-agent invoked inside a supervisor's tool checkpoints under its own namespace, the task path tools:<id> (not the graph id); the supervisor writes under '' (langgraph 1.0.0, 1.1.9, 1.2.21).",
                 True, "attribution; 'the graph id' replaced by what the probe observed",
                 AFF("affirmative namespace fact; 'not the graph id' contrasts the original claim")),
    "f68ed948": ("On langchain 1.5.0 the next model request carries an error ToolMessage for each invalid tool call (none on 1.2.15); the agent loop still ends when only invalid calls are present.",
                 True, "attribution; the 1.4.3 boundary (not pinned by the cells)",
                 AFF("affirmative message fact; 'none on 1.2.15' bounds the versions")),
    "28a30bff": ("The f-string prompt template format inserts variable values without HTML escaping (langchain-core 0.3.79, 1.3.1, 1.8.0).",
                 True, "attribution; the jinja2 half (jinja2 not installed in the cells)",
                 AFF("affirmative insertion fact; 'without HTML escaping' describes the output")),
    "f10d0649": ("A Deep Agents subagent returns only its final message to the parent agent, as the task tool's ToolMessage.",
                 True, "attribution; the 'without a checkpointer' half (not probed)", None),
    "70b7cd56": ("With create_agent, response_format and a checkpointer, turn N+1 returned turn N's structured_response on langchain 1.0.0 and 1.2.15, not on 1.5.0.",
                 True, "the 1.5.0 cell, where it no longer reproduces (issue closed 2026-08-05)",
                 AFF("affirmative reproduction fact; 'not on 1.5.0' bounds the versions")),
}


def restate():
    rcpt = None
    made = []
    for prefix, (statement, qualified, dropped, polarity) in RESTATE.items():
        orig = sql_json(f"""select to_jsonb(x) from (select c.id, c.statement, c.structured, c.claim_type,
                               v.id verdict_id, v.probe_id, v.verdict::text verdict, v.cells, v.rationale, p.slug probe
                          from evidence.claim c
                          join verification.probe_verdict v on v.claim_id = c.id and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)
                          join verification.probe p on p.id = v.probe_id
                         where c.id::text like {q(prefix + '%')} and v.review_state = 'human_confirmed') x""")
        if len(orig) != 1:
            raise SystemExit(f"{prefix}: expected one claim with a current human-confirmed verdict, found {len(orig)}")
        o = orig[0]
        existing = one(f"select id from evidence.claim where atomized_from_id = {q(o['id'])} and structured->>'path' = 'restatement'")
        if existing:
            made.append({"original": o["id"], "restated": existing, "skipped": True})
            continue
        if rcpt is None:
            rcpt = native_receipt("loop7-restatements", {"loop": 7, "delta": "D-80", "confirmed_by": "John, written answer 2026-11-15"})
        src = o["structured"] or {}
        structured = {"path": "restatement", "restates": o["id"], "probe": o["probe"], "qualified": qualified, "dropped": dropped,
                      "source_role": src.get("source_role") or ("community" if src.get("path") == "community_thread" else "first_party"),
                      "original_quote": src.get("quote"), "original_document": src.get("document"), "polarity": polarity,
                      "confirmed": "John, written answer in chat, 2026-11-15 (D-80 restatements)"}
        cid = one(f"""insert into evidence.claim(tenant_id, claim_type, statement, structured, status, composite, atomized_from_id, producer_origin_digest, created_by_receipt_id)
                      values ({q(TENANT)}, {q(o['claim_type'])}, {q(statement)}, {q(structured)}, 'proposed', false, {q(o['id'])},
                              {q('sha256:' + sha256_text('build08-loop7-restatement:' + statement))}, {q(rcpt)}) returning id""")
        sql(f"""insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role)
                select tenant_id, {q(cid)}, entity_id, role from evidence.claim_subject where claim_id = {q(o['id'])} on conflict do nothing;
                insert into evidence.attribution(tenant_id, source_id, claim_id, entity_id, role, locator_id)
                select tenant_id, source_id, {q(cid)}, entity_id, role, locator_id from evidence.attribution where claim_id = {q(o['id'])};
                insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role)
                select tenant_id, {q(cid)}, locator_id, role from evidence.claim_evidence_link where claim_id = {q(o['id'])} on conflict do nothing""")
        rationale = (f"Restatement (D-80) of claim {o['id']} over the same probe runs: {o['rationale'].split(' | ')[0]}"
                     f" | Dropped from the original: {dropped}. | Human confirmation: John confirmed this restated claim (written answer, 2026-11-15).")
        vid = one(f"""insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state)
                      values ({q(TENANT)}, {q(cid)}, {q(o['probe_id'])}, 'directly_supported'::evidence.support_verdict, {q(o['cells'])}, {q(rationale)},
                              {q(DECIDED_BY)}, 'human_confirmed') returning id""")
        made.append({"original": o["id"], "original_verdict": o["verdict"], "restated": cid, "verdict": vid, "probe": o["probe"], "qualified": qualified, "statement": statement})
    write_json(os.path.join(RUN7, "restatements.json"), {"at": now_iso(), "decided_by": DECIDED_BY, "rows": made})
    log(f"restatements: {sum(1 for m in made if not m.get('skipped'))} written, {sum(1 for m in made if m.get('skipped'))} existed")


def index():
    L1.RUN_DIR = RUN7
    rows = sql_json(f"""select json_build_object('id', c.id, 'statement', c.statement, 'status', c.status::text,
                               'subject', (select entity_id from evidence.claim_subject s where s.claim_id = c.id limit 1), 'role', c.structured->>'source_role')
                          from evidence.claim c where c.tenant_id = {q(TENANT)} and c.structured->>'path' = 'restatement'""")
    for r in rows:
        tier = 0 if r["status"] == "verified" else {"community": 3, "third_party_editorial": 3, "own_experiment": 1, "first_party": 2}.get(r["role"], 3)
        text = f"[{r['status']} claim] {r['statement']}"
        for space in ("assertions", "knowledge_text"):
            L1.index_item(space, "claim", r["id"], text, "evidence", tier, "claim", entity_id=r["subject"], assurance_rank=20 if r["status"] == "verified" else 10)
    log(f"indexed {len(rows)} restated claims")
    L1.stage_embed()


if __name__ == "__main__":
    {"restate": restate, "index": index}[sys.argv[1]]()
