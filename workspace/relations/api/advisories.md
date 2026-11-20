---
id: "rel:api.advisories"
kind: view
schema: api
name: advisories
domain: api-surface
lens: corpus
aliases: []
tokens: [api, advisories, api.advisories, advisory_id, advisory, ghsa_id, cve_id, severity, summary, url, published_at, software_id, software, software_kind, affected_range, fixed_version, claim_id, learned_k]
summary: "L1: security advisories with the affected software, vulnerable range and first patched version (GHSA records; OSV used only to resolve aliases)."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"advisories\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.advisories

view in domain `api-surface`, lens `corpus` — L1: security advisories with the affected software, vulnerable range and first patched version (GHSA records; OSV used only to resolve aliases)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `advisory_id` | `uuid` | yes | — | — |
| 2 | `advisory` | `text` | yes | — | — |
| 3 | `ghsa_id` | `text` | yes | — | — |
| 4 | `cve_id` | `text` | yes | — | — |
| 5 | `severity` | `text` | yes | — | — |
| 6 | `summary` | `text` | yes | — | — |
| 7 | `url` | `text` | yes | — | — |
| 8 | `published_at` | `text` | yes | — | — |
| 9 | `software_id` | `uuid` | yes | — | — |
| 10 | `software` | `text` | yes | — | — |
| 11 | `software_kind` | `text` | yes | — | — |
| 12 | `affected_range` | `text` | yes | — | — |
| 13 | `fixed_version` | `text` | yes | — | — |
| 14 | `claim_id` | `uuid` | yes | — | — |
| 15 | `learned_k` | `bigint` | yes | — | — |

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

See [details](advisories.details.md).

## TypeScript

row: `Database["api"]["Views"]["advisories"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
