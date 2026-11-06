---
id: "rel:staging.candidate"
kind: table
schema: staging
name: candidate
domain: staging
aliases: [candidate]
tokens: [staging, candidate, staging.candidate, id, tenant_id, proposed_kind, proposed_payload, resolved_entity_id, source_id, created_at]
summary: Proposed identity awaiting resolution; not a draft fact.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"staging\"][\"Tables\"][\"candidate\"][\"Row\"]"
defined_in: ["20260826000700_staging.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# staging.candidate

table in domain `staging`.

> curated (model_assisted, unreviewed) — Proposed identity awaiting resolution; not a draft fact.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `proposed_kind` | `text` | no | — | FK → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md).code; _curated:_ FK to taxonomy.entity_kind. |
| 4 | `proposed_payload` | `jsonb` | no | — | — |
| 5 | `resolved_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id; _curated:_ Set after a match or create decision. |
| 6 | `source_id` | `uuid` | yes | — | FK → [`evidence.source`](../evidence/source.md).id |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `proposed_kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`; `resolved_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `source_id` → [`evidence.source`](../evidence/source.md)`.id` (+tenant).
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).candidate_id, [`staging.identity_match`](identity_match.md).candidate_id, [`staging.resolution_decision`](resolution_decision.md).candidate_id, [`staging.vetting_decision`](vetting_decision.md).candidate_id.
Polymorphic: `proposed_kind` selects one of 36 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`candidate_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:staging.candidates_for_kind`, `q:staging.unresolved`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["staging"]["Tables"]["candidate"]["Insert"]`; row: `Database["staging"]["Tables"]["candidate"]["Row"]`; update: `Database["staging"]["Tables"]["candidate"]["Update"]`

## Examples

Unresolved candidates

```bash
knowledge db query staging.unresolved --param limit=50
```
Excludes create/match/reject decisions.

Defined in: `20260826000700_staging.sql`, `20260912010900_km_09_ranking_staging.sql`.
