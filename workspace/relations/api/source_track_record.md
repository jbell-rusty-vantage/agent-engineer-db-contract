---
id: "rel:api.source_track_record"
kind: view
schema: api
name: source_track_record
domain: api-surface
lens: corpus
aliases: []
tokens: [api, source_track_record, api.source_track_record, source_entity_id, source, source_kind, claim_id, statement, status, stated_at, first_party_at, verdict, probe]
summary: "Every claim a source stated, with its latest verdict: the rows behind an assessment's counts."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"source_track_record\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.source_track_record

view in domain `api-surface`, lens `corpus` — Every claim a source stated, with its latest verdict: the rows behind an assessment's counts..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `source_entity_id` | `uuid` | yes | — | — |
| 2 | `source` | `text` | yes | — | — |
| 3 | `source_kind` | `text` | yes | — | — |
| 4 | `claim_id` | `uuid` | yes | — | — |
| 5 | `statement` | `text` | yes | — | — |
| 6 | `status` | `text` | yes | — | — |
| 7 | `stated_at` | `text` | yes | — | — |
| 8 | `first_party_at` | `text` | yes | — | — |
| 9 | `verdict` | `text` | yes | — | — |
| 10 | `probe` | `text` | yes | — | — |

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

See [details](source_track_record.details.md).

## TypeScript

row: `Database["api"]["Views"]["source_track_record"]["Row"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
