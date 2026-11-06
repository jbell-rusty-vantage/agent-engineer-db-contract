---
id: "rel:retrieval.retrieval_policy"
kind: table
schema: retrieval
name: retrieval_policy
domain: retrieval
aliases: []
tokens: [retrieval, retrieval_policy, retrieval.retrieval_policy, id, tenant_id, slug, purpose, lifecycle, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_policy\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.retrieval_policy

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `lifecycle` | `text` | no | `'active'::text` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug)

## Relationships

Outbound: none.
Inbound: [`retrieval.retrieval_policy_version`](retrieval_policy_version.md).retrieval_policy_id.

## Indexes

`retrieval_policy_tenant_id_id_key` unique; `retrieval_policy_tenant_id_slug_key` unique

## Triggers

- `retrieval_policy_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["retrieval"]["Tables"]["retrieval_policy"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_policy"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_policy"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
