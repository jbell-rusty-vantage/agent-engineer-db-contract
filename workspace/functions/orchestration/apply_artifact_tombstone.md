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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# orchestration.apply_artifact_tombstone

Domain `orchestration-ledger`, lens `machinery`.

## apply_artifact_tombstone() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Touches (best effort): reads —; writes [`orchestration.artifact`](../../relations/orchestration/artifact.md); calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
