---
id: "rel:knowledge.implementation_example"
kind: table
schema: knowledge
name: implementation_example
domain: knowledge-records
aliases: []
tokens: [knowledge, implementation_example, knowledge.implementation_example, id, tenant_id, kind, repository_file_id, symbol, start_line, end_line]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"implementation_example\"][\"Row\"]"
defined_in: ["20260826000600_knowledge.sql", "20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge.implementation_example

table in domain `knowledge-records`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`knowledge.record`](record.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'implementation_example'::text` | — |
| 4 | `repository_file_id` | `uuid` | yes | — | FK → [`corpus.repository_file`](../corpus/repository_file.md).id |
| 5 | `symbol` | `text` | yes | — | — |
| 6 | `start_line` | `integer` | yes | — | — |
| 7 | `end_line` | `integer` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `implementation_example_check`: `((end_line IS NULL) OR (end_line >= start_line))`
- check `implementation_example_kind_check`: `(kind = 'implementation_example'::text)`
- check `implementation_example_start_line_check`: `((start_line IS NULL) OR (start_line > 0))`

## Relationships

Outbound: `id` → [`knowledge.record`](record.md)`.id` (+tenant); `repository_file_id` → [`corpus.repository_file`](../corpus/repository_file.md)`.id` (+tenant); `tenant_id,id,kind` → [`knowledge.record`](record.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`curriculum.challenge_derived_from`](../curriculum/challenge_derived_from.md).implementation_example_id, [`curriculum.lesson_backed_by`](../curriculum/lesson_backed_by.md).implementation_example_id, [`retrieval.packet_member`](../retrieval/packet_member.md).implementation_example_id.
Polymorphic target of: [`curriculum.challenge_derived_from`](../curriculum/challenge_derived_from.md) (check constraint challenge_derived_exactly_one), [`curriculum.lesson_backed_by`](../curriculum/lesson_backed_by.md) (check constraint lesson_backed_by_exactly_one).

## Indexes

`implementation_example_tenant_id_id_key` unique

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

insert: `Database["knowledge"]["Tables"]["implementation_example"]["Insert"]`; row: `Database["knowledge"]["Tables"]["implementation_example"]["Row"]`; update: `Database["knowledge"]["Tables"]["implementation_example"]["Update"]`

Defined in: `20260826000600_knowledge.sql`, `20260912010700_km_07_knowledge.sql`.
