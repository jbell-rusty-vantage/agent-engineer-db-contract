---
id: "types:orchestration"
kind: types
schema: orchestration
enums: 4
domains: 0
composites: 0
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Types in orchestration

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `attempt_outcome` | `succeeded`, `failed`, `timeout`, `cancelled`, `rejected` | `Database["orchestration"]["Enums"]["attempt_outcome"]` |
| `bucket_class` | `source_captures`, `candidate`, `accepted`, `ledger`, `published` | `Database["orchestration"]["Enums"]["bucket_class"]` |
| `mission_status` | `created`, `planning`, `running`, `paused`, `blocked`, `succeeded`, `failed`, `cancelled`, `superseded` | `Database["orchestration"]["Enums"]["mission_status"]` |
| `work_item_status` | `pending`, `ready`, `running`, `blocked`, `succeeded`, `failed`, `cancelled`, `skipped` | `Database["orchestration"]["Enums"]["work_item_status"]` |
