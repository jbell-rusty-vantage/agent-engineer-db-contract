---
id: "rel:knowledge_service.checkpoint_artifact_reference"
kind: table
schema: knowledge_service
name: checkpoint_artifact_reference
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, checkpoint_artifact_reference, knowledge_service.checkpoint_artifact_reference, tenant_id, checkpoint_id, artifact_id]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"checkpoint_artifact_reference\"][\"Row\"]"
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.checkpoint_artifact_reference

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `checkpoint_id` | `uuid` | no | — | PK |
| 3 | `artifact_id` | `uuid` | no | — | PK |

## Constraints

- PK (tenant_id, checkpoint_id, artifact_id)

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`; `tenant_id,checkpoint_id` → [`knowledge_service.scoped_checkpoint`](scoped_checkpoint.md)`.tenant_id,id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_b979b881fc8098870278fb13` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `checkpoint_artifact_reference_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `checkpoint_reference_admission` → [`knowledge_service.guard_checkpoint_reference`](../../functions/knowledge_service/guard_checkpoint_reference.md)

## Row-level security

Enabled.
- `checkpoint_reference_tenant` (ALL) for `executor_service`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["checkpoint_artifact_reference"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["checkpoint_artifact_reference"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["checkpoint_artifact_reference"]["Update"]`

Defined in: `20260914010500_scoped_checkpoints.sql`.
