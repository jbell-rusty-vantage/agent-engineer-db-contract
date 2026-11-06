---
id: "rel:evaluation.experiment"
kind: table
schema: evaluation
name: experiment
domain: evaluation
aliases: []
tokens: [evaluation, experiment, evaluation.experiment, id, tenant_id, name, hypothesis, dataset_version_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"experiment\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.experiment

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `name` | `text` | no | — | — |
| 4 | `hypothesis` | `text` | no | — | — |
| 5 | `dataset_version_id` | `uuid` | no | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `tenant_id,dataset_version_id` → [`evaluation.eval_dataset_version`](eval_dataset_version.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.experiment_arm`](experiment_arm.md).experiment_id.

## Indexes

`experiment_tenant_id_id_key` unique

## Triggers

- `experiment_benchmark_publication_immutable` → [`evaluation.guard_benchmark_publication_dependency`](../../functions/evaluation/guard_benchmark_publication_dependency.md)
- `experiment_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["experiment"]["Insert"]`; row: `Database["evaluation"]["Tables"]["experiment"]["Row"]`; update: `Database["evaluation"]["Tables"]["experiment"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
