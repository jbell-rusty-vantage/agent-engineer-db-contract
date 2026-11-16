---
id: "task:what-is-due"
kind: task
lens: evidence
domains: [source-intelligence, verified-knowledge, authoring]
queries: [acquisition.attention_due, evidence.probe_revalidation_due, ours.releases_needing_review, acquisition.attention_policies, facts.changes_since]
aliases: [due, due list, what needs attention, watch due, probes to rerun, revalidation, releases needing review, stale, overdue]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# What is due (sources to sweep, probes to rerun, releases to review)?

Domains: [`source-intelligence`](../domains/source-intelligence.md), [`verified-knowledge`](../domains/verified-knowledge.md), [`authoring`](../domains/authoring.md). Queries: [`q:acquisition.attention_due`](../queries/README.md), [`q:evidence.probe_revalidation_due`](../queries/README.md), [`q:ours.releases_needing_review`](../queries/README.md), [`q:acquisition.attention_policies`](../queries/README.md), [`q:facts.changes_since`](../queries/README.md).

## Navigation

`START_HERE.md` (L2) → `functions/api/attention_due.md`, `functions/api/probe_revalidation_due.md`, `functions/api/releases_needing_review.md` → the three queries below.

## Operation

Three lists, one per kind of work: `api.attention_due` (sources to sweep), `api.probe_revalidation_due` (probes to rerun), `api.releases_needing_review` (our releases to review). An empty list is an answer.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "due-now",
  "operations": [
    { "opId": "sweeps", "kind": "named_query", "query": "acquisition.attention_due", "params": { "as_of": null } },
    { "opId": "probes", "kind": "named_query", "query": "evidence.probe_revalidation_due", "params": { "as_of": null } },
    { "opId": "releases", "kind": "named_query", "query": "ours.releases_needing_review", "params": {} }
  ]
}
```

`as_of` null means now. What was learned since a time is `q:facts.changes_since`; every policy with its last sweep is `q:acquisition.attention_policies`.

## Expected shape

`sweeps`: `policy_id`, `slug`, `watch_level`, `reason` (a trigger event inside its window, or the cadence elapsed), `trigger_ref`, `last_sweep_at`, `budget_usd_per_run`, `mission`. `probes`: `probe`, `cell_label`, `last_run_at`, `library`, `resolved_version`, `newest_version`, `newest_released_at`, `reason`. `releases`: `release_id`, `release_no`, `root_work_id`, `released_at`, `claim_id`, `statement`, `verdict_at_release`, `verdict_now`, `status_now`, `decided_at`.

## Pitfalls

These readers filter on the session tenant: a database session without `app.tenant_id` gets no rows, which reads as "nothing due"; check `q:knowledge.head` first. W0 and paused policies are never due. A probe is due only on its latest unpinned cell; a pinned cell never goes stale. A release needs review when a bound claim's verdict changed after the release was frozen; a human confirmation of the same verdict does not count. A signed-in user sees the releases of workspaces they are a member of; app_reader and the pipeline roles see all. The due lists say what to do, they do not do it: a watch mission runs the sweep under the policy budget.
