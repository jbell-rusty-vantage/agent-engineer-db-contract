---
id: "rel:evaluation.promotion_gate_version"
kind: table
schema: evaluation
name: promotion_gate_version
domain: evaluation
aliases: []
tokens: [evaluation, promotion_gate_version, evaluation.promotion_gate_version, id, tenant_id, slug, version, definition, definition_sha256, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"evaluation\"][\"Tables\"][\"promotion_gate_version\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.promotion_gate_version

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, slug, version) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug, version) |
| 4 | `version` | `integer` | no | — | unique (tenant_id, slug, version) |
| 5 | `definition` | `jsonb` | no | — | — |
| 6 | `definition_sha256` | `text` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug, version)
- check `promotion_gate_version_definition_sha256_check`: `(definition_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: none.
Inbound: [`evaluation.promotion_gate_result`](promotion_gate_result.md).gate_version_id.

## Indexes

`promotion_gate_version_tenant_id_id_key` unique; `promotion_gate_version_tenant_id_slug_version_key` unique

## Triggers

- `promotion_gate_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["evaluation"]["Tables"]["promotion_gate_version"]["Insert"]`; row: `Database["evaluation"]["Tables"]["promotion_gate_version"]["Row"]`; update: `Database["evaluation"]["Tables"]["promotion_gate_version"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
