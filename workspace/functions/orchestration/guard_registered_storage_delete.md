---
id: "fn:orchestration.guard_registered_storage_delete()"
kind: function
schema: orchestration
name: guard_registered_storage_delete
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_registered_storage_delete()"]
security: definer
volatility: volatile
executors: []
raises: [storage object retains live artifact registrations]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone], writes: [] }
tokens: [orchestration, guard_registered_storage_delete, orchestration.guard_registered_storage_delete]
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# orchestration.guard_registered_storage_delete

Domain `orchestration-ledger`, lens `machinery`.

## guard_registered_storage_delete() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `storage object retains live artifact registrations`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md); writes —; calls —.

Defined in: `20260914010500_scoped_checkpoints.sql`.
