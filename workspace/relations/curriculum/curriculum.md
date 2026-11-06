---
id: "rel:curriculum.curriculum"
kind: table
schema: curriculum
name: curriculum
domain: curriculum
aliases: []
tokens: [curriculum, curriculum, curriculum.curriculum, id, tenant_id, slug, title, audience, version, status, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"curriculum\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.curriculum

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug, version) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug, version) |
| 4 | `title` | `text` | no | — | — |
| 5 | `audience` | `text` | yes | — | — |
| 6 | `version` | `integer` | no | `1` | unique (tenant_id, slug, version) |
| 7 | `status` | `curriculum.publish_status` | no | `'draft'::curriculum.publish_status` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug, version)

## Relationships

Outbound: none.
Inbound: [`curriculum.track`](track.md).curriculum_id.

## Indexes

`curriculum_tenant_id_slug_version_key` unique

## Triggers

- `curriculum_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["curriculum"]["Tables"]["curriculum"]["Insert"]`; row: `Database["curriculum"]["Tables"]["curriculum"]["Row"]`; update: `Database["curriculum"]["Tables"]["curriculum"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
