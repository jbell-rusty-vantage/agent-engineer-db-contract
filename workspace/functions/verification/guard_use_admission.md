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
defined_in: ["20261113150000_build08_ks_admission_verified_claims.sql", "20261113150100_build08_loop6_fixup_require_admitted_use.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# verification.guard_use_admission

Domain `evidence`, lens `machinery`.

## guard_use_admission() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `TENANT_MISMATCH`.

Touches (best effort): reads —; writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md), [`verification.require_admitted_use`](require_admitted_use.md).

Defined in: `20261113150000_build08_ks_admission_verified_claims.sql`, `20261113150100_build08_loop6_fixup_require_admitted_use.sql`.
