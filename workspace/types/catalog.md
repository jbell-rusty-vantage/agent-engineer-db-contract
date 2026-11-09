---
id: "types:catalog"
kind: types
schema: catalog
enums: 0
domains: 2
composites: 0
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Types in catalog

## Domains
| Domain | Base type | Constraints |
| --- | --- | --- |
| `confidence` | `numeric(4,3)` | CHECK (VALUE IS NULL OR VALUE >= 0::numeric AND VALUE <= 1::numeric) |
| `lifecycle_state` | `text` | CHECK (VALUE = ANY (ARRAY['active'::text, 'disputed'::text, 'superseded'::text, 'retracted'::text, 'ended'::text])); NOT NULL |
