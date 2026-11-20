---
id: "fn:api.probe_revalidation_due(timestamptz)"
kind: function
schema: api
name: probe_revalidation_due
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.probe_revalidation_due(timestamptz)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.software_releases, catalog.entity, verification.probe, verification.probe_run], writes: [] }
tokens: [api, probe_revalidation_due, api.probe_revalidation_due]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql", "20261113160200_build08_loop5_fixup_revalidation_due.sql", "20261113160300_build08_loop5_fixup_latest_cell.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.probe_revalidation_due

Domain `verified-knowledge`, lens `corpus`.

## probe_revalidation_due(timestamp with time zone) → TABLE(probe_id uuid, probe text, cell_label text, last_run_at timestamp with time zone, library text, resolved_version text, newest_version text, newest_released_at timestamp with time zone, reason text)

function, stable, security definer, language sql, config `search_path=""`. Loop 5 (D-76): probes whose latest (unpinned) cell resolved a different, older version of a subject library than its newest catalogued release: the probe-revalidation policy rebuilds the latest cell and reruns them.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_as_of` | `timestamp with time zone` | `now()` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.software_releases`](../../relations/api/software_releases.md), [`catalog.entity`](../../relations/catalog/entity.md), [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_run`](../../relations/verification/probe_run.md); writes —; calls —.

Named queries: `q:evidence.probe_revalidation_due`.

TypeScript: `Database["api"]["Functions"]["probe_revalidation_due"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`, `20261113160200_build08_loop5_fixup_revalidation_due.sql`, `20261113160300_build08_loop5_fixup_latest_cell.sql`.
