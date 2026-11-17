---
id: "rel:api.registry_listings"
kind: view
schema: api
name: registry_listings
domain: api-surface
lens: corpus
aliases: []
tokens: [api, registry_listings, api.registry_listings, relationship_id, server_id, server, namespace, first_party_inferred, transports, latest_version, repository_url, registry_status, registry, properties, learned_k, current_status]
summary: "L1: servers listed in a registry with transports, namespace-inferred first-party flag and the registry's own status stream (official = registry validation, not vendor status)."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"registry_listings\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.registry_listings

view in domain `api-surface`, lens `corpus` — L1: servers listed in a registry with transports, namespace-inferred first-party flag and the registry's own status stream (official = registry validation, not vendor status)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `relationship_id` | `uuid` | yes | — | — |
| 2 | `server_id` | `uuid` | yes | — | — |
| 3 | `server` | `text` | yes | — | — |
| 4 | `namespace` | `text` | yes | — | — |
| 5 | `first_party_inferred` | `boolean` | yes | — | — |
| 6 | `transports` | `jsonb` | yes | — | — |
| 7 | `latest_version` | `text` | yes | — | — |
| 8 | `repository_url` | `text` | yes | — | — |
| 9 | `registry_status` | `text` | yes | — | — |
| 10 | `registry` | `text` | yes | — | — |
| 11 | `properties` | `jsonb` | yes | — | — |
| 12 | `learned_k` | `bigint` | yes | — | — |
| 13 | `current_status` | `text` | yes | — | — |

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

See [details](registry_listings.details.md).

## TypeScript

row: `Database["api"]["Views"]["registry_listings"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
