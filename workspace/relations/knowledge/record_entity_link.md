---
id: "rel:knowledge.record_entity_link"
kind: table
schema: knowledge
name: record_entity_link
domain: knowledge-records
aliases: []
tokens: [knowledge, record_entity_link, knowledge.record_entity_link, tenant_id, record_id, entity_id, role]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"record_entity_link\"][\"Row\"]"
defined_in: ["20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge.record_entity_link

table in domain `knowledge-records`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `record_id` | `uuid` | no | — | PK; FK → [`knowledge.record`](record.md).id |
| 3 | `entity_id` | `uuid` | no | — | PK; FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `role` | `text` | no | — | PK |

## Constraints

- PK (tenant_id, record_id, entity_id, role)

## Relationships

Outbound: `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `record_id` → [`knowledge.record`](record.md)`.id` (+tenant).
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["knowledge"]["Tables"]["record_entity_link"]["Insert"]`; row: `Database["knowledge"]["Tables"]["record_entity_link"]["Row"]`; update: `Database["knowledge"]["Tables"]["record_entity_link"]["Update"]`

Defined in: `20260912010700_km_07_knowledge.sql`.
