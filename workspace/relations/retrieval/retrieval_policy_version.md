---
id: "rel:retrieval.retrieval_policy_version"
kind: table
schema: retrieval
name: retrieval_policy_version
domain: retrieval
aliases: []
tokens: [retrieval, retrieval_policy_version, retrieval.retrieval_policy_version, id, tenant_id, retrieval_policy_id, version, policy, policy_schema, policy_sha256, status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_policy_version\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.retrieval_policy_version

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, retrieval_policy_id, version) |
| 3 | `retrieval_policy_id` | `uuid` | no | — | unique (tenant_id, retrieval_policy_id, version) |
| 4 | `version` | `integer` | no | — | unique (tenant_id, retrieval_policy_id, version) |
| 5 | `policy` | `jsonb` | no | — | — |
| 6 | `policy_schema` | `jsonb` | no | — | — |
| 7 | `policy_sha256` | `text` | no | — | — |
| 8 | `status` | `text` | no | `'candidate'::text` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, retrieval_policy_id, version)
- check `retrieval_policy_version_policy_sha256_check`: `(policy_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,retrieval_policy_id` → [`retrieval.retrieval_policy`](retrieval_policy.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`retrieval_policy_version_tenant_id_id_key` unique; `retrieval_policy_version_tenant_id_retrieval_policy_id_vers_key` unique

## Triggers

- `retrieval_policy_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["retrieval"]["Tables"]["retrieval_policy_version"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_policy_version"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_policy_version"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
