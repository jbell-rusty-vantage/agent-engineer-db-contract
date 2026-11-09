---
id: "fn:catalog.check_relationship_kinds()"
kind: function
schema: catalog
name: check_relationship_kinds
domain: relationships
lens: machinery
overloads: ["fn:catalog.check_relationship_kinds()"]
security: invoker
volatility: volatile
executors: []
raises: [invalid relationship endpoint kinds, invalid version pair]
touches: { reads: [catalog.entity, taxonomy.relationship_kind], writes: [] }
tokens: [catalog, check_relationship_kinds, catalog.check_relationship_kinds]
defined_in: []
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# catalog.check_relationship_kinds

Domain `relationships`, lens `machinery`.

## check_relationship_kinds() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `invalid relationship endpoint kinds`; `invalid version pair`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md); writes —; calls —.

Defined in: unknown.
