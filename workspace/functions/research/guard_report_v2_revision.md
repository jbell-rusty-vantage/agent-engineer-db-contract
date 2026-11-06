---
id: "fn:research.guard_report_v2_revision()"
kind: function
schema: research
name: guard_report_v2_revision
domain: research-v2
overloads: ["fn:research.guard_report_v2_revision()"]
security: invoker
volatility: volatile
executors: []
raises: [EXACT_REVISION_UNAVAILABLE, REPORT_PROJECTION_MISMATCH, TENANT_MISMATCH]
touches: { reads: [], writes: [] }
tokens: [research, guard_report_v2_revision, research.guard_report_v2_revision]
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.guard_report_v2_revision

Domain `research-v2`.

## guard_report_v2_revision() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `EXACT_REVISION_UNAVAILABLE`; `REPORT_PROJECTION_MISMATCH`; `TENANT_MISMATCH`.

Touches (best effort): reads —; writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20261024010100_research_report_v2_projection.sql`.
