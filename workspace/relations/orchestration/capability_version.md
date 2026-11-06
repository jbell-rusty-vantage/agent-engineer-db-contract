---
id: "rel:orchestration.capability_version"
kind: table
schema: orchestration
name: capability_version
domain: orchestration-ledger
aliases: []
tokens: [orchestration, capability_version, orchestration.capability_version, id, capability_id, version_label, lifecycle, eval_suite_id, network_requirements, secret_requirements, approval_policy, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"capability_version\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.capability_version

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `capability_id` | `uuid` | no | — | unique (capability_id, version_label); FK → [`orchestration.capability`](capability.md).id |
| 3 | `version_label` | `text` | no | — | unique (capability_id, version_label) |
| 4 | `lifecycle` | `text` | no | `'draft'::text` | — |
| 5 | `eval_suite_id` | `uuid` | yes | — | FK → [`evaluation.eval_dataset`](../evaluation/eval_dataset.md).id |
| 6 | `network_requirements` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `secret_requirements` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `approval_policy` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (capability_id, version_label)
- check `capability_version_lifecycle_check`: `(lifecycle = ANY (ARRAY['draft'::text, 'candidate'::text, 'active'::text, 'deprecated'::text, 'retired'::text]))`

## Relationships

Outbound: `capability_id` → [`orchestration.capability`](capability.md)`.id` on delete cascade; `eval_suite_id` → [`evaluation.eval_dataset`](../evaluation/eval_dataset.md)`.id`.
Inbound: [`content.transformation_run`](../content/transformation_run.md).capability_version_id, [`evaluation.eval_run`](../evaluation/eval_run.md).capability_version_id, [`evaluation.review_task`](../evaluation/review_task.md).capability_version_id, [`knowledge_service.operation`](../knowledge_service/operation.md).capability_version_id, [`orchestration.capability_profile_item`](capability_profile_item.md).capability_version_id, [`retrieval.chunking_procedure_version`](../retrieval/chunking_procedure_version.md).capability_version_id.
Polymorphic target of: [`evaluation.eval_run`](../evaluation/eval_run.md) (check constraint eval_run_exactly_one_target), [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`capability_version_capability_id_version_label_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["capability_version"]["Insert"]`; row: `Database["orchestration"]["Tables"]["capability_version"]["Row"]`; update: `Database["orchestration"]["Tables"]["capability_version"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
