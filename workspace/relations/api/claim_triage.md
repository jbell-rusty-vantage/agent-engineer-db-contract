---
id: "rel:api.claim_triage"
kind: view
schema: api
name: claim_triage
domain: verified-knowledge
lens: corpus
aliases: []
tokens: [api, claim_triage, api.claim_triage, claim_id, statement, claim_type, status, disposition, checkability, priority, components, rationale, probe, duplicate_of_claim_id, decided_by, review_state, decided_at, verdict]
summary: "Loop 5: the current triage of each claim candidate, with the probe it became and its verdict if probed."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"claim_triage\"][\"Row\"]"
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.claim_triage

view in domain `verified-knowledge`, lens `corpus` — Loop 5: the current triage of each claim candidate, with the probe it became and its verdict if probed..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `statement` | `text` | yes | — | — |
| 3 | `claim_type` | `text` | yes | — | — |
| 4 | `status` | `text` | yes | — | — |
| 5 | `disposition` | `text` | yes | — | — |
| 6 | `checkability` | `text` | yes | — | — |
| 7 | `priority` | `numeric(6,2)` | yes | — | — |
| 8 | `components` | `jsonb` | yes | — | — |
| 9 | `rationale` | `text` | yes | — | — |
| 10 | `probe` | `text` | yes | — | — |
| 11 | `duplicate_of_claim_id` | `uuid` | yes | — | — |
| 12 | `decided_by` | `text` | yes | — | — |
| 13 | `review_state` | `text` | yes | — | — |
| 14 | `decided_at` | `timestamp with time zone` | yes | — | — |
| 15 | `verdict` | `text` | yes | — | — |

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

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `executor_service`.

## Read paths

- Named queries: `q:evidence.claim_triage`.
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](claim_triage.details.md).

## TypeScript

row: `Database["api"]["Views"]["claim_triage"]["Row"]`

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
