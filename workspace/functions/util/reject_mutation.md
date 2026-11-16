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
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# util.reject_mutation

Domain `api-surface`, lens `machinery`.

## reject_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. BEFORE UPDATE OR DELETE trigger enforcing append-only tables.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260826000100_foundation.sql`.
