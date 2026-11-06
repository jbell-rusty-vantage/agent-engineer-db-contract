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
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.protect_factory_episode_identity_and_terminal

Domain `research-starter-protected`.

## protect_factory_episode_identity_and_terminal() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `Factory episode identity is immutable`; `Terminal factory episode status is inconsistent`; `Terminal factory episodes are immutable`; `Terminal factory episodes cannot be deleted`.

Defined in: `20260822050000_factory_ledger_safety.sql`.
