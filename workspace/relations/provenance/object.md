---
id: "rel:provenance.object"
kind: table
schema: provenance
name: object
domain: provenance
aliases: []
tokens: [provenance, object, provenance.object, id, tenant_id, kind, key, title, local_uri, created_at, updated_at]
summary: "Stable design-object identity. One row per conversation, doc, spec, issue, or PR."
summary_basis: comment
rls: enabled
readers: [authenticated, service_role]
writers: [authenticated, service_role]
typescript: "Database[\"provenance\"][\"Tables\"][\"object\"][\"Row\"]"
defined_in: ["20260831201650_project_provenance.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# provenance.object

table in domain `provenance` — Stable design-object identity. One row per conversation, doc, spec, issue, or PR..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, kind, key) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, kind, key) |
| 4 | `key` | `text` | no | — | unique (tenant_id, kind, key); Tenant-unique handle with kind. File slugs, or {system}:{external_id} for conversations and projections. |
| 5 | `title` | `text` | no | — | — |
| 6 | `local_uri` | `text` | yes | — | Working-copy locator: {repo_slug}:{posix_relative_path}. Null for tracker-only or conversation objects. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, kind, key)
- check `object_key_nonempty`: `((btrim(key) <> ''::text) AND (btrim(title) <> ''::text))`
- check `object_kind_check`: `(kind = ANY (ARRAY['conversation'::text, 'architecture_doc'::text, 'adr'::text, 'spec'::text, 'feature'::text, 'issue'::text, 'pr'::text]))`

## Relationships

Outbound: none.
Inbound: [`provenance.binding`](binding.md).object_id, [`provenance.edge`](edge.md).from_object_id|to_object_id, [`provenance.revision`](revision.md).object_id.

## Indexes

`object_kind_idx`; `object_tenant_id_kind_key_key` unique

## Triggers

- `object_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `object_tenant` (ALL) for `authenticated`, `service_role`: `(tenant_id = util.current_tenant_id())`

## Grants

`authenticated`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["provenance"]["Tables"]["object"]["Insert"]`; row: `Database["provenance"]["Tables"]["object"]["Row"]`; update: `Database["provenance"]["Tables"]["object"]["Update"]`

Defined in: `20260831201650_project_provenance.sql`.
