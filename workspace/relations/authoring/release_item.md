---
id: "rel:authoring.release_item"
kind: table
schema: authoring
name: release_item
domain: authoring
lens: ours
aliases: []
tokens: [authoring, release_item, authoring.release_item, id, tenant_id, workspace_id, release_id, item_key, revision_id, artifact_id, capture_id, locator_id, claim_id, record_id, entity_id, via_binding_id, disposition, substitute_artifact_id, decided_by, rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"release_item\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# authoring.release_item

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, release_id, item_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, release_id, item_key) |
| 4 | `release_id` | `uuid` | no | — | unique (tenant_id, workspace_id, release_id, item_key) |
| 5 | `item_key` | `text` | no | — | unique (tenant_id, workspace_id, release_id, item_key) |
| 6 | `revision_id` | `uuid` | yes | — | — |
| 7 | `artifact_id` | `uuid` | yes | — | — |
| 8 | `capture_id` | `uuid` | yes | — | — |
| 9 | `locator_id` | `uuid` | yes | — | — |
| 10 | `claim_id` | `uuid` | yes | — | — |
| 11 | `record_id` | `uuid` | yes | — | — |
| 12 | `entity_id` | `uuid` | yes | — | — |
| 13 | `via_binding_id` | `uuid` | yes | — | — |
| 14 | `disposition` | `text` | no | — | — |
| 15 | `substitute_artifact_id` | `uuid` | yes | — | — |
| 16 | `decided_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 17 | `rationale` | `text` | yes | — | — |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, release_id, item_key)
- check `release_item_check`: `(num_nonnulls(revision_id, artifact_id, capture_id, locator_id, claim_id, record_id, entity_id) = 1)`
- check `release_item_check1`: `((disposition = 'snapshot'::text) = (substitute_artifact_id IS NOT NULL))`
- check `release_item_check2`: `((decided_by IS NULL) = (rationale IS NULL))`
- check `release_item_disposition_check`: `(disposition = ANY (ARRAY['include'::text, 'snapshot'::text, 'reference'::text, 'withheld'::text]))`

## Relationships

Outbound: `tenant_id,workspace_id,via_binding_id` → [`authoring.revision_binding`](revision_binding.md)`.tenant_id,workspace_id,id` on delete restrict; `decided_by` → `auth.users``.id` on delete restrict; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,entity_id` → [`catalog.entity`](../catalog/entity.md)`.tenant_id,id` on delete restrict; `tenant_id,locator_id` → [`evidence.locator`](../evidence/locator.md)`.tenant_id,id` on delete restrict; `tenant_id,record_id` → [`guidance.item`](../guidance/item.md)`.tenant_id,id` on delete restrict; `tenant_id,substitute_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,release_id` → [`authoring.release`](release.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`authoring.revision_binding`](revision_binding.md).release_item_id, [`conversation.context_item`](../conversation/context_item.md).release_item_id, [`learning.attempt`](../learning/attempt.md).task_release_item_id.

## Indexes

`release_item_binding_fk_ix`; `release_item_decided_by_fkey_ix`; `release_item_tenant_id_artifact_id_fkey_ix`; `release_item_tenant_id_capture_id_fkey_ix`; `release_item_tenant_id_claim_id_fkey_ix`; `release_item_tenant_id_entity_id_fkey_ix`; `release_item_tenant_id_id_key` unique; `release_item_tenant_id_locator_id_fkey_ix`; `release_item_tenant_id_record_id_fkey_ix`; `release_item_tenant_id_substitute_artifact_id_fkey_ix`; `release_item_tenant_id_workspace_id_id_key` unique; `release_item_tenant_id_workspace_id_release_id_item_key_key` unique; `release_item_tenant_id_workspace_id_revision_id_fkey_ix`

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)
- `release_item_promote_passages` → [`retrieval.on_release_item_promote`](../../functions/retrieval/on_release_item_promote.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:ours.releases_needing_review`, `q:ours.works_authored`.
- Exposed through: [`api.works_authored`](../api/works_authored.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`freeze_release`](../../ops/freeze_release.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["release_item"]["Insert"]`; row: `Database["authoring"]["Tables"]["release_item"]["Row"]`; update: `Database["authoring"]["Tables"]["release_item"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
