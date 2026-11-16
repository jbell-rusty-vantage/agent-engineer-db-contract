---
id: "rel:access.processing_authorization"
kind: table
schema: access
name: processing_authorization
domain: access
lens: ours
aliases: []
tokens: [access, processing_authorization, access.processing_authorization, id, tenant_id, principal_id, processor_class, processor_key, purpose, basis, guardian_link_id, policy_version_id, granted_by, granted_at, withdrawn_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"processing_authorization\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# access.processing_authorization

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id) |
| 3 | `principal_id` | `uuid` | no | — | FK → `auth.users`.id |
| 4 | `processor_class` | `text` | no | — | — |
| 5 | `processor_key` | `text` | no | — | — |
| 6 | `purpose` | `text` | no | — | — |
| 7 | `basis` | `text` | no | — | — |
| 8 | `guardian_link_id` | `uuid` | yes | — | — |
| 9 | `policy_version_id` | `uuid` | no | — | — |
| 10 | `granted_by` | `uuid` | no | — | FK → `auth.users`.id |
| 11 | `granted_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `withdrawn_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `processing_authorization_basis_check`: `(basis = ANY (ARRAY['self'::text, 'guardian'::text]))`
- check `processing_authorization_check`: `((basis = 'guardian'::text) = (guardian_link_id IS NOT NULL))`
- check `processing_authorization_processor_class_check`: `(processor_class = ANY (ARRAY['llm_inference'::text, 'embedding'::text, 'connector'::text, 'analytics'::text, 'third_party_share'::text]))`
- check `processing_authorization_processor_key_check`: `(processor_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'::text)`
- check `processing_authorization_purpose_check`: `product.nonblank(purpose)`

## Relationships

Outbound: `granted_by` → `auth.users``.id` on delete restrict; `principal_id` → `auth.users``.id` on delete restrict; `tenant_id,guardian_link_id` → [`access.guardian_link`](guardian_link.md)`.tenant_id,id` on delete restrict; `tenant_id,policy_version_id` → [`access.policy_version`](policy_version.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`processing_authorization_active_uq` unique where `(withdrawn_at IS NULL)`; `processing_authorization_granted_by_fkey_ix`; `processing_authorization_principal_id_fkey_ix`; `processing_authorization_tenant_id_guardian_link_id_fke_ix`; `processing_authorization_tenant_id_id_key` unique; `processing_authorization_tenant_id_policy_version_id_fk_ix`

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
- Product operations (best effort): [`authorize_processing`](../../ops/authorize_processing.md).

## TypeScript

insert: `Database["access"]["Tables"]["processing_authorization"]["Insert"]`; row: `Database["access"]["Tables"]["processing_authorization"]["Row"]`; update: `Database["access"]["Tables"]["processing_authorization"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
