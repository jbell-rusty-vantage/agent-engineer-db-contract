---
id: "rel:access.provided_credential"
kind: table
schema: access
name: provided_credential
domain: access
lens: ours
aliases: []
tokens: [access, provided_credential, access.provided_credential, id, tenant_id, principal_id, provider_key, secret_handle, spend_limit_usd, period, issued_at, expires_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"provided_credential\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# access.provided_credential

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id) |
| 3 | `principal_id` | `uuid` | no | — | FK → `auth.users`.id |
| 4 | `provider_key` | `text` | no | — | — |
| 5 | `secret_handle` | `text` | no | — | — |
| 6 | `spend_limit_usd` | `numeric(12,2)` | no | — | — |
| 7 | `period` | `text` | no | — | — |
| 8 | `issued_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `expires_at` | `timestamp with time zone` | no | — | — |
| 10 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `provided_credential_check`: `(expires_at > issued_at)`
- check `provided_credential_period_check`: `(period = ANY (ARRAY['once'::text, 'day'::text, 'month'::text]))`
- check `provided_credential_provider_key_check`: `(provider_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'::text)`
- check `provided_credential_secret_handle_check`: `((secret_handle ~ '^[a-z0-9][a-z0-9_./:-]{2,200}$'::text) AND (secret_handle !~ '(sk-\|ghp_\|xox[bp]-\|AKIA\|-----BEGIN)'::text))`
- check `provided_credential_spend_limit_usd_check`: `(spend_limit_usd >= (0)::numeric)`

## Relationships

Outbound: `principal_id` → `auth.users``.id` on delete restrict.
Inbound: none.

## Indexes

`provided_credential_principal_id_fkey_ix`; `provided_credential_tenant_id_id_key` unique

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
- Product operations (best effort): [`issue_provided_credential`](../../ops/issue_provided_credential.md).

## TypeScript

insert: `Database["access"]["Tables"]["provided_credential"]["Insert"]`; row: `Database["access"]["Tables"]["provided_credential"]["Row"]`; update: `Database["access"]["Tables"]["provided_credential"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
