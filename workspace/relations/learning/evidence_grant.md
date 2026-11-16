---
id: "rel:learning.evidence_grant"
kind: table
schema: learning
name: evidence_grant
domain: learning
lens: ours
aliases: []
tokens: [learning, evidence_grant, learning.evidence_grant, id, tenant_id, workspace_id, learner_id, grantee_id, scope_kind, enrollment_id, includes, guardian_link_id, granted_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"evidence_grant\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# learning.evidence_grant

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `grantee_id` | `uuid` | no | — | FK → `auth.users`.id |
| 6 | `scope_kind` | `text` | no | — | — |
| 7 | `enrollment_id` | `uuid` | yes | — | — |
| 8 | `includes` | `text[]` | no | — | — |
| 9 | `guardian_link_id` | `uuid` | yes | — | — |
| 10 | `granted_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `evidence_grant_check`: `((scope_kind = 'enrollment'::text) = (enrollment_id IS NOT NULL))`
- check `evidence_grant_check1`: `(learner_id <> grantee_id)`
- check `evidence_grant_includes_check`: `((cardinality(includes) > 0) AND (includes <@ ARRAY['progress'::text, 'results'::text, 'submissions'::text, 'mastery'::text, 'goals'::text]…`
- check `evidence_grant_scope_kind_check`: `(scope_kind = ANY (ARRAY['enrollment'::text, 'all_learning'::text]))`

## Relationships

Outbound: `grantee_id` → `auth.users``.id` on delete restrict; `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,guardian_link_id` → [`access.guardian_link`](../access/guardian_link.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id` → [`learning.enrollment`](enrollment.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`evidence_grant_grantee_id_fkey_ix`; `evidence_grant_learner_id_fkey_ix`; `evidence_grant_tenant_id_guardian_link_id_fkey_ix`; `evidence_grant_tenant_id_workspace_id_enrollment_id_fke_ix`; `evidence_grant_tenant_id_workspace_id_id_key` unique

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
- Product operations (best effort): [`grant_evidence`](../../ops/grant_evidence.md).

## TypeScript

insert: `Database["learning"]["Tables"]["evidence_grant"]["Insert"]`; row: `Database["learning"]["Tables"]["evidence_grant"]["Row"]`; update: `Database["learning"]["Tables"]["evidence_grant"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
