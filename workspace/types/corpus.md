---
id: "types:corpus"
kind: types
schema: corpus
enums: 0
domains: 2
composites: 0
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Types in corpus

## Domains
| Domain | Base type | Constraints |
| --- | --- | --- |
| `confidence` | `numeric(4,3)` | CHECK (VALUE IS NULL OR VALUE >= 0::numeric AND VALUE <= 1::numeric) |
| `lifecycle_state` | `text` | CHECK (VALUE = ANY (ARRAY['active'::text, 'disputed'::text, 'superseded'::text, 'retracted'::text, 'ended'::text])); NOT NULL |
