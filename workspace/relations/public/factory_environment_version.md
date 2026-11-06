---
id: "rel:public.factory_environment_version"
kind: table
schema: public
name: factory_environment_version
domain: research-starter-protected
aliases: []
tokens: [public, factory_environment_version, public.factory_environment_version, environment_version_id, slug, version, task_kind, image_digest, verifier_bundle_digest, reward_contract_version, protocol_version, spec, status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_environment_version\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_environment_version

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `environment_version_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `slug` | `text` | no | — | unique (slug, version) |
| 3 | `version` | `text` | no | — | unique (slug, version) |
| 4 | `task_kind` | `text` | no | — | — |
| 5 | `image_digest` | `text` | no | — | — |
| 6 | `verifier_bundle_digest` | `text` | no | — | — |
| 7 | `reward_contract_version` | `text` | no | — | — |
| 8 | `protocol_version` | `text` | no | `'1'::text` | — |
| 9 | `spec` | `jsonb` | no | — | — |
| 10 | `status` | `text` | no | `'draft'::text` | — |
| 11 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (environment_version_id)
- unique (slug, version)
- check `factory_environment_status_check`: `(status = ANY (ARRAY['draft'::text, 'active'::text, 'retired'::text]))`
- check `factory_environment_task_kind_check`: `(task_kind = ANY (ARRAY['research_ingestion'::text, 'curriculum_generation'::text, 'app_feature'::text, 'app_repair'::text, 'learner_submis…`

## Relationships

Outbound: none.
Inbound: [`public.factory_episode`](factory_episode.md).environment_version_id.

## Indexes

`factory_environment_slug_version_uniq` unique

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

insert: `Database["public"]["Tables"]["factory_environment_version"]["Insert"]`; row: `Database["public"]["Tables"]["factory_environment_version"]["Row"]`; update: `Database["public"]["Tables"]["factory_environment_version"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
