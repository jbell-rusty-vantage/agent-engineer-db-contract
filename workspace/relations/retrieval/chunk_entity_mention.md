---
id: "rel:retrieval.chunk_entity_mention"
kind: table
schema: retrieval
name: chunk_entity_mention
domain: retrieval
aliases: []
tokens: [retrieval, chunk_entity_mention, retrieval.chunk_entity_mention, tenant_id, chunk_id, entity_id, verb, confidence, method]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"chunk_entity_mention\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql", "20260912010800_km_08_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.chunk_entity_mention

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `chunk_id` | `uuid` | no | — | PK; FK → [`retrieval.retrieval_chunk`](retrieval_chunk.md).id |
| 3 | `entity_id` | `uuid` | no | — | PK; FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `verb` | `text` | no | — | PK |
| 5 | `confidence` | `numeric` | yes | — | — |
| 6 | `method` | `text` | no | — | — |

## Constraints

- PK (tenant_id, chunk_id, entity_id, verb)
- check `chunk_entity_mention_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `chunk_entity_mention_verb_check`: `(verb = ANY (ARRAY['mentions'::text, 'is_about'::text, 'defines'::text, 'compares'::text, 'demonstrates'::text, 'quotes'::text, 'cites'::te…`

## Relationships

Outbound: `chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["chunk_entity_mention"]["Insert"]`; row: `Database["retrieval"]["Tables"]["chunk_entity_mention"]["Row"]`; update: `Database["retrieval"]["Tables"]["chunk_entity_mention"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`, `20260912010800_km_08_retrieval.sql`.
