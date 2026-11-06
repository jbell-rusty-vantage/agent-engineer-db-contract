---
id: "rel:evidence.source_capture"
kind: table
schema: evidence
name: source_capture
domain: evidence
aliases: [capture]
tokens: [evidence, source_capture, evidence.source_capture, id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, http_headers, context, produced_by_attempt_id, knowledge_operation_id]
summary: "One immutable capture of a source, hashed and stored as an artifact."
summary_basis: curated
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_capture\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.source_capture

table in domain `evidence`.

> curated (model_assisted, unreviewed) — One immutable capture of a source, hashed and stored as an artifact.

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

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `source_capture_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `source_capture_exactly_one_producer_ck`: `(num_nonnulls(produced_by_attempt_id, knowledge_operation_id) = 1)`

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `capture_method` → [`evidence.capture_method`](capture_method.md)`.code`; `tenant_id,knowledge_operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `produced_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `source_id` → [`evidence.source`](source.md)`.id` (+tenant).
Inbound: [`content.document_version_source_capture`](../content/document_version_source_capture.md).source_capture_id, [`content.transformation_input`](../content/transformation_input.md).source_capture_id, [`corpus.repository_file`](../corpus/repository_file.md).capture_id, [`corpus.repository_revision`](../corpus/repository_revision.md).capture_id, [`evaluation.eval_case_provenance`](../evaluation/eval_case_provenance.md).source_capture_id, [`evidence.locator`](locator.md).capture_id, [`evidence.source`](source.md).last_capture_id, [`evidence.source_encounter`](source_encounter.md).capture_id, [`orchestration.verification_structured_extraction`](../orchestration/verification_structured_extraction.md).capture_id.

## Indexes

`source_capture_artifact_uq` unique; `source_capture_knowledge_operation_idx` where `(knowledge_operation_id IS NOT NULL)`; `source_capture_sha_idx`; `source_capture_source_idx`; `source_capture_tenant_id_uq` unique

## Triggers

- `artifact_retirement_c08714869d5afff48b340d4a` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_f3374d238fdcd1b81b8410c2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `source_capture_artifact_binding` → [`evidence.validate_capture_artifact`](../../functions/evidence/validate_capture_artifact.md)
- `source_capture_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Named queries: `q:evidence.captures_for_source`.
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
