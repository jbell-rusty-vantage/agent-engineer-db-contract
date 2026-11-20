---
id: "rel:content.unit_entity_role"
kind: table
schema: content
name: unit_entity_role
domain: content
lens: corpus
aliases: [unit entity role, mentions]
tokens: [content, unit_entity_role, content.unit_entity_role, tenant_id, node_id, entity_id, role, method, confidence, claim_id, created_at]
summary: "Which entity a unit is about and in what role from the unit kind's role vocabulary; anchored on units, never chunks."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"unit_entity_role\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# content.unit_entity_role

table in domain `content`, lens `corpus` — Which entity a unit is about and in what role from the unit kind's role vocabulary (offering, provider, model, speaker, software, release, mentions ...). Anchored on units, never chunks..

> curated (model_assisted, unreviewed) — Which entity a unit is about and in what role from the unit kind's role vocabulary; anchored on units, never chunks.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 2 | `node_id` | `uuid` | no | — | PK |
| 3 | `entity_id` | `uuid` | no | — | PK; FK → [`catalog.entity`](../catalog/entity.md).id |
| 4 | `role` | `text` | no | — | PK; _curated:_ offering, provider, model, speaker, software, release, mentions, … (content.unit_kind.entity_roles). |
| 5 | `method` | `text` | no | — | _curated:_ rule, model or person. |
| 6 | `confidence` | `numeric` | yes | — | — |
| 7 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (node_id, entity_id, role)
- check `unit_entity_role_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `unit_entity_role_method_check`: `(method = ANY (ARRAY['rule'::text, 'model'::text, 'person'::text, 'mapping'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `tenant_id,node_id` → [`content.document_node`](document_node.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`unit_entity_role_entity_idx`

## Triggers

- `unit_entity_role_valid` → [`content.validate_unit_entity_role`](../../functions/content/validate_unit_entity_role.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Exposed through: [`api.api_symbols`](../api/api_symbols.md), [`api.bundle_files`](../api/bundle_files.md), [`api.endpoints`](../api/endpoints.md), [`api.hook_entries`](../api/hook_entries.md), [`api.mcp_prompts`](../api/mcp_prompts.md), [`api.mcp_resources`](../api/mcp_resources.md), [`api.mcp_tools`](../api/mcp_tools.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["unit_entity_role"]["Insert"]`; row: `Database["content"]["Tables"]["unit_entity_role"]["Row"]`; update: `Database["content"]["Tables"]["unit_entity_role"]["Update"]`

## Examples

Units about an entity

```bash
knowledge db query retrieval.search_unified --param entity_ids=["0192b000-0000-7000-8000-000000000001"] --param lenses=["corpus"] --param limit=20 --param query=pricing
```
entity_ids facet uses these roles.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
