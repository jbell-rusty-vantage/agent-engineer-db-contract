---
id: "fn:knowledge_service.guard_checkpoint_scope()"
kind: function
schema: knowledge_service
name: guard_checkpoint_scope
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.guard_checkpoint_scope()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [checkpoint head requires the next committed revision, checkpoint scope identity is immutable, checkpoint scopes are retained]
touches: { reads: [knowledge_service.scoped_checkpoint], writes: [] }
tokens: [knowledge_service, guard_checkpoint_scope, knowledge_service.guard_checkpoint_scope]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# knowledge_service.guard_checkpoint_scope

Domain `knowledge-service-runtime`, lens `machinery`.

## guard_checkpoint_scope() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `checkpoint head requires the next committed revision`; `checkpoint scope identity is immutable`; `checkpoint scopes are retained`.

Touches (best effort): reads [`knowledge_service.scoped_checkpoint`](../../relations/knowledge_service/scoped_checkpoint.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
