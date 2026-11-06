---
id: "rel:knowledge.security_consideration"
kind: table
schema: knowledge
name: security_consideration
domain: knowledge-records
aliases: []
tokens: [knowledge, security_consideration, knowledge.security_consideration, id, tenant_id, kind, severity, threat, mitigation]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"security_consideration\"][\"Row\"]"
defined_in: ["20260826000600_knowledge.sql", "20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge.security_consideration

table in domain `knowledge-records`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`knowledge.record`](record.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'security_consideration'::text` | — |
| 4 | `severity` | `text` | yes | — | — |
| 5 | `threat` | `text` | yes | — | — |
| 6 | `mitigation` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `security_consideration_kind_check`: `(kind = 'security_consideration'::text)`

## Relationships

Outbound: `id` → [`knowledge.record`](record.md)`.id` (+tenant); `tenant_id,id,kind` → [`knowledge.record`](record.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`curriculum.lesson_backed_by`](../curriculum/lesson_backed_by.md).security_consideration_id, [`retrieval.packet_member`](../retrieval/packet_member.md).security_consideration_id.
Polymorphic target of: [`curriculum.lesson_backed_by`](../curriculum/lesson_backed_by.md) (check constraint lesson_backed_by_exactly_one).

## Indexes

`security_consideration_tenant_id_id_key` unique

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

insert: `Database["knowledge"]["Tables"]["security_consideration"]["Insert"]`; row: `Database["knowledge"]["Tables"]["security_consideration"]["Row"]`; update: `Database["knowledge"]["Tables"]["security_consideration"]["Update"]`

Defined in: `20260826000600_knowledge.sql`, `20260912010700_km_07_knowledge.sql`.
