---
id: "types:orchestration"
kind: types
schema: orchestration
enums: 4
domains: 0
composites: 0
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# Types in orchestration

## Enums
| Enum | Labels | TypeScript |
| --- | --- | --- |
| `attempt_outcome` | `succeeded`, `failed`, `timeout`, `cancelled`, `rejected` | `Database["orchestration"]["Enums"]["attempt_outcome"]` |
| `bucket_class` | `source_captures`, `candidate`, `accepted`, `ledger`, `published`, `workspace` | `Database["orchestration"]["Enums"]["bucket_class"]` |
| `mission_status` | `created`, `planning`, `running`, `paused`, `blocked`, `succeeded`, `failed`, `cancelled`, `superseded` | `Database["orchestration"]["Enums"]["mission_status"]` |
| `work_item_status` | `pending`, `ready`, `running`, `blocked`, `succeeded`, `failed`, `cancelled`, `skipped` | `Database["orchestration"]["Enums"]["work_item_status"]` |
