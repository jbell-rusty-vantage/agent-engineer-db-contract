---
id: "rel:corpus.entity_alias"
kind: table
schema: corpus
name: entity_alias
domain: identity
aliases: [alias, synonym]
tokens: [corpus, entity_alias, corpus.entity_alias, id, tenant_id, entity_id, alias, alias_normalized, alias_kind, language, source_claim_id]
summary: "Typed alternate name for one entity; unique per entity, not globally."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"entity_alias\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.entity_alias

table in domain `identity`.

> curated (model_assisted, unreviewed) — Typed alternate name for one entity; unique per entity, not globally.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, entity_id, alias_normalized, alias_kind); unique (tenant_id, id) |
| 3 | `entity_id` | `uuid` | no | — | unique (tenant_id, entity_id, alias_normalized, alias_kind); FK → [`corpus.entity`](entity.md).id |
| 4 | `alias` | `text` | no | — | — |
| 5 | `alias_normalized` | `text` | yes | — | unique (tenant_id, entity_id, alias_normalized, alias_kind); generated: `lower(btrim(alias))`; _curated:_ Generated lower(btrim(alias)). |
| 6 | `alias_kind` | `text` | no | — | unique (tenant_id, entity_id, alias_normalized, alias_kind); _curated:_ synonym, acronym, former_name, handle, ticker, slug, misspelling, translation, model_alias. |
| 7 | `language` | `text` | yes | — | — |
| 8 | `source_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |

## Constraints

- PK (id)
- unique (tenant_id, entity_id, alias_normalized, alias_kind)
- unique (tenant_id, id)
- check `entity_alias_alias_check`: `(btrim(alias) <> ''::text)`
- check `entity_alias_alias_kind_check`: `(alias_kind = ANY (ARRAY['synonym'::text, 'acronym'::text, 'former_name'::text, 'handle'::text, 'ticker'::text, 'slug'::text, 'misspelling'…`

## Relationships

Outbound: `entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `source_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
Inbound: none.

## Indexes

`entity_alias_tenant_id_entity_id_alias_normalized_alias_kin_key` unique; `entity_alias_tenant_id_id_key` unique; `entity_alias_trgm`

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.card`, `q:entity.resolve`.
- Exposed through: [`api.entities`](../api/entities.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["entity_alias"]["Insert"]`; row: `Database["corpus"]["Tables"]["entity_alias"]["Row"]`; update: `Database["corpus"]["Tables"]["entity_alias"]["Update"]`

## Examples

Name resolve uses aliases

```bash
knowledge db query entity.resolve --param text=OpenAI
```
Trigram match on alias as well as display_name.

Defined in: `20260912010200_km_02_corpus_identity.sql`.
