---
id: "rel:corpus.benchmark_run"
kind: table
schema: corpus
name: benchmark_run
domain: identity
aliases: []
tokens: [corpus, benchmark_run, corpus.benchmark_run, id, tenant_id, kind, benchmark_id, subject_entity_id, protocol, artifact_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"benchmark_run\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.benchmark_run

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'benchmark_run'::text` | — |
| 4 | `benchmark_id` | `uuid` | no | — | FK → [`corpus.benchmark`](benchmark.md).id |
| 5 | `subject_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id |
| 6 | `protocol` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `benchmark_run_kind_check`: `(kind = 'benchmark_run'::text)`

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `benchmark_id` → [`corpus.benchmark`](benchmark.md)`.id` (+tenant); `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `subject_entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`knowledge.benchmark_result`](../knowledge/benchmark_result.md).benchmark_run_id, [`ranking.metric_observation`](../ranking/metric_observation.md).benchmark_run_id.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`benchmark_run_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_8261d720a38111a14ccd8b1e` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_ecf73d49abffb9b907ef9b19` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.typed_row`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["benchmark_run"]["Insert"]`; row: `Database["corpus"]["Tables"]["benchmark_run"]["Row"]`; update: `Database["corpus"]["Tables"]["benchmark_run"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
