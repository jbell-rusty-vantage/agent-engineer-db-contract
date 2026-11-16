---
id: "fn:orchestration.artifact_guard()"
kind: function
schema: orchestration
name: artifact_guard
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.artifact_guard()"]
security: definer
volatility: volatile
executors: []
raises: [artifact immutable identity changed, artifact storage metadata requires a state transition, artifact successor may be assigned once, artifact successor must be newer and same-tenant, invalid artifact storage-state transition, orchestration.artifact is append-only]
touches: { reads: [orchestration.artifact, orchestration.artifact_tombstone], writes: [] }
tokens: [orchestration, artifact_guard, orchestration.artifact_guard]
defined_in: ["20260826000200_orchestration.sql", "20260903010200_knowledge_runtime_security.sql", "20260905011000_artifact_registration_lifecycle.sql", "20260914010600_checkpoint_retirement_compatibility.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# orchestration.artifact_guard

Domain `orchestration-ledger`, lens `machinery`.

## artifact_guard() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `artifact immutable identity changed`; `artifact storage metadata requires a state transition`; `artifact successor may be assigned once`; `artifact successor must be newer and same-tenant`; `invalid artifact storage-state transition`; `orchestration.artifact is append-only`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.artifact_tombstone`](../../relations/orchestration/artifact_tombstone.md); writes —; calls —.

Defined in: `20260826000200_orchestration.sql`, `20260903010200_knowledge_runtime_security.sql`, `20260905011000_artifact_registration_lifecycle.sql`, `20260914010600_checkpoint_retirement_compatibility.sql`.
