---
id: "voc:orchestration.artifact_type"
kind: vocabulary
schema: orchestration
name: artifact_type
rows: 92
rows_sha256: "sha256:bc577acac6941447c85da1a8701847465a7e8490f20bb5ffaa0baf91bfdf5499"
codes: [canonical_source_projection, checkpoint_package, claims, comparisons, content_link_intent, content_link_plan, content_link_receipt, content_summary_preparation_receipt, content_summary_text, deterministic_verification_result, eval_dataset, evaluation_arm_manifest, evaluation_case_input, evaluation_dataset_manifest, evaluation_gold_label, evidence_links, evidence_packet, execution_receipt, grader_manifest, ingestion_intent, knowledge_ingestion_plan, knowledge_ingestion_receipt, knowledge_read_intent, knowledge_read_snapshot, knowledge_report_markdown, metric_probe_report, report_json, report_markdown, research_notes, research_report_manifest, research_report_structure, research_report_verification, run_manifest, schema_workspace_manifest, source_attribution_audit, source_capture, source_query_response, timeline_summary, transcript, verification_adjudication_decision, verification_adjudication_packet, verification_audit_bundle, verification_audit_inspection_result, verification_benchmark_comparison_profile, verification_benchmark_comparison_publication, verification_benchmark_comparison_result, verification_benchmark_experiment, verification_benchmark_profile_file, verification_benchmark_provenance, verification_benchmark_recorded_call, verification_benchmark_run_manifest, verification_benchmark_source_import_manifest, verification_benchmark_source_import_payload, verification_benchmark_summary, verification_bundle, verification_canonical_projection, verification_claims_artifact, verification_component_drift_observation, verification_extraction_candidate, verification_parse_result, verification_parser_native_output, verification_policy, verification_policy_decision, verification_policy_inputs, verification_provider_cost_lookup, verification_provider_input, verification_provider_precontext, verification_provider_precontext_envelope, verification_provider_raw_response, verification_provider_reconciliation, verification_provider_request, verification_provider_response_envelope, verification_provider_transport_response, verification_report_ledger, verification_report_result, verification_run_manifest, verification_runtime_principal_binding, verification_semantic_blinded_input, verification_semantic_judge_profile, verification_semantic_response_observation, verification_signature, verification_source_authority_receipt, verification_structured_extraction_execution, verification_structured_extraction_failure, verification_structured_extraction_precontext, verification_structured_extraction_profile, verification_structured_extraction_provenance, verification_structured_extraction_publication, verification_structured_extraction_source_custody, verification_transformation_envelope, workspace_file, workspace_manifest]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.artifact_type

Reference data snapshot (92 rows, digest `sha256:bc577acac6941447c85da1a8701847465a7e8490f20bb5ffaa0baf91bfdf5499`). Codes are enforced wherever a column has a foreign key to [`orchestration.artifact_type`](../relations/orchestration/artifact_type.md).

