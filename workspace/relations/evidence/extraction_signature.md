---
id: "rel:evidence.extraction_signature"
kind: table
schema: evidence
name: extraction_signature
domain: evidence
aliases: []
tokens: [evidence, extraction_signature, evidence.extraction_signature, id, locator_id, signature_sha256, produced_by_attempt_id, created_at, tenant_id, verification_contract_version]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"evidence\"][\"Tables\"][\"extraction_signature\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.extraction_signature

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `locator_id` | `uuid` | no | — | unique (locator_id, signature_sha256); FK → [`evidence.locator`](locator.md).id |
| 3 | `signature_sha256` | `text` | no | — | unique (locator_id, signature_sha256) |
| 4 | `produced_by_attempt_id` | `uuid` | no | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 5 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 6 | `tenant_id` | `uuid` | yes | — | unique (tenant_id, id) |
| 7 | `verification_contract_version` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (locator_id, signature_sha256)
- unique (tenant_id, id)
- check `extraction_signature_signature_sha256_check`: `(signature_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `extraction_signature_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `extraction_signature_verification_contract_version_ck`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `extraction_signature_verification_tenant_ck`: `((verification_contract_version IS NULL) OR (tenant_id IS NOT NULL))`

## Relationships

Outbound: `locator_id` → [`evidence.locator`](locator.md)`.id` (+tenant); `produced_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant).
Inbound: none.

## Indexes

`extraction_signature_locator_id_signature_sha256_key` unique; `extraction_signature_tenant_id_uq` unique

## Triggers

- `extraction_signature_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["evidence"]["Tables"]["extraction_signature"]["Insert"]`; row: `Database["evidence"]["Tables"]["extraction_signature"]["Row"]`; update: `Database["evidence"]["Tables"]["extraction_signature"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
