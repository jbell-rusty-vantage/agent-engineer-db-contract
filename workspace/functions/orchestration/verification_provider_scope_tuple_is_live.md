---
id: "fn:orchestration.verification_provider_scope_tuple_is_live(uuid,uuid,uuid,uuid,text,jsonb)"
kind: function
schema: orchestration
name: verification_provider_scope_tuple_is_live
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_provider_scope_tuple_is_live(uuid,uuid,uuid,uuid,text,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role, verifier_agent]
raises: []
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step], writes: [] }
tokens: [orchestration, verification_provider_scope_tuple_is_live, orchestration.verification_provider_scope_tuple_is_live]
defined_in: ["20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_scope_tuple_is_live

Domain `orchestration-ledger`.

## verification_provider_scope_tuple_is_live(uuid, uuid, uuid, uuid, text, jsonb) → boolean

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_operation` | `uuid` | — | — |
| `p_step` | `uuid` | — | — |
| `p_profile` | `uuid` | — | — |
| `p_profile_sha` | `text` | — | — |
| `p_claim` | `jsonb` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

TypeScript: `Database["orchestration"]["Functions"]["verification_provider_scope_tuple_is_live"]`.

Defined in: `20260907013000_verification_semantic_provider_observation.sql`.
