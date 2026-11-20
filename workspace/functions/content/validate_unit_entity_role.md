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
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
