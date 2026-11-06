---
id: "rel:evidence.locator"
kind: table
schema: evidence
name: locator
domain: evidence
aliases: [quote, selector]
tokens: [evidence, locator, evidence.locator, id, capture_id, media_type, selector, selected_content_sha256, normalized_value, context_fingerprint, extractor_name, extractor_version, extraction_params, created_at, tenant_id, verification_contract_version, representation_artifact_id, selector_sha256, selected_size_bytes, occurrence_count, resolution_state, normalization_policy, resolution_version, selector_kind, start_ms, end_ms, page_number]
summary: "Precise selection inside a capture, with selected_content_sha256."
summary_basis: curated
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"evidence\"][\"Tables\"][\"locator\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.locator

table in domain `evidence`.

> curated (model_assisted, unreviewed) — Precise selection inside a capture, with selected_content_sha256.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `capture_id` | `uuid` | no | — | FK → [`evidence.source_capture`](source_capture.md).id |
| 3 | `media_type` | `text` | no | — | — |
| 4 | `selector` | `jsonb` | no | — | — |
| 5 | `selected_content_sha256` | `text` | yes | — | _curated:_ Digest of the selected span, not the whole capture. |
| 6 | `normalized_value` | `text` | yes | — | — |
| 7 | `context_fingerprint` | `text` | yes | — | — |
| 8 | `extractor_name` | `text` | no | — | — |
| 9 | `extractor_version` | `text` | no | — | — |
| 10 | `extraction_params` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `tenant_id` | `uuid` | yes | — | unique (tenant_id, id) |
| 13 | `verification_contract_version` | `text` | yes | — | — |
| 14 | `representation_artifact_id` | `uuid` | yes | — | — |
| 15 | `selector_sha256` | `text` | yes | — | — |
| 16 | `selected_size_bytes` | `bigint` | yes | — | — |
| 17 | `occurrence_count` | `integer` | yes | — | — |
| 18 | `resolution_state` | `text` | yes | — | — |
| 19 | `normalization_policy` | `text` | yes | — | — |
| 20 | `resolution_version` | `text` | yes | — | — |
| 21 | `selector_kind` | `text` | no | `'text_quote'::text` | _curated:_ text_quote, table, media_timecode, and others. |
| 22 | `start_ms` | `integer` | yes | — | — |
| 23 | `end_ms` | `integer` | yes | — | — |
| 24 | `page_number` | `integer` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `locator_check`: `((end_ms IS NULL) OR ((start_ms IS NOT NULL) AND (end_ms >= start_ms)))`
- check `locator_check1`: `((selector_kind <> ALL (ARRAY['media_timecode'::text, 'media_region'::text])) OR (start_ms IS NOT NULL))`
- check `locator_occurrence_count_check`: `((occurrence_count IS NULL) OR (occurrence_count >= 0))`
- check `locator_resolution_cardinality_ck`: `((verification_contract_version IS NULL) OR ((tenant_id IS NOT NULL) AND (representation_artifact_id IS NOT NULL) AND (selector_sha256 IS N…`
- check `locator_resolution_state_check`: `((resolution_state IS NULL) OR (resolution_state = ANY (ARRAY['resolved'::text, 'not_found'::text, 'ambiguous'::text, 'invalid'::text, 'par…`
- check `locator_selected_content_sha256_check`: `(selected_content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `locator_selected_size_bytes_check`: `((selected_size_bytes IS NULL) OR (selected_size_bytes >= 0))`
- check `locator_selector_kind_check`: `(selector_kind = ANY (ARRAY['text_quote'::text, 'character_position'::text, 'multi_fragment_text'::text, 'json_pointer'::text, 'html'::text…`
- check `locator_selector_sha256_check`: `((selector_sha256 IS NULL) OR (selector_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `locator_start_ms_check`: `((start_ms IS NULL) OR (start_ms >= 0))`
- check `locator_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `locator_verification_contract_version_ck`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`

## Relationships

3 outbound and 19 inbound foreign keys; full list in [details](locator.details.md).

## Indexes

2 indexes; see [details](locator.details.md).

## Triggers

3 triggers; see [details](locator.details.md).

## Row-level security

Enabled; 1 policies in [details](locator.details.md).

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`, `verifier_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["locator"]["Insert"]`; row: `Database["evidence"]["Tables"]["locator"]["Row"]`; update: `Database["evidence"]["Tables"]["locator"]["Update"]`

## Examples

Support rows carry locator_id

```bash
knowledge db query evidence.claim_support --param claim_id=0192d000-0000-7000-8000-000000000001
```
admit_support requires a locator.

Defined in: `20260826000300_evidence_core.sql`.
