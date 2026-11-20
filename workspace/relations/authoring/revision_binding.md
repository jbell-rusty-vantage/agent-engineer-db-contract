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
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
- check `revision_binding_check`: `(num_nonnulls(target_revision_id, target_work_id, artifact_id, capture_id, locator_id, claim_id, entity_id, record_id, release_item_id, fil…`
- check `revision_binding_check1`: `((target_work_id IS NOT NULL) <= (relation = ANY (ARRAY['links_to'::text, 'contains'::text])))`
- check `revision_binding_check10`: `((relation <> 'source'::text) OR (capture_id IS NOT NULL) OR (locator_id IS NOT NULL))`
- check `revision_binding_check11`: `((relation <> 'has_component'::text) OR (target_revision_id IS NOT NULL))`
- check `revision_binding_check2`: `((release_item_id IS NOT NULL) <= (relation = ANY (ARRAY['adapted_from'::text, 'generated_under'::text, 'anchored_to'::text, 'scenario_of':…`
- check `revision_binding_check3`: `((relation <> 'scenario_of'::text) OR (release_item_id IS NOT NULL) OR (target_revision_id IS NOT NULL))`
- check `revision_binding_check4`: `((assertion_id IS NOT NULL) <= (relation = ANY (ARRAY['uses'::text, 'supports'::text, 'contradicts'::text, 'links_to'::text])))`
- check `revision_binding_check5`: `((relation <> ALL (ARRAY['adapted_from'::text, 'generated_under'::text])) OR (release_item_id IS NOT NULL))`
- check `revision_binding_check6`: `((relation <> 'anchored_to'::text) OR (release_item_id IS NOT NULL) OR (target_revision_id IS NOT NULL))`
- check `revision_binding_check7`: `((file_set_id IS NOT NULL) <= (relation = ANY (ARRAY['representation'::text, 'uses'::text, 'evaluates_with'::text])))`
- check `revision_binding_check8`: `((relation <> ALL (ARRAY['links_to'::text, 'contains'::text])) OR (target_work_id IS NOT NULL) OR (target_revision_id IS NOT NULL) OR (asse…`
- check `revision_binding_check9`: `((relation <> 'representation'::text) OR (artifact_id IS NOT NULL) OR (file_set_id IS NOT NULL))`
- check `revision_binding_local_key_check`: `(local_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'::text)`
- check `revision_binding_relation_check`: `(relation = ANY (ARRAY['derived_from'::text, 'uses'::text, 'representation'::text, 'source'::text, 'supports'::text, 'contradicts'::text, '…`
- check `revision_binding_rights_basis_check`: `product.nonblank(rights_basis)`
- check `revision_binding_role_check`: `(role = ANY (ARRAY['original'::text, 'transcript'::text, 'captions'::text, 'thumbnail'::text, 'poster'::text, 'accessible_fallback'::text, …`
- check `revision_binding_usage_check`: `(usage = ANY (ARRAY['reference_only'::text, 'private_copy'::text, 'redistributable'::text, 'unknown'::text]))`

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
