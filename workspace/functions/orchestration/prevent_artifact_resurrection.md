---
id: "fn:orchestration.prevent_artifact_resurrection()"
kind: function
schema: orchestration
name: prevent_artifact_resurrection
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.prevent_artifact_resurrection()"]
security: definer
volatility: volatile
executors: []
raises: [retired artifact cannot regain custody]
touches: { reads: [orchestration.artifact_tombstone], writes: [] }
tokens: [orchestration, prevent_artifact_resurrection, orchestration.prevent_artifact_resurrection]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# orchestration.prevent_artifact_resurrection

Domain `orchestration-ledger`, lens `machinery`.

## prevent_artifact_resurrection() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `retired artifact cannot regain custody`.

Touches (best effort): reads [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
