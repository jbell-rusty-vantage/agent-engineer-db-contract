---
id: "rel:learning.environment_session"
kind: table
schema: learning
name: environment_session
domain: learning
lens: ours
aliases: []
tokens: [learning, environment_session, learning.environment_session, id, tenant_id, workspace_id, learner_id, project_work_id, spec_revision_id, provider, adapter, status, key_handles, spend_limit_usd, spent_usd, external_ref, created_at, expires_at, ended_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"environment_session\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# learning.environment_session

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `project_work_id` | `uuid` | yes | — | — |
| 6 | `spec_revision_id` | `uuid` | yes | — | — |
| 7 | `provider` | `text` | no | — | — |
| 8 | `adapter` | `text` | yes | — | — |
| 9 | `status` | `text` | no | — | — |
| 10 | `key_handles` | `jsonb` | no | `'[]'::jsonb` | — |
| 11 | `spend_limit_usd` | `numeric(12,2)` | yes | — | — |
| 12 | `spent_usd` | `numeric(12,4)` | no | `0` | — |
| 13 | `external_ref` | `jsonb` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `expires_at` | `timestamp with time zone` | yes | — | — |
| 16 | `ended_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `environment_session_check`: `((provider <> ALL (ARRAY['browser_runtime'::text, 'cloud_sandbox'::text])) OR (adapter IS NOT NULL))`
- check `environment_session_provider_check`: `(provider = ANY (ARRAY['local_harness'::text, 'browser_runtime'::text, 'cloud_sandbox'::text, 'external'::text]))`
- check `environment_session_status_check`: `(status = ANY (ARRAY['requested'::text, 'provisioning'::text, 'ready'::text, 'stopped'::text, 'expired'::text, 'failed'::text]))`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,spec_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,project_work_id` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,environment_session_id.

## Indexes

`environment_session_learner_id_fkey_ix`; `environment_session_tenant_id_spec_revision_id_fkey_ix`; `environment_session_tenant_id_workspace_id_id_key` unique; `environment_session_tenant_id_workspace_id_project_work_ix`

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`request_environment`](../../ops/request_environment.md).

## TypeScript

insert: `Database["learning"]["Tables"]["environment_session"]["Insert"]`; row: `Database["learning"]["Tables"]["environment_session"]["Row"]`; update: `Database["learning"]["Tables"]["environment_session"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
