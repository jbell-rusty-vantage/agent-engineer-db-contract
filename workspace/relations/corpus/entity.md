---
id: "rel:corpus.entity"
kind: table
schema: corpus
name: entity
domain: identity
aliases: [entity, canonical entity, identity row]
tokens: [corpus, entity, corpus.entity, id, tenant_id, kind, display_name, slug, summary, lifecycle, merged_into_id, projection_knowledge_seq, created_by_receipt_id, created_at, updated_at]
summary: "One row per canonical identity; typed attributes live in corpus.<kind>."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"entity\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.entity

table in domain `identity`.

> curated (model_assisted, unreviewed) — One row per canonical identity; typed attributes live in corpus.<kind>.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, id, kind) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, id, kind); unique (tenant_id, kind, slug) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, id, kind); unique (tenant_id, kind, slug); FK → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md).code; _curated:_ FK to taxonomy.entity_kind; picks the typed child table. |
| 4 | `display_name` | `text` | no | — | _curated:_ Projection of the entity_name stream, not a unique key. |
| 5 | `slug` | `text` | no | — | unique (tenant_id, kind, slug) |
| 6 | `summary` | `text` | yes | — | — |
| 7 | `lifecycle` | `text` | no | `'active'::text` | _curated:_ active, merged, or retired. Resolve hides merged. |
| 8 | `merged_into_id` | `uuid` | yes | — | FK → [`corpus.entity`](entity.md).id; _curated:_ Set when lifecycle is merged. |
| 9 | `projection_knowledge_seq` | `bigint` | yes | — | — |
| 10 | `created_by_receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id; _curated:_ Required; executor writes the receipt first. |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, id, kind)
- unique (tenant_id, kind, slug)
- check `entity_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'merged'::text, 'retired'::text]))`

## Relationships

Outbound: `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`; `merged_into_id` → [`corpus.entity`](entity.md)`.id` (+tenant).
Inbound: [`content.document`](../content/document.md).work_entity_id, [`content.document_about_entity`](../content/document_about_entity.md).entity_id, [`content.document_node`](../content/document_node.md).speaker_entity_id, [`content.document_summary`](../content/document_summary.md).focus_entity_id, [`corpus.agent_skill`](agent_skill.md).id|id,kind, [`corpus.ai_model`](ai_model.md).id|id,kind, [`corpus.ai_model_version`](ai_model_version.md).id|id,kind, [`corpus.ai_protocol`](ai_protocol.md).id|id,kind, [`corpus.ai_protocol_feature`](ai_protocol_feature.md).id|id,kind, [`corpus.ai_protocol_version`](ai_protocol_version.md).id|id,kind, [`corpus.benchmark`](benchmark.md).id|id,kind, [`corpus.benchmark_run`](benchmark_run.md).id|subject_entity_id|id,kind … 58 more in [details](entity.details.md).
Polymorphic: `kind` selects one of 36 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey.
Polymorphic target of: [`curriculum.challenge_targets`](../curriculum/challenge_targets.md) (check constraint challenge_targets_exactly_one), [`ranking.group_membership`](../ranking/group_membership.md) (check constraint group_membership_exactly_one_entity), [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_check), [`taxonomy.assignment`](../taxonomy/assignment.md) (check constraint assignment_check), [`temporal.stream`](../temporal/stream.md) (check constraint stream_check).

## Indexes

4 indexes; see [details](entity.details.md).

## Triggers

2 triggers; see [details](entity.details.md).

## Row-level security

Enabled; 1 policies in [details](entity.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.at`, `q:entity.by_identifier`, `q:entity.card`, `q:entity.resolve`, `q:entity.typed_row`.
- Exposed through: [`api.entities`](../api/entities.md), [`api.library_profile`](../api/library_profile.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`corpus.import_research_starter_catalog`](../../functions/corpus/import_research_starter_catalog.md), [`corpus.rebuild_entity_projections`](../../functions/corpus/rebuild_entity_projections.md).

## TypeScript

insert: `Database["corpus"]["Tables"]["entity"]["Insert"]`; row: `Database["corpus"]["Tables"]["entity"]["Row"]`; update: `Database["corpus"]["Tables"]["entity"]["Update"]`

## Examples

Resolve OpenAI

```bash
knowledge db query entity.resolve --param text=OpenAI
```
Active rows only; score combines name, alias, and identifier.

Defined in: `20260912010200_km_02_corpus_identity.sql`.
