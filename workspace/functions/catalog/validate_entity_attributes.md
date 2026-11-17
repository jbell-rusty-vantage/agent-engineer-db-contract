---
id: "fn:catalog.validate_entity_attributes()"
kind: function
schema: catalog
name: validate_entity_attributes
domain: identity
lens: machinery
overloads: ["fn:catalog.validate_entity_attributes()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["entity attributes do not match the %s schema"]
touches: { reads: [taxonomy.entity_kind], writes: [] }
tokens: [catalog, validate_entity_attributes, catalog.validate_entity_attributes]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# catalog.validate_entity_attributes

Domain `identity`, lens `machinery`.

## validate_entity_attributes() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `entity attributes do not match the %s schema`.

Touches (best effort): reads [`taxonomy.entity_kind`](../../relations/taxonomy/entity_kind.md); writes —; calls —.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
