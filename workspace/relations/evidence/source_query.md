---
id: "rel:evidence.source_query"
kind: table
schema: evidence
name: source_query
domain: evidence
aliases: [search query]
tokens: [evidence, source_query, evidence.source_query, id, tenant_id, provider_code, query_text, purpose, parameters, response_artifact_id, attempt_id, queried_at]
summary: One provider query issued during discovery.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_query\"][\"Row\"]"
defined_in: ["20260829181815_cloud_agent_parallel_source_provenance.sql", "20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.source_query

table in domain `evidence`.

> curated (model_assisted, unreviewed) — One provider query issued during discovery.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `provider_code` | `text` | no | — | FK → [`evidence.search_provider`](search_provider.md).code; _curated:_ FK to evidence.search_provider. |
| 4 | `query_text` | `text` | no | — | — |
| 5 | `purpose` | `text` | no | — | _curated:_ Why the query was issued. |
| 6 | `parameters` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `response_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 8 | `attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 9 | `queried_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `provider_code` → [`evidence.search_provider`](search_provider.md)`.code`; `response_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant).
Inbound: [`evidence.provider_result`](provider_result.md).query_id, [`evidence.source_provider_attempt`](source_provider_attempt.md).source_query_id.

## Indexes

`source_query_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_0868620440e80788e45f34ae` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_20dce6ec5b69e861e6394755` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
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

insert: `Database["evidence"]["Tables"]["source_query"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_query"]["Row"]`; update: `Database["evidence"]["Tables"]["source_query"]["Update"]`

## Examples

Sources discovered under a domain

```bash
knowledge db query evidence.sources_by_domain --param domain=openai.com --param limit=50
```
Queries themselves are not in the catalog; start from the resulting sources.

Defined in: `20260829181815_cloud_agent_parallel_source_provenance.sql`, `20260912010500_km_05_evidence.sql`.
