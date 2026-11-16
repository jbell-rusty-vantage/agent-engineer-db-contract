---
id: "fn:knowledge_service.require_checkpoint_commit()"
kind: function
schema: knowledge_service
name: require_checkpoint_commit
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.require_checkpoint_commit()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [checkpoint requires manifest custody and committed head]
touches: { reads: [knowledge_service.checkpoint_artifact_reference, knowledge_service.checkpoint_scope], writes: [] }
tokens: [knowledge_service, require_checkpoint_commit, knowledge_service.require_checkpoint_commit]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# knowledge_service.require_checkpoint_commit

Domain `knowledge-service-runtime`, lens `machinery`.

## require_checkpoint_commit() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `checkpoint requires manifest custody and committed head`.

Touches (best effort): reads [`knowledge_service.checkpoint_artifact_reference`](../../relations/knowledge_service/checkpoint_artifact_reference.md), [`knowledge_service.checkpoint_scope`](../../relations/knowledge_service/checkpoint_scope.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
