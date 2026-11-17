---
id: "sch:conversation"
kind: schema
name: conversation
lens: private
domains: [library]
relations: 4
functions: 0
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# conversation

Lens `private`. Domains: [`library`](../../domains/library.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`context_item`](../../relations/conversation/context_item.md) | table | unknown | — | → `orchestration.artifact`, → `authoring.distribution_offer`, → `curriculum.part`, → `authoring.release_item` |
| [`context_snapshot`](../../relations/conversation/context_snapshot.md) | table | unknown | — | → `authoring.workspace` |
| [`message`](../../relations/conversation/message.md) | table | unknown | — | → `auth.users`, → `library.removal`, → `conversation.context_snapshot`, → `conversation.thread` |
| [`thread`](../../relations/conversation/thread.md) | table | unknown | A learner's or author's conversation; messages become passages with lens private. | → `auth.users`, → `authoring.workspace` |

Functions: none.

Types: none.
