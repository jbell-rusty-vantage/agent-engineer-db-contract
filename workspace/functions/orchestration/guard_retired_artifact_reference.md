---
id: "fn:orchestration.guard_retired_artifact_reference()"
kind: function
schema: orchestration
name: guard_retired_artifact_reference
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_retired_artifact_reference()"]
security: definer
volatility: volatile
executors: []
raises: [canonical reference cannot bind a retired artifact]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone], writes: [] }
tokens: [orchestration, guard_retired_artifact_reference, orchestration.guard_retired_artifact_reference]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# orchestration.guard_retired_artifact_reference

Domain `orchestration-ledger`, lens `machinery`.

## guard_retired_artifact_reference() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `canonical reference cannot bind a retired artifact`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
