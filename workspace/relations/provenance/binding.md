---
id: "rel:provenance.binding"
kind: table
schema: provenance
name: binding
domain: provenance
aliases: []
tokens: [provenance, binding, provenance.binding, id, tenant_id, object_id, system, external_id, url, created_at, updated_at]
summary: "Pointer to Linear, GitHub, or a Cursor conversation. The ledger stays here; those systems are projections."
summary_basis: comment
rls: enabled
readers: [authenticated, service_role]
writers: [authenticated, service_role]
typescript: "Database[\"provenance\"][\"Tables\"][\"binding\"][\"Row\"]"
defined_in: ["20260831201650_project_provenance.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# provenance.binding

table in domain `provenance` — Pointer to Linear, GitHub, or a Cursor conversation. The ledger stays here; those systems are projections..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, system, external_id) |
| 3 | `object_id` | `uuid` | no | — | FK → [`provenance.object`](object.md).id |
| 4 | `system` | `text` | no | — | unique (tenant_id, system, external_id) |
| 5 | `external_id` | `text` | no | — | unique (tenant_id, system, external_id); Linear issue identifier (AIE-123) or UUID; GitHub issue/PR number as owner/repo#n; Cursor transcript or agent id. |
| 6 | `url` | `text` | yes | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, system, external_id)
- check `binding_external_id_nonempty`: `(btrim(external_id) <> ''::text)`
- check `binding_system_check`: `(system = ANY (ARRAY['linear'::text, 'github'::text, 'cursor_local'::text, 'cursor_cloud'::text]))`

## Relationships

Outbound: `object_id` → [`provenance.object`](object.md)`.id`.
Inbound: none.

## Indexes

`binding_object_idx`; `binding_tenant_id_system_external_id_key` unique

## Triggers

- `binding_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `binding_tenant` (ALL) for `authenticated`, `service_role`: `(tenant_id = util.current_tenant_id())`

## Grants

`authenticated`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["provenance"]["Tables"]["binding"]["Insert"]`; row: `Database["provenance"]["Tables"]["binding"]["Row"]`; update: `Database["provenance"]["Tables"]["binding"]["Update"]`

Defined in: `20260831201650_project_provenance.sql`.
