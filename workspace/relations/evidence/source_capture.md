---
id: "rel:evidence.source_capture"
kind: table
schema: evidence
name: source_capture
domain: evidence
lens: evidence
aliases: [capture]
tokens: [evidence, source_capture, evidence.source_capture, id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, http_headers, context, produced_by_attempt_id, knowledge_operation_id, acquisition_fetch_id]
summary: "One immutable capture of a source, hashed and stored as an artifact; points at the acquisition fetch that produced it."
summary_basis: curated
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_capture\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# evidence.source_capture

table in domain `evidence`, lens `evidence`.

> curated (model_assisted, unreviewed) — One immutable capture of a source, hashed and stored as an artifact; points at the acquisition fetch that produced it.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `source_id` | `uuid` | no | — | FK → [`evidence.source`](source.md).id |
| 4 | `artifact_id` | `uuid` | no | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 5 | `content_sha256` | `text` | no | — | _curated:_ Digest of captured bytes. |
| 6 | `media_type` | `text` | no | — | — |
| 7 | `captured_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `capture_method` | `text` | no | — | FK → [`evidence.capture_method`](capture_method.md).code; _curated:_ FK to evidence.capture_method. |
| 9 | `capture_method_version` | `text` | no | — | — |
| 10 | `request_url` | `text` | yes | — | — |
| 11 | `http_status` | `integer` | yes | — | — |
| 12 | `http_headers` | `jsonb` | yes | — | — |
| 13 | `context` | `jsonb` | no | `'{}'::jsonb` | — |
| 14 | `produced_by_attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 15 | `knowledge_operation_id` | `uuid` | yes | — | Standalone knowledge-service producer. Mutually exclusive with produced_by_attempt_id; Mission Control operations retain attempt lineage through knowledge_service.operation. |
| 16 | `acquisition_fetch_id` | `uuid` | yes | — | FK → [`acquisition.fetch`](../acquisition/fetch.md).id; Producer when the bytes came from a product/harness fetch (acquisition.fetch) rather than a mission attempt or a KS operation.; _curated:_ Producer when the bytes came from a product/harness fetch (acquisition.fetch) rather than a mission attempt or a KS operation. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `source_capture_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `source_capture_exactly_one_producer_ck`: `(num_nonnulls(produced_by_attempt_id, knowledge_operation_id, acquisition_fetch_id) = 1)`

## Relationships

9 outbound and 17 inbound foreign keys; full list in [details](source_capture.details.md).

## Indexes

5 indexes; see [details](source_capture.details.md).

## Triggers

4 triggers; see [details](source_capture.details.md).

## Row-level security

Enabled; 2 policies in [details](source_capture.details.md).

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Named queries: `q:evidence.captures_for_source`, `q:facts.locators`.
- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["source_capture"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_capture"]["Row"]`; update: `Database["evidence"]["Tables"]["source_capture"]["Update"]`

## Examples

Captures for one source

```bash
knowledge db query evidence.captures_for_source --param source_id=0192e000-0000-7000-8000-000000000001
```
Insert-only.

Defined in: `20260826000300_evidence_core.sql`.
