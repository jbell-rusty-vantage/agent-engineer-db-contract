---
id: "rel:acquisition.fetch"
kind: table
schema: acquisition
name: fetch
domain: acquisition
lens: corpus
aliases: [fetch, fetch ledger, spend]
tokens: [acquisition, fetch, acquisition.fetch, id, tenant_id, origin_kind, origin_label, actor_principal_id, mc_mission_id, mc_run_id, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, credits_used, cost_usd, failure_class, prior_capture_id, notes, sweep_id]
summary: "One attempt to obtain bytes from a URL — who, with what tool, outcome, hash, spend — recorded before any capture exists."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"acquisition\"][\"Tables\"][\"fetch\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# acquisition.fetch

table in domain `acquisition`, lens `corpus` — One attempt to obtain bytes from a URL: who (origin), with what tool, outcome, hash, spend. unchanged = same bytes as prior_capture_id (no new document version)..

> curated (model_assisted, unreviewed) — One attempt to obtain bytes from a URL — who, with what tool, outcome, hash, spend — recorded before any capture exists.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `origin_kind` | `text` | no | — | _curated:_ product, harness or mission; origin_label and actor_principal_id / mc_mission_id say who. |
| 4 | `origin_label` | `text` | no | — | — |
| 5 | `actor_principal_id` | `uuid` | yes | — | — |
| 6 | `mc_mission_id` | `text` | yes | — | — |
| 7 | `mc_run_id` | `text` | yes | — | — |
| 8 | `tool` | `text` | no | — | — |
| 9 | `tool_version` | `text` | yes | — | — |
| 10 | `request_url` | `text` | no | — | — |
| 11 | `final_url` | `text` | yes | — | — |
| 12 | `requested_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 14 | `http_status` | `integer` | yes | — | — |
| 15 | `outcome` | `text` | no | — | _curated:_ fetched, unchanged (same bytes as prior_capture_id), blocked, failed. |
| 16 | `content_sha256` | `text` | yes | — | — |
| 17 | `media_type` | `text` | yes | — | — |
| 18 | `size_bytes` | `bigint` | yes | — | — |
| 19 | `credits_used` | `numeric` | yes | — | — |
| 20 | `cost_usd` | `numeric` | yes | — | _curated:_ Spend of this fetch; credits_used for credit-metered tools. |
| 21 | `failure_class` | `text` | yes | — | — |
| 22 | `prior_capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](../evidence/source_capture.md).id; _curated:_ Capture whose bytes an unchanged outcome matched; no new document version is created. |
| 23 | `notes` | `jsonb` | no | `'{}'::jsonb` | — |
| 24 | `sweep_id` | `uuid` | yes | — | FK → [`acquisition.attention_sweep`](attention_sweep.md).id |

## Constraints

- PK (id)
- check `fetch_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `fetch_origin_kind_check`: `(origin_kind = ANY (ARRAY['native_harness'::text, 'mission_invocation'::text, 'product_user'::text, 'scheduled_refresh'::text, 'manual_uplo…`
- check `fetch_outcome_check`: `(outcome = ANY (ARRAY['captured'::text, 'unchanged'::text, 'failed'::text, 'blocked'::text, 'skipped'::text]))`
- check `fetch_size_bytes_check`: `((size_bytes IS NULL) OR (size_bytes >= 0))`
- check `fetch_tool_check`: `(tool = ANY (ARRAY['http'::text, 'firecrawl'::text, 'browser'::text, 'api'::text, 'repository'::text, 'upload'::text, 'youtube_transcript':…`

## Relationships

Outbound: `prior_capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.id`; `sweep_id` → [`acquisition.attention_sweep`](attention_sweep.md)`.id`.
Inbound: [`content.refresh_check`](../content/refresh_check.md).fetch_id, [`evidence.source_capture`](../evidence/source_capture.md).acquisition_fetch_id.
Polymorphic target of: [`evidence.source_capture`](../evidence/source_capture.md) (check constraint source_capture_exactly_one_producer_ck).

## Indexes

`fetch_url_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:acquisition.fetches_for_url`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["acquisition"]["Tables"]["fetch"]["Insert"]`; row: `Database["acquisition"]["Tables"]["fetch"]["Row"]`; update: `Database["acquisition"]["Tables"]["fetch"]["Update"]`

## Examples

Fetch history and spend for a URL

```bash
knowledge db query acquisition.fetches_for_url --param limit=50 --param url=null
```
Newest first; unchanged rows are honest no-ops.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
