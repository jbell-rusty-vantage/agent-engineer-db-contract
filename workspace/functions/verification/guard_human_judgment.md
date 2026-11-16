---
id: "fn:verification.guard_human_judgment()"
kind: function
schema: verification
name: guard_human_judgment
domain: evidence
lens: machinery
overloads: ["fn:verification.guard_human_judgment()"]
security: invoker
volatility: volatile
executors: []
raises: [HUMAN_REVIEW_NOT_AGENT_WRITABLE]
touches: { reads: [], writes: [] }
tokens: [verification, guard_human_judgment, verification.guard_human_judgment]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# verification.guard_human_judgment

Domain `evidence`, lens `machinery`.

## guard_human_judgment() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. Refuses an insert of a row that records a person's judgment (probe_verdict / claim_triage review_state other than agent_proposed, source_assessment method reviewed) unless the acting role owns the table or is a superuser: no bounded role (pipeline_agent, verifier_agent, executor_service, control_plane, app_reader, service_role) can record a human review.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `HUMAN_REVIEW_NOT_AGENT_WRITABLE`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
