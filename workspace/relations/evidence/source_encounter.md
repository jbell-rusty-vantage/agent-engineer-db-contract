---
id: "rel:evidence.source_encounter"
kind: table
schema: evidence
name: source_encounter
domain: evidence
aliases: [encounter]
tokens: [evidence, source_encounter, evidence.source_encounter, id, tenant_id, source_id, provider_result_id, capture_id, encounter_kind, encountered_at, details, receipt_id, source_provider_attempt_id, requested_url, final_url, redirect_urls, result_disposition, failure_code]
summary: "When a provider result was seen as a source, optionally with a capture."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_encounter\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.source_encounter

table in domain `evidence`.

> curated (model_assisted, unreviewed) — When a provider result was seen as a source, optionally with a capture.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `source_id` | `uuid` | no | — | FK → [`evidence.source`](source.md).id |
| 4 | `provider_result_id` | `uuid` | yes | — | FK → [`evidence.provider_result`](provider_result.md).id; _curated:_ The search hit that produced this encounter. |
| 5 | `capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](source_capture.md).id; _curated:_ Optional evidence.source_capture taken at encounter time. |
| 6 | `encounter_kind` | `text` | no | — | — |
| 7 | `encountered_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `details` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 10 | `source_provider_attempt_id` | `uuid` | yes | — | FK → [`evidence.source_provider_attempt`](source_provider_attempt.md).id |
| 11 | `requested_url` | `text` | yes | — | — |
| 12 | `final_url` | `text` | yes | — | — |
| 13 | `redirect_urls` | `text[]` | no | `'{}'::text[]` | — |
| 14 | `result_disposition` | `text` | yes | — | — |
| 15 | `failure_code` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `source_encounter_encounter_kind_check`: `(encounter_kind = ANY (ARRAY['discovered'::text, 'captured'::text, 'unchanged'::text, 'failed'::text, 'blocked'::text, 'revisited'::text]))`
- check `source_encounter_failure_code_check`: `((failure_code IS NULL) OR (failure_code ~ '^[A-Z][A-Z0-9_]{2,127}$'::text))`
- check `source_encounter_result_disposition_check`: `(result_disposition = ANY (ARRAY['selected'::text, 'omitted'::text, 'duplicate'::text, 'unreviewed'::text]))`

## Relationships

Outbound: `capture_id` → [`evidence.source_capture`](source_capture.md)`.id` (+tenant); `provider_result_id` → [`evidence.provider_result`](provider_result.md)`.id` (+tenant); `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `source_id` → [`evidence.source`](source.md)`.id` (+tenant); `source_provider_attempt_id` → [`evidence.source_provider_attempt`](source_provider_attempt.md)`.id` (+tenant).
Inbound: none.

## Indexes

`source_encounter_provider_attempt_idx` where `(source_provider_attempt_id IS NOT NULL)`; `source_encounter_tenant_id_id_key` unique

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

insert: `Database["evidence"]["Tables"]["source_encounter"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_encounter"]["Row"]`; update: `Database["evidence"]["Tables"]["source_encounter"]["Update"]`

## Examples

Captures for one source

```bash
knowledge db query evidence.captures_for_source --param source_id=0192e000-0000-7000-8000-000000000001
```
Encounters may exist before a capture_id is filled.

Defined in: `20260912010500_km_05_evidence.sql`.
