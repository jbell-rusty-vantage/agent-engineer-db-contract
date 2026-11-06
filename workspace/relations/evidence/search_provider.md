---
id: "rel:evidence.search_provider"
kind: table
schema: evidence
name: search_provider
domain: evidence
aliases: []
tokens: [evidence, search_provider, evidence.search_provider, code, description, provider_kind]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"search_provider\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.search_provider

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |
| 3 | `provider_kind` | `text` | no | `'search'::text` | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`evidence.source_provider_attempt`](source_provider_attempt.md).provider_code, [`evidence.source_query`](source_query.md).provider_code.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["search_provider"]["Insert"]`; row: `Database["evidence"]["Tables"]["search_provider"]["Row"]`; update: `Database["evidence"]["Tables"]["search_provider"]["Update"]`

Defined in: `20260912010100_km_01_vocabularies.sql`.
