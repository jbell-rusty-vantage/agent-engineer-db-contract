---
id: "rel:evaluation.grader"
kind: table
schema: evaluation
name: grader
domain: evaluation
aliases: []
tokens: [evaluation, grader, evaluation.grader, id, slug, kind, purpose, created_at, tenant_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"grader\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.grader

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 3 | `kind` | `text` | no | — | — |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 6 | `tenant_id` | `uuid` | yes | — | unique (tenant_id, id); unique (tenant_id, slug) |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug)
- check `grader_kind_check`: `(kind = ANY (ARRAY['deterministic'::text, 'model'::text, 'hybrid'::text, 'human'::text]))`

## Relationships

Outbound: none.
Inbound: [`evaluation.grader_version`](grader_version.md).grader_id.

## Indexes

`grader_tenant_id_uq` unique; `grader_tenant_slug_uq` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["grader"]["Insert"]`; row: `Database["evaluation"]["Tables"]["grader"]["Row"]`; update: `Database["evaluation"]["Tables"]["grader"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
