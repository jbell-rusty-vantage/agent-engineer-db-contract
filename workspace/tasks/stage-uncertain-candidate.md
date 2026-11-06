---
id: "task:stage-uncertain-candidate"
kind: task
domains: [staging, identity]
queries: [entity.resolve, staging.candidates_for_kind, staging.unresolved]
aliases: [defer, ambiguous identity]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Stage a candidate you are unsure about

Domains: [`staging`](../domains/staging.md), [`identity`](../domains/identity.md). Queries: [`q:entity.resolve`](../queries/README.md), [`q:staging.candidates_for_kind`](../queries/README.md), [`q:staging.unresolved`](../queries/README.md).

## Navigation

`domains/staging.md` → `q:staging.unresolved`

## Operation

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "stage-openai-foundation",
  "expectedKnowledgeHead": 41,
  "proposals": [
    {
      "proposalId": "p-stage",
      "kind": "candidate.stage",
      "entityKind": "organization",
      "displayName": "OpenAI Foundation",
      "payload": { "note": "resolve_entity returned score 0.61; unclear whether distinct from OpenAI" },
      "reason": "identity_ambiguous"
    }
  ]
}
```

## Expected shape

One `staging.candidate` with proposed_kind organization and resolved_entity_id null. It appears in `q:staging.unresolved` until a resolution_decision of create, match, or reject.

## Pitfalls

Staging is for identity, not for facts you are unsure about. Uncertain facts use `belief: disputed` or `temporal_basis: unresolved`. `proposed_kind` must be a vocabulary entity kind.
