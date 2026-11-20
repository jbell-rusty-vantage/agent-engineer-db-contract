---
id: "fn:catalog.canonical_entity(uuid)"
kind: function
schema: catalog
name: canonical_entity
domain: identity
lens: corpus
overloads: ["fn:catalog.canonical_entity(uuid)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity], writes: [] }
tokens: [catalog, canonical_entity, catalog.canonical_entity]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.canonical_entity

Domain `identity`, lens `corpus`.

## canonical_entity(uuid) → uuid

function, stable, security definer, language plpgsql, config `search_path=""`. The record a merged record now stands for (itself when it was never merged). Use it where a read returns an entity id from rows a merge could not move.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls —.

TypeScript: `Database["catalog"]["Functions"]["canonical_entity"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
