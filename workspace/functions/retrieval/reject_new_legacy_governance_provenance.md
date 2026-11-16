---
id: "fn:retrieval.reject_new_legacy_governance_provenance()"
kind: function
schema: retrieval
name: reject_new_legacy_governance_provenance
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.reject_new_legacy_governance_provenance()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [legacy provenance is migration-owned and cannot be asserted for a new row]
touches: { reads: [], writes: [] }
tokens: [retrieval, reject_new_legacy_governance_provenance, retrieval.reject_new_legacy_governance_provenance]
defined_in: ["20260904011000_governed_projection_embedding_publication.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# retrieval.reject_new_legacy_governance_provenance

Domain `retrieval`, lens `machinery`.

## reject_new_legacy_governance_provenance() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `legacy provenance is migration-owned and cannot be asserted for a new row`.

Defined in: `20260904011000_governed_projection_embedding_publication.sql`.
