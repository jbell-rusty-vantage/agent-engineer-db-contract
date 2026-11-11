---
id: "fn:orchestration.guard_artifact_tombstone()"
kind: function
schema: orchestration
name: guard_artifact_tombstone
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_artifact_tombstone()"]
security: definer
volatility: volatile
executors: []
raises: [artifact has retained canonical references, artifact minimum retention has not elapsed, artifact not found]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, guard_artifact_tombstone, orchestration.guard_artifact_tombstone]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# orchestration.guard_artifact_tombstone

Domain `orchestration-ledger`, lens `machinery`.

## guard_artifact_tombstone() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `artifact has retained canonical references`; `artifact minimum retention has not elapsed`; `artifact not found`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
