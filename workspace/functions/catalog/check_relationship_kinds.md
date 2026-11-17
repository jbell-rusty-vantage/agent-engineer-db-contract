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
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql", "20261109130300_build08_loop2_fixups3.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# catalog.check_relationship_kinds

Domain `relationships`, lens `machinery`.

## check_relationship_kinds() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`. Relationship endpoints must match the kind vocabulary; version_of pairs are enumerated: product_version→product, ai_model_version→ai_model, library_release→library, ai_protocol_version→ai_protocol, benchmark_version→benchmark (loop 2).

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `invalid relationship endpoint kinds`; `invalid version pair`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md); writes —; calls —.

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`, `20261109130300_build08_loop2_fixups3.sql`.
