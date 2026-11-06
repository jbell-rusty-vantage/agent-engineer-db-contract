---
id: "rel:public.factory_artifact"
kind: table
schema: public
name: factory_artifact
domain: research-starter-protected
aliases: []
tokens: [public, factory_artifact, public.factory_artifact, factory_artifact_id, factory_episode_id, artifact_kind, content_digest, storage_uri, media_type, byte_size, retention_class, contains_sensitive_data, metadata, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_artifact\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_artifact

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_artifact_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_episode_id` | `uuid` | no | — | unique (factory_episode_id, artifact_kind, content_digest); FK → [`public.factory_episode`](factory_episode.md).factory_episode_id |
| 3 | `artifact_kind` | `text` | no | — | unique (factory_episode_id, artifact_kind, content_digest) |
| 4 | `content_digest` | `text` | no | — | unique (factory_episode_id, artifact_kind, content_digest) |
| 5 | `storage_uri` | `text` | no | — | — |
| 6 | `media_type` | `text` | yes | — | — |
| 7 | `byte_size` | `bigint` | yes | — | — |
| 8 | `retention_class` | `text` | no | `'standard'::text` | — |
| 9 | `contains_sensitive_data` | `boolean` | no | `false` | — |
| 10 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_artifact_id)
- unique (factory_episode_id, artifact_kind, content_digest)
- check `factory_artifact_kind_check`: `(artifact_kind = ANY (ARRAY['trace'::text, 'patch'::text, 'repository'::text, 'build'::text, 'log'::text, 'sbom'::text, 'screenshot'::text,…`
- check `factory_artifact_retention_check`: `(retention_class = ANY (ARRAY['ephemeral'::text, 'standard'::text, 'long_term'::text, 'legal_hold'::text]))`
- check `factory_artifact_size_check`: `((byte_size IS NULL) OR (byte_size >= 0))`

## Relationships

Outbound: `factory_episode_id` → [`public.factory_episode`](factory_episode.md)`.factory_episode_id` on delete cascade.
Inbound: [`public.factory_trace_span_ref`](factory_trace_span_ref.md).artifact_id.

## Indexes

`factory_artifact_episode_digest_uniq` unique

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

insert: `Database["public"]["Tables"]["factory_artifact"]["Insert"]`; row: `Database["public"]["Tables"]["factory_artifact"]["Row"]`; update: `Database["public"]["Tables"]["factory_artifact"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
