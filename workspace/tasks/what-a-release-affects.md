---
id: "task:what-a-release-affects"
kind: task
lens: evidence
domains: [verified-knowledge, authoring, api-surface]
queries: [catalog.software_releases, ours.modules_affected_by_release, evidence.probe_revalidation_due, ours.releases_needing_review, evidence.verified_claims]
aliases: [release impact, affected by release, new version, what breaks, revalidate after release, flywheel, upgrade impact]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# What does a software release affect (our modules, probes, releases)?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`authoring`](../domains/authoring.md), [`api-surface`](../domains/api-surface.md). Queries: [`q:catalog.software_releases`](../queries/README.md), [`q:ours.modules_affected_by_release`](../queries/README.md), [`q:evidence.probe_revalidation_due`](../queries/README.md), [`q:ours.releases_needing_review`](../queries/README.md), [`q:evidence.verified_claims`](../queries/README.md).

## Navigation

`relations/api/software_releases.md` → `q:catalog.software_releases` (get `release_id`) → `functions/api/modules_affected_by_release.md` → `q:ours.modules_affected_by_release` → `q:evidence.probe_revalidation_due`.

## Operation

A release reaches three things: our head revisions that use the software (`api.modules_affected_by_release`), the probes that ran against an older version (`api.probe_revalidation_due`), and our frozen releases whose claims those probes judge (`api.releases_needing_review`).

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "release-impact-langgraph",
  "operations": [
    { "opId": "releases", "kind": "named_query", "query": "catalog.software_releases", "params": { "software_id": null, "text": "langgraph", "limit": 5 } },
    { "opId": "modules", "kind": "named_query", "query": "ours.modules_affected_by_release", "params": { "release_id": "$releases.rows[0].release_id" } },
    { "opId": "probes", "kind": "named_query", "query": "evidence.probe_revalidation_due", "params": { "as_of": null } },
    { "opId": "frozen", "kind": "named_query", "query": "ours.releases_needing_review", "params": {} }
  ]
}
```

## Expected shape

`modules`: `work_id`, `work_kind`, `work_slug`, `revision_id`, `revision_title`, `software`, `release`, `released_at`, `breaking`, `binding`, `version_spec`. `probes`: the probes whose latest cell resolved an older version of that library (`library`, `resolved_version`, `newest_version`, `reason`). `frozen`: our releases whose bound claims changed verdict since they were frozen.

## Pitfalls

The order is causal and takes time: a release makes probes due, a rerun may change a verdict, and only then does a frozen release need review, so `frozen` is empty right after a release. `modules` lists head revisions authored before the release; `breaking` rows first. Verified claims about the software were verified on the versions in `q:evidence.probe_matrix`; until the due probes rerun, say which version a claim was checked on. A signed-in user sees the modules they may read and the releases of their workspaces; database roles see all. Authoring the fix is `tasks/modules-affected-by-release.md`.
