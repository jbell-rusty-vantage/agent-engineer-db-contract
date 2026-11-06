---
id: "rel:orchestration.verification_structured_extraction"
kind: table
schema: orchestration
name: verification_structured_extraction
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_structured_extraction, orchestration.verification_structured_extraction, id, tenant_id, operation_id, operation_step_id, producer_attempt_id, identity_sha256, request_sha256, step_input_sha256, capture_id, profile_artifact_id, profile_sha256, schema_artifact_id, schema_artifact_sha256, source_artifact_id, source_sha256, representation_artifact_id, representation_sha256, transformation_artifact_id, transformation_sha256, prompt_sha256, schema_digest_sha256, status, started_at, retention_started_at, completed_at, provider_attempt_id, original_dispatch_fencing_token, http_status, captured_at, provider_request_artifact_id, provider_request_sha256, raw_response_artifact_id, raw_response_sha256, response_envelope_artifact_id, response_envelope_sha256, transport_artifact_id, transport_sha256, candidate_artifact_id, candidate_sha256, precontext_artifact_id, precontext_sha256, provenance_artifact_id, provenance_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_structured_extraction\"][\"Row\"]"
defined_in: ["20260906031700_verification_structured_extraction_lifecycle.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.verification_structured_extraction

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK; unique (tenant_id, provider_attempt_id); unique (tenant_id, id) |
| 3 | `operation_id` | `uuid` | no | — | PK |
| 4 | `operation_step_id` | `uuid` | no | — | — |
| 5 | `producer_attempt_id` | `uuid` | no | — | — |
| 6 | `identity_sha256` | `text` | no | — | — |
| 7 | `request_sha256` | `text` | no | — | — |
| 8 | `step_input_sha256` | `text` | no | — | — |
| 9 | `capture_id` | `uuid` | no | — | — |
| 10 | `profile_artifact_id` | `uuid` | no | — | — |
| 11 | `profile_sha256` | `text` | no | — | — |
| 12 | `schema_artifact_id` | `uuid` | no | — | — |
| 13 | `schema_artifact_sha256` | `text` | no | — | — |
| 14 | `source_artifact_id` | `uuid` | no | — | — |
| 15 | `source_sha256` | `text` | no | — | — |
| 16 | `representation_artifact_id` | `uuid` | no | — | — |
| 17 | `representation_sha256` | `text` | no | — | — |
| 18 | `transformation_artifact_id` | `uuid` | no | — | — |
| 19 | `transformation_sha256` | `text` | no | — | — |
| 20 | `prompt_sha256` | `text` | no | — | — |
| 21 | `schema_digest_sha256` | `text` | no | — | — |
| 22 | `status` | `text` | no | `'running'::text` | — |
| 23 | `started_at` | `timestamp with time zone` | no | `date_trunc('milliseconds'::text, clock_timestamp())` | — |
| 24 | `retention_started_at` | `timestamp with time zone` | yes | — | — |
| 25 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 26 | `provider_attempt_id` | `uuid` | yes | — | unique (tenant_id, provider_attempt_id) |
| 27 | `original_dispatch_fencing_token` | `bigint` | yes | — | — |
| 28 | `http_status` | `integer` | yes | — | — |
| 29 | `captured_at` | `timestamp with time zone` | yes | — | — |
| 30 | `provider_request_artifact_id` | `uuid` | yes | — | — |
| 31 | `provider_request_sha256` | `text` | yes | — | — |
| 32 | `raw_response_artifact_id` | `uuid` | yes | — | — |
| 33 | `raw_response_sha256` | `text` | yes | — | — |
| 34 | `response_envelope_artifact_id` | `uuid` | yes | — | — |
| 35 | `response_envelope_sha256` | `text` | yes | — | — |
| 36 | `transport_artifact_id` | `uuid` | yes | — | — |
| 37 | `transport_sha256` | `text` | yes | — | — |
| 38 | `candidate_artifact_id` | `uuid` | yes | — | — |
| 39 | `candidate_sha256` | `text` | yes | — | — |
| 40 | `precontext_artifact_id` | `uuid` | yes | — | — |
| 41 | `precontext_sha256` | `text` | yes | — | — |
| 42 | `provenance_artifact_id` | `uuid` | yes | — | — |
| 43 | `provenance_sha256` | `text` | yes | — | — |

## Constraints

- PK (tenant_id, operation_id)
- unique (tenant_id, provider_attempt_id)
- unique (tenant_id, id)
- 22 check constraints; see [details](verification_structured_extraction.details.md)

## Relationships

17 outbound and 2 inbound foreign keys; full list in [details](verification_structured_extraction.details.md).

## Indexes

2 indexes; see [details](verification_structured_extraction.details.md).

## Triggers

14 triggers; see [details](verification_structured_extraction.details.md).

## Row-level security

Enabled; 2 policies in [details](verification_structured_extraction.details.md).

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_structured_extraction"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_structured_extraction"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_structured_extraction"]["Update"]`

Defined in: `20260906031700_verification_structured_extraction_lifecycle.sql`.
