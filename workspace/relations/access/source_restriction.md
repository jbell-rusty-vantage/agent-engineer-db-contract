---
id: "rel:access.source_restriction"
kind: table
schema: access
name: source_restriction
domain: access
lens: ours
aliases: []
tokens: [access, source_restriction, access.source_restriction, id, tenant_id, source_id, capture_id, artifact_id, kind, effect, reason, decided_by, created_at, lifted_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"source_restriction\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# access.source_restriction

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id) |
| 3 | `source_id` | `uuid` | yes | — | — |
| 4 | `capture_id` | `uuid` | yes | — | — |
| 5 | `artifact_id` | `uuid` | yes | — | — |
| 6 | `kind` | `text` | no | — | — |
| 7 | `effect` | `text` | no | — | — |
| 8 | `reason` | `text` | no | — | — |
| 9 | `decided_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `lifted_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `source_restriction_check`: `(num_nonnulls(source_id, capture_id, artifact_id) = 1)`
- check `source_restriction_effect_check`: `(effect = ANY (ARRAY['deny_bytes'::text, 'deny_all'::text, 'reference_only'::text, 'hold_no_delete'::text]))`
- check `source_restriction_kind_check`: `(kind = ANY (ARRAY['takedown'::text, 'license_change'::text, 'legal_hold'::text, 'access_lost'::text, 'safety'::text]))`
- check `source_restriction_reason_check`: `product.nonblank(reason)`

## Relationships

Outbound: `decided_by` → `auth.users``.id` on delete restrict; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`source_restriction_decided_by_fkey_ix`; `source_restriction_tenant_id_artifact_id_fkey_ix`; `source_restriction_tenant_id_capture_id_fkey_ix`; `source_restriction_tenant_id_id_key` unique

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
- Via functions (best effort): [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`restrict_source`](../../ops/restrict_source.md).

## TypeScript

insert: `Database["access"]["Tables"]["source_restriction"]["Insert"]`; row: `Database["access"]["Tables"]["source_restriction"]["Row"]`; update: `Database["access"]["Tables"]["source_restriction"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
