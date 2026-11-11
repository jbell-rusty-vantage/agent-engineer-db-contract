---
id: "fn:orchestration.verification_provider_semantic_identity()"
kind: function
schema: orchestration
name: verification_provider_semantic_identity
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.verification_provider_semantic_identity()"]
security: definer
volatility: volatile
executors: []
raises: [nonsemantic provider cannot choose semantic identity, semantic provider logical identity immutable, semantic provider logical request mismatch]
touches: { reads: [knowledge_service.operation], writes: [] }
tokens: [orchestration, verification_provider_semantic_identity, orchestration.verification_provider_semantic_identity]
defined_in: ["20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# orchestration.verification_provider_semantic_identity

Domain `orchestration-ledger`, lens `machinery`.

## verification_provider_semantic_identity() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `nonsemantic provider cannot choose semantic identity`; `semantic provider logical identity immutable`; `semantic provider logical request mismatch`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md); writes —; calls —.

Defined in: `20260907013000_verification_semantic_provider_observation.sql`.
