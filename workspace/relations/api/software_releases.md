---
id: "rel:api.software_releases"
kind: view
schema: api
name: software_releases
domain: api-surface
lens: corpus
aliases: [releases table, changelog]
tokens: [api, software_releases, api.software_releases, release_id, release, software_id, software, software_kind, version_label, released_at, breaking, highlights, release_url, learned_k, observed_at]
summary: "L1/L2 — every known release of a software thing with date, breaking flag, highlights and the knowledge seq it was learned at."
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"software_releases\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.software_releases

view in domain `api-surface`, lens `corpus` — L1/L2: every known release of a software thing with its date, breaking flag, highlights and the knowledge sequence it was learned at. Order by released_at for history..

> curated (model_assisted, unreviewed) — L1/L2 — every known release of a software thing with date, breaking flag, highlights and the knowledge seq it was learned at.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `release_id` | `uuid` | yes | — | — |
| 2 | `release` | `text` | yes | — | — |
| 3 | `software_id` | `uuid` | yes | — | — |
| 4 | `software` | `text` | yes | — | — |
| 5 | `software_kind` | `text` | yes | — | — |
| 6 | `version_label` | `text` | yes | — | — |
| 7 | `released_at` | `timestamp with time zone` | yes | — | — |
| 8 | `breaking` | `boolean` | yes | — | _curated:_ Null means unknown. |
| 9 | `highlights` | `text[]` | yes | — | — |
| 10 | `release_url` | `text` | yes | — | — |
| 11 | `learned_k` | `bigint` | yes | — | _curated:_ Knowledge head when we learned about the release; later than released_at is normal. |
| 12 | `observed_at` | `timestamp with time zone` | yes | — | — |

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

- Named queries: `q:catalog.software_releases`, `q:evidence.probe_revalidation_due`, `q:ours.modules_affected_by_release`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](software_releases.details.md).

## TypeScript

row: `Database["api"]["Views"]["software_releases"]["Row"]`

## Examples

Release history

```bash
knowledge db query catalog.software_releases --param limit=50 --param software_id=null --param text=langgraph
```
Newest first; api.modules_affected_by_release takes release_id.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
