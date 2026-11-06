---
id: "rel:research.use_admission"
kind: table
schema: research
name: use_admission
domain: research-v2
aliases: []
tokens: [research, use_admission, research.use_admission, tenant_id, use_decision_id, bound_effect_digest, xact_id, processed_epoch, authoritative_epoch, effect_key, admitted_at, normalized_values_digest]
summary: "AI Engineer native admission record: knowledge_verification.admit_exact_use admitted (decision, bound effect digest) inside transaction xact_id. Written only through research.assert_admitted_use; append-only."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"use_admission\"][\"Row\"]"
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.use_admission

table in domain `research-v2` — AI Engineer native admission record: knowledge_verification.admit_exact_use admitted (decision, bound effect digest) inside transaction xact_id. Written only through research.assert_admitted_use; append-only..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) |
| 2 | `use_decision_id` | `text` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) |
| 3 | `bound_effect_digest` | `text` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) |
| 4 | `xact_id` | `bigint` | no | — | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) |
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

- `use_admission_guard` → [`research.guard_use_admission`](../../functions/research/guard_use_admission.md)
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
- Via functions (best effort): [`research.assert_admitted_use`](../../functions/research/assert_admitted_use.md).

## TypeScript

insert: `Database["research"]["Tables"]["use_admission"]["Insert"]`; row: `Database["research"]["Tables"]["use_admission"]["Row"]`; update: `Database["research"]["Tables"]["use_admission"]["Update"]`

Defined in: `20261024010100_research_report_v2_projection.sql`.
