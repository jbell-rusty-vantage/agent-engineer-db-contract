---
id: "rel:access.guardian_link"
kind: table
schema: access
name: guardian_link
domain: access
lens: ours
aliases: []
tokens: [access, guardian_link, access.guardian_link, id, tenant_id, youth_id, guardian_id, state, consent_method, consent_evidence_artifact_id, help_scope, created_at, consented_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"guardian_link\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# access.guardian_link

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id) |
| 3 | `youth_id` | `uuid` | no | — | FK → `auth.users`.id |
| 4 | `guardian_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `state` | `text` | no | — | — |
| 6 | `consent_method` | `text` | yes | — | — |
| 7 | `consent_evidence_artifact_id` | `uuid` | yes | — | — |
| 8 | `help_scope` | `text[]` | no | `'{}'::text[]` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `consented_at` | `timestamp with time zone` | yes | — | — |
| 11 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `guardian_link_check`: `(youth_id <> guardian_id)`
- check `guardian_link_check1`: `(((state = 'consented'::text) = ((consented_at IS NOT NULL) AND (revoked_at IS NULL))) OR (state = ANY (ARRAY['revoked'::text, 'declined'::…`
- check `guardian_link_help_scope_check`: `(help_scope <@ ARRAY['progress'::text, 'results'::text, 'projects'::text, 'conversations'::text])`
- check `guardian_link_state_check`: `(state = ANY (ARRAY['invited'::text, 'consented'::text, 'declined'::text, 'revoked'::text]))`

## Relationships

Outbound: `guardian_id` → `auth.users``.id` on delete restrict; `tenant_id,consent_evidence_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `youth_id` → `auth.users``.id` on delete restrict.
Inbound: [`access.processing_authorization`](processing_authorization.md).guardian_link_id, [`learning.evidence_grant`](../learning/evidence_grant.md).guardian_link_id.

## Indexes

`guardian_link_active_uq` unique where `(state = ANY (ARRAY['invited'::text, 'consented'::text]))`; `guardian_link_guardian_id_fkey_ix`; `guardian_link_tenant_id_consent_evidence_artifact_id_fk_ix`; `guardian_link_tenant_id_id_key` unique; `guardian_link_youth_id_fkey_ix`

## Triggers

- `immutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

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
- Product operations (best effort): [`consent_guardian`](../../ops/consent_guardian.md), [`invite_guardian`](../../ops/invite_guardian.md).

## TypeScript

insert: `Database["access"]["Tables"]["guardian_link"]["Insert"]`; row: `Database["access"]["Tables"]["guardian_link"]["Row"]`; update: `Database["access"]["Tables"]["guardian_link"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
