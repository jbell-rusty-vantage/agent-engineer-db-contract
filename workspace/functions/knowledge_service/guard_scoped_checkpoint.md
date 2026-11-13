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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
