---
id: "sch:conversation"
kind: schema
name: conversation
lens: private
domains: [library]
relations: 4
functions: 0
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
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
