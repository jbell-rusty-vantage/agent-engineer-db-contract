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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
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
