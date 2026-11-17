---
id: "rel:api.talks"
kind: view
schema: api
name: talks
domain: api-surface
lens: corpus
aliases: []
tokens: [api, talks, api.talks, talk_id, title, slug, talk_kind, track, level, event, event_id, event_starts_on, speakers, speaker_affiliations, topics, repositories, recorded_at, duration_ms, canonical_url, video_url, slides_url, session_id, document_count, summary]
summary: "L1: conference talks with event, track, speakers and their affiliations, topics (about), linked repositories (has_code), recording and slides links."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"talks\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261108120400_build08_r2_fixups4.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.talks

view in domain `api-surface`, lens `corpus` — L1: conference talks with event, track, speakers and their affiliations, topics (about), linked repositories (has_code), recording and slides links..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `talk_id` | `uuid` | yes | — | — |
| 2 | `title` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `talk_kind` | `text` | yes | — | — |
| 5 | `track` | `text` | yes | — | — |
| 6 | `level` | `text` | yes | — | — |
| 7 | `event` | `text` | yes | — | — |
| 8 | `event_id` | `uuid` | yes | — | — |
| 9 | `event_starts_on` | `text` | yes | — | — |
| 10 | `speakers` | `text[]` | yes | — | — |
| 11 | `speaker_affiliations` | `text[]` | yes | — | — |
| 12 | `topics` | `text[]` | yes | — | — |
| 13 | `repositories` | `text[]` | yes | — | — |
| 14 | `recorded_at` | `timestamp with time zone` | yes | — | — |
| 15 | `duration_ms` | `integer` | yes | — | — |
| 16 | `canonical_url` | `text` | yes | — | — |
| 17 | `video_url` | `text` | yes | — | — |
| 18 | `slides_url` | `text` | yes | — | — |
| 19 | `session_id` | `text` | yes | — | — |
| 20 | `document_count` | `bigint` | yes | — | — |
| 21 | `summary` | `text` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Named queries: `q:catalog.talks`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](talks.details.md).

## TypeScript

row: `Database["api"]["Views"]["talks"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120400_build08_r2_fixups4.sql`, `part4_views_seeds.sql`.
