---
id: "rel:evaluation.gate_binding"
kind: table
schema: evaluation
name: gate_binding
domain: evaluation
aliases: []
tokens: [evaluation, gate_binding, evaluation.gate_binding, id, gate_id, guards_kind, guards_ref, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"gate_binding\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.gate_binding

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `gate_id` | `uuid` | no | — | unique (gate_id, guards_kind, guards_ref); FK → [`evaluation.gate`](gate.md).id |
| 3 | `guards_kind` | `text` | no | — | unique (gate_id, guards_kind, guards_ref) |
| 4 | `guards_ref` | `text` | yes | — | unique (gate_id, guards_kind, guards_ref) |
| 5 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (gate_id, guards_kind, guards_ref)

## Relationships

Outbound: `gate_id` → [`evaluation.gate`](gate.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`gate_binding_gate_id_guards_kind_guards_ref_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["gate_binding"]["Insert"]`; row: `Database["evaluation"]["Tables"]["gate_binding"]["Row"]`; update: `Database["evaluation"]["Tables"]["gate_binding"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
