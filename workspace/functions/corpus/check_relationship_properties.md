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
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
