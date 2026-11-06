---
id: "rel:content.document_about_entity"
kind: table
schema: content
name: document_about_entity
domain: content
aliases: []
tokens: [content, document_about_entity, content.document_about_entity, tenant_id, document_id, entity_id, role, method, confidence]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_about_entity\"][\"Row\"]"
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_about_entity

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `document_id` | `uuid` | no | — | PK; FK → [`content.document`](document.md).id |
| 3 | `entity_id` | `uuid` | no | — | PK; FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `role` | `text` | no | — | — |
| 5 | `method` | `text` | no | — | — |
| 6 | `confidence` | `numeric(5,4)` | yes | — | — |

## Constraints

- PK (tenant_id, document_id, entity_id)
- check `document_about_entity_method_check`: `(method = ANY (ARRAY['extraction'::text, 'manual'::text, 'inherited'::text, 'provider'::text]))`
- check `document_about_entity_role_check`: `(role = ANY (ARRAY['primary'::text, 'secondary'::text, 'mention'::text]))`

## Relationships

Outbound: `document_id` → [`content.document`](document.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
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

insert: `Database["content"]["Tables"]["document_about_entity"]["Insert"]`; row: `Database["content"]["Tables"]["document_about_entity"]["Row"]`; update: `Database["content"]["Tables"]["document_about_entity"]["Update"]`

Defined in: `20260912010600_km_06_content.sql`.
