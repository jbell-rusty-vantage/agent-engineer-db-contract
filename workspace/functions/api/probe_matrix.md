---
id: "fn:api.probe_matrix(text)"
kind: function
schema: api
name: probe_matrix
domain: api-surface
lens: corpus
overloads: ["fn:api.probe_matrix(text)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [verification.probe, verification.probe_run], writes: [] }
tokens: [api, probe_matrix, api.probe_matrix]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.probe_matrix

Domain `api-surface`, lens `corpus`.

## probe_matrix(text) → TABLE(cell_label text, cell jsonb, outcome text, resolved jsonb, observations jsonb, started_at timestamp with time zone, run_id uuid, locator_id uuid)

function, stable, security definer, language sql, config `search_path=""`. The latest run of a probe in each cell: outcome, the resolved package versions and what was observed. Cells are dates (what a tutorial-follower got that day) or explicit pins.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_probe` | `text` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_run`](../../relations/verification/probe_run.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["probe_matrix"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
