---
id: "types:orchestration"
kind: types
schema: orchestration
enums: 4
domains: 0
composites: 0
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# Types in orchestration

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `attempt_outcome` | `succeeded`, `failed`, `timeout`, `cancelled`, `rejected` | `Database["orchestration"]["Enums"]["attempt_outcome"]` |
| `bucket_class` | `source_captures`, `candidate`, `accepted`, `ledger`, `published`, `workspace` | `Database["orchestration"]["Enums"]["bucket_class"]` |
| `mission_status` | `created`, `planning`, `running`, `paused`, `blocked`, `succeeded`, `failed`, `cancelled`, `superseded` | `Database["orchestration"]["Enums"]["mission_status"]` |
| `work_item_status` | `pending`, `ready`, `running`, `blocked`, `succeeded`, `failed`, `cancelled`, `skipped` | `Database["orchestration"]["Enums"]["work_item_status"]` |
