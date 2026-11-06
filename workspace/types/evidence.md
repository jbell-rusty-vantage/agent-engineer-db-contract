---
id: "types:evidence"
kind: types
schema: evidence
enums: 2
domains: 0
composites: 0
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Types in evidence

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `claim_status` | `proposed`, `verified`, `disputed`, `retracted`, `superseded` | `Database["evidence"]["Enums"]["claim_status"]` |
| `support_verdict` | `directly_supported`, `supported_with_qualification`, `partially_supported`, `context_only`, `contradicted`, `not_supported`, `unverifiable`, `pending_semantic_review`, `mixed_or_conflicting`, `insufficient_evidence`, `source_unavailable`, `locator_error`, `parser_error`, `derived_verified`, `derived_failed` | `Database["evidence"]["Enums"]["support_verdict"]` |
