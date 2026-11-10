---
id: "types:catalog"
kind: types
schema: catalog
enums: 0
domains: 2
composites: 0
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# Types in catalog

## Domains
| Domain | Base type | Constraints |
| --- | --- | --- |
| `confidence` | `numeric(4,3)` | CHECK (VALUE IS NULL OR VALUE >= 0::numeric AND VALUE <= 1::numeric) |
| `lifecycle_state` | `text` | CHECK (VALUE = ANY (ARRAY['active'::text, 'disputed'::text, 'superseded'::text, 'retracted'::text, 'ended'::text])); NOT NULL |
