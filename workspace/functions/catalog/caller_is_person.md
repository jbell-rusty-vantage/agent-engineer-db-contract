---
id: "fn:catalog.caller_is_person()"
kind: function
schema: catalog
name: caller_is_person
domain: identity
lens: corpus
overloads: ["fn:catalog.caller_is_person()"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.proposal], writes: [] }
tokens: [catalog, caller_is_person, catalog.caller_is_person]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.caller_is_person

Domain `identity`, lens `corpus`.

## caller_is_person() → boolean

function, stable, security invoker, language sql, config `search_path=""`. True when the session role is the owner of catalog.proposal or a superuser: the same test verification.guard_human_judgment applies. Agent roles are never a person. The person's own path is unit RV10.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.proposal`](../../relations/catalog/proposal.md); writes —; calls [`catalog.caller_role`](caller_role.md).

TypeScript: `Database["catalog"]["Functions"]["caller_is_person"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
