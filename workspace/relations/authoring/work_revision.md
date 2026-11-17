---
id: "rel:authoring.work_revision"
kind: table
schema: authoring
name: work_revision
domain: authoring
lens: ours
aliases: [revision, immutable revision]
tokens: [authoring, work_revision, authoring.work_revision, id, tenant_id, workspace_id, work_id, revision_no, parent_revision_id, title, body_schema, body, content_sha256, origin, origin_ref, knowledge_seq, world_from, world_to, world_precision, created_by, created_at, purged_at, purged_by_removal_id]
summary: "Immutable revision of a work (title, body blocks, content hash); product operations create new ones, never update."
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"work_revision\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# authoring.work_revision

table in domain `authoring`, lens `ours`.

> curated (model_assisted, unreviewed) — Immutable revision of a work (title, body blocks, content hash); product operations create new ones, never update.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, work_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, work_id, id); unique (tenant_id, workspace_id, work_id, revision_no) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, work_id, id); unique (tenant_id, workspace_id, work_id, revision_no) |
| 4 | `work_id` | `uuid` | no | — | unique (tenant_id, workspace_id, work_id, id); unique (tenant_id, workspace_id, work_id, revision_no) |
| 5 | `revision_no` | `integer` | no | — | unique (tenant_id, workspace_id, work_id, revision_no); _curated:_ Monotonic per work. |
| 6 | `parent_revision_id` | `uuid` | yes | — | — |
| 7 | `title` | `text` | no | — | — |
| 8 | `body_schema` | `text` | no | — | — |
| 9 | `body` | `jsonb` | no | — | — |
| 10 | `content_sha256` | `text` | yes | — | _curated:_ Digest of the body; identical content is a no-op revision. |
| 11 | `origin` | `text` | no | — | — |
| 12 | `origin_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `knowledge_seq` | `bigint` | yes | — | — |
| 14 | `world_from` | `timestamp with time zone` | yes | — | — |
| 15 | `world_to` | `timestamp with time zone` | yes | — | — |
| 16 | `world_precision` | `text` | no | `'unknown'::text` | — |
| 17 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 19 | `purged_at` | `timestamp with time zone` | yes | — | _curated:_ Purged revisions are hidden from reads and search. |
| 20 | `purged_by_removal_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, work_id, id)
- unique (tenant_id, workspace_id, work_id, revision_no)
- check `work_revision_body_check`: `((jsonb_typeof(body) = 'object'::text) AND (octet_length((body)::text) <= 1048576))`
- check `work_revision_body_schema_check`: `(body_schema = ANY (ARRAY['aieng.work-body.v1'::text, 'aieng.work-body.v2'::text]))`
- check `work_revision_check`: `(((world_precision = 'unknown'::text) AND (world_from IS NULL) AND (world_to IS NULL)) OR ((world_precision = 'instant'::text) AND (world_f…`
- check `work_revision_check1`: `((purged_at IS NULL) = (purged_by_removal_id IS NULL))`
- check `work_revision_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `work_revision_origin_check`: `(origin = ANY (ARRAY['human'::text, 'native_harness'::text, 'import'::text, 'mc'::text, 'agent'::text]))`
- check `work_revision_revision_no_check`: `(revision_no > 0)`
- check `work_revision_title_check`: `product.nonblank(title)`
- check `work_revision_world_precision_check`: `(world_precision = ANY (ARRAY['instant'::text, 'day'::text, 'unknown'::text]))`

## Relationships

5 outbound and 38 inbound foreign keys; full list in [details](work_revision.details.md).

## Indexes

8 indexes; see [details](work_revision.details.md).

## Triggers

2 triggers; see [details](work_revision.details.md).

## Row-level security

Enabled; 1 policies in [details](work_revision.details.md).

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:ours.modules_affected_by_release`, `q:ours.works_authored`.
- Exposed through: [`api.works_authored`](../api/works_authored.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.insert_revision`](../../functions/product/insert_revision.md).
- Product operations (best effort): [`confirm_removal`](../../ops/confirm_removal.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["work_revision"]["Insert"]`; row: `Database["authoring"]["Tables"]["work_revision"]["Row"]`; update: `Database["authoring"]["Tables"]["work_revision"]["Update"]`

## Examples

Modules affected by a release are head revisions

```bash
knowledge db query ours.modules_affected_by_release --param release_id=0192b000-0000-7000-8000-000000000001
```
revision_id and revision_created_at come from this table.

Defined in: `20261105010100_product_foundation.sql`.
