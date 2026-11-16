---
id: "rel:access.account_profile"
kind: table
schema: access
name: account_profile
domain: access
lens: ours
aliases: []
tokens: [access, account_profile, access.account_profile, tenant_id, principal_id, seq, age_band, jurisdiction, established_by, eligibility, policy_version_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"account_profile\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# access.account_profile

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `principal_id` | `uuid` | no | — | PK; FK → `auth.users`.id |
| 3 | `seq` | `integer` | no | — | PK |
| 4 | `age_band` | `text` | no | — | — |
| 5 | `jurisdiction` | `text` | no | — | — |
| 6 | `established_by` | `text` | no | — | — |
| 7 | `eligibility` | `text` | no | — | — |
| 8 | `policy_version_id` | `uuid` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, principal_id, seq)
- check `account_profile_age_band_check`: `(age_band = ANY (ARRAY['adult'::text, 'teen'::text, 'child'::text, 'unknown'::text]))`
- check `account_profile_eligibility_check`: `(eligibility = ANY (ARRAY['eligible'::text, 'pending_guardian_consent'::text, 'restricted'::text, 'suspended'::text]))`
- check `account_profile_established_by_check`: `(established_by = ANY (ARRAY['self_declared'::text, 'guardian'::text, 'verified'::text, 'admin'::text]))`
- check `account_profile_jurisdiction_check`: `(jurisdiction ~ '^[A-Z]{2}(-[A-Z0-9]{1,3})?$\|^ZZ$'::text)`
- check `account_profile_seq_check`: `(seq > 0)`

## Relationships

Outbound: `principal_id` → `auth.users``.id` on delete restrict; `tenant_id,policy_version_id` → [`access.policy_version`](policy_version.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`account_profile_principal_id_fkey_ix`; `account_profile_tenant_id_policy_version_id_fkey_ix`

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
- Product operations (best effort): [`set_account_profile`](../../ops/set_account_profile.md).

## TypeScript

insert: `Database["access"]["Tables"]["account_profile"]["Insert"]`; row: `Database["access"]["Tables"]["account_profile"]["Row"]`; update: `Database["access"]["Tables"]["account_profile"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
