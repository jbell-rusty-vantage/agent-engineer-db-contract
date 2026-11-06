---
id: "rel:orchestration.verification_structured_extraction_publication"
kind: table
schema: orchestration
name: verification_structured_extraction_publication
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_structured_extraction_publication, orchestration.verification_structured_extraction_publication, tenant_id, operation_id, publication_artifact_id, publication_sha256, seal_payload_sha256, provider_call_sha256, published_at]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_structured_extraction_publication\"][\"Row\"]"
defined_in: ["20260906031900_verification_structured_extraction_publication.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_structured_extraction_publication

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `operation_id` | `uuid` | no | — | PK |
| 3 | `publication_artifact_id` | `uuid` | no | — | — |
| 4 | `publication_sha256` | `text` | no | — | — |
| 5 | `seal_payload_sha256` | `text` | no | — | — |
| 6 | `provider_call_sha256` | `text` | no | — | — |
| 7 | `published_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, operation_id)
- check `verification_structured_extraction_p_provider_call_sha256_check`: `(provider_call_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_pu_seal_payload_sha256_check`: `(seal_payload_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_pub_publication_sha256_check`: `(publication_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,publication_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_id` → [`orchestration.verification_structured_extraction`](verification_structured_extraction.md)`.tenant_id,operation_id`; `tenant_id,operation_id` → [`orchestration.verification_structured_extraction_execution`](verification_structured_extraction_execution.md)`.tenant_id,operation_id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_16f6cc9635b6eced06e0c955` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_structured_extraction_publication_guard` → [`orchestration.guard_verification_structured_extraction_publication`](../../functions/orchestration/guard_verification_structured_extraction_publication.md)
- `verification_structured_extraction_publication_source_guard` → [`orchestration.guard_structured_extraction_source_custody`](../../functions/orchestration/guard_structured_extraction_source_custody.md)

## Row-level security

Enabled.
- `verification_structured_extraction_publication_reader` (SELECT) for `app_reader`: `(tenant_id = util.current_tenant_id())`
- `verification_structured_extraction_publication_worker` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_structured_extraction_publication"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_structured_extraction_publication"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_structured_extraction_publication"]["Update"]`

Defined in: `20260906031900_verification_structured_extraction_publication.sql`.
