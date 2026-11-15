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
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
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
