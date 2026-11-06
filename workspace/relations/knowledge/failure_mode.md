---
id: "rel:knowledge.failure_mode"
kind: table
schema: knowledge
name: failure_mode
domain: knowledge-records
aliases: []
tokens: [knowledge, failure_mode, knowledge.failure_mode, id, tenant_id, kind, failure_class, trigger_conditions, mitigations]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"failure_mode\"][\"Row\"]"
defined_in: ["20260826000600_knowledge.sql", "20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge.failure_mode

table in domain `knowledge-records`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`knowledge.record`](record.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'failure_mode'::text` | — |
| 4 | `failure_class` | `text` | yes | — | — |
| 5 | `trigger_conditions` | `text` | yes | — | — |
| 6 | `mitigations` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `failure_mode_kind_check`: `(kind = 'failure_mode'::text)`

## Relationships

Outbound: `id` → [`knowledge.record`](record.md)`.id` (+tenant); `tenant_id,id,kind` → [`knowledge.record`](record.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`retrieval.packet_member`](../retrieval/packet_member.md).failure_mode_id.

## Indexes

`failure_mode_tenant_id_id_key` unique

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

insert: `Database["knowledge"]["Tables"]["failure_mode"]["Insert"]`; row: `Database["knowledge"]["Tables"]["failure_mode"]["Row"]`; update: `Database["knowledge"]["Tables"]["failure_mode"]["Update"]`

Defined in: `20260826000600_knowledge.sql`, `20260912010700_km_07_knowledge.sql`.
