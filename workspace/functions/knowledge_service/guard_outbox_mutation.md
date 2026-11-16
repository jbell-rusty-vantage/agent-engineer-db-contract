---
id: "fn:knowledge_service.guard_outbox_mutation()"
kind: function
schema: knowledge_service
name: guard_outbox_mutation
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.guard_outbox_mutation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [outbox event linkage and payload are immutable, outbox messages cannot be deleted, terminal outbox messages are immutable]
touches: { reads: [], writes: [] }
tokens: [knowledge_service, guard_outbox_mutation, knowledge_service.guard_outbox_mutation]
defined_in: ["20260903010500_outbox_claiming_and_packet_materialization.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# knowledge_service.guard_outbox_mutation

Domain `knowledge-service-runtime`, lens `machinery`.

## guard_outbox_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `outbox event linkage and payload are immutable`; `outbox messages cannot be deleted`; `terminal outbox messages are immutable`.

Defined in: `20260903010500_outbox_claiming_and_packet_materialization.sql`.
