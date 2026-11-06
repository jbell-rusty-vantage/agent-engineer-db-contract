---
id: "fn:api.submit_intent(text,jsonb,text,uuid,uuid,jsonb)"
kind: function
schema: api
name: submit_intent
domain: orchestration-ledger
overloads: ["fn:api.submit_intent(text,jsonb,text,uuid,uuid,jsonb)"]
security: definer
volatility: volatile
executors: [pipeline_agent, service_role, verifier_agent]
raises: [IDEMPOTENCY_KEY_FOREIGN_TENANT, TENANT_CONTEXT_REQUIRED, idempotency_key is required, payload must be a JSON object, "unknown intent_type %"]
touches: { reads: [orchestration.intent_type], writes: [orchestration.operation_intent] }
tokens: [api, submit_intent, api.submit_intent]
defined_in: ["20260826001500_api_and_grants.sql", "20261024010000_knowledge_component_binding.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.submit_intent

Domain `orchestration-ledger`.

## submit_intent(text, jsonb, text, uuid, uuid, jsonb) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_intent_type` | `text` | — | — |
| `p_payload` | `jsonb` | — | — |
| `p_idempotency_key` | `text` | — | — |
| `p_mission_id` | `uuid` | `NULL::uuid` | — |
| `p_attempt_id` | `uuid` | `NULL::uuid` | — |
| `p_preconditions` | `jsonb` | `'{}'::jsonb` | — |

Execute: `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `IDEMPOTENCY_KEY_FOREIGN_TENANT`; `TENANT_CONTEXT_REQUIRED`; `idempotency_key is required`; `payload must be a JSON object`; `unknown intent_type %`.

Touches (best effort): reads [`orchestration.intent_type`](../../relations/orchestration/intent_type.md); writes [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["submit_intent"]`.

Defined in: `20260826001500_api_and_grants.sql`, `20261024010000_knowledge_component_binding.sql`.
