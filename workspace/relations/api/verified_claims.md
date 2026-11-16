---
id: "rel:api.verified_claims"
kind: view
schema: api
name: verified_claims
domain: verified-knowledge
lens: corpus
aliases: []
tokens: [api, verified_claims, api.verified_claims, claim_id, statement, claim_type, receipt_id, use_decision_id, bound_effect_digest, verified_at, executor_version, effect, verdicts]
summary: "Loop 6: claims that reached verified through a Knowledge Services admission, with the use decision, the admission-bound receipt, the bound native payload and the current probe verdicts."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"verified_claims\"][\"Row\"]"
defined_in: ["20261113150000_build08_ks_admission_verified_claims.sql", "20261113150000_build08_loop6_ks_admission.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.verified_claims

view in domain `verified-knowledge`, lens `corpus` — Loop 6: claims that reached verified through a Knowledge Services admission, with the use decision, the admission-bound receipt, the bound native payload and the current probe verdicts..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `statement` | `text` | yes | — | — |
| 3 | `claim_type` | `text` | yes | — | — |
| 4 | `receipt_id` | `uuid` | yes | — | — |
| 5 | `use_decision_id` | `text` | yes | — | — |
| 6 | `bound_effect_digest` | `text` | yes | — | — |
| 7 | `verified_at` | `timestamp with time zone` | yes | — | — |
| 8 | `executor_version` | `text` | yes | — | — |
| 9 | `effect` | `jsonb` | yes | — | — |
| 10 | `verdicts` | `jsonb` | yes | — | — |

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

- Named queries: `q:evidence.verified_claims`.
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](verified_claims.details.md).

## TypeScript

row: `Database["api"]["Views"]["verified_claims"]["Row"]`

Defined in: `20261113150000_build08_ks_admission_verified_claims.sql`, `20261113150000_build08_loop6_ks_admission.sql`.
