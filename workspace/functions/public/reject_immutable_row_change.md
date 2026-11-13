---
id: "fn:public.reject_immutable_row_change()"
kind: function
schema: public
name: reject_immutable_row_change
domain: legacy
lens: machinery
overloads: ["fn:public.reject_immutable_row_change()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["% rows are append-only"]
touches: { reads: [], writes: [] }
tokens: [public, reject_immutable_row_change, public.reject_immutable_row_change]
defined_in: ["20260822050000_factory_ledger_safety.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# public.reject_immutable_row_change

Domain `legacy`, lens `machinery`.

## reject_immutable_row_change() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `% rows are append-only`.

Defined in: `20260822050000_factory_ledger_safety.sql`.
