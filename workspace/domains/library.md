---
id: "dom:library"
kind: domain
lens: private
schemas: [library, conversation]
aliases: [notes, passages, uploads, connections, threads, messages, my notes]
relations: [library.connection, library.connected_item, library.passage, library.preparation, library.removal, library.resource_control, conversation.thread, conversation.message, conversation.context_snapshot, conversation.context_item]
functions: [product.readable_revision, product.restricted, retrieval.index_text_item, retrieval.retire_items_for_passages]
tasks: [search-my-notes]
summary: "A workspace's own material — uploaded sources, notes, conversations — as passages indexed with lens private (or ours when released)."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# Library and conversation (private lens)

A workspace's own material — uploaded sources, notes, conversations — as passages indexed with lens private (or ours when released).

> curated (model_assisted, unreviewed) — `library.connection` + `library.connected_item` bring outside resources (uploads, repos,
> documents) into a workspace; `library.preparation` records how an item was prepared and
> `library.passage` is the indexed text unit (a revision, an uploaded artifact or a
> conversation message, with locator, text and tsvector). `library.removal` (two-step:
> `preview_removal`, `confirm_removal`) and `library.resource_control` (`set_control`) govern
> exclusion and deletion; retiring passages also retires their vector items
> (`retrieval.retire_items_for_passages`).
> 
> `conversation.thread` and `conversation.message` are the learner's or author's dialogue
> (`create_thread`, `append_message`), with `conversation.context_snapshot` /
> `conversation.context_item` recording what context a turn saw. Messages become passages too.
> 
> Everything here is lens `private`, RLS-isolated per workspace; the worker `index_passages`
> indexes them into the `learner_notes` space (or `own_content` with lens ours once a work is
> released). The product `search` operation (`ops/search.md`) calls `api.search_unified` with
> lenses private+ours and the caller's workspace ids, then applies the readability rules
> (member of the workspace, readable revision, shared asset, own or workspace-visible thread).
> Trap: calling `q:retrieval.search_unified` with lens private and no `workspace_ids` returns
> nothing — private items are returned only for the workspaces passed in.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`library.connection`](../relations/library/connection.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`library.connected_item`](../relations/library/connected_item.md) | table | PK (id); unique (tenant_id, workspace_id, connection_id, external_id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, work_id); RLS | helpers only |
| [`library.passage`](../relations/library/passage.md) | Indexed text unit of a workspace's own material (a revision, an uploaded artifact or a conversation message);… | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`library.preparation`](../relations/library/preparation.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`library.removal`](../relations/library/removal.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`library.resource_control`](../relations/library/resource_control.md) | table | PK (tenant_id, workspace_id, work_id); RLS | helpers only |
| [`conversation.thread`](../relations/conversation/thread.md) | A learner's or author's conversation; messages become passages with lens private. | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`conversation.message`](../relations/conversation/message.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, thread_id, seq); RLS | helpers only |
| [`conversation.context_snapshot`](../relations/conversation/context_snapshot.md) | table | PK (id); unique (tenant_id, workspace_id, digest), (tenant_id, workspace_id, id); RLS | helpers only |
| [`conversation.context_item`](../relations/conversation/context_item.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, snapshot_id, item_key); RLS | helpers only |

## Functions

[`product.readable_revision`](../functions/product/readable_revision.md), [`product.restricted`](../functions/product/restricted.md), [`retrieval.index_text_item`](../functions/retrieval/index_text_item.md), [`retrieval.retire_items_for_passages`](../functions/retrieval/retire_items_for_passages.md)

## Named queries

[`q:retrieval.search_unified`](../queries/README.md)

## Tasks

[`search-my-notes`](../tasks/search-my-notes.md)

Schemas: [`library`](../schemas/library/README.md), [`conversation`](../schemas/conversation/README.md).
