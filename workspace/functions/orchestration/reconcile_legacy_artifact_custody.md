---
id: "fn:orchestration.reconcile_legacy_artifact_custody(uuid,text,int8,text,uuid)"
kind: function
schema: orchestration
name: reconcile_legacy_artifact_custody
domain: orchestration-ledger
overloads: ["fn:orchestration.reconcile_legacy_artifact_custody(uuid,text,int8,text,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [artifact reconciliation identity mismatch, artifact reconciliation state invalid, artifact tenant mismatch]
touches: { reads: [], writes: [orchestration.artifact] }
tokens: [orchestration, reconcile_legacy_artifact_custody, orchestration.reconcile_legacy_artifact_custody]
defined_in: ["20260914010300_receipt_custody_reconciliation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.reconcile_legacy_artifact_custody

Domain `orchestration-ledger`.

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
