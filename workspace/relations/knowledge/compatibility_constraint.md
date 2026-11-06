---
id: "rel:knowledge.compatibility_constraint"
kind: table
schema: knowledge
name: compatibility_constraint
domain: knowledge-records
aliases: []
tokens: [knowledge, compatibility_constraint, knowledge.compatibility_constraint, id, tenant_id, kind, constraint_kind, expression]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"compatibility_constraint\"][\"Row\"]"
defined_in: ["20260826000600_knowledge.sql", "20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge.compatibility_constraint

table in domain `knowledge-records`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`knowledge.record`](record.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'compatibility_constraint'::text` | — |
| 4 | `constraint_kind` | `text` | yes | — | — |
| 5 | `expression` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `compatibility_constraint_kind_check`: `(kind = 'compatibility_constraint'::text)`

## Relationships

Outbound: `id` → [`knowledge.record`](record.md)`.id` (+tenant); `tenant_id,id,kind` → [`knowledge.record`](record.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`curriculum.lesson_backed_by`](../curriculum/lesson_backed_by.md).compatibility_constraint_id, [`retrieval.packet_member`](../retrieval/packet_member.md).compatibility_constraint_id.
Polymorphic target of: [`curriculum.lesson_backed_by`](../curriculum/lesson_backed_by.md) (check constraint lesson_backed_by_exactly_one).

## Indexes

`compatibility_constraint_tenant_id_id_key` unique

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

insert: `Database["knowledge"]["Tables"]["compatibility_constraint"]["Insert"]`; row: `Database["knowledge"]["Tables"]["compatibility_constraint"]["Row"]`; update: `Database["knowledge"]["Tables"]["compatibility_constraint"]["Update"]`

Defined in: `20260826000600_knowledge.sql`, `20260912010700_km_07_knowledge.sql`.
