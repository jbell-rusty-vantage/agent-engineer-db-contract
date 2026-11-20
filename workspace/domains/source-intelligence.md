---
id: "dom:source-intelligence"
kind: domain
lens: evidence
schemas: []
aliases: [source registry, source assessment, track record, source trust, authority score, attention policy, watch level, sweep, due list, what to watch]
relations: [api.source_registry, api.source_track_record, api.attention_policies, evidence.source_assessment, acquisition.attention_policy, acquisition.attention_sweep]
functions: [api.attention_due, api.raise_attention_sweep, api.record_source_assessment, api.settle_attention_sweep]
tasks: [how-trusted-is-source, run-attention-sweep, triage-claims-and-assess-sources, what-agents-may-not-write, what-is-due, write-verification-chain]
summary: "What we know about each source on each topic, from the claims it stated and how they checked out; and what we watch, how often, on what budget."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# Source intelligence and attention (registry, track record, watch policies)

What we know about each source on each topic, from the claims it stated and how they checked out; and what we watch, how often, on what budget.

> curated (model_assisted, unreviewed) — **Source registry.** `evidence.source_assessment` records what we know about a source (a
> channel, an actor, an organization, a person) on a topic at a time, as components and never
> a bare score: the role prior (`source_role_code`), `conflict_of_interest`,
> `method_disclosure`, the track record from verdicts (`claims_observed`, `claims_checked`,
> `confirmed`, `qualified`, `refuted`), `median_lead_days` against the first-party docs and
> the sweep `noise_ratio`. Rows are append-only; `api.source_registry` shows the latest per
> source and topic with the derived `authority_score` and a recommended watch level, which is
> suggested only from five checked claims. Claims a source checked about itself are counted
> in `self_checked` and not scored.
> 
> **Track record.** `api.source_track_record` is every claim a source stated with its latest
> verdict: the rows behind an assessment's counts. A claim and its verdict are read in the
> verified-knowledge domain (`q:evidence.claim`, `q:evidence.claim_verdicts`).
> 
> **Attention.** `acquisition.attention_policy` says what we watch, how often (`cadence`,
> `triggers`), how deep (`depth`, `selection`) and on what budget. Watch levels: W0 ignore
> (registered, never swept), W1 reference, W2 sampled, W3 release-coupled. One execution of a
> policy is an `acquisition.attention_sweep` (window, items seen, selected and captured,
> spend); every fetch it makes carries the sweep. `api.attention_policies` shows each policy
> with its last sweep and totals.
> 
> **Due.** `api.attention_due` is the contract a watch mission calls: the policies due at a
> time because a trigger event happened inside its window since the last sweep, or because
> the cadence elapsed. W0 and paused policies are never due. The other due lists
> (`api.probe_revalidation_due`, `api.releases_needing_review`) are in the verified-knowledge
> domain; `tasks/what-is-due.md` reads all three.
> 
> Start with `q:evidence.source_registry` for trust and `q:acquisition.attention_due` for
> work. An agent role records a prior or a derived assessment with
> `api.record_source_assessment` and runs a sweep with `api.raise_attention_sweep` and
> `api.settle_attention_sweep` (`tasks/run-attention-sweep.md`). Policies (what to watch,
> on what budget) and reviewed assessments are a person's decisions: no agent function
> writes them, and a read role writes nothing.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`api.source_registry`](../relations/api/source_registry.md) | Latest assessment per source and topic: role prior, conflict of interest, method disclosure, track record fro… | — | helpers only |
| [`api.source_track_record`](../relations/api/source_track_record.md) | Every claim a source stated, with its latest verdict: the rows behind an assessment's counts. | — | helpers only |
| [`api.attention_policies`](../relations/api/attention_policies.md) | Attention policies (what we watch, watch level W0 to W3, cadence, triggers, budget) with their last sweep and… | — | helpers only |
| [`evidence.source_assessment`](../relations/evidence/source_assessment.md) | Loop 4: what we know about a source (channel, actor, organization, person) on a topic at a time. Components, … | PK (id); RLS | `control_plane`, `pipeline_agent`, `verifier_agent` |
| [`acquisition.attention_policy`](../relations/acquisition/attention_policy.md) | Loop 4: what we watch, how often (cadence, triggers), how deep (depth, selection) and on what budget. W0 igno… | PK (id); unique (tenant_id, slug); RLS | `control_plane`, `pipeline_agent` |
| [`acquisition.attention_sweep`](../relations/acquisition/attention_sweep.md) | Loop 4: one execution of an attention policy: trigger, window, items seen / selected / captured, rejections b… | PK (id); RLS | `control_plane`, `pipeline_agent` |

## Functions

[`api.attention_due`](../functions/api/attention_due.md), [`api.raise_attention_sweep`](../functions/api/raise_attention_sweep.md), [`api.record_source_assessment`](../functions/api/record_source_assessment.md), [`api.settle_attention_sweep`](../functions/api/settle_attention_sweep.md)

## Named queries

[`q:acquisition.attention_due`](../queries/README.md), [`q:acquisition.attention_policies`](../queries/README.md), [`q:acquisition.open_sweeps`](../queries/README.md), [`q:evidence.source_registry`](../queries/README.md), [`q:evidence.source_track_record`](../queries/README.md)

## Tasks

[`how-trusted-is-source`](../tasks/how-trusted-is-source.md), [`run-attention-sweep`](../tasks/run-attention-sweep.md), [`triage-claims-and-assess-sources`](../tasks/triage-claims-and-assess-sources.md), [`what-agents-may-not-write`](../tasks/what-agents-may-not-write.md), [`what-is-due`](../tasks/what-is-due.md), [`write-verification-chain`](../tasks/write-verification-chain.md)

Schemas: —.
