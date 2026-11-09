"""Build 08 knowledge loop 1: our own content for Q10/Q11/Q16 through the product API (real Auth users on the lab stack).

Creates an author ("author") with a shared workspace and a module revision that covers the concept 'Durable execution' and uses
LangGraph (revision bindings with entity targets), and a learner with a personal note mentioning sandboxes, indexed as a private
passage (lens private). Fixture content is synthetic lab material, labelled as such. Run after loop1_process.py entities.
"""
import os, sys, json, uuid
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "product-lab"))
os.environ.setdefault("PRODUCT_LAB_WORKDIR", r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\11-build04-lab")
from lab_common import *  # noqa
import run_lab as L  # the Build 01-07 lab helpers: User, worker, ok, body


def main():
    concept = one("select id from catalog.entity where kind='concept' and slug='durable-execution'")
    sandbox_concept = one("select id from catalog.entity where kind='concept' and slug='sandboxes'")
    langgraph = one("select id from catalog.entity where kind='library' and slug='langgraph'")
    assert concept and langgraph, "entities stage must run first"
    L.ok(L.worker("add_policy_version", {"body": {"schema": "aieng.access-policy.v1", "default_band": "adult", "public_publish_min_band": "adult", "public_read_min_band": "teen", "connector_min_band": "teen", "self_consent_min_band": "teen",
                                                   "consent_required_bands": {"embedding": ["child", "unknown"], "connector": ["child", "teen", "unknown"], "llm_inference": ["child", "unknown"], "third_party_share": ["child", "teen", "unknown"]},
                                                   "retention": {"temporary_asset_days": 7, "child_inactive_days": 365}, "backup_purge_days": 35, "jurisdictions": {"US": {"child_under": 13, "teen_under": 18, "guardian_consent_required_under": 13}}}}))
    author, learner, outsider = (L.User(x) for x in ("b08author", "b08learner", "b08outsider"))
    for u in (author, learner, outsider):
        L.ok(L.worker("set_account_profile", {"principal_id": u.id, "age_band": "adult", "jurisdiction": "US", "established_by": "admin", "eligibility": "eligible"}))
    ws = L.ok(author.cmd(None, "create_workspace", {"name": "Build 08 course workspace"}))["workspaceId"]
    module = L.ok(author.cmd(ws, "create_work", {"kind": "module", "slug": "durable-execution-langgraph", "revision": {
        "title": "Durable execution with LangGraph checkpointers",
        "body": L.body("Module (lab fixture): durable execution means an agent run survives restarts because every step is checkpointed. LangGraph persists graph state through a checkpointer (MemorySaver for tests, PostgresSaver in production) and resumes from the last checkpoint; this module builds a retry-safe ingestion graph with a thread_id per job."),
        "bindings": [{"local_key": "covers-durable-execution", "relation": "covers", "target": {"kind": "entity", "id": concept}},
                     {"local_key": "uses-langgraph", "relation": "uses", "target": {"kind": "entity", "id": langgraph}}],
        "runtime": [{"local_key": "lg", "kind": "package", "ecosystem": "pypi", "name": "langgraph", "version_spec": ">=1.0,<2", "resolved_version": "1.0.2"}]}}))
    guide = L.ok(author.cmd(ws, "create_work", {"kind": "lesson", "slug": "sandboxes-for-coding-agents", "revision": {
        "title": "Why coding agents need sandboxes",
        "body": L.body("Lesson (lab fixture): run agent-written code inside a sandbox with a filesystem snapshot so a bad step can be undone; never give the agent the production credentials."),
        "bindings": [{"local_key": "covers-sandboxes", "relation": "covers", "target": {"kind": "entity", "id": sandbox_concept}}]}}))
    L.ok(L.worker("index_passages", {"workspace_id": ws, "revision_id": module["revisionId"], "procedure_version": "lab-md-1", "passages": [
        {"text": "Durable execution: every LangGraph step is checkpointed, so an ingestion run resumes from the last checkpoint after a crash; use a thread_id per job and PostgresSaver in production.", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    L.ok(L.worker("index_passages", {"workspace_id": ws, "revision_id": guide["revisionId"], "procedure_version": "lab-md-1", "passages": [
        {"text": "Coding agents need a sandbox with filesystem snapshots so a bad step can be undone without touching production.", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    lws = L.ok(learner.cmd(None, "ensure_personal_workspace", {}))["workspaceId"]
    note = L.ok(learner.cmd(lws, "create_work", {"kind": "note", "slug": "sandbox-notes", "revision": {"title": "My sandbox notes", "body": L.body("Private note (lab fixture): tried the E2B sandbox for the retry exercise; the LangGraph checkpointer kept state across my restarts.")}}))
    L.ok(L.worker("index_passages", {"workspace_id": lws, "revision_id": note["revisionId"], "procedure_version": "lab-md-1", "passages": [
        {"text": "Tried the E2B sandbox for the retry exercise; the LangGraph checkpointer kept my graph state across restarts. Next: compare with Modal sandboxes.", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    out = {"workspace": ws, "module": module, "guide": guide, "learner_workspace": lws, "note": note, "users": {"author": author.id, "learner": learner.id, "outsider": outsider.id},
           "tokens_note": "access tokens are held in memory by loop1_questions when it recreates the users; never written"}
    write_json(os.path.join(RUN_DIR, "own-content.json"), out)
    # the question stage needs the learner/outsider tokens: keep them in a session-only file inside the lab run dir (git-ignored lab workdir), deleted at the end of the loop
    write_json(os.path.join(RUN_DIR, ".session-tokens.json"), {"learner": learner.token, "outsider": outsider.token, "author": author.token})
    log(f"own content created: module {module['revisionId']} covers durable-execution; learner note {note['revisionId']} in {lws}")


if __name__ == "__main__":
    main()
