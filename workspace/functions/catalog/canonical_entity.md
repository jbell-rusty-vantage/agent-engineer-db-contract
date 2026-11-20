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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
