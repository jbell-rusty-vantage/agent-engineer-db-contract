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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
