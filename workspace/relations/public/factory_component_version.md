---
id: "rel:public.factory_component_version"
kind: table
schema: public
name: factory_component_version
domain: research-starter-protected
aliases: []
tokens: [public, factory_component_version, public.factory_component_version, component_version_id, component_kind, slug, version, content_digest, source_revision, storage_uri, metadata, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_component_version\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_component_version

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `component_version_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `component_kind` | `text` | no | — | unique (component_kind, slug, version) |
| 3 | `slug` | `text` | no | — | unique (component_kind, slug, version) |
| 4 | `version` | `text` | no | — | unique (component_kind, slug, version) |
| 5 | `content_digest` | `text` | no | — | — |
| 6 | `source_revision` | `text` | no | — | — |
| 7 | `storage_uri` | `text` | yes | — | — |
| 8 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (component_version_id)
- unique (component_kind, slug, version)
- check `factory_component_kind_check`: `(component_kind = ANY (ARRAY['instructions'::text, 'skill'::text, 'tool'::text, 'retriever'::text, 'workflow'::text, 'model_route'::text, '…`

## Relationships

Outbound: none.
Inbound: [`public.factory_evolution_proposal`](factory_evolution_proposal.md).rollback_component_version_id, [`public.factory_promotion_decision`](factory_promotion_decision.md).rollback_component_version_id.

## Indexes

`factory_component_slug_version_uniq` unique

## Triggers

_None._

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["factory_component_version"]["Insert"]`; row: `Database["public"]["Tables"]["factory_component_version"]["Row"]`; update: `Database["public"]["Tables"]["factory_component_version"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
