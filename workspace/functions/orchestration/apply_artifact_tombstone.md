---
id: "fn:orchestration.apply_artifact_tombstone()"
kind: function
schema: orchestration
name: apply_artifact_tombstone
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.apply_artifact_tombstone()"]
security: definer
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [orchestration.artifact] }
tokens: [orchestration, apply_artifact_tombstone, orchestration.apply_artifact_tombstone]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# orchestration.apply_artifact_tombstone

Domain `orchestration-ledger`, lens `machinery`.

## apply_artifact_tombstone() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Touches (best effort): reads —; writes [`orchestration.artifact`](../../relations/orchestration/artifact.md); calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
