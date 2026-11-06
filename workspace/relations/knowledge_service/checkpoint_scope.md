---
id: "rel:knowledge_service.checkpoint_scope"
kind: table
schema: knowledge_service
name: checkpoint_scope
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, checkpoint_scope, knowledge_service.checkpoint_scope, tenant_id, id, scope, parent_scope_id, head_checkpoint_id, revision, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"checkpoint_scope\"][\"Row\"]"
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.checkpoint_scope

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `id` | `uuid` | no | — | PK |
| 3 | `scope` | `jsonb` | no | — | — |
| 4 | `parent_scope_id` | `uuid` | yes | — | — |
| 5 | `head_checkpoint_id` | `uuid` | yes | — | — |
| 6 | `revision` | `bigint` | no | `0` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, id)
- check `checkpoint_scope_check`: `((head_checkpoint_id IS NULL) = (revision = 0))`
- check `checkpoint_scope_check1`: `(NOT ((scope ->> 'tenantId'::text) IS DISTINCT FROM (tenant_id)::text))`
- check `checkpoint_scope_check2`: `(NOT ((scope ->> 'parentScopeId'::text) IS DISTINCT FROM (parent_scope_id)::text))`
- check `checkpoint_scope_revision_check`: `(revision >= 0)`
- check `checkpoint_scope_scope_check`: `(jsonb_typeof(scope) = 'object'::text)`
- check `checkpoint_scope_scope_check1`: `(scope ?& ARRAY['tenantId'::text, 'runId'::text, 'producerAttemptId'::text, 'sessionId'::text, 'sandboxId'::text, 'namespace'::text])`

## Relationships

Outbound: `tenant_id,id,head_checkpoint_id` → [`knowledge_service.scoped_checkpoint`](scoped_checkpoint.md)`.tenant_id,scope_id,id` (deferrable); `tenant_id,parent_scope_id` → [`knowledge_service.checkpoint_scope`](checkpoint_scope.md)`.tenant_id,id`.
Inbound: [`knowledge_service.checkpoint_scope`](checkpoint_scope.md).parent_scope_id, [`knowledge_service.scoped_checkpoint`](scoped_checkpoint.md).scope_id.

## Indexes

_None._

## Triggers

- `checkpoint_scope_guard` → [`knowledge_service.guard_checkpoint_scope`](../../functions/knowledge_service/guard_checkpoint_scope.md)

## Row-level security

Enabled.
- `checkpoint_scope_tenant` (ALL) for `executor_service`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["checkpoint_scope"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["checkpoint_scope"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["checkpoint_scope"]["Update"]`

Defined in: `20260914010500_scoped_checkpoints.sql`.
