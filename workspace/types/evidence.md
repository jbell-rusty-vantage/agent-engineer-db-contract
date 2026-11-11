---
id: "types:evidence"
kind: types
schema: evidence
enums: 2
domains: 0
composites: 0
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# Types in evidence

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `claim_status` | `proposed`, `verified`, `disputed`, `retracted`, `superseded` | `Database["evidence"]["Enums"]["claim_status"]` |
| `support_verdict` | `directly_supported`, `supported_with_qualification`, `partially_supported`, `context_only`, `contradicted`, `not_supported`, `unverifiable`, `pending_semantic_review`, `mixed_or_conflicting`, `insufficient_evidence`, `source_unavailable`, `locator_error`, `parser_error`, `derived_verified`, `derived_failed` | `Database["evidence"]["Enums"]["support_verdict"]` |
