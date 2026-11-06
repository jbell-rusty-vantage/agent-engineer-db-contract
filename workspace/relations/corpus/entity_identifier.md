---
id: "rel:corpus.entity_identifier"
kind: table
schema: corpus
name: entity_identifier
domain: identity
aliases: [external id, scheme]
tokens: [corpus, entity_identifier, corpus.entity_identifier, id, tenant_id, entity_id, scheme, value]
summary: "Schemed external identifier; unique per tenant on (scheme, value)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"entity_identifier\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.entity_identifier

table in domain `identity`.

> curated (model_assisted, unreviewed) — Schemed external identifier; unique per tenant on (scheme, value).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, scheme, value) |
| 3 | `entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id |
| 4 | `scheme` | `text` | no | — | unique (tenant_id, scheme, value); _curated:_ Closed check list (github, doi, youtube_video, other, …). |
| 5 | `value` | `text` | no | — | unique (tenant_id, scheme, value); _curated:_ Exact match; resolve_entity treats an exact value as score 1.0. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, scheme, value)
- check `entity_identifier_scheme_check`: `(scheme = ANY (ARRAY['wikidata'::text, 'ror'::text, 'orcid'::text, 'github'::text, 'huggingface'::text, 'npm'::text, 'pypi'::text, 'crates'…`

## Relationships

Outbound: `entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant).
Inbound: none.

## Indexes

`entity_identifier_tenant_id_id_key` unique; `entity_identifier_tenant_id_scheme_value_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.by_identifier`, `q:entity.resolve`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`corpus.import_research_starter_catalog`](../../functions/corpus/import_research_starter_catalog.md).

## TypeScript

insert: `Database["corpus"]["Tables"]["entity_identifier"]["Insert"]`; row: `Database["corpus"]["Tables"]["entity_identifier"]["Row"]`; update: `Database["corpus"]["Tables"]["entity_identifier"]["Update"]`

## Examples

Lookup by GitHub repo

```bash
knowledge db query entity.by_identifier --param scheme=github --param value=openai/openai-python
```
Empty if that identifier has not been admitted.

Defined in: `20260912010200_km_02_corpus_identity.sql`.
