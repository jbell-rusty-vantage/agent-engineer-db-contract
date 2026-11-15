---
id: "types:staging"
kind: types
schema: staging
enums: 3
domains: 0
composites: 0
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# Types in staging

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `candidate_status` | `discovered`, `enriched`, `matched`, `resolved`, `promoted`, `quarantined`, `rejected` | `Database["staging"]["Enums"]["candidate_status"]` |
| `resolution_outcome` | `insert`, `update`, `link`, `merge`, `supersede`, `no_op`, `quarantine`, `reject`, `review` | `Database["staging"]["Enums"]["resolution_outcome"]` |
| `vetting_outcome` | `approved_for_metrics`, `approved_for_research`, `approved_provisionally`, `deferred`, `insufficient_evidence`, `out_of_scope`, `rejected` | `Database["staging"]["Enums"]["vetting_outcome"]` |
