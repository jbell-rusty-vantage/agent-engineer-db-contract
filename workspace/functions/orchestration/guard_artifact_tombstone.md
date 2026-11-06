---
id: "fn:orchestration.guard_artifact_tombstone()"
kind: function
schema: orchestration
name: guard_artifact_tombstone
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_artifact_tombstone()"]
security: definer
volatility: volatile
executors: []
raises: [artifact has retained canonical references, artifact minimum retention has not elapsed, artifact not found]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, guard_artifact_tombstone, orchestration.guard_artifact_tombstone]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.guard_artifact_tombstone

Domain `orchestration-ledger`.

## guard_artifact_tombstone() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `artifact has retained canonical references`; `artifact minimum retention has not elapsed`; `artifact not found`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
