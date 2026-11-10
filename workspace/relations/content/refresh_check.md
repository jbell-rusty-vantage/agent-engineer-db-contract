---
id: "rel:content.refresh_check"
kind: table
schema: content
name: refresh_check
domain: content
lens: corpus
aliases: [refresh, daily refresh]
tokens: [content, refresh_check, content.refresh_check, id, tenant_id, document_id, prior_version_id, fetch_id, checked_at, outcome, content_sha256, new_version_id]
summary: "Each refresh of a document — unchanged (same bytes), changed (new version) or failed — written even when nothing moved."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"refresh_check\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# content.refresh_check

table in domain `content`, lens `corpus` — Each refresh of a document: unchanged (same bytes, no new version), changed (new version created) or failed. This is what a daily refresh writes even when nothing moved..

> curated (model_assisted, unreviewed) — Each refresh of a document — unchanged (same bytes), changed (new version) or failed — written even when nothing moved.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `document_id` | `uuid` | no | — | — |
| 4 | `prior_version_id` | `uuid` | no | — | — |
| 5 | `fetch_id` | `uuid` | yes | — | FK → [`acquisition.fetch`](../acquisition/fetch.md).id; _curated:_ acquisition.fetch that performed the check. |
| 6 | `checked_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `outcome` | `text` | no | — | _curated:_ unchanged, changed or failed. |
| 8 | `content_sha256` | `text` | yes | — | — |
| 9 | `new_version_id` | `uuid` | yes | — | _curated:_ Set when outcome is changed. |

## Constraints

- PK (id)
- check `refresh_check_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `refresh_check_outcome_check`: `(outcome = ANY (ARRAY['unchanged'::text, 'changed'::text, 'failed'::text]))`

## Relationships

Outbound: `fetch_id` → [`acquisition.fetch`](../acquisition/fetch.md)`.id`; `tenant_id,document_id` → [`content.document`](document.md)`.tenant_id,id`; `tenant_id,new_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id`; `tenant_id,prior_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id`.
Inbound: [`content.unit_change`](unit_change.md).refresh_check_id.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:content.refresh_checks`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["refresh_check"]["Insert"]`; row: `Database["content"]["Tables"]["refresh_check"]["Row"]`; update: `Database["content"]["Tables"]["refresh_check"]["Update"]`

## Examples

Documents that changed

```bash
knowledge db query content.refresh_checks --param document_id=null --param limit=50 --param outcome=changed
```
Follow new_version_id and content.unit_changes.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
