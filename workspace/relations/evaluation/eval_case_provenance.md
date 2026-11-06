---
id: "rel:evaluation.eval_case_provenance"
kind: table
schema: evaluation
name: eval_case_provenance
domain: evaluation
aliases: []
tokens: [evaluation, eval_case_provenance, evaluation.eval_case_provenance, id, tenant_id, eval_case_id, artifact_id, source_capture_id, provenance, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_case_provenance\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.eval_case_provenance

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `eval_case_id` | `uuid` | no | — | — |
| 4 | `artifact_id` | `uuid` | yes | — | — |
| 5 | `source_capture_id` | `uuid` | yes | — | — |
| 6 | `provenance` | `jsonb` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,eval_case_id` → [`evaluation.eval_case`](eval_case.md)`.tenant_id,id` on delete restrict; `tenant_id,source_capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_cc4d5d9105cdbeae8a3c01c3` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `eval_case_provenance_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_case_provenance"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_case_provenance"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_case_provenance"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`.
