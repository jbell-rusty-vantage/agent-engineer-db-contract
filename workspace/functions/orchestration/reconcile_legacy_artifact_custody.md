---
id: "fn:orchestration.reconcile_legacy_artifact_custody(uuid,text,int8,text,uuid)"
kind: function
schema: orchestration
name: reconcile_legacy_artifact_custody
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.reconcile_legacy_artifact_custody(uuid,text,int8,text,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [artifact reconciliation identity mismatch, artifact reconciliation state invalid, artifact tenant mismatch]
touches: { reads: [], writes: [orchestration.artifact] }
tokens: [orchestration, reconcile_legacy_artifact_custody, orchestration.reconcile_legacy_artifact_custody]
defined_in: ["20260914010300_receipt_custody_reconciliation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# orchestration.reconcile_legacy_artifact_custody

Domain `orchestration-ledger`, lens `machinery`.

## reconcile_legacy_artifact_custody(uuid, text, bigint, text, uuid) → void

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_id` | `uuid` | — | — |
| `p_sha256` | `text` | — | — |
| `p_size` | `bigint` | — | — |
| `p_bucket` | `text` | — | — |
| `p_tenant` | `uuid` | — | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `artifact reconciliation identity mismatch`; `artifact reconciliation state invalid`; `artifact tenant mismatch`.

Touches (best effort): reads —; writes [`orchestration.artifact`](../../relations/orchestration/artifact.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["orchestration"]["Functions"]["reconcile_legacy_artifact_custody"]`.

Defined in: `20260914010300_receipt_custody_reconciliation.sql`.
