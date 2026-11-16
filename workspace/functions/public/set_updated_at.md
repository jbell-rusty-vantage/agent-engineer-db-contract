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
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# public.set_updated_at

Domain `legacy`, lens `machinery`.

## set_updated_at() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260814025347_research_starter_videos.sql`.
