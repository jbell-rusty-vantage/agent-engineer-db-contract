---
id: "fn:public.protect_factory_episode_identity_and_terminal()"
kind: function
schema: public
name: protect_factory_episode_identity_and_terminal
domain: research-starter-protected
overloads: ["fn:public.protect_factory_episode_identity_and_terminal()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [Factory episode identity is immutable, Terminal factory episode status is inconsistent, Terminal factory episodes are immutable, Terminal factory episodes cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [public, protect_factory_episode_identity_and_terminal, public.protect_factory_episode_identity_and_terminal]
defined_in: ["20260822050000_factory_ledger_safety.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.protect_factory_episode_identity_and_terminal

Domain `research-starter-protected`.

## protect_factory_episode_identity_and_terminal() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `Factory episode identity is immutable`; `Terminal factory episode status is inconsistent`; `Terminal factory episodes are immutable`; `Terminal factory episodes cannot be deleted`.

Defined in: `20260822050000_factory_ledger_safety.sql`.
