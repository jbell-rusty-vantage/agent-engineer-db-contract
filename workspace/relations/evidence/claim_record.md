---
id: "rel:evidence.claim_record"
kind: table
schema: evidence
name: claim_record
domain: evidence
aliases: []
tokens: [evidence, claim_record, evidence.claim_record, tenant_id, claim_id, record_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"claim_record\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.claim_record

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `claim_id` | `uuid` | no | — | PK; FK → [`evidence.claim`](claim.md).id |
| 3 | `record_id` | `uuid` | no | — | PK; FK → [`knowledge.record`](../knowledge/record.md).id |

## Constraints

- PK (tenant_id, claim_id, record_id)

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `record_id` → [`knowledge.record`](../knowledge/record.md)`.id` (+tenant).
Inbound: none.

## Indexes

_None._

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

insert: `Database["evidence"]["Tables"]["claim_record"]["Insert"]`; row: `Database["evidence"]["Tables"]["claim_record"]["Row"]`; update: `Database["evidence"]["Tables"]["claim_record"]["Update"]`

Defined in: `20260912010500_km_05_evidence.sql`.
