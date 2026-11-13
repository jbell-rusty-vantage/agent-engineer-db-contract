---
id: "fn:catalog.check_relationship_properties()"
kind: function
schema: catalog
name: check_relationship_properties
domain: relationships
lens: machinery
overloads: ["fn:catalog.check_relationship_properties()"]
security: invoker
volatility: volatile
executors: []
raises: [relationship properties violate JSON schema]
touches: { reads: [taxonomy.relationship_kind], writes: [] }
tokens: [catalog, check_relationship_properties, catalog.check_relationship_properties]
defined_in: []
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# catalog.check_relationship_properties

Domain `relationships`, lens `machinery`.

## check_relationship_properties() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `relationship properties violate JSON schema`.

Touches (best effort): reads [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md); writes —; calls [`temporal.payload_valid`](../temporal/payload_valid.md).

Defined in: unknown.
