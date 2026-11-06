---
id: "fn:research.guard_report_projection()"
kind: function
schema: research
name: guard_report_projection
domain: research
overloads: ["fn:research.guard_report_projection()"]
security: definer
volatility: volatile
executors: []
raises: [REPORT_V1_WITHDRAWN]
touches: { reads: [research.report_v2_revision], writes: [] }
tokens: [research, guard_report_projection, research.guard_report_projection]
defined_in: ["20260913010000_research_report_packages.sql", "20261025010000_withdraw_legacy_verification_truth.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.guard_report_projection

Domain `research`.

## guard_report_projection() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`. Closes the v1 report projection (report_package and its section/assertion/artifact/question rows) for new rows since 20261025010000: v1 seals, assessments and ingestion links were withdrawn in favour of the knowledge_verification report revision and research.report_v2_* projections.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `REPORT_V1_WITHDRAWN`.

Touches (best effort): reads [`research.report_v2_revision`](../../relations/research/report_v2_revision.md); writes —; calls —.

Defined in: `20260913010000_research_report_packages.sql`, `20261025010000_withdraw_legacy_verification_truth.sql`.
