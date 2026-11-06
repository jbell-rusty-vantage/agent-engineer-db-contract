---
id: "rel:evidence.attribution"
kind: table
schema: evidence
name: attribution
domain: evidence
aliases: []
tokens: [evidence, attribution, evidence.attribution, id, tenant_id, source_id, claim_id, entity_id, role, locator_id, extraction_record_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"attribution\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.attribution

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `source_id` | `uuid` | yes | — | FK → [`evidence.source`](source.md).id |
| 4 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](claim.md).id |
| 5 | `entity_id` | `uuid` | no | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 6 | `role` | `text` | no | — | — |
| 7 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](locator.md).id |
| 8 | `extraction_record_id` | `uuid` | yes | — | FK → [`evidence.extraction_record`](extraction_record.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `attribution_check`: `(num_nonnulls(source_id, claim_id) >= 1)`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `extraction_record_id` → [`evidence.extraction_record`](extraction_record.md)`.id` (+tenant); `locator_id` → [`evidence.locator`](locator.md)`.id` (+tenant); `source_id` → [`evidence.source`](source.md)`.id` (+tenant).
Inbound: none.

## Indexes

`attribution_tenant_id_id_key` unique

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

insert: `Database["evidence"]["Tables"]["attribution"]["Insert"]`; row: `Database["evidence"]["Tables"]["attribution"]["Row"]`; update: `Database["evidence"]["Tables"]["attribution"]["Update"]`

Defined in: `20260912010500_km_05_evidence.sql`.
