---
id: "fn:api.interview_outputs(uuid)"
kind: function
schema: api
name: interview_outputs
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.interview_outputs(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [acquisition.attention_policy, acquisition.attention_sweep, verification.probe, verification.probe_run], writes: [] }
tokens: [api, interview_outputs, api.interview_outputs]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.interview_outputs

Domain `verified-knowledge`, lens `corpus`.

## interview_outputs(uuid) → TABLE(output_kind text, output_id uuid, slug text, title text, state text, runs bigint, last_run_at timestamp with time zone)

function, stable, security definer, language sql, config `search_path=""`. What a design interview (conversation.thread purpose interview) produced: probes and attention policies, and whether each has run.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_thread` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`acquisition.attention_policy`](../../relations/acquisition/attention_policy.md), [`acquisition.attention_sweep`](../../relations/acquisition/attention_sweep.md), [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_run`](../../relations/verification/probe_run.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["interview_outputs"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
