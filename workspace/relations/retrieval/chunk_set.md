---
id: "rel:retrieval.chunk_set"
kind: table
schema: retrieval
name: chunk_set
domain: retrieval
aliases: []
tokens: [retrieval, chunk_set, retrieval.chunk_set, id, tenant_id, representation_id, procedure_version_id, frozen_config, tokenizer, input_manifest_sha256, output_manifest_sha256, chunk_set_sha256, status, qa_evaluation_id, promotion_decision_id, supersedes_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"chunk_set\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.chunk_set

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, chunk_set_sha256); unique (tenant_id, id) |
| 3 | `representation_id` | `uuid` | no | — | — |
| 4 | `procedure_version_id` | `uuid` | no | — | — |
| 5 | `frozen_config` | `jsonb` | no | — | — |
| 6 | `tokenizer` | `text` | no | — | — |
| 7 | `input_manifest_sha256` | `text` | no | — | — |
| 8 | `output_manifest_sha256` | `text` | yes | — | — |
| 9 | `chunk_set_sha256` | `text` | no | — | unique (tenant_id, chunk_set_sha256) |
| 10 | `status` | `text` | no | `'queued'::text` | — |
| 11 | `qa_evaluation_id` | `uuid` | yes | — | — |
| 12 | `promotion_decision_id` | `uuid` | yes | — | — |
| 13 | `supersedes_id` | `uuid` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, chunk_set_sha256)
- unique (tenant_id, id)
- check `chunk_set_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `chunk_set_chunk_set_sha256_check`: `(chunk_set_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `chunk_set_input_manifest_sha256_check`: `(input_manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `chunk_set_output_manifest_sha256_check`: `((output_manifest_sha256 IS NULL) OR (output_manifest_sha256 ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `tenant_id,procedure_version_id` → [`retrieval.chunking_procedure_version`](chunking_procedure_version.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](../content/document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`retrieval.chunk_set`](chunk_set.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.chunk_set`](chunk_set.md).supersedes_id, [`retrieval.retrieval_chunk`](retrieval_chunk.md).chunk_set_id.

## Indexes

`chunk_set_representation_idx`; `chunk_set_tenant_id_chunk_set_sha256_key` unique; `chunk_set_tenant_id_id_key` unique

## Triggers

- `chunk_set_terminal_guard` → [`retrieval.guard_terminal_status`](../../functions/retrieval/guard_terminal_status.md)
- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md)

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

insert: `Database["retrieval"]["Tables"]["chunk_set"]["Insert"]`; row: `Database["retrieval"]["Tables"]["chunk_set"]["Row"]`; update: `Database["retrieval"]["Tables"]["chunk_set"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
