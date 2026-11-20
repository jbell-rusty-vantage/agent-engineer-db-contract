---
id: "fn:product.session_reads_revision(uuid)"
kind: function
schema: product
name: session_reads_revision
domain: product-operations
lens: ours
overloads: ["fn:product.session_reads_revision(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [product, session_reads_revision, product.session_reads_revision]
defined_in: ["20261116120000_build08_api_default_closed.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# product.session_reads_revision

Domain `product-operations`, lens `ours`. Used by views: [`api.works_authored`](../../relations/api/works_authored.md).

## session_reads_revision(uuid) → boolean

function, stable, security definer, language sql, config `search_path=""`. True when the reading session may see a work revision: a signed-in user under product.readable_revision (a member of the owning workspace, or a release that includes the revision is offered or distributed to them); a trusted role always. The row filter of api.works_authored, api.modules_using_software and api.modules_affected_by_release.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `rid` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads —; writes —; calls [`product.readable_revision`](readable_revision.md), [`product.session_reader`](session_reader.md).

TypeScript: `Database["product"]["Functions"]["session_reads_revision"]`.

Defined in: `20261116120000_build08_api_default_closed.sql`.
