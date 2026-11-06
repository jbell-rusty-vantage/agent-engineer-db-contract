---
id: "rel:provenance.edge"
kind: table
schema: provenance
name: edge
domain: provenance
aliases: []
tokens: [provenance, edge, provenance.edge, id, tenant_id, kind, from_object_id, from_revision_id, to_object_id, to_revision_id, created_at]
summary: Declared citation. from was informed by / derived from / supersedes to. Not a causal debugger log.
summary_basis: comment
rls: enabled
readers: [authenticated, service_role]
writers: [authenticated, service_role]
typescript: "Database[\"provenance\"][\"Tables\"][\"edge\"][\"Row\"]"
defined_in: ["20260831201650_project_provenance.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# provenance.edge

table in domain `provenance` — Declared citation. from was informed by / derived from / supersedes to. Not a causal debugger log..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `kind` | `text` | no | — | unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind) |
| 4 | `from_object_id` | `uuid` | no | — | unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind); FK → [`provenance.object`](object.md).id |
| 5 | `from_revision_id` | `uuid` | yes | — | unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind); FK → [`provenance.revision`](revision.md).id |
| 6 | `to_object_id` | `uuid` | no | — | unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind); FK → [`provenance.object`](object.md).id |
| 7 | `to_revision_id` | `uuid` | yes | — | unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind); FK → [`provenance.revision`](revision.md).id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind)
- check `edge_kind_check`: `(kind = ANY (ARRAY['informed_by'::text, 'derived_from'::text, 'supersedes'::text]))`
- check `edge_shape`: `(((kind = 'supersedes'::text) AND (from_object_id = to_object_id) AND (from_revision_id IS NOT NULL) AND (to_revision_id IS NOT NULL) AND (…`

## Relationships

Outbound: `from_object_id` → [`provenance.object`](object.md)`.id`; `from_revision_id` → [`provenance.revision`](revision.md)`.id`; `to_object_id` → [`provenance.object`](object.md)`.id`; `to_revision_id` → [`provenance.revision`](revision.md)`.id`.
Inbound: none.

## Indexes

`edge_from_idx`; `edge_from_object_id_from_revision_id_to_object_id_to_revisi_key` unique; `edge_to_idx`

## Triggers

- `edge_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `edge_tenant` (ALL) for `authenticated`, `service_role`: `(tenant_id = util.current_tenant_id())`

## Grants

`authenticated`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["provenance"]["Tables"]["edge"]["Insert"]`; row: `Database["provenance"]["Tables"]["edge"]["Row"]`; update: `Database["provenance"]["Tables"]["edge"]["Update"]`

Defined in: `20260831201650_project_provenance.sql`.
