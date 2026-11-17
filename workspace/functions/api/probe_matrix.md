---
id: "fn:api.probe_matrix(text)"
kind: function
schema: api
name: probe_matrix
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.probe_matrix(text)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [verification.probe, verification.probe_run], writes: [] }
tokens: [api, probe_matrix, api.probe_matrix]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.probe_matrix

Domain `verified-knowledge`, lens `corpus`.

## probe_matrix(text) → TABLE(cell_label text, cell jsonb, outcome text, resolved jsonb, observations jsonb, started_at timestamp with time zone, run_id uuid, locator_id uuid)

function, stable, security definer, language sql, config `search_path=""`. The latest run of a probe in each cell: outcome, the resolved package versions and what was observed. Cells are dates (what a tutorial-follower got that day) or explicit pins.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_probe` | `text` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_run`](../../relations/verification/probe_run.md); writes —; calls —.

Named queries: `q:evidence.probe_matrix`.

TypeScript: `Database["api"]["Functions"]["probe_matrix"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
