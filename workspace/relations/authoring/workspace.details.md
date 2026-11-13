---
id: "rel:authoring.workspace#details"
kind: details
schema: authoring
name: workspace
of: "rel:authoring.workspace"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# authoring.workspace — details

Spill-over from [the main page](workspace.md).

## Relationships

Outbound: `owner_id` → `auth.users``.id` on delete restrict.
Inbound: [`authoring.asset_scope`](asset_scope.md).workspace_id, [`authoring.command`](command.md).workspace_id, [`authoring.event`](event.md).workspace_id, [`authoring.file_set`](file_set.md).workspace_id, [`authoring.work`](work.md).workspace_id, [`authoring.workspace_member`](workspace_member.md).workspace_id, [`conversation.context_snapshot`](../conversation/context_snapshot.md).workspace_id, [`conversation.thread`](../conversation/thread.md).workspace_id, [`learning.attempt`](../learning/attempt.md).workspace_id, [`learning.enrollment`](../learning/enrollment.md).workspace_id, [`learning.mastery_decision`](../learning/mastery_decision.md).workspace_id, [`library.connection`](../library/connection.md).workspace_id, [`library.removal`](../library/removal.md).workspace_id.

## Indexes

| Index | Definition |
| --- | --- |
| `workspace_owner_id_fkey_ix` | `CREATE INDEX workspace_owner_id_fkey_ix ON authoring.workspace USING btree (owner_id)` |
| `workspace_personal_uq` | `CREATE UNIQUE INDEX workspace_personal_uq ON authoring.workspace USING btree (tenant_id, owner_id) WHERE (kind = 'personal'::text)` |
| `workspace_tenant_id_id_key` | `CREATE UNIQUE INDEX workspace_tenant_id_id_key ON authoring.workspace USING btree (tenant_id, id)` |

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md): `CREATE TRIGGER immutable_guard BEFORE DELETE OR UPDATE ON authoring.workspace FOR EACH ROW EXECUTE FUNCTION product.guard_immutable()`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: using `true`; with check `true`
