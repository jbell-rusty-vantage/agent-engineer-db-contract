---
id: "rel:evidence.source_result_selection"
kind: table
schema: evidence
name: source_result_selection
domain: evidence
aliases: []
tokens: [evidence, source_result_selection, evidence.source_result_selection, tenant_id, attempt_id, revision, rank, disposition, reason, idempotency_key, selection_artifact_id, created_at]
summary: Append-only research inclusion revisions per provider result; reads choose the latest recorded rank decision without redispatching discovery.
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_result_selection\"][\"Row\"]"
defined_in: ["20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.source_result_selection

table in domain `evidence` — Append-only research inclusion revisions per provider result; reads choose the latest recorded rank decision without redispatching discovery..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `attempt_id` | `uuid` | no | — | PK |
| 3 | `revision` | `bigint` | no | — | PK |
| 4 | `rank` | `integer` | no | — | PK |
| 5 | `disposition` | `text` | no | — | — |
| 6 | `reason` | `text` | no | — | — |
| 7 | `idempotency_key` | `text` | no | — | — |
| 8 | `selection_artifact_id` | `uuid` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, attempt_id, rank, revision)
- check `source_result_selection_disposition_check`: `(disposition = ANY (ARRAY['selected'::text, 'omitted'::text, 'duplicate'::text]))`
- check `source_result_selection_rank_check`: `(rank > 0)`
- check `source_result_selection_reason_check`: `((length(btrim(reason)) >= 1) AND (length(btrim(reason)) <= 2000))`
- check `source_result_selection_revision_check`: `(revision > 0)`

## Relationships

Outbound: `tenant_id,attempt_id` → [`evidence.source_provider_attempt`](source_provider_attempt.md)`.tenant_id,id`; `tenant_id,attempt_id,revision,idempotency_key,selection_artifact_id` → [`evidence.source_selection_revision`](source_selection_revision.md)`.tenant_id,attempt_id,revision,idempotency_key,selection_artifact_id`; `tenant_id,selection_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_7b285fe337618c030875f90a` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `source_result_selection_admission` → [`evidence.guard_source_result_selection`](../../functions/evidence/guard_source_result_selection.md)
- `source_result_selection_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `source_result_selection_tenant` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["source_result_selection"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_result_selection"]["Row"]`; update: `Database["evidence"]["Tables"]["source_result_selection"]["Update"]`

Defined in: `20260914010400_source_attempt_recovery.sql`.
