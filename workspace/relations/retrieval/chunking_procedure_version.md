---
id: "rel:retrieval.chunking_procedure_version"
kind: table
schema: retrieval
name: chunking_procedure_version
domain: retrieval
aliases: []
tokens: [retrieval, chunking_procedure_version, retrieval.chunking_procedure_version, id, tenant_id, slug, version, capability_version_id, supported_content_classes, tokenizer, schema_contract, code_sha256, container_sha256, defaults, limits, status, created_at, strategy, target_tokens, overlap_tokens, respect_boundaries]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"chunking_procedure_version\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.chunking_procedure_version

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, slug, version) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug, version) |
| 4 | `version` | `text` | no | — | unique (tenant_id, slug, version) |
| 5 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 6 | `supported_content_classes` | `jsonb` | no | — | — |
| 7 | `tokenizer` | `text` | no | — | — |
| 8 | `schema_contract` | `jsonb` | no | — | — |
| 9 | `code_sha256` | `text` | no | — | — |
| 10 | `container_sha256` | `text` | yes | — | — |
| 11 | `defaults` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `limits` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `status` | `text` | no | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `strategy` | `text` | yes | — | — |
| 16 | `target_tokens` | `integer` | yes | — | — |
| 17 | `overlap_tokens` | `integer` | yes | — | — |
| 18 | `respect_boundaries` | `boolean` | no | `true` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug, version)
- check `chunking_procedure_version_code_sha256_check`: `(code_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `chunking_procedure_version_status_check`: `(status = ANY (ARRAY['candidate'::text, 'admitted'::text, 'retired'::text]))`
- check `chunking_procedure_version_strategy_check`: `(strategy = ANY (ARRAY['structural_heading'::text, 'semantic_boundary'::text, 'transcript_window'::text, 'code_symbol'::text, 'table_row'::…`

## Relationships

Outbound: `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id` on delete restrict.
Inbound: [`retrieval.chunk_set`](chunk_set.md).procedure_version_id.

## Indexes

`chunking_procedure_version_tenant_id_id_key` unique; `chunking_procedure_version_tenant_id_slug_version_key` unique

## Triggers

- `chunking_procedure_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["chunking_procedure_version"]["Insert"]`; row: `Database["retrieval"]["Tables"]["chunking_procedure_version"]["Row"]`; update: `Database["retrieval"]["Tables"]["chunking_procedure_version"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
