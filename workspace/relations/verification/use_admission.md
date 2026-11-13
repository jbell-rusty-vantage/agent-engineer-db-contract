---
id: "rel:verification.use_admission"
kind: table
schema: verification
name: use_admission
domain: evidence
lens: evidence
aliases: [admission ledger, admitted use, use decision]
tokens: [verification, use_admission, verification.use_admission, tenant_id, use_decision_id, bound_effect_digest, xact_id, processed_epoch, authoritative_epoch, effect_key, admitted_at, normalized_values_digest]
summary: Append-only record that knowledge_verification admitted a use decision inside the writing transaction; required before a claim is verified.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"verification\"][\"Tables\"][\"use_admission\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# verification.use_admission

table in domain `evidence`, lens `evidence` — AI Engineer native admission record: knowledge_verification.admit_exact_use admitted (decision, bound effect digest) inside transaction xact_id. Written only through research.assert_admitted_use; append-only..

> curated (model_assisted, unreviewed) — Append-only record that knowledge_verification admitted a use decision inside the writing transaction; required before a claim is verified.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) |
| 2 | `use_decision_id` | `text` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest); _curated:_ The component's use decision; a verified claim's receipt names it. |
| 3 | `bound_effect_digest` | `text` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest); _curated:_ Digest of the exact effect the decision was bound to. |
| 4 | `xact_id` | `bigint` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest); _curated:_ Transaction in which verification.assert_admitted_use ran; the canonical rows commit with it or not at all. |
| 5 | `processed_epoch` | `bigint` | no | — | — |
| 6 | `authoritative_epoch` | `bigint` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) |
| 7 | `effect_key` | `text` | no | — | — |
| 8 | `admitted_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `normalized_values_digest` | `text` | yes | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest); K01 canonical digest of the normalized values the native transaction presented to admit_exact_use; null when the caller presented none (the component then skipped the comparison). |

## Constraints

- unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest)
- check `use_admission_authoritative_epoch_check`: `(authoritative_epoch >= 0)`
- check `use_admission_bound_effect_digest_check`: `(bound_effect_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `use_admission_check`: `(processed_epoch >= authoritative_epoch)`
- check `use_admission_normalized_values_digest`: `((normalized_values_digest IS NULL) OR (normalized_values_digest ~ '^sha256:[0-9a-f]{64}$'::text))`
- check `use_admission_processed_epoch_check`: `(processed_epoch >= 0)`
- check `use_admission_use_decision_id_check`: `(btrim(use_decision_id) <> ''::text)`

## Relationships

Outbound: none.
Inbound: none.

## Indexes

`use_admission_key` unique

## Triggers

- `use_admission_guard` → [`verification.guard_use_admission`](../../functions/verification/guard_use_admission.md)
- `use_admission_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled and forced.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`verification.assert_admitted_use`](../../functions/verification/assert_admitted_use.md).

## TypeScript

insert: `Database["verification"]["Tables"]["use_admission"]["Insert"]`; row: `Database["verification"]["Tables"]["use_admission"]["Row"]`; update: `Database["verification"]["Tables"]["use_admission"]["Update"]`

## Examples

Claims that must carry an admission

```bash
knowledge db query evidence.claims_for_entity --param entity_id=0192b000-0000-7000-8000-000000000001 --param limit=100
```
status verified implies a use_admission row in the same transaction (ADMISSION_REQUIRED otherwise).

Defined in: unknown.
