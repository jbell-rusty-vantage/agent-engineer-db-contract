---
id: "rel:api.claim_restatements"
kind: view
schema: api
name: claim_restatements
domain: verified-knowledge
lens: corpus
aliases: []
tokens: [api, claim_restatements, api.claim_restatements, claim_id, statement, status, qualified, dropped, probe, original_claim_id, original_statement, original_status, created_at]
summary: "Loop 7 (D-80): restated claims and the attribution-framed originals they were atomized from (the original stays proposed as the record of what a source said)."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"claim_restatements\"][\"Row\"]"
defined_in: ["20261115120000_build08_loop7_search_collapse_restatements.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.claim_restatements

view in domain `verified-knowledge`, lens `corpus` — Loop 7 (D-80): restated claims and the attribution-framed originals they were atomized from (the original stays proposed as the record of what a source said)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `statement` | `text` | yes | — | — |
| 3 | `status` | `text` | yes | — | — |
| 4 | `qualified` | `boolean` | yes | — | — |
| 5 | `dropped` | `text` | yes | — | — |
| 6 | `probe` | `text` | yes | — | — |
| 7 | `original_claim_id` | `uuid` | yes | — | — |
| 8 | `original_statement` | `text` | yes | — | — |
| 9 | `original_status` | `text` | yes | — | — |
| 10 | `created_at` | `timestamp with time zone` | yes | — | — |

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

- Named queries: `q:evidence.claim_restatements`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](claim_restatements.details.md).

## TypeScript

row: `Database["api"]["Views"]["claim_restatements"]["Row"]`

Defined in: `20261115120000_build08_loop7_search_collapse_restatements.sql`.
