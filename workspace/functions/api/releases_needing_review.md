---
id: "fn:api.releases_needing_review()"
kind: function
schema: api
name: releases_needing_review
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.releases_needing_review()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [authoring.release, authoring.release_item, authoring.revision_binding, evidence.claim, verification.probe_verdict], writes: [] }
tokens: [api, releases_needing_review, api.releases_needing_review]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql", "20261116120000_build08_api_default_closed.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.releases_needing_review

Domain `verified-knowledge`, lens `corpus`.

## releases_needing_review() → TABLE(release_id uuid, release_no integer, root_work_id uuid, released_at timestamp with time zone, claim_id uuid, statement text, verdict_at_release text, verdict_now text, status_now text, decided_at timestamp with time zone)

function, stable, security definer, language sql, config `search_path=""`. Loop 5: releases whose bound claims have a current probe verdict, decided after the release, that differs from the verdict current when the release was frozen; a human confirmation of the same verdict does not trigger. A signed-in user sees the releases of the workspaces they are a member of; database roles see all.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`authoring.release`](../../relations/authoring/release.md), [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`evidence.claim`](../../relations/evidence/claim.md), [`verification.probe_verdict`](../../relations/verification/probe_verdict.md); writes —; calls [`product.session_reads_workspace`](../product/session_reads_workspace.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:ours.releases_needing_review`.

TypeScript: `Database["api"]["Functions"]["releases_needing_review"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`, `20261116120000_build08_api_default_closed.sql`.
