---
id: "rel:retrieval.projection_procedure"
kind: table
schema: retrieval
name: projection_procedure
domain: retrieval
aliases: []
tokens: [retrieval, projection_procedure, retrieval.projection_procedure, id, slug, version, description, code_ref, chunking, template, created_at, prompt_schema, tokenizer, projection_policy, implementation_sha256, container_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"projection_procedure\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.projection_procedure

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `slug` | `text` | no | — | unique (slug, version) |
| 3 | `version` | `integer` | no | — | unique (slug, version) |
| 4 | `description` | `text` | yes | — | — |
| 5 | `code_ref` | `text` | yes | — | — |
| 6 | `chunking` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `template` | `text` | yes | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `prompt_schema` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `tokenizer` | `text` | yes | — | — |
| 11 | `projection_policy` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `implementation_sha256` | `text` | yes | — | — |
| 13 | `container_sha256` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (slug, version)

## Relationships

Outbound: none.
Inbound: [`retrieval.search_projection`](search_projection.md).projection_procedure_id, [`retrieval.vector_space_version`](vector_space_version.md).projection_procedure_id.

## Indexes

`projection_procedure_slug_version_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`retrieval.project_entity_timeline`](../../functions/retrieval/project_entity_timeline.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["projection_procedure"]["Insert"]`; row: `Database["retrieval"]["Tables"]["projection_procedure"]["Row"]`; update: `Database["retrieval"]["Tables"]["projection_procedure"]["Update"]`

Defined in: `20260826001000_retrieval.sql`.
