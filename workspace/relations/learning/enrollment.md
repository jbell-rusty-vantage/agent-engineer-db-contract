---
id: "rel:learning.enrollment"
kind: table
schema: learning
name: enrollment
domain: learning
lens: ours
aliases: []
tokens: [learning, enrollment, learning.enrollment, id, tenant_id, workspace_id, learner_id, source_workspace_id, distribution_id, update_policy, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"enrollment\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# learning.enrollment

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, learner_id, distribution_id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, learner_id, distribution_id) |
| 4 | `learner_id` | `uuid` | no | — | unique (tenant_id, workspace_id, learner_id, distribution_id); FK → `auth.users`.id |
| 5 | `source_workspace_id` | `uuid` | no | — | — |
| 6 | `distribution_id` | `uuid` | no | — | unique (tenant_id, workspace_id, learner_id, distribution_id) |
| 7 | `update_policy` | `text` | no | `'manual'::text` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, learner_id, distribution_id)
- check `enrollment_update_policy_check`: `(update_policy = ANY (ARRAY['manual'::text, 'auto_compatible'::text]))`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,source_workspace_id,distribution_id` → [`authoring.distribution`](../authoring/distribution.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,enrollment_id, [`learning.equivalence_request`](equivalence_request.md).workspace_id,enrollment_id, [`learning.evidence_grant`](evidence_grant.md).workspace_id,enrollment_id, [`learning.release_adoption`](release_adoption.md).workspace_id,enrollment_id.

## Indexes

`enrollment_learner_id_fkey_ix`; `enrollment_tenant_id_id_key` unique; `enrollment_tenant_id_source_workspace_id_distribution_i_ix`; `enrollment_tenant_id_workspace_id_id_key` unique; `enrollment_tenant_id_workspace_id_learner_id_distribution_i_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)

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
- Product operations (best effort): [`enroll`](../../ops/enroll.md).

## TypeScript

insert: `Database["learning"]["Tables"]["enrollment"]["Insert"]`; row: `Database["learning"]["Tables"]["enrollment"]["Row"]`; update: `Database["learning"]["Tables"]["enrollment"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