| code | description |
| --- | --- |
| `canonical_source_projection` | Canonical source representation derived from immutable capture bytes for selector replay |
| `checkpoint_package` | Coordinator continuation checkpoint bundle |
| `claims` | Extracted claims payload |
| `comparisons` | Normalized entity comparison payload |
| `content_link_intent` | content-link-intent.v1: immutable typed content-link proposals and evidence references |
| `content_link_plan` | content-link-plan.v1: per-operation admission and dependency outcomes |
| `content_link_receipt` | content-link-receipt.v1: exact canonical row keys and applied, held or no-op outcomes |
| `content_summary_preparation_receipt` | Actual deterministic summary transformation, input/output custody and pending representation receipt |
| `content_summary_text` | Deterministic retained admitted-statement summary output awaiting independent representation review |
| `deterministic_verification_result` | Deterministic verification result |
| `eval_dataset` | Evaluation dataset snapshot |
| `evaluation_arm_manifest` | Frozen evaluation variant manifest |
| `evaluation_case_input` | Frozen evaluation case input manifest |
| `evaluation_dataset_manifest` | Frozen evaluation dataset-version manifest |
| `evaluation_gold_label` | Frozen evaluation gold label |
| `evidence_links` | Claim to locator link set |
| `evidence_packet` | Retrieval evidence packet |
| `execution_receipt` | Executor receipt payload |
| `grader_manifest` | Frozen grader definition manifest |
| `ingestion_intent` | Validated deterministic canonical mutation intent |
| `knowledge_ingestion_plan` | knowledge-ingestion-plan.v1: deterministic per-proposal admission plan for one ingestion intent |
| `knowledge_ingestion_receipt` | knowledge-ingestion-receipt.v1: outcome of applying one ingestion intent through the temporal helpers |
| `knowledge_read_intent` | knowledge-read-intent.v1: a reproducible batch of named queries and retrieval operations |
| `knowledge_read_snapshot` | knowledge-read-snapshot.v1: digested read results at one tenant knowledge head |
| `knowledge_report_markdown` | Source-attributed Markdown report produced alongside a knowledge ingestion |
| `metric_probe_report` | Source-attributed metric probe results for one entity |
| `report_json` | Rendered report, structured |
| `report_markdown` | Rendered report, markdown |
| `research_notes` | Intermediate research notes preserved for provenance |
| `research_report_manifest` | Immutable report package artifact/dependency manifest |
| `research_report_structure` | research-report.v1 structured sections, blocks and assertion references |
| `research_report_verification` | Exact-revision report verification output; registration is not admission |
| `run_manifest` | Manifest describing one pipeline run |
| `schema_workspace_manifest` | Schema workspace manifest (fingerprint, migration head, scope) an agent session observed |
| `source_attribution_audit` | Independent locator and extraction verification report |
| `source_capture` | Raw captured source content |
| `source_query_response` | Raw provider response for one research query |
| `timeline_summary` | Versioned rolling chronological summary across source videos |
| `transcript` | Media transcript |
| `verification_adjudication_decision` | Append-only authorized reviewer decision bound to a review packet |
| `verification_adjudication_packet` | Bounded immutable review request with original evidence custody |
| `verification_audit_bundle` | Portable sealed verification audit bundle; must pass signature and content checks |
| `verification_audit_inspection_result` | Immutable compact inspection result bound to an exact signed audit bundle; no new policy admission |
| `verification_benchmark_comparison_profile` | Immutable operator-granted arm pairs, statistical family and observed engineering regression threshold |
| `verification_benchmark_comparison_publication` | Signed comparison publication with exact registered profile, inputs, result and durable lifecycle |
| `verification_benchmark_comparison_result` | Immutable paired engineering comparison of two signed completed benchmark runs |
| `verification_benchmark_experiment` | Immutable registered offline verification benchmark experiment definition |
| `verification_benchmark_profile_file` | Immutable retained file in a sealed verification benchmark replay profile |
| `verification_benchmark_provenance` | Immutable registered replay and source-import provenance for a benchmark publication |
| `verification_benchmark_recorded_call` | Immutable retained verification benchmark provider call checkpoint for offline replay |
| `verification_benchmark_run_manifest` | Immutable terminal manifest for a durable offline verification benchmark run |
| `verification_benchmark_source_import_manifest` | Restricted imported source-preparation manifest retaining original provenance identities |
| `verification_benchmark_source_import_payload` | Tenant-owned copy of restricted historical source artifact bytes for offline benchmark replay |
| `verification_benchmark_summary` | Immutable orthogonal benchmark statistics bound to a completed runner manifest |
| `verification_bundle` | Canonical verification input bundle |
| `verification_canonical_projection` | Strict canonical selector projection content; parent-specific lineage is retained by a transformation envelope |
| `verification_claims_artifact` | Immutable claim assertions and declared evidence; not verified judgments |
| `verification_component_drift_observation` | Immutable five-component drift observation derived from two signed verification run manifests |
| `verification_extraction_candidate` | Schema-valid structured extraction output; unverified candidate |
| `verification_parse_result` | Immutable canonical parser custody result; no extraction or policy admission |
| `verification_parser_native_output` | Bounded native parser response retained before canonical projection admission |
| `verification_policy` | Versioned verification admission policy |
| `verification_policy_decision` | Replayable verification policy decision |
| `verification_policy_inputs` | Immutable recorded verification policy inputs used to recompute a decision without semantic provider calls |
| `verification_provider_cost_lookup` | Restricted provider generation-cost lookup envelope linked to the original response evidence |
| `verification_provider_input` | Restricted bytes supplied to a bounded verification provider call |
| `verification_provider_precontext` | Restricted provider precontext projection retained outside semantic model context |
| `verification_provider_precontext_envelope` | Restricted request-bound lineage envelope for a content-addressed provider precontext projection |
| `verification_provider_raw_response` | Restricted exact raw response from a bounded verification provider |
| `verification_provider_reconciliation` | Operator-signed original provider accounting decision with immutable evidence; never authorizes redispatch |
| `verification_provider_request` | Exact restricted outbound bounded verification provider request |
| `verification_provider_response_envelope` | Restricted request-bound lineage envelope for a content-addressed raw provider response |
| `verification_provider_transport_response` | Canonical hash-bound provider transport response custody |
| `verification_report_ledger` | Immutable report assertion spans and declared citation edges; not verified judgments |
| `verification_report_result` | Immutable report-wide mechanical gate bound to a sealed verification run |
| `verification_run_manifest` | Sealed public verification run manifest |
| `verification_runtime_principal_binding` | Canonical server-resolved runtime principal binding retained for claims and report audit replay |
| `verification_semantic_blinded_input` | Immutable blinded authorized semantic judge input |
| `verification_semantic_judge_profile` | Immutable server-owned semantic judge profile |
| `verification_semantic_response_observation` | Immutable semantic provider response observation bound to raw response custody |
| `verification_signature` | Detached verification manifest signature |
| `verification_source_authority_receipt` | Immutable host-approved source, capture, claim and policy authority with an explicit critical-fact census |
| `verification_structured_extraction_execution` | Immutable original structured extraction execution and code custody |
| `verification_structured_extraction_failure` | Signed captured producer failure custody; no candidate or verification-quality claim |
| `verification_structured_extraction_precontext` | Operation-bound envelope preserving exact replay-emitted provider precontext |
| `verification_structured_extraction_profile` | Immutable server-owned structured-extraction provider profile |
| `verification_structured_extraction_provenance` | Immutable unverified candidate and captured provider ancestry |
| `verification_structured_extraction_publication` | Final structured extraction custody publication; output remains unverified |
| `verification_structured_extraction_source_custody` | Canonical listed-file source bytes and hashes for structured extraction runtime custody |
| `verification_transformation_envelope` | Canonical authenticated binding between capture bytes, native parser output, canonical projection, and parser deploymen… |
| `workspace_file` | One preserved file from a cloud-agent attempt workspace |
| `workspace_manifest` | Deterministic manifest for a preserved attempt workspace |
