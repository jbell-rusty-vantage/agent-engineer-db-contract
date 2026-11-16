---
id: "fn:api.library_dossier(text)"
kind: function
schema: api
name: library_dossier
domain: api-surface
lens: corpus
overloads: ["fn:api.library_dossier(text)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.probes, api.source_registry, catalog.entity, catalog.relationship, evidence.claim, evidence.claim_subject], writes: [] }
tokens: [api, library_dossier, api.library_dossier]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.library_dossier

Domain `api-surface`, lens `corpus`.

## library_dossier(text) → jsonb

function, stable, security definer, language sql, config `search_path=""`. One call for the report a module embeds: releases (count, latest, recent), claims by status, open community claims, probes with their per-cell outcomes and verdicts, and the ranked sources on this library.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_library` | `text` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.probes`](../../relations/api/probes.md), [`api.source_registry`](../../relations/api/source_registry.md), [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.claim_subject`](../../relations/evidence/claim_subject.md); writes —; calls [`api.probe_matrix`](probe_matrix.md).

TypeScript: `Database["api"]["Functions"]["library_dossier"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
