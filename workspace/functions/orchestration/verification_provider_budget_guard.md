---
id: "fn:orchestration.verification_provider_budget_guard()"
kind: function
schema: orchestration
name: verification_provider_budget_guard
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_provider_budget_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification provider budget immutable identity, verification provider budgets are append-only]
touches: { reads: [], writes: [] }
tokens: [orchestration, verification_provider_budget_guard, orchestration.verification_provider_budget_guard]
defined_in: ["20260906012000_harden_verification_provider_accounting.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_budget_guard

Domain `orchestration-ledger`.

## verification_provider_budget_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification provider budget immutable identity`; `verification provider budgets are append-only`.

Defined in: `20260906012000_harden_verification_provider_accounting.sql`.
