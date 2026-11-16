---
id: "rel:catalog.work"
kind: table
schema: catalog
name: work
domain: identity
lens: corpus
aliases: [published work, bibliographic row, paper row, talk row]
tokens: [catalog, work, catalog.work, id, tenant_id, kind, title, subtitle, abstract, canonical_url, published_at, language, duration_ms, venue_entity_id, attributes]
summary: "Bibliographic row behind a work entity (paper, talk, media work, story, case study); content lives in content.document."
summary_basis: curated
rls: disabled
readers: []
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"work\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# catalog.work

table in domain `identity`, lens `corpus` — A published work entity (paper, talk, media work, story, case study): the bibliographic row behind the entity. Content lives in content.document (work_entity_id)..

> curated (model_assisted, unreviewed) — Bibliographic row behind a work entity (paper, talk, media work, story, case study); content lives in content.document.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`catalog.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | — | _curated:_ The work entity kind (paper, talk, media_work, story, case_study); taxonomy.entity_kind.is_work. |
| 4 | `title` | `text` | no | — | — |
| 5 | `subtitle` | `text` | yes | — | — |
| 6 | `abstract` | `text` | yes | — | — |
| 7 | `canonical_url` | `text` | yes | — | — |
| 8 | `published_at` | `timestamp with time zone` | yes | — | — |
| 9 | `language` | `text` | yes | — | — |
| 10 | `duration_ms` | `integer` | yes | — | _curated:_ For talks and media works; transcript timecodes stay inside that range. |
| 11 | `venue_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](entity.md).id; _curated:_ Where it appeared: an industry_event, media_channel or publisher organization. |
| 12 | `attributes` | `jsonb` | no | `'{}'::jsonb` | _curated:_ Work-level attributes beyond the entity attributes (edition, language variants). |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `work_duration_ms_check`: `((duration_ms IS NULL) OR (duration_ms >= 0))`
- check `work_kind_check`: `(kind = ANY (ARRAY['paper'::text, 'talk'::text, 'media_work'::text, 'story'::text, 'case_study'::text]))`

## Relationships

Outbound: `id` → [`catalog.entity`](entity.md)`.id`; `tenant_id,id,kind` → [`catalog.entity`](entity.md)`.tenant_id,id,kind` (deferrable); `venue_entity_id` → [`catalog.entity`](entity.md)`.id`.
Inbound: none.
Polymorphic target of: [`catalog.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.entity_kind`](../taxonomy/entity_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_parent_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`work_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Disabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:catalog.papers`, `q:catalog.talks`, `q:content.talk_segments`.
- Exposed through: [`api.claim_surfaces`](../api/claim_surfaces.md), [`api.digest_items`](../api/digest_items.md), [`api.papers`](../api/papers.md), [`api.talks`](../api/talks.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["catalog"]["Tables"]["work"]["Insert"]`; row: `Database["catalog"]["Tables"]["work"]["Row"]`; update: `Database["catalog"]["Tables"]["work"]["Update"]`

## Examples

Talks are works

```bash
knowledge db query catalog.talks --param event_id=null --param limit=20 --param text=null
```
The L1 view joins the entity, the work row and the presented_at / presented_by edges.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
