---
id: "fn:util.set_updated_at()"
kind: function
schema: util
name: set_updated_at
domain: api-surface
lens: machinery
overloads: ["fn:util.set_updated_at()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, set_updated_at, util.set_updated_at]
defined_in: ["20260826000100_foundation.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# util.set_updated_at

Domain `api-surface`, lens `machinery`.

## set_updated_at() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. BEFORE UPDATE trigger maintaining updated_at. Distinct from public.set_updated_at, which belongs to the pre-research pipeline and must not be touched.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260826000100_foundation.sql`.
