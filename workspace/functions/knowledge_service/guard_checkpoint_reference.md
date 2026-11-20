---
id: "fn:knowledge_service.guard_checkpoint_reference()"
kind: function
schema: knowledge_service
name: guard_checkpoint_reference
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.guard_checkpoint_reference()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [checkpoint requires available live artifact custody]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone], writes: [] }
tokens: [knowledge_service, guard_checkpoint_reference, knowledge_service.guard_checkpoint_reference]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# knowledge_service.guard_checkpoint_reference

Domain `knowledge-service-runtime`, lens `machinery`.

## guard_checkpoint_reference() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `checkpoint requires available live artifact custody`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
