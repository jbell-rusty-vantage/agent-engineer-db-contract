---
id: "types:staging"
kind: types
schema: staging
enums: 3
domains: 0
composites: 0
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# Types in staging

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `candidate_status` | `discovered`, `enriched`, `matched`, `resolved`, `promoted`, `quarantined`, `rejected` | `Database["staging"]["Enums"]["candidate_status"]` |
| `resolution_outcome` | `insert`, `update`, `link`, `merge`, `supersede`, `no_op`, `quarantine`, `reject`, `review` | `Database["staging"]["Enums"]["resolution_outcome"]` |
| `vetting_outcome` | `approved_for_metrics`, `approved_for_research`, `approved_provisionally`, `deferred`, `insufficient_evidence`, `out_of_scope`, `rejected` | `Database["staging"]["Enums"]["vetting_outcome"]` |
