---
id: "fn:retrieval.enforce_evidence_gate()"
kind: function
schema: retrieval
name: enforce_evidence_gate
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.enforce_evidence_gate()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["evidence gate: claim % is %, not verified", "evidence gate: guidance item % is below the assurance floor (rank %, floor %)", "evidence gate: packet member has no resolvable subject", "evidence gate: representation class % is not source-faithful", "evidence gate: source representation % is %, not accepted", "evidence gate: source-native representation % is not byte-identical"]
touches: { reads: [content.document_representation, evidence.claim, guidance.assurance_level, guidance.item], writes: [] }
tokens: [retrieval, enforce_evidence_gate, retrieval.enforce_evidence_gate]
defined_in: ["20260826001000_retrieval.sql", "20260826001050_fix_evidence_gate_generated_column.sql", "20260903010600_source_native_packet_members.sql", "20260903010700_packet_member_tenant_targets.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# retrieval.enforce_evidence_gate

Domain `retrieval`, lens `machinery`.

## enforce_evidence_gate() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `evidence gate: claim % is %, not verified`; `evidence gate: guidance item % is below the assurance floor (rank %, floor %)`; `evidence gate: packet member has no resolvable subject`; `evidence gate: representation class % is not source-faithful`; `evidence gate: source representation % is %, not accepted`; `evidence gate: source-native representation % is not byte-identical`.

Touches (best effort): reads [`content.document_representation`](../../relations/content/document_representation.md), [`evidence.claim`](../../relations/evidence/claim.md), [`guidance.assurance_level`](../../relations/guidance/assurance_level.md), [`guidance.item`](../../relations/guidance/item.md); writes —; calls —.

Defined in: `20260826001000_retrieval.sql`, `20260826001050_fix_evidence_gate_generated_column.sql`, `20260903010600_source_native_packet_members.sql`, `20260903010700_packet_member_tenant_targets.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
