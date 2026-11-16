---
id: "rel:authoring.revision_binding"
kind: table
schema: authoring
name: revision_binding
domain: authoring
lens: ours
aliases: []
tokens: [authoring, revision_binding, authoring.revision_binding, id, tenant_id, workspace_id, revision_id, local_key, relation, target_revision_id, target_work_id, artifact_id, capture_id, locator_id, claim_id, entity_id, record_id, release_item_id, file_set_id, assertion_id, role, block_key, usage, rights_basis, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"revision_binding\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# authoring.revision_binding

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, local_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, local_key) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, local_key) |
| 5 | `local_key` | `text` | no | — | unique (tenant_id, workspace_id, revision_id, local_key) |
| 6 | `relation` | `text` | no | — | — |
| 7 | `target_revision_id` | `uuid` | yes | — | — |
| 8 | `target_work_id` | `uuid` | yes | — | — |
| 9 | `artifact_id` | `uuid` | yes | — | — |
| 10 | `capture_id` | `uuid` | yes | — | — |
| 11 | `locator_id` | `uuid` | yes | — | — |
| 12 | `claim_id` | `uuid` | yes | — | — |
| 13 | `entity_id` | `uuid` | yes | — | — |
| 14 | `record_id` | `uuid` | yes | — | — |
| 15 | `release_item_id` | `uuid` | yes | — | — |
| 16 | `file_set_id` | `uuid` | yes | — | — |
| 17 | `assertion_id` | `uuid` | yes | — | — |
| 18 | `role` | `text` | yes | — | — |
| 19 | `block_key` | `uuid` | yes | — | — |
| 20 | `usage` | `text` | no | — | — |
| 21 | `rights_basis` | `text` | no | — | — |
| 22 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, local_key)
- 17 check constraints; see [details](revision_binding.details.md)

## Relationships

12 outbound and 1 inbound foreign keys; full list in [details](revision_binding.details.md).

## Indexes

13 indexes; see [details](revision_binding.details.md).

## Triggers

2 triggers; see [details](revision_binding.details.md).

## Row-level security

Enabled; 1 policies in [details](revision_binding.details.md).

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:catalog.concepts`, `q:ours.modules_affected_by_release`, `q:ours.releases_needing_review`, `q:ours.works_authored`.
- Exposed through: [`api.concepts`](../api/concepts.md), [`api.works_authored`](../api/works_authored.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.insert_revision`](../../functions/product/insert_revision.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["revision_binding"]["Insert"]`; row: `Database["authoring"]["Tables"]["revision_binding"]["Row"]`; update: `Database["authoring"]["Tables"]["revision_binding"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
