---
id: "sch:util"
kind: schema
name: util
lens: machinery
domains: [api-surface]
relations: 1
functions: 8
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# util

Shared helper functions. Owns no domain tables. Lens `machinery`. Domains: [`api-surface`](../../domains/api-surface.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`database_release`](../../relations/util/database_release.md) | table | unknown | Which release this database is: one row per stamp, newest last, never edited. A release i… | — |

Functions: [`current_tenant_id`](../../functions/util/current_tenant_id.md), [`default_tenant_id`](../../functions/util/default_tenant_id.md), [`ensure_month_partitions`](../../functions/util/ensure_month_partitions.md), [`reject_mutation`](../../functions/util/reject_mutation.md), [`set_updated_at`](../../functions/util/set_updated_at.md), [`stamp_database_release`](../../functions/util/stamp_database_release.md), [`uuidv7`](../../functions/util/uuidv7.md), [`validate_predecessor`](../../functions/util/validate_predecessor.md).

Types: none.
