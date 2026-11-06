---
id: "rel:evidence.claim_evidence_link"
kind: table
schema: evidence
name: claim_evidence_link
domain: evidence
aliases: []
tokens: [evidence, claim_evidence_link, evidence.claim_evidence_link, id, claim_id, locator_id, role, support_verdict, authority_assessment, created_at, tenant_id, verification_contract_version]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"evidence\"][\"Tables\"][\"claim_evidence_link\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.claim_evidence_link

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `claim_id` | `uuid` | no | — | unique (claim_id, locator_id, role); FK → [`evidence.claim`](claim.md).id |
| 3 | `locator_id` | `uuid` | no | — | unique (claim_id, locator_id, role); FK → [`evidence.locator`](locator.md).id |
| 4 | `role` | `text` | no | — | unique (claim_id, locator_id, role) |
| 5 | `support_verdict` | `evidence.support_verdict` | yes | — | Legacy projection; new verification writes use evidence.claim_evidence_assessment. |
| 6 | `authority_assessment` | `jsonb` | yes | — | Legacy projection; new verification writes use evidence.claim_evidence_assessment. |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `tenant_id` | `uuid` | yes | — | unique (tenant_id, id) |
| 10 | `verification_contract_version` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (claim_id, locator_id, role)
- unique (tenant_id, id)
- check `claim_evidence_link_role_check`: `(role = ANY (ARRAY['supports'::text, 'contradicts'::text, 'qualifies'::text, 'context'::text]))`
- check `claim_evidence_link_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `claim_evidence_link_verification_contract_version_ck`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `claim_evidence_link_verification_tenant_ck`: `((verification_contract_version IS NULL) OR (tenant_id IS NOT NULL))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant) on delete cascade; `locator_id` → [`evidence.locator`](locator.md)`.id` (+tenant).
Inbound: none.

## Indexes

`claim_evidence_link_claim_id_locator_id_role_key` unique; `claim_evidence_link_locator_idx`; `claim_evidence_link_tenant_id_uq` unique

## Triggers

- `claim_evidence_link_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`, `verifier_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["claim_evidence_link"]["Insert"]`; row: `Database["evidence"]["Tables"]["claim_evidence_link"]["Row"]`; update: `Database["evidence"]["Tables"]["claim_evidence_link"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
