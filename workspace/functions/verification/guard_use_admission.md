---
id: "fn:verification.guard_use_admission()"
kind: function
schema: verification
name: guard_use_admission
domain: evidence
lens: machinery
overloads: ["fn:verification.guard_use_admission()"]
security: invoker
volatility: volatile
executors: []
raises: [TENANT_MISMATCH]
touches: { reads: [], writes: [] }
tokens: [verification, guard_use_admission, verification.guard_use_admission]
defined_in: []
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# verification.guard_use_admission

Domain `evidence`, lens `machinery`.

## guard_use_admission() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `TENANT_MISMATCH`.

Touches (best effort): reads —; writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: unknown.
