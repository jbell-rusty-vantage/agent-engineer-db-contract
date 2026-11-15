---
id: "rel:api.claim_verdicts"
kind: view
schema: api
name: claim_verdicts
domain: api-surface
lens: corpus
aliases: []
tokens: [api, claim_verdicts, api.claim_verdicts, claim_id, statement, claim_type, status, stated_at, quote, stated_by, channel, verdict, probe, review_state, decided_by, decided_at, cells, rationale]
summary: "Claims that a probe has judged, with who stated them, on which channel, the latest verdict, its review state and the per-cell summary."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"claim_verdicts\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.claim_verdicts

view in domain `api-surface`, lens `corpus` — Claims that a probe has judged, with who stated them, on which channel, the latest verdict, its review state and the per-cell summary..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `statement` | `text` | yes | — | — |
| 3 | `claim_type` | `text` | yes | — | — |
| 4 | `status` | `text` | yes | — | — |
| 5 | `stated_at` | `text` | yes | — | — |
| 6 | `quote` | `text` | yes | — | — |
| 7 | `stated_by` | `text` | yes | — | — |
| 8 | `channel` | `text` | yes | — | — |
| 9 | `verdict` | `text` | yes | — | — |
| 10 | `probe` | `text` | yes | — | — |
| 11 | `review_state` | `text` | yes | — | — |
| 12 | `decided_by` | `text` | yes | — | — |
| 13 | `decided_at` | `timestamp with time zone` | yes | — | — |
| 14 | `cells` | `jsonb` | yes | — | — |
| 15 | `rationale` | `text` | yes | — | — |

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

See [details](claim_verdicts.details.md).

## TypeScript

row: `Database["api"]["Views"]["claim_verdicts"]["Row"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
