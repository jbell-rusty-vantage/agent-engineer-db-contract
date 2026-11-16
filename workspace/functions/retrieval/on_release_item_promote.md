---
id: "fn:retrieval.on_release_item_promote()"
kind: function
schema: retrieval
name: on_release_item_promote
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.on_release_item_promote()"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [retrieval, on_release_item_promote, retrieval.on_release_item_promote]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# retrieval.on_release_item_promote

Domain `retrieval`, lens `machinery`.

## on_release_item_promote() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads —; writes —; calls [`retrieval.promote_revision_passages`](promote_revision_passages.md).

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
