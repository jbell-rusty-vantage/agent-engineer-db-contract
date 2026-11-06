---
id: "fn:corpus.check_relationship_properties()"
kind: function
schema: corpus
name: check_relationship_properties
domain: identity
overloads: ["fn:corpus.check_relationship_properties()"]
security: invoker
volatility: volatile
executors: []
raises: [relationship properties violate JSON schema]
touches: { reads: [taxonomy.relationship_kind], writes: [] }
tokens: [corpus, check_relationship_properties, corpus.check_relationship_properties]
defined_in: ["20260912010300_km_03_relationship.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.check_relationship_properties

Domain `identity`.

## check_relationship_properties() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `relationship properties violate JSON schema`.

Touches (best effort): reads [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md); writes —; calls [`temporal.payload_valid`](../temporal/payload_valid.md).

Defined in: `20260912010300_km_03_relationship.sql`.
