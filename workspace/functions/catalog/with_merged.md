---
id: "fn:catalog.with_merged(uuid[])"
kind: function
schema: catalog
name: with_merged
domain: identity
lens: corpus
overloads: ["fn:catalog.with_merged(uuid[])"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity], writes: [] }
tokens: [catalog, with_merged, catalog.with_merged]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.with_merged

Domain `identity`, lens `corpus`.

## with_merged(uuid[]) → uuid[]

function, stable, security definer, language sql, config `search_path=""`. The given records plus every record merged into them.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_ids` | `uuid[]` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls [`catalog.canonical_entity`](canonical_entity.md).

TypeScript: `Database["catalog"]["Functions"]["with_merged"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
