---
id: "fn:orchestration.guard_artifact_blob_alias()"
kind: function
schema: orchestration
name: guard_artifact_blob_alias
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_artifact_blob_alias()"]
security: definer
volatility: volatile
executors: []
raises: [artifact blob address custody collision]
touches: { reads: [orchestration.artifact], writes: [] }
tokens: [orchestration, guard_artifact_blob_alias, orchestration.guard_artifact_blob_alias]
defined_in: ["20260914010000_artifact_logical_custody.sql", "20260914010100_artifact_legacy_registration_compatibility.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# orchestration.guard_artifact_blob_alias

Domain `orchestration-ledger`, lens `machinery`.

## guard_artifact_blob_alias() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `artifact blob address custody collision`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md); writes —; calls —.

Defined in: `20260914010000_artifact_logical_custody.sql`, `20260914010100_artifact_legacy_registration_compatibility.sql`.
