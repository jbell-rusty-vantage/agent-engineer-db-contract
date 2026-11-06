---
id: "rel:corpus.media_platform"
kind: table
schema: corpus
name: media_platform
domain: identity
aliases: []
tokens: [corpus, media_platform, corpus.media_platform, code, name, media_url_template, channel_url_template, timecode_param, product_entity_id]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"media_platform\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.media_platform

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `name` | `text` | no | — | — |
| 3 | `media_url_template` | `text` | yes | — | — |
| 4 | `channel_url_template` | `text` | yes | — | — |
| 5 | `timecode_param` | `text` | yes | — | — |
| 6 | `product_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](entity.md).id |

## Constraints

- PK (code)
- check `media_platform_code_check`: `(code = ANY (ARRAY['youtube'::text, 'vimeo'::text, 'spotify'::text, 'apple_podcasts'::text, 'x'::text, 'linkedin'::text, 'twitch'::text, 'b…`

## Relationships

Outbound: `product_entity_id` → [`corpus.entity`](entity.md)`.id`.
Inbound: [`corpus.media_channel`](media_channel.md).platform_code, [`corpus.media_series`](media_series.md).platform_code, [`corpus.media_work`](media_work.md).platform_code.

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

insert: `Database["corpus"]["Tables"]["media_platform"]["Insert"]`; row: `Database["corpus"]["Tables"]["media_platform"]["Row"]`; update: `Database["corpus"]["Tables"]["media_platform"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
