---
id: "rel:api.digest_items"
kind: view
schema: api
name: digest_items
domain: api-surface
lens: corpus
aliases: []
tokens: [api, digest_items, api.digest_items, item_id, digest_id, scope, scope_node_id, scope_heading, document_id, document_title, document_type_code, document_version_id, version_label, ordinal, item_kind, text, payload, node_ids, anchor_count, entity_id, entity, entity_role, claim_id, unit_change_id, confidence, producer_kind, producer_identity, start_ms, end_ms, work_id, deep_link]
summary: "L3 summary level: one row per structured digest item with its anchor units, entity role, claim candidate, timecode range and (for talks) a video deep link. The item, not a prose summary, is the unit of retrieval."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"digest_items\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.digest_items

view in domain `api-surface`, lens `corpus` — L3 summary level: one row per structured digest item with its anchor units, entity role, claim candidate, timecode range and (for talks) a video deep link. The item, not a prose summary, is the unit of retrieval..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `item_id` | `uuid` | yes | — | — |
| 2 | `digest_id` | `uuid` | yes | — | — |
| 3 | `scope` | `text` | yes | — | — |
| 4 | `scope_node_id` | `uuid` | yes | — | — |
| 5 | `scope_heading` | `text` | yes | — | — |
| 6 | `document_id` | `uuid` | yes | — | — |
| 7 | `document_title` | `text` | yes | — | — |
| 8 | `document_type_code` | `text` | yes | — | — |
| 9 | `document_version_id` | `uuid` | yes | — | — |
| 10 | `version_label` | `text` | yes | — | — |
| 11 | `ordinal` | `integer` | yes | — | — |
| 12 | `item_kind` | `text` | yes | — | — |
| 13 | `text` | `text` | yes | — | — |
| 14 | `payload` | `jsonb` | yes | — | — |
| 15 | `node_ids` | `uuid[]` | yes | — | — |
| 16 | `anchor_count` | `integer` | yes | — | — |
| 17 | `entity_id` | `uuid` | yes | — | — |
| 18 | `entity` | `text` | yes | — | — |
| 19 | `entity_role` | `text` | yes | — | — |
| 20 | `claim_id` | `uuid` | yes | — | — |
| 21 | `unit_change_id` | `uuid` | yes | — | — |
| 22 | `confidence` | `numeric` | yes | — | — |
| 23 | `producer_kind` | `text` | yes | — | — |
| 24 | `producer_identity` | `text` | yes | — | — |
| 25 | `start_ms` | `integer` | yes | — | — |
| 26 | `end_ms` | `integer` | yes | — | — |
| 27 | `work_id` | `uuid` | yes | — | — |
| 28 | `deep_link` | `text` | yes | — | — |

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

See [details](digest_items.details.md).

## TypeScript

row: `Database["api"]["Views"]["digest_items"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
