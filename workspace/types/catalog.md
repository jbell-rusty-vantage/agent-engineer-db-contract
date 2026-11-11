---
id: "types:catalog"
kind: types
schema: catalog
enums: 0
domains: 2
composites: 0
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# Types in catalog

## Domains
| Domain | Base type | Constraints |
| --- | --- | --- |
| `confidence` | `numeric(4,3)` | CHECK (VALUE IS NULL OR VALUE >= 0::numeric AND VALUE <= 1::numeric) |
| `lifecycle_state` | `text` | CHECK (VALUE = ANY (ARRAY['active'::text, 'disputed'::text, 'superseded'::text, 'retracted'::text, 'ended'::text])); NOT NULL |
