---
id: "rel:evidence.extraction_record"
kind: table
schema: evidence
name: extraction_record
domain: evidence
aliases: []
tokens: [evidence, extraction_record, evidence.extraction_record, id, tenant_id, extraction_run_id, record_kind, payload, locator_id, claim_id, confidence, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"extraction_record\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.extraction_record

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `extraction_run_id` | `uuid` | no | — | FK → [`evidence.extraction_run`](extraction_run.md).id |
| 4 | `record_kind` | `text` | no | — | — |
| 5 | `payload` | `jsonb` | no | — | — |
| 6 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](locator.md).id |
| 7 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](claim.md).id |
| 8 | `confidence` | `numeric` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `extraction_record_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `extraction_run_id` → [`evidence.extraction_run`](extraction_run.md)`.id` (+tenant); `locator_id` → [`evidence.locator`](locator.md)`.id` (+tenant).
Inbound: [`evidence.attribution`](attribution.md).extraction_record_id.

## Indexes

`extraction_record_tenant_id_id_key` unique

## Triggers

- `km_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["extraction_record"]["Insert"]`; row: `Database["evidence"]["Tables"]["extraction_record"]["Row"]`; update: `Database["evidence"]["Tables"]["extraction_record"]["Update"]`

Defined in: `20260912010500_km_05_evidence.sql`.
