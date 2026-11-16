---
id: "rel:catalog.entity_alias"
kind: table
schema: catalog
name: entity_alias
domain: identity
lens: corpus
aliases: [alias, synonym]
tokens: [catalog, entity_alias, catalog.entity_alias, id, tenant_id, entity_id, alias, alias_normalized, alias_kind, language, source_claim_id]
summary: "Typed alternate name for one entity; unique per entity, not globally."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"catalog\"][\"Tables\"][\"entity_alias\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# catalog.entity_alias

table in domain `identity`, lens `corpus`.

> curated (model_assisted, unreviewed) — Typed alternate name for one entity; unique per entity, not globally.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, entity_id, alias_normalized, alias_kind); unique (tenant_id, id) |
| 3 | `entity_id` | `uuid` | no | — | unique (tenant_id, entity_id, alias_normalized, alias_kind); FK → [`catalog.entity`](entity.md).id |
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

Outbound: `entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant); `source_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
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

insert: `Database["catalog"]["Tables"]["entity_alias"]["Insert"]`; row: `Database["catalog"]["Tables"]["entity_alias"]["Row"]`; update: `Database["catalog"]["Tables"]["entity_alias"]["Update"]`

## Examples

Name resolve uses aliases

```bash
knowledge db query entity.resolve --param text=OpenAI
```
Trigram match on alias as well as display_name.

Defined in: unknown.
