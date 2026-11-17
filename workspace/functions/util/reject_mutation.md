---
id: "fn:util.reject_mutation()"
kind: function
schema: util
name: reject_mutation
domain: api-surface
lens: machinery
overloads: ["fn:util.reject_mutation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, reject_mutation, util.reject_mutation]
defined_in: ["20260826000100_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# util.reject_mutation

Domain `api-surface`, lens `machinery`.

## reject_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. BEFORE UPDATE OR DELETE trigger enforcing append-only tables.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260826000100_foundation.sql`.
