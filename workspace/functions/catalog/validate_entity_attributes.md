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
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
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
