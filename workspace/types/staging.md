---
id: "types:staging"
kind: types
schema: staging
enums: 3
domains: 0
composites: 0
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# Types in staging

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `candidate_status` | `discovered`, `enriched`, `matched`, `resolved`, `promoted`, `quarantined`, `rejected` | `Database["staging"]["Enums"]["candidate_status"]` |
| `resolution_outcome` | `insert`, `update`, `link`, `merge`, `supersede`, `no_op`, `quarantine`, `reject`, `review` | `Database["staging"]["Enums"]["resolution_outcome"]` |
| `vetting_outcome` | `approved_for_metrics`, `approved_for_research`, `approved_provisionally`, `deferred`, `insufficient_evidence`, `out_of_scope`, `rejected` | `Database["staging"]["Enums"]["vetting_outcome"]` |
