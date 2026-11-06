---
id: "rel:retrieval.chunk_relationship_evidence"
kind: table
schema: retrieval
name: chunk_relationship_evidence
domain: retrieval
aliases: []
tokens: [retrieval, chunk_relationship_evidence, retrieval.chunk_relationship_evidence, tenant_id, chunk_id, relationship_id, verb]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"chunk_relationship_evidence\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql", "20260912010800_km_08_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.chunk_relationship_evidence

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `chunk_id` | `uuid` | no | — | PK; FK → [`retrieval.retrieval_chunk`](retrieval_chunk.md).id |
| 3 | `relationship_id` | `uuid` | no | — | PK; FK → [`corpus.relationship`](../corpus/relationship.md).id |
| 4 | `verb` | `text` | no | — | PK |

## Constraints

- PK (tenant_id, chunk_id, relationship_id, verb)
- check `chunk_relationship_evidence_verb_check`: `(verb = ANY (ARRAY['supports'::text, 'challenges'::text, 'context'::text, 'dates'::text]))`

## Relationships

Outbound: `chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.id` (+tenant); `relationship_id` → [`corpus.relationship`](../corpus/relationship.md)`.id` (+tenant).
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

insert: `Database["retrieval"]["Tables"]["chunk_relationship_evidence"]["Insert"]`; row: `Database["retrieval"]["Tables"]["chunk_relationship_evidence"]["Row"]`; update: `Database["retrieval"]["Tables"]["chunk_relationship_evidence"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`, `20260912010800_km_08_retrieval.sql`.
