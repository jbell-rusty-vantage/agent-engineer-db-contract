---
id: "rel:knowledge.technical_problem"
kind: table
schema: knowledge
name: technical_problem
domain: knowledge-records
aliases: []
tokens: [knowledge, technical_problem, knowledge.technical_problem, id, tenant_id, kind, problem_class, symptoms, context_of_occurrence]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"technical_problem\"][\"Row\"]"
defined_in: ["20260826000600_knowledge.sql", "20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge.technical_problem

table in domain `knowledge-records`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`knowledge.record`](record.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'technical_problem'::text` | — |
| 4 | `problem_class` | `text` | yes | — | — |
| 5 | `symptoms` | `text[]` | yes | — | — |
| 6 | `context_of_occurrence` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `technical_problem_kind_check`: `(kind = 'technical_problem'::text)`

## Relationships

Outbound: `id` → [`knowledge.record`](record.md)`.id` (+tenant); `tenant_id,id,kind` → [`knowledge.record`](record.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`retrieval.packet_member`](../retrieval/packet_member.md).technical_problem_id.

## Indexes

`technical_problem_tenant_id_id_key` unique

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

insert: `Database["knowledge"]["Tables"]["technical_problem"]["Insert"]`; row: `Database["knowledge"]["Tables"]["technical_problem"]["Row"]`; update: `Database["knowledge"]["Tables"]["technical_problem"]["Update"]`

Defined in: `20260826000600_knowledge.sql`, `20260912010700_km_07_knowledge.sql`.
