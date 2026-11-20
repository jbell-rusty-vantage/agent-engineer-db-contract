---
id: "fn:product.dispatch_authoring_read(uuid,text,jsonb,uuid,client_grant)"
kind: function
schema: product
name: dispatch_authoring_read
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_authoring_read(uuid,text,jsonb,uuid,client_grant)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.event, authoring.revision_binding, authoring.runtime_requirement, authoring.work, authoring.work_revision, authoring.workspace, authoring.workspace_member, conversation.message, conversation.thread, curriculum.outcome, curriculum.outcome_alignment, curriculum.part, curriculum.prerequisite, curriculum.requirement, curriculum.requirement_option, inquiry.assertion], writes: [] }
tokens: [product, dispatch_authoring_read, product.dispatch_authoring_read]
defined_in: ["20261116140000_build08_authoring_review_reads.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# product.dispatch_authoring_read

Domain `product-operations`, lens `ours`.

## dispatch_authoring_read(uuid, text, jsonb, uuid, access.client_grant) → jsonb

function, stable, security invoker, language plpgsql, config `search_path=""`. Product reads list_workspaces, get_revision_structure and list_reviews, routed by api.product_read. The principal comes from product.actor() and the client grant from product.client_grant; membership (product.role_in) decides what is visible: a caller sees only its own memberships, the structure of revisions in workspaces it belongs to, and the review requests, reviews and workspace-visible hand-over replies of a workspace it belongs to.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `op` | `text` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |
| `g` | `access.client_grant` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.event`](../../relations/authoring/event.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.runtime_requirement`](../../relations/authoring/runtime_requirement.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`authoring.workspace`](../../relations/authoring/workspace.md), [`authoring.workspace_member`](../../relations/authoring/workspace_member.md), [`conversation.message`](../../relations/conversation/message.md), [`conversation.thread`](../../relations/conversation/thread.md), [`curriculum.outcome`](../../relations/curriculum/outcome.md), [`curriculum.outcome_alignment`](../../relations/curriculum/outcome_alignment.md), [`curriculum.part`](../../relations/curriculum/part.md), [`curriculum.prerequisite`](../../relations/curriculum/prerequisite.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`curriculum.requirement_option`](../../relations/curriculum/requirement_option.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md); writes —; calls [`product.fail`](fail.md), [`product.require_role`](require_role.md), [`product.role_in`](role_in.md), [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["dispatch_authoring_read"]`.

Defined in: `20261116140000_build08_authoring_review_reads.sql`.
