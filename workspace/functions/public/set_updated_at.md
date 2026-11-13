---
id: "fn:public.set_updated_at()"
kind: function
schema: public
name: set_updated_at
domain: legacy
lens: machinery
overloads: ["fn:public.set_updated_at()"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [public, set_updated_at, public.set_updated_at]
defined_in: ["20260814025347_research_starter_videos.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# public.set_updated_at

Domain `legacy`, lens `machinery`.

## set_updated_at() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260814025347_research_starter_videos.sql`.
