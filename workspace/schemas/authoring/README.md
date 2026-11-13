---
id: "sch:authoring"
kind: schema
name: authoring
lens: ours
domains: [authoring]
relations: 20
functions: 0
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# authoring

Lens `ours`. Domains: [`authoring`](../../domains/authoring.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`asset_scope`](../../relations/authoring/asset_scope.md) | table | small | — | → `auth.users`, → `orchestration.artifact`, → `authoring.workspace` |
| [`block_type`](../../relations/authoring/block_type.md) | table | unknown | — | — |
| [`command`](../../relations/authoring/command.md) | table | medium | — | → `auth.users`, → `access.client_grant`, → `authoring.workspace` |
| [`deployment`](../../relations/authoring/deployment.md) | table | unknown | — | → `auth.users`, → `authoring.file_set`, → `authoring.work_revision` |
| [`distribution`](../../relations/authoring/distribution.md) | table | unknown | — | → `auth.users`, → `authoring.event`, → `authoring.work` |
| [`distribution_member`](../../relations/authoring/distribution_member.md) | table | unknown | — | → `auth.users`, → `authoring.distribution` |
| [`distribution_offer`](../../relations/authoring/distribution_offer.md) | table | unknown | — | → `auth.users`, → `authoring.event`, → `authoring.distribution`, → `authoring.release` |
| [`event`](../../relations/authoring/event.md) | table | small | — | → `auth.users`, → `authoring.workspace`, → `authoring.work`, → `authoring.work_revision` |
| [`file_set`](../../relations/authoring/file_set.md) | table | unknown | — | → `auth.users`, → `authoring.workspace` |
| [`file_set_entry`](../../relations/authoring/file_set_entry.md) | table | unknown | — | → `orchestration.artifact`, → `authoring.file_set` |
| [`publisher_grant`](../../relations/authoring/publisher_grant.md) | table | unknown | — | → `auth.users` |
| [`release`](../../relations/authoring/release.md) | table | unknown | — | → `auth.users`, → `orchestration.artifact`, → `authoring.event`, → `authoring.work_revision` |
| [`release_item`](../../relations/authoring/release_item.md) | table | small | — | → `authoring.revision_binding`, → `auth.users`, → `orchestration.artifact`, → `evidence.source_capture` |
| [`revision_binding`](../../relations/authoring/revision_binding.md) | table | small | — | → `inquiry.assertion`, → `orchestration.artifact`, → `evidence.source_capture`, → `evidence.claim` |
| [`revision_block`](../../relations/authoring/revision_block.md) | table | small | — | → `authoring.block_type`, → `authoring.work_revision` |
| [`runtime_requirement`](../../relations/authoring/runtime_requirement.md) | table | unknown | — | → `catalog.entity`, → `authoring.work_revision` |
| [`work`](../../relations/authoring/work.md) | table | small | Identity of an authored thing (course, module, lesson, activity, brief, report, template,… | → `auth.users`, → `authoring.work_revision`, → `authoring.workspace` |
| [`work_revision`](../../relations/authoring/work_revision.md) | table | small | Immutable revision of a work (title, body blocks, content hash); product operations creat… | → `auth.users`, → `library.removal`, → `temporal.knowledge_batch`, → `authoring.work` |
| [`workspace`](../../relations/authoring/workspace.md) | table | unknown | — | → `auth.users` |
| [`workspace_member`](../../relations/authoring/workspace_member.md) | table | unknown | — | → `auth.users`, → `authoring.workspace` |

Functions: none.

Types: none.
