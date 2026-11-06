---
id: "rel:evidence.provider_result"
kind: table
schema: evidence
name: provider_result
domain: evidence
aliases: [search hit]
tokens: [evidence, provider_result, evidence.provider_result, id, tenant_id, query_id, rank, source_id, url, title, snippet, payload, artifact_id, created_at, source_provider_attempt_id, provider_native_result_id, disposition]
summary: One ranked hit from a source_query; query_id points at the discovery query.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"provider_result\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.provider_result

table in domain `evidence`.

> curated (model_assisted, unreviewed) — One ranked hit from a source_query; query_id points at the discovery query.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `query_id` | `uuid` | no | — | FK → [`evidence.source_query`](source_query.md).id; _curated:_ Parent evidence.source_query. |
| 4 | `rank` | `integer` | no | — | _curated:_ Provider rank in that result page. |
| 5 | `source_id` | `uuid` | yes | — | FK → [`evidence.source`](source.md).id |
| 6 | `url` | `text` | yes | — | — |
| 7 | `title` | `text` | yes | — | — |
| 8 | `snippet` | `text` | yes | — | — |
| 9 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `source_provider_attempt_id` | `uuid` | yes | — | FK → [`evidence.source_provider_attempt`](source_provider_attempt.md).id |
| 13 | `provider_native_result_id` | `text` | yes | — | — |
| 14 | `disposition` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `provider_result_disposition_check`: `(disposition = ANY (ARRAY['selected'::text, 'omitted'::text, 'duplicate'::text, 'unreviewed'::text]))`
- check `provider_result_rank_check`: `(rank > 0)`

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `query_id` → [`evidence.source_query`](source_query.md)`.id` (+tenant); `source_id` → [`evidence.source`](source.md)`.id` (+tenant); `source_provider_attempt_id` → [`evidence.source_provider_attempt`](source_provider_attempt.md)`.id` (+tenant).
Inbound: [`evidence.source_encounter`](source_encounter.md).provider_result_id.

## Indexes

`provider_result_attempt_rank_uq` unique where `(source_provider_attempt_id IS NOT NULL)`; `provider_result_legacy_query_rank_uq` unique where `(source_provider_attempt_id IS NULL)`; `provider_result_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_557024633d24e360dd44d7c6` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_d03440088769e131ad6b502b` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
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

insert: `Database["evidence"]["Tables"]["provider_result"]["Insert"]`; row: `Database["evidence"]["Tables"]["provider_result"]["Row"]`; update: `Database["evidence"]["Tables"]["provider_result"]["Update"]`

## Examples

Sources for a domain

```bash
knowledge db query evidence.sources_by_domain --param domain=openai.com --param limit=50
```
Walk source_query → provider_result → source_encounter to the source row.

Defined in: `20260912010500_km_05_evidence.sql`.
