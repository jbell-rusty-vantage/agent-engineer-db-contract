---
id: "rel:evaluation.gate"
kind: table
schema: evaluation
name: gate
domain: evaluation
aliases: []
tokens: [evaluation, gate, evaluation.gate, id, slug, purpose, thresholds, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"gate\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.gate

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `slug` | `text` | no | — | unique (slug) |
| 3 | `purpose` | `text` | no | — | — |
| 4 | `thresholds` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (slug)

## Relationships

Outbound: none.
Inbound: [`evaluation.gate_binding`](gate_binding.md).gate_id, [`evaluation.gate_result`](gate_result.md).gate_id, [`evaluation.regression`](regression.md).gate_id.

## Indexes

`gate_slug_key` unique

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

insert: `Database["evaluation"]["Tables"]["gate"]["Insert"]`; row: `Database["evaluation"]["Tables"]["gate"]["Row"]`; update: `Database["evaluation"]["Tables"]["gate"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
