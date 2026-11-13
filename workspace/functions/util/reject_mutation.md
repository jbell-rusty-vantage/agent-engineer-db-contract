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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# util.reject_mutation

Domain `api-surface`, lens `machinery`.

## reject_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. BEFORE UPDATE OR DELETE trigger enforcing append-only tables.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260826000100_foundation.sql`.
