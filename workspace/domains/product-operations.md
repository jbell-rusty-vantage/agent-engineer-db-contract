---
id: "dom:product-operations"
kind: domain
lens: ours
schemas: [product]
aliases: [product api, dispatch, commands, reads, worker, ops]
relations: [authoring.command, authoring.event, access.client_grant]
functions: [api.product_command, api.product_read, api.product_worker, product.actor, product.dispatch_command, product.dispatch_read, product.dispatch_research_command, product.dispatch_research_read, product.dispatch_worker, product.fail, product.new_event, product.register_artifact, product.require_role, product.sha256_text, product.tenant]
tasks: [modules-affected-by-release, search-my-notes]
summary: "The product's command/read/worker dispatchers; every `when '<op>' then` arm has a page under ops/."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# Product operations (dispatchers and helpers)

The product's command/read/worker dispatchers; every `when '<op>' then` arm has a page under ops/.

> curated (model_assisted, unreviewed) — `api.product_command(p_workspace_id, p_operation, p_idempotency_key, p_expected_head,
> p_payload)` resolves the actor and client grant, computes the input digest, replays a prior
> `authoring.command` with the same idempotency key (CONFLICT when the input differs) and
> dispatches to `product.dispatch_command`, which falls through to
> `product.dispatch_research_command` for Build 07 research operations. `api.product_read`
> dispatches to `product.dispatch_read` then `product.dispatch_research_read`;
> `api.product_worker` (service_role only) to `product.dispatch_worker`. Unknown operations
> fail with `UNKNOWN_OPERATION`; other failures are `product.fail(code, detail)` exceptions
> (NOT_FOUND, FORBIDDEN, CONFLICT, VALIDATION, EXPOSURE_BLOCKED, LIMIT_EXCEEDED).
> 
> The generator parses these bodies into one page per operation (`ops/<operation>.md`:
> dispatcher, how to call, relations the arm touches, helpers called) and lists them in
> INDEX.md. Helpers: `product.require_role` / `product.role_in` (workspace roles),
> `product.new_event` (authoring events), `product.register_artifact` (content-addressed
> uploads), `product.insert_revision` / `product.exposure` (authoring), `product.finalize`
> (assessment), `product.dataset_*` (datasets), `product.support_*` (inquiry support).
> 
> Trap: the page lists relations by scanning the arm text — joins inside helper functions are
> attributed to the helper's own page, not the operation.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`authoring.command`](../relations/authoring/command.md) | table | PK (id); unique (tenant_id, workspace_id, actor_id, idempotency_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.event`](../relations/authoring/event.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, dedupe_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`access.client_grant`](../relations/access/client_grant.md) | table | PK (id); unique (tenant_id, id), (token_sha256); RLS | helpers only |

## Functions

[`api.product_command`](../functions/api/product_command.md), [`api.product_read`](../functions/api/product_read.md), [`api.product_worker`](../functions/api/product_worker.md), [`product.actor`](../functions/product/actor.md), [`product.dispatch_command`](../functions/product/dispatch_command.md), [`product.dispatch_read`](../functions/product/dispatch_read.md), [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md), [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md), [`product.dispatch_worker`](../functions/product/dispatch_worker.md), [`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.register_artifact`](../functions/product/register_artifact.md), [`product.require_role`](../functions/product/require_role.md), [`product.sha256_text`](../functions/product/sha256_text.md), [`product.tenant`](../functions/product/tenant.md)

## Tasks

[`modules-affected-by-release`](../tasks/modules-affected-by-release.md), [`search-my-notes`](../tasks/search-my-notes.md)

Schemas: [`product`](../schemas/product/README.md).
