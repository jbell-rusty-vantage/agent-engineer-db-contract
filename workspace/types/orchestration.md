---
id: "types:orchestration"
kind: types
schema: orchestration
enums: 4
domains: 0
composites: 0
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# Types in orchestration

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `attempt_outcome` | `succeeded`, `failed`, `timeout`, `cancelled`, `rejected` | `Database["orchestration"]["Enums"]["attempt_outcome"]` |
| `bucket_class` | `source_captures`, `candidate`, `accepted`, `ledger`, `published`, `workspace` | `Database["orchestration"]["Enums"]["bucket_class"]` |
| `mission_status` | `created`, `planning`, `running`, `paused`, `blocked`, `succeeded`, `failed`, `cancelled`, `superseded` | `Database["orchestration"]["Enums"]["mission_status"]` |
| `work_item_status` | `pending`, `ready`, `running`, `blocked`, `succeeded`, `failed`, `cancelled`, `skipped` | `Database["orchestration"]["Enums"]["work_item_status"]` |
