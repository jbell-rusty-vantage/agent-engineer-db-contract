---
id: "fn:content.validate_unit_attributes()"
kind: function
schema: content
name: validate_unit_attributes
domain: content
lens: machinery
overloads: ["fn:content.validate_unit_attributes()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["unit attributes do not match the %/% schema"]
touches: { reads: [content.unit_kind], writes: [] }
tokens: [content, validate_unit_attributes, content.validate_unit_attributes]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# content.validate_unit_attributes

Domain `content`, lens `machinery`.

## validate_unit_attributes() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `unit attributes do not match the %/% schema`.

Touches (best effort): reads [`content.unit_kind`](../../relations/content/unit_kind.md); writes —; calls —.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
