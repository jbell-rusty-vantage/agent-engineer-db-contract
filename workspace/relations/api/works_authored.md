---
id: "rel:api.works_authored"
kind: view
schema: api
name: works_authored
domain: authoring
lens: ours
aliases: [our works, courses table, modules table]
tokens: [api, works_authored, api.works_authored, work_id, kind, slug, title, head_revision_id, revision_no, workspace_id, workspace_kind, released, covers_concepts, uses_software, runtime_requirements, knowledge_seq, created_at, source_tier]
summary: "L1 (lens ours, tier 1) — our courses, modules, lessons, activities, reports and templates at head revision, released flag, covered concepts and used software."
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"works_authored\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.works_authored

view in domain `authoring`, lens `ours` — L1 (ours, tier 1): our courses, modules, lessons, activities, reports and templates at their head revision, whether released, which concepts they cover and which software/versions they use..

> curated (model_assisted, unreviewed) — L1 (lens ours, tier 1) — our courses, modules, lessons, activities, reports and templates at head revision, released flag, covered concepts and used software.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `work_id` | `uuid` | yes | — | — |
| 2 | `kind` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `title` | `text` | yes | — | — |
| 5 | `head_revision_id` | `uuid` | yes | — | — |
| 6 | `revision_no` | `integer` | yes | — | — |
| 7 | `workspace_id` | `uuid` | yes | — | — |
| 8 | `workspace_kind` | `text` | yes | — | — |
| 9 | `released` | `boolean` | yes | — | _curated:_ True when the head revision is inside a frozen release that has been offered. |
| 10 | `covers_concepts` | `text[]` | yes | — | _curated:_ From authoring.revision_binding on the head revision. |
| 11 | `uses_software` | `text[]` | yes | — | _curated:_ Software and versions the revision binds; feeds api.modules_affected_by_release. |
| 12 | `runtime_requirements` | `text[]` | yes | — | — |
| 13 | `knowledge_seq` | `bigint` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | yes | — | — |
| 15 | `source_tier` | `smallint` | yes | — | _curated:_ Always 1 (our content). |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Named queries: `q:ours.works_authored`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](works_authored.details.md).

## TypeScript

row: `Database["api"]["Views"]["works_authored"]["Row"]`

## Examples

Our modules

```bash
knowledge db query ours.works_authored --param kind=module --param limit=50 --param released=null --param text=null
```
Drafts included unless released is true.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
