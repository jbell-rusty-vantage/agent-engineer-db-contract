---
id: "rel:catalog.media_platform"
kind: table
schema: catalog
name: media_platform
domain: identity
lens: corpus
aliases: []
tokens: [catalog, media_platform, catalog.media_platform, code, name, media_url_template, channel_url_template, timecode_param, product_entity_id]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"catalog\"][\"Tables\"][\"media_platform\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# catalog.media_platform

table in domain `identity`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `name` | `text` | no | — | — |
| 3 | `media_url_template` | `text` | yes | — | — |
| 4 | `channel_url_template` | `text` | yes | — | — |
| 5 | `timecode_param` | `text` | yes | — | — |
| 6 | `product_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](entity.md).id |

## Constraints

- PK (code)
- check `media_platform_code_check`: `(code = ANY (ARRAY['youtube'::text, 'vimeo'::text, 'spotify'::text, 'apple_podcasts'::text, 'x'::text, 'linkedin'::text, 'twitch'::text, 'b…`

## Relationships

Outbound: `product_entity_id` → [`catalog.entity`](entity.md)`.id`.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["catalog"]["Tables"]["media_platform"]["Insert"]`; row: `Database["catalog"]["Tables"]["media_platform"]["Row"]`; update: `Database["catalog"]["Tables"]["media_platform"]["Update"]`

Defined in: unknown.
