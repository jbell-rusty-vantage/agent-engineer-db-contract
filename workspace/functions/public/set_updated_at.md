---
id: "fn:public.set_updated_at()"
kind: function
schema: public
name: set_updated_at
domain: research-starter-protected
overloads: ["fn:public.set_updated_at()"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [public, set_updated_at, public.set_updated_at]
defined_in: ["20260814025347_research_starter_videos.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.set_updated_at

Domain `research-starter-protected`.

## set_updated_at() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Defined in: `20260814025347_research_starter_videos.sql`.
