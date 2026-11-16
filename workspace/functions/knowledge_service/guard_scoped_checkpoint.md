---
id: "fn:knowledge_service.guard_scoped_checkpoint()"
kind: function
schema: knowledge_service
name: guard_scoped_checkpoint
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.guard_scoped_checkpoint()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [checkpoint parent must match current scope head]
touches: { reads: [knowledge_service.checkpoint_scope], writes: [] }
tokens: [knowledge_service, guard_scoped_checkpoint, knowledge_service.guard_scoped_checkpoint]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# knowledge_service.guard_scoped_checkpoint

Domain `knowledge-service-runtime`, lens `machinery`.

## guard_scoped_checkpoint() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `checkpoint parent must match current scope head`.

Touches (best effort): reads [`knowledge_service.checkpoint_scope`](../../relations/knowledge_service/checkpoint_scope.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
