---
id: "fn:retrieval.enforce_evidence_gate()"
kind: function
schema: retrieval
name: enforce_evidence_gate
domain: retrieval
overloads: ["fn:retrieval.enforce_evidence_gate()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["evidence gate: % record % is below the assurance floor (rank %, floor %)", "evidence gate: claim % is %, not verified", "evidence gate: packet member has no resolvable subject", "evidence gate: representation class % is not source-faithful", "evidence gate: source representation % is %, not accepted", "evidence gate: source-native representation % is not byte-identical"]
touches: { reads: [content.document_representation, evidence.claim, knowledge.assurance_level], writes: [] }
tokens: [retrieval, enforce_evidence_gate, retrieval.enforce_evidence_gate]
defined_in: ["20260826001000_retrieval.sql", "20260826001050_fix_evidence_gate_generated_column.sql", "20260903010600_source_native_packet_members.sql", "20260903010700_packet_member_tenant_targets.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.enforce_evidence_gate

Domain `retrieval`.

## enforce_evidence_gate() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `evidence gate: % record % is below the assurance floor (rank %, floor %)`; `evidence gate: claim % is %, not verified`; `evidence gate: packet member has no resolvable subject`; `evidence gate: representation class % is not source-faithful`; `evidence gate: source representation % is %, not accepted`; `evidence gate: source-native representation % is not byte-identical`.

Touches (best effort): reads [`content.document_representation`](../../relations/content/document_representation.md), [`evidence.claim`](../../relations/evidence/claim.md), [`knowledge.assurance_level`](../../relations/knowledge/assurance_level.md); writes —; calls —.

Defined in: `20260826001000_retrieval.sql`, `20260826001050_fix_evidence_gate_generated_column.sql`, `20260903010600_source_native_packet_members.sql`, `20260903010700_packet_member_tenant_targets.sql`.
