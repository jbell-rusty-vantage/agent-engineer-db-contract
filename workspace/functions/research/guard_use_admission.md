---
id: "fn:research.guard_use_admission()"
kind: function
schema: research
name: guard_use_admission
domain: research-v2
overloads: ["fn:research.guard_use_admission()"]
security: invoker
volatility: volatile
executors: []
raises: [TENANT_MISMATCH]
touches: { reads: [], writes: [] }
tokens: [research, guard_use_admission, research.guard_use_admission]
defined_in: ["20261024010100_research_report_v2_projection.sql", "20261024010200_research_admission_normalized_values.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.guard_use_admission

Domain `research-v2`.

## guard_use_admission() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `TENANT_MISMATCH`.

Touches (best effort): reads —; writes —; calls [`research.require_admitted_use`](require_admitted_use.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20261024010100_research_report_v2_projection.sql`, `20261024010200_research_admission_normalized_values.sql`.
