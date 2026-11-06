---
id: "fn:corpus.check_relationship_kinds()"
kind: function
schema: corpus
name: check_relationship_kinds
domain: identity
overloads: ["fn:corpus.check_relationship_kinds()"]
security: invoker
volatility: volatile
executors: []
raises: [invalid relationship endpoint kinds, invalid version pair]
touches: { reads: [corpus.entity, taxonomy.relationship_kind], writes: [] }
tokens: [corpus, check_relationship_kinds, corpus.check_relationship_kinds]
defined_in: ["20260912010300_km_03_relationship.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.check_relationship_kinds

Domain `identity`.

## check_relationship_kinds() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `invalid relationship endpoint kinds`; `invalid version pair`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md); writes —; calls —.

Defined in: `20260912010300_km_03_relationship.sql`.
