---
id: "fn:content.validate_unit_entity_role()"
kind: function
schema: content
name: validate_unit_entity_role
domain: content
lens: machinery
overloads: ["fn:content.validate_unit_entity_role()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["role % is not in the unit kind role vocabulary %"]
touches: { reads: [content.document_node, content.unit_kind], writes: [] }
tokens: [content, validate_unit_entity_role, content.validate_unit_entity_role]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# content.validate_unit_entity_role

Domain `content`, lens `machinery`.

## validate_unit_entity_role() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `role % is not in the unit kind role vocabulary %`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`content.unit_kind`](../../relations/content/unit_kind.md); writes —; calls —.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
