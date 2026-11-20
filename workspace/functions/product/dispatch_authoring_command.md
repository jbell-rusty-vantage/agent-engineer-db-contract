---
id: "fn:product.dispatch_authoring_command(uuid,text,uuid,jsonb,uuid,client_grant)"
kind: function
schema: product
name: dispatch_authoring_command
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_authoring_command(uuid,text,uuid,jsonb,uuid,client_grant)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.event, authoring.work_revision, conversation.message, conversation.thread], writes: [] }
tokens: [product, dispatch_authoring_command, product.dispatch_authoring_command]
defined_in: ["20261116140000_build08_authoring_review_reads.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# product.dispatch_authoring_command

Domain `product-operations`, lens `ours`.

## dispatch_authoring_command(uuid, text, uuid, jsonb, uuid, access.client_grant) → jsonb

function, volatile, security invoker, language plpgsql, config `search_path=""`. Product command mark_ready_for_review, routed by api.product_command: an owner or editor of the workspace marks an exact revision ready for a person's review (authoring.event kind revision_proposed) with the exposure closure the database computes at the ceiling, the note and optionally the workspace conversation that holds the hand-over. It records no review and no decision; actor_kind is agent for an MCP, harness or API client grant, as in product.dispatch_command.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `op` | `text` | — | — |
| `head` | `uuid` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |
| `g` | `access.client_grant` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.event`](../../relations/authoring/event.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`conversation.message`](../../relations/conversation/message.md), [`conversation.thread`](../../relations/conversation/thread.md); writes —; calls [`product.exposure`](exposure.md), [`product.fail`](fail.md), [`product.new_event`](new_event.md), [`product.nonblank`](nonblank.md), [`product.require_role`](require_role.md).

TypeScript: `Database["product"]["Functions"]["dispatch_authoring_command"]`.

Defined in: `20261116140000_build08_authoring_review_reads.sql`.
