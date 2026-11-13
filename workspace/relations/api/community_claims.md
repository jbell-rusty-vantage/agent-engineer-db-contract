---
id: "rel:api.community_claims"
kind: view
schema: api
name: community_claims
domain: api-surface
lens: corpus
aliases: []
tokens: [api, community_claims, api.community_claims, claim_id, statement, claim_type, status, quote, stated_at, channel_slug, channel, stated_by, stated_by_kind, thread_url, thread, thread_state, subjects, extracted_by, verdict]
summary: "Claims stated on a community or editorial channel (issue trackers, forums, aggregators, comparison articles): quote, who stated it (handle as published), thread and its state, subjects, whether a model extracted it, and the latest probe verdict if any. Candidates, never facts."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"community_claims\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql", "20261113120400_build08_loop4_fixup_community_claims.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.community_claims

view in domain `api-surface`, lens `corpus` — Claims stated on a community or editorial channel (issue trackers, forums, aggregators, comparison articles): quote, who stated it (handle as published), thread and its state, subjects, whether a model extracted it, and the latest probe verdict if any. Candidates, never facts..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `statement` | `text` | yes | — | — |
| 3 | `claim_type` | `text` | yes | — | — |
| 4 | `status` | `text` | yes | — | — |
| 5 | `quote` | `text` | yes | — | — |
| 6 | `stated_at` | `text` | yes | — | — |
| 7 | `channel_slug` | `text` | yes | — | — |
| 8 | `channel` | `text` | yes | — | — |
| 9 | `stated_by` | `text` | yes | — | — |
| 10 | `stated_by_kind` | `text` | yes | — | — |
| 11 | `thread_url` | `text` | yes | — | — |
| 12 | `thread` | `text` | yes | — | — |
| 13 | `thread_state` | `text` | yes | — | — |
| 14 | `subjects` | `text[]` | yes | — | — |
| 15 | `extracted_by` | `text` | yes | — | — |
| 16 | `verdict` | `text` | yes | — | — |

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

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](community_claims.details.md).

## TypeScript

row: `Database["api"]["Views"]["community_claims"]["Row"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`, `20261113120400_build08_loop4_fixup_community_claims.sql`.
