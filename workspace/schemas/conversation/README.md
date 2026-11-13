---
id: "sch:conversation"
kind: schema
name: conversation
lens: private
domains: [library]
relations: 4
functions: 0
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
