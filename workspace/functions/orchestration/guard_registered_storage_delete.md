---
id: "fn:orchestration.guard_registered_storage_delete()"
kind: function
schema: orchestration
name: guard_registered_storage_delete
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_registered_storage_delete()"]
security: definer
volatility: volatile
executors: []
raises: [storage object retains live artifact registrations]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone], writes: [] }
tokens: [orchestration, guard_registered_storage_delete, orchestration.guard_registered_storage_delete]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.guard_registered_storage_delete

Domain `orchestration-ledger`.

## guard_registered_storage_delete() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `storage object retains live artifact registrations`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
