---
id: "rel:evidence.extraction_record"
kind: table
schema: evidence
name: extraction_record
domain: evidence
lens: evidence
aliases: [extraction, act 2]
tokens: [evidence, extraction_record, evidence.extraction_record, id, tenant_id, extraction_run_id, record_kind, payload, locator_id, claim_id, confidence, created_at, document_node_id, mapping_id]
summary: Faithful extraction anchored on a typed unit and interpreted through an assertion mapping.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"extraction_record\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# evidence.extraction_record

table in domain `evidence`, lens `evidence`.

> curated (model_assisted, unreviewed) — Faithful extraction anchored on a typed unit and interpreted through an assertion mapping.

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
| 10 | `document_node_id` | `uuid` | yes | — | Act 2 anchor: the typed unit this faithful extraction reads (chunks are derived; units are stable).; _curated:_ Act 2 anchor: the typed unit this extraction reads (units are stable; chunks are derived). |
| 11 | `mapping_id` | `uuid` | yes | — | FK → [`content.unit_assertion_mapping`](../content/unit_assertion_mapping.md).id; Act 3 template used to interpret this unit into a claim (content.unit_assertion_mapping).; _curated:_ Act 3 template used to interpret this unit into a claim (content.unit_assertion_mapping). |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `extraction_record_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `extraction_run_id` → [`evidence.extraction_run`](extraction_run.md)`.id` (+tenant); `locator_id` → [`evidence.locator`](locator.md)`.id` (+tenant); `mapping_id` → [`content.unit_assertion_mapping`](../content/unit_assertion_mapping.md)`.id`; `tenant_id,document_node_id` → [`content.document_node`](../content/document_node.md)`.tenant_id,id` (deferrable).
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

- Named queries: `q:evidence.claim`, `q:evidence.verified_claims`, `q:facts.locators`.
- Exposed through: [`api.claim_candidates`](../api/claim_candidates.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["extraction_record"]["Insert"]`; row: `Database["evidence"]["Tables"]["extraction_record"]["Row"]`; update: `Database["evidence"]["Tables"]["extraction_record"]["Update"]`

## Examples

Unit behind a current fact

```bash
knowledge db query facts.locators --param entity_id=0192b000-0000-7000-8000-000000000001 --param scope_key=null --param stream_kind=offering_price
```
document_node_id, unit_kind and logical_key columns come from this anchor.

Defined in: `20260912010500_km_05_evidence.sql`.
