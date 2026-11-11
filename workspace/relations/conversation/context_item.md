---
id: "rel:conversation.context_item"
kind: table
schema: conversation
name: context_item
domain: library
lens: private
aliases: []
tokens: [conversation, context_item, conversation.context_item, id, tenant_id, workspace_id, snapshot_id, item_key, reason, revision_id, artifact_id, release_item_id, passage_id, offer_id, part_id]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"conversation\"][\"Tables\"][\"context_item\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# conversation.context_item

table in domain `library`, lens `private`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, snapshot_id, item_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, snapshot_id, item_key) |
| 4 | `snapshot_id` | `uuid` | no | — | unique (tenant_id, workspace_id, snapshot_id, item_key) |
| 5 | `item_key` | `text` | no | — | unique (tenant_id, workspace_id, snapshot_id, item_key) |
| 6 | `reason` | `text` | no | — | — |
| 7 | `revision_id` | `uuid` | yes | — | — |
| 8 | `artifact_id` | `uuid` | yes | — | — |
| 9 | `release_item_id` | `uuid` | yes | — | — |
| 10 | `passage_id` | `uuid` | yes | — | — |
| 11 | `offer_id` | `uuid` | yes | — | — |
| 12 | `part_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, snapshot_id, item_key)
- check `context_item_check`: `(num_nonnulls(revision_id, artifact_id, release_item_id, passage_id, offer_id, part_id) = 1)`
- check `context_item_reason_check`: `(reason = ANY (ARRAY['view'::text, 'pinned'::text, 'retrieved'::text, 'attached'::text]))`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,offer_id` → [`authoring.distribution_offer`](../authoring/distribution_offer.md)`.tenant_id,id` on delete restrict; `tenant_id,part_id` → [`curriculum.part`](../curriculum/part.md)`.tenant_id,id` on delete restrict; `tenant_id,release_item_id` → [`authoring.release_item`](../authoring/release_item.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,snapshot_id` → [`conversation.context_snapshot`](context_snapshot.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`context_item_tenant_id_artifact_id_fkey_ix`; `context_item_tenant_id_offer_id_fkey_ix`; `context_item_tenant_id_part_id_fkey_ix`; `context_item_tenant_id_release_item_id_fkey_ix`; `context_item_tenant_id_workspace_id_id_key` unique; `context_item_tenant_id_workspace_id_revision_id_fkey_ix`; `context_item_tenant_id_workspace_id_snapshot_id_item_key_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`append_message`](../../ops/append_message.md).

## TypeScript

insert: `Database["conversation"]["Tables"]["context_item"]["Insert"]`; row: `Database["conversation"]["Tables"]["context_item"]["Row"]`; update: `Database["conversation"]["Tables"]["context_item"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
