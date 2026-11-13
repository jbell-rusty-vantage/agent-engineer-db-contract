---
id: "types:catalog"
kind: types
schema: catalog
enums: 0
domains: 2
composites: 0
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# Types in catalog

## Domains
| Domain | Base type | Constraints |
| --- | --- | --- |
| `confidence` | `numeric(4,3)` | CHECK (VALUE IS NULL OR VALUE >= 0::numeric AND VALUE <= 1::numeric) |
| `lifecycle_state` | `text` | CHECK (VALUE = ANY (ARRAY['active'::text, 'disputed'::text, 'superseded'::text, 'retracted'::text, 'ended'::text])); NOT NULL |
