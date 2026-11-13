---
id: "rel:api.claim_conflicts"
kind: view
schema: api
name: claim_conflicts
domain: api-surface
lens: corpus
aliases: []
tokens: [api, claim_conflicts, api.claim_conflicts, conflict_id, conflict_kind, detected_by, detected_at, first_party_claim_id, first_party_statement, first_party_status, other_claim_id, other_statement, other_status, other_source_role, other_provenance, reconciliation]
summary: "Kept disagreements between a first-party claim and another statement (value, scope or subject ambiguity); never averaged away, reconciled only by an explicit decision."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"claim_conflicts\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261108120500_build08_r2_fixups5.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.claim_conflicts

view in domain `api-surface`, lens `corpus` — Kept disagreements between a first-party claim and another statement (value, scope or subject ambiguity); never averaged away, reconciled only by an explicit decision..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `conflict_id` | `uuid` | yes | — | — |
| 2 | `conflict_kind` | `text` | yes | — | — |
| 3 | `detected_by` | `text` | yes | — | — |
| 4 | `detected_at` | `timestamp with time zone` | yes | — | — |
| 5 | `first_party_claim_id` | `uuid` | yes | — | — |
| 6 | `first_party_statement` | `text` | yes | — | — |
| 7 | `first_party_status` | `text` | yes | — | — |
| 8 | `other_claim_id` | `uuid` | yes | — | — |
| 9 | `other_statement` | `text` | yes | — | — |
| 10 | `other_status` | `text` | yes | — | — |
| 11 | `other_source_role` | `text` | yes | — | — |
| 12 | `other_provenance` | `text` | yes | — | — |
| 13 | `reconciliation` | `text` | yes | — | — |

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

See [details](claim_conflicts.details.md).

## TypeScript

row: `Database["api"]["Views"]["claim_conflicts"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120500_build08_r2_fixups5.sql`.
