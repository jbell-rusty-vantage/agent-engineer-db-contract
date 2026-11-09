---
id: "types:staging"
kind: types
schema: staging
enums: 3
domains: 0
composites: 0
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Types in staging

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `candidate_status` | `discovered`, `enriched`, `matched`, `resolved`, `promoted`, `quarantined`, `rejected` | `Database["staging"]["Enums"]["candidate_status"]` |
| `resolution_outcome` | `insert`, `update`, `link`, `merge`, `supersede`, `no_op`, `quarantine`, `reject`, `review` | `Database["staging"]["Enums"]["resolution_outcome"]` |
| `vetting_outcome` | `approved_for_metrics`, `approved_for_research`, `approved_provisionally`, `deferred`, `insufficient_evidence`, `out_of_scope`, `rejected` | `Database["staging"]["Enums"]["vetting_outcome"]` |
