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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# retrieval.on_release_item_promote

Domain `retrieval`, lens `machinery`.

## on_release_item_promote() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads —; writes —; calls [`retrieval.promote_revision_passages`](promote_revision_passages.md).

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
