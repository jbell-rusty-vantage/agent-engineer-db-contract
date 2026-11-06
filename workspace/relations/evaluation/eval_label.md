---
id: "rel:evaluation.eval_label"
kind: table
schema: evaluation
name: eval_label
domain: evaluation
aliases: []
tokens: [evaluation, eval_label, evaluation.eval_label, id, case_id, label, labeled_by, review_decision_id, created_at, tenant_id, verification_contract_version, label_artifact_id, label_sha256, provenance_class]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_label\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.eval_label

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `case_id` | `uuid` | no | — | FK → [`evaluation.eval_case`](eval_case.md).id |
| 3 | `label` | `jsonb` | no | — | — |
| 4 | `labeled_by` | `text` | no | — | — |
| 5 | `review_decision_id` | `uuid` | yes | — | FK → [`evaluation.review_decision`](review_decision.md).id |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `tenant_id` | `uuid` | yes | — | unique (tenant_id, id) |
| 8 | `verification_contract_version` | `text` | yes | — | — |
| 9 | `label_artifact_id` | `uuid` | yes | — | — |
| 10 | `label_sha256` | `text` | yes | — | — |
| 11 | `provenance_class` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `eval_label_label_sha256_check`: `((label_sha256 IS NULL) OR (label_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `eval_label_provenance_class_check`: `((provenance_class IS NULL) OR (provenance_class = ANY (ARRAY['human_adjudicated'::text, 'human_reviewed'::text, 'synthetic'::text, 'agent_…`
- check `eval_label_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `eval_label_verification_freeze_ck`: `((verification_contract_version IS NULL) OR ((tenant_id IS NOT NULL) AND (label_artifact_id IS NOT NULL) AND (label_sha256 IS NOT NULL) AND…`

## Relationships

Outbound: `tenant_id,label_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `case_id` → [`evaluation.eval_case`](eval_case.md)`.id` (+tenant) on delete cascade; `review_decision_id` → [`evaluation.review_decision`](review_decision.md)`.id`.
Inbound: [`evaluation.review_decision`](review_decision.md).eval_label_id.

## Indexes

`eval_label_case_idx`; `eval_label_tenant_id_uq` unique

## Triggers

- `artifact_retirement_777daf39250347b922c336b1` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `eval_label_artifact_admission` → [`evaluation.validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md)
- `eval_label_verification_freeze` → [`evaluation.guard_verification_freeze`](../../functions/evaluation/guard_verification_freeze.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_label"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_label"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_label"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
