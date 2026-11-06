---
id: "rel:evidence.source_provider_attempt"
kind: table
schema: evidence
name: source_provider_attempt
domain: evidence
aliases: []
tokens: [evidence, source_provider_attempt, evidence.source_provider_attempt, id, tenant_id, source_query_id, provider_code, origin, idempotency_key, request_sha256, requested_urls, request_artifact_id, raw_output_artifact_id, external_receipt_artifact_id, provider_native_attempt_id, attempt_ordinal, state, failure_code, dispatch_owner, dispatch_token, dispatch_fencing_token, dispatch_claimed_at, dispatch_expires_at, started_at, completed_at, completion_sha256, provider_version, retry_of_attempt_id, root_attempt_id, original_dispatch_token, original_dispatch_fencing_token, completion_artifact_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_provider_attempt\"][\"Row\"]"
defined_in: ["20260914010200_source_attempt_accounting.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.source_provider_attempt

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, idempotency_key); unique (tenant_id, source_query_id, attempt_ordinal) |
| 3 | `source_query_id` | `uuid` | no | — | unique (tenant_id, source_query_id, attempt_ordinal); FK → [`evidence.source_query`](source_query.md).id |
| 4 | `provider_code` | `text` | no | — | FK → [`evidence.search_provider`](search_provider.md).code |
| 5 | `origin` | `text` | no | — | — |
| 6 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 7 | `request_sha256` | `text` | no | — | — |
| 8 | `requested_urls` | `jsonb` | no | `'[]'::jsonb` | — |
| 9 | `request_artifact_id` | `uuid` | no | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 10 | `raw_output_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 11 | `external_receipt_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 12 | `provider_native_attempt_id` | `text` | yes | — | — |
| 13 | `attempt_ordinal` | `integer` | no | `0` | unique (tenant_id, source_query_id, attempt_ordinal) |
| 14 | `state` | `text` | no | — | — |
| 15 | `failure_code` | `text` | yes | — | — |
| 16 | `dispatch_owner` | `text` | yes | — | — |
| 17 | `dispatch_token` | `uuid` | yes | — | — |
| 18 | `dispatch_fencing_token` | `bigint` | no | `0` | — |
| 19 | `dispatch_claimed_at` | `timestamp with time zone` | yes | — | — |
| 20 | `dispatch_expires_at` | `timestamp with time zone` | yes | — | — |
| 21 | `started_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |
| 22 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 23 | `completion_sha256` | `text` | yes | — | — |
| 24 | `provider_version` | `text` | no | `'unspecified'::text` | — |
| 25 | `retry_of_attempt_id` | `uuid` | yes | — | — |
| 26 | `root_attempt_id` | `uuid` | yes | — | — |
| 27 | `original_dispatch_token` | `uuid` | yes | — | — |
| 28 | `original_dispatch_fencing_token` | `bigint` | yes | — | — |
| 29 | `completion_artifact_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- unique (tenant_id, source_query_id, attempt_ordinal)
- 15 check constraints; see [details](source_provider_attempt.details.md)

## Relationships

12 outbound and 8 inbound foreign keys; full list in [details](source_provider_attempt.details.md).

## Indexes

5 indexes; see [details](source_provider_attempt.details.md).

## Triggers

8 triggers; see [details](source_provider_attempt.details.md).

## Row-level security

Enabled; 1 policies in [details](source_provider_attempt.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["source_provider_attempt"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_provider_attempt"]["Row"]`; update: `Database["evidence"]["Tables"]["source_provider_attempt"]["Update"]`

Defined in: `20260914010200_source_attempt_accounting.sql`.
