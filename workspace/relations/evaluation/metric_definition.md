---
id: "rel:evaluation.metric_definition"
kind: table
schema: evaluation
name: metric_definition
domain: evaluation
aliases: []
tokens: [evaluation, metric_definition, evaluation.metric_definition, id, tenant_id, slug, version, metric_kind, definition, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"evaluation\"][\"Tables\"][\"metric_definition\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.metric_definition

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, slug, version) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug, version) |
| 4 | `version` | `integer` | no | — | unique (tenant_id, slug, version) |
| 5 | `metric_kind` | `text` | no | — | — |
| 6 | `definition` | `jsonb` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug, version)

## Relationships

Outbound: none.
Inbound: [`evaluation.metric_observation`](metric_observation.md).metric_definition_id.

## Indexes

`metric_definition_tenant_id_id_key` unique; `metric_definition_tenant_id_slug_version_key` unique

## Triggers

- `metric_definition_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["evaluation"]["Tables"]["metric_definition"]["Insert"]`; row: `Database["evaluation"]["Tables"]["metric_definition"]["Row"]`; update: `Database["evaluation"]["Tables"]["metric_definition"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
