---
id: "fn:catalog.caller_role()"
kind: function
schema: catalog
name: caller_role
domain: identity
lens: corpus
overloads: ["fn:catalog.caller_role()"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [catalog, caller_role, catalog.caller_role]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.caller_role

Domain `identity`, lens `corpus`.

## caller_role() → text

function, stable, security invoker, language sql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

TypeScript: `Database["catalog"]["Functions"]["caller_role"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
