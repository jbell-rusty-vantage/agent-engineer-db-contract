---
id: "fn:retrieval.validate_embedding_item()"
kind: function
schema: retrieval
name: validate_embedding_item
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.validate_embedding_item()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["embedding dimensions %, expected % and canonical physical dimension 1536"]
touches: { reads: [retrieval.embedding_run], writes: [] }
tokens: [retrieval, validate_embedding_item, retrieval.validate_embedding_item]
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# retrieval.validate_embedding_item

Domain `retrieval`, lens `machinery`.

## validate_embedding_item() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `embedding dimensions %, expected % and canonical physical dimension 1536`.

Touches (best effort): reads [`retrieval.embedding_run`](../../relations/retrieval/embedding_run.md); writes —; calls —.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
