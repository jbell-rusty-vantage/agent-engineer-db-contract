---
id: "types:evidence"
kind: types
schema: evidence
enums: 2
domains: 0
composites: 0
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# Types in evidence

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `claim_status` | `proposed`, `verified`, `disputed`, `retracted`, `superseded` | `Database["evidence"]["Enums"]["claim_status"]` |
| `support_verdict` | `directly_supported`, `supported_with_qualification`, `partially_supported`, `context_only`, `contradicted`, `not_supported`, `unverifiable`, `pending_semantic_review`, `mixed_or_conflicting`, `insufficient_evidence`, `source_unavailable`, `locator_error`, `parser_error`, `derived_verified`, `derived_failed` | `Database["evidence"]["Enums"]["support_verdict"]` |
