---
id: "rel:orchestration.operation_receipt"
kind: table
schema: orchestration
name: operation_receipt
domain: orchestration-ledger
aliases: [receipt]
tokens: [orchestration, operation_receipt, orchestration.operation_receipt, id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, applied_at, requires_admission, use_decision_id, bound_effect_digest, origin_digest]
summary: "Immutable outcome of one intent (applied, rejected, noop, partial)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"operation_receipt\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.operation_receipt

table in domain `orchestration-ledger`.

> curated (model_assisted, unreviewed) — Immutable outcome of one intent (applied, rejected, noop, partial).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `intent_id` | `uuid` | no | — | unique (intent_id); FK → [`orchestration.operation_intent`](operation_intent.md).id; _curated:_ Unique; one receipt per intent. |
| 3 | `executor_version` | `text` | no | — | — |
| 4 | `precondition_results` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `outcome` | `text` | no | — | _curated:_ applied, rejected, noop, or partial. |
| 6 | `changes_summary` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `affected_refs` | `jsonb` | no | `'[]'::jsonb` | — |
| 8 | `applied_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `requires_admission` | `boolean` | no | `false` | True exactly when the receipt names a use decision: its commit (and every canonical row it creates) requires research.use_admission in the same transaction. |
| 10 | `use_decision_id` | `text` | yes | — | knowledge_verification.use_decision.use_decision_id admitted for this receipt (validated by function, no cross-schema FK). |
| 11 | `bound_effect_digest` | `text` | yes | — | The exact K01 bound effect digest the decision admitted; set together with use_decision_id. |
| 12 | `origin_digest` | `text` | yes | — | The originating origin digest of the intent this receipt applied (same value as operation_intent.origin_digest). |

## Constraints

- PK (id)
- unique (intent_id)
- check `operation_receipt_admission_declared`: `(requires_admission = (use_decision_id IS NOT NULL))`
- check `operation_receipt_admission_pair`: `((use_decision_id IS NULL) = (bound_effect_digest IS NULL))`
- check `operation_receipt_bound_effect_digest`: `((bound_effect_digest IS NULL) OR (bound_effect_digest ~ '^sha256:[0-9a-f]{64}$'::text))`
- check `operation_receipt_origin_digest_check`: `(origin_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `operation_receipt_outcome_check`: `(outcome = ANY (ARRAY['applied'::text, 'rejected'::text, 'noop'::text, 'partial'::text]))`

## Relationships

Outbound: `intent_id` → [`orchestration.operation_intent`](operation_intent.md)`.id`.
Inbound: [`corpus.entity`](../corpus/entity.md).created_by_receipt_id, [`corpus.entity_merge`](../corpus/entity_merge.md).receipt_id, [`evidence.claim`](../evidence/claim.md).created_by_receipt_id, [`evidence.source_encounter`](../evidence/source_encounter.md).receipt_id, [`knowledge.record`](../knowledge/record.md).created_by_receipt_id, [`knowledge.record_reconciliation`](../knowledge/record_reconciliation.md).created_by_receipt_id, [`orchestration.artifact_lineage`](artifact_lineage.md).receipt_id, [`orchestration.operation_receipt_target`](operation_receipt_target.md).receipt_id, [`research.report_v2_ingestion`](../research/report_v2_ingestion.md).receipt_id, [`retrieval.vector_item`](../retrieval/vector_item.md).receipt_id, [`staging.resolution_decision`](../staging/resolution_decision.md).receipt_id, [`staging.vetting_decision`](../staging/vetting_decision.md).receipt_id … 2 more in [details](operation_receipt.details.md).

## Indexes

`operation_receipt_applied_idx`; `operation_receipt_intent_id_key` unique; `operation_receipt_use_decision_idx` where `(use_decision_id IS NOT NULL)`

## Triggers

- `operation_receipt_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `receipt_requires_admission` → [`research.require_receipt_admission`](../../functions/research/require_receipt_admission.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `intent_tenant_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(EXISTS ( SELECT 1 FROM orchestration.operation_intent i WHERE ((i.id = operation_receipt…`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Exposed through: [`orchestration.mission_run_effects`](mission_run_effects.md).
- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["operation_receipt"]["Insert"]`; row: `Database["orchestration"]["Tables"]["operation_receipt"]["Row"]`; update: `Database["orchestration"]["Tables"]["operation_receipt"]["Update"]`

## Examples

Batch that cites the receipt id

```bash
knowledge db query receipts.for_intent --param intent_id=0192f000-0000-7000-8000-000000000001
```
pipeline_agent cannot SELECT this table; the catalog query returns receipt_id from knowledge_batch.

Defined in: `20260826000200_orchestration.sql`.
