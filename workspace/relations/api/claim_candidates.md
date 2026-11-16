---
id: "rel:api.claim_candidates"
kind: view
schema: api
name: claim_candidates
domain: verified-knowledge
lens: corpus
aliases: []
tokens: [api, claim_candidates, api.claim_candidates, claim_id, claim_type, statement, status, path, source_role, subject_resolved, speakers, attribution, learned_at, agrees_with_first_party_claim, subjects, document_node_id, document_title, created_at]
summary: "L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candidate = prose/media candidate awaiting verification), status, subjects and the document it was read from. Candidates are never facts."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"claim_candidates\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261108120500_build08_r2_fixups5.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.claim_candidates

view in domain `verified-knowledge`, lens `corpus` — L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candidate = prose/media candidate awaiting verification), status, subjects and the document it was read from. Candidates are never facts..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `claim_id` | `uuid` | yes | — | — |
| 2 | `claim_type` | `text` | yes | — | — |
| 3 | `statement` | `text` | yes | — | — |
| 4 | `status` | `text` | yes | — | — |
| 5 | `path` | `text` | yes | — | — |
| 6 | `source_role` | `text` | yes | — | — |
| 7 | `subject_resolved` | `boolean` | yes | — | — |
| 8 | `speakers` | `jsonb` | yes | — | — |
| 9 | `attribution` | `text` | yes | — | — |
| 10 | `learned_at` | `text` | yes | — | — |
| 11 | `agrees_with_first_party_claim` | `text` | yes | — | — |
| 12 | `subjects` | `text[]` | yes | — | — |
| 13 | `document_node_id` | `uuid` | yes | — | — |
| 14 | `document_title` | `text` | yes | — | — |
| 15 | `created_at` | `timestamp with time zone` | yes | — | — |

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

- Named queries: `q:evidence.claim`, `q:evidence.verified_claims`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](claim_candidates.details.md).

## TypeScript

row: `Database["api"]["Views"]["claim_candidates"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120500_build08_r2_fixups5.sql`.
