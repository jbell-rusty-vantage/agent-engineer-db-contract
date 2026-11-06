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
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
