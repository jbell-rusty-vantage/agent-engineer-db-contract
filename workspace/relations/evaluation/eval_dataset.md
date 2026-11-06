---
id: "rel:evaluation.eval_dataset"
kind: table
schema: evaluation
name: eval_dataset
domain: evaluation
aliases: []
tokens: [evaluation, eval_dataset, evaluation.eval_dataset, id, tenant_id, slug, purpose, description, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_dataset\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.eval_dataset

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug); unique (tenant_id, id) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `description` | `text` | yes | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- unique (tenant_id, id)

## Relationships

Outbound: none.
Inbound: [`evaluation.eval_case`](eval_case.md).dataset_id, [`evaluation.eval_dataset_version`](eval_dataset_version.md).dataset_id, [`evaluation.eval_run`](eval_run.md).dataset_id, [`orchestration.capability_version`](../orchestration/capability_version.md).eval_suite_id.

## Indexes

`eval_dataset_tenant_id_slug_key` unique; `eval_dataset_tenant_id_uq` unique

## Triggers

- `eval_dataset_benchmark_publication_immutable` → [`evaluation.guard_benchmark_publication_dependency`](../../functions/evaluation/guard_benchmark_publication_dependency.md)

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

insert: `Database["evaluation"]["Tables"]["eval_dataset"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_dataset"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_dataset"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
