---
id: "fn:api.releases_needing_review()"
kind: function
schema: api
name: releases_needing_review
domain: api-surface
lens: corpus
overloads: ["fn:api.releases_needing_review()"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [authoring.release, authoring.release_item, authoring.revision_binding, evidence.claim, verification.probe_verdict], writes: [] }
tokens: [api, releases_needing_review, api.releases_needing_review]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.releases_needing_review

Domain `api-surface`, lens `corpus`.

## releases_needing_review() → TABLE(release_id uuid, release_no integer, root_work_id uuid, released_at timestamp with time zone, claim_id uuid, statement text, verdict_at_release text, verdict_now text, status_now text, decided_at timestamp with time zone)

function, stable, security definer, language sql, config `search_path=""`. Loop 5: releases whose bound claims have a current probe verdict, decided after the release, that differs from the verdict current when the release was frozen; a human confirmation of the same verdict does not trigger.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`authoring.release`](../../relations/authoring/release.md), [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`evidence.claim`](../../relations/evidence/claim.md), [`verification.probe_verdict`](../../relations/verification/probe_verdict.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["releases_needing_review"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
