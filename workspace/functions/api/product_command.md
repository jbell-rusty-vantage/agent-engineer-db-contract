---
id: "fn:api.product_command(uuid,text,text,uuid,jsonb)"
kind: function
schema: api
name: product_command
domain: api-surface
lens: ours
overloads: ["fn:api.product_command(uuid,text,text,uuid,jsonb)"]
security: definer
volatility: volatile
executors: [authenticated]
raises: []
touches: { reads: [access.client_grant], writes: [authoring.command] }
tokens: [api, product_command, api.product_command]
defined_in: ["20261105010300_product_api.sql", "20261116140000_build08_authoring_review_reads.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.product_command

Domain `api-surface`, lens `ours`.

## product_command(uuid, text, text, uuid, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_workspace_id` | `uuid` | — | — |
| `p_operation` | `text` | — | — |
| `p_idempotency_key` | `text` | — | — |
| `p_expected_head` | `uuid` | — | — |
| `p_payload` | `jsonb` | — | — |

Execute: `authenticated`.

Touches (best effort): reads [`access.client_grant`](../../relations/access/client_grant.md); writes [`authoring.command`](../../relations/authoring/command.md); calls [`product.actor`](../product/actor.md), [`product.client_grant`](../product/client_grant.md), [`product.dispatch_authoring_command`](../product/dispatch_authoring_command.md), [`product.dispatch_command`](../product/dispatch_command.md), [`product.fail`](../product/fail.md), [`product.personal_workspace`](../product/personal_workspace.md), [`product.role_in`](../product/role_in.md), [`product.sha256_text`](../product/sha256_text.md), [`product.tenant`](../product/tenant.md).

TypeScript: `Database["api"]["Functions"]["product_command"]`.

Defined in: `20261105010300_product_api.sql`, `20261116140000_build08_authoring_review_reads.sql`.
