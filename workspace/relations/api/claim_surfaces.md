---
id: "rel:api.claim_surfaces"
kind: view
schema: api
name: claim_surfaces
domain: api-surface
lens: corpus
aliases: []
tokens: [api, claim_surfaces, api.claim_surfaces, claim_id, claim_type, statement, status, path, assertion_mode, speakers, quote, start_ms, deep_link, talk_id, talk, consistency, consistency_note, compared_by, subjects, surfaces, conflicts]
summary: "Claim candidates from talks (speaker, timecode, exact quote; always proposed, never adjudicated) with the library surfaces they concern (evidence links of role context) and the recorded reading: appears_consistent | appears_inconsistent | not_addressed | not_compared."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"claim_surfaces\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.claim_surfaces

view in domain `api-surface`, lens `corpus` — Claim candidates from talks (speaker, timecode, exact quote; always proposed, never adjudicated) with the library surfaces they concern (evidence links of role context) and the recorded reading: appears_consistent | appears_inconsistent | not_addressed | not_compared..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `claim_type` | `text` | yes | — | — |
| 3 | `statement` | `text` | yes | — | — |
| 4 | `status` | `text` | yes | — | — |
| 5 | `path` | `text` | yes | — | — |
| 6 | `assertion_mode` | `text` | yes | — | — |
| 7 | `speakers` | `jsonb` | yes | — | — |
| 8 | `quote` | `text` | yes | — | — |
| 9 | `start_ms` | `integer` | yes | — | — |
| 10 | `deep_link` | `text` | yes | — | — |
| 11 | `talk_id` | `uuid` | yes | — | — |
| 12 | `talk` | `text` | yes | — | — |
| 13 | `consistency` | `text` | yes | — | — |
| 14 | `consistency_note` | `text` | yes | — | — |
| 15 | `compared_by` | `text` | yes | — | — |
| 16 | `subjects` | `text[]` | yes | — | — |
| 17 | `surfaces` | `jsonb` | yes | — | — |
| 18 | `conflicts` | `bigint` | yes | — | — |

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

See [details](claim_surfaces.details.md).

## TypeScript

row: `Database["api"]["Views"]["claim_surfaces"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
