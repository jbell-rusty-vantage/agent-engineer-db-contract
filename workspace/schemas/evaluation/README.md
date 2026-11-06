---
id: "sch:evaluation"
kind: schema
name: evaluation
domains: [evaluation]
relations: 30
functions: 20
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation

Datasets, cases, graders, runs, scores, gates, review queue. Domains: [`evaluation`](../../domains/evaluation.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`eval_case`](../../relations/evaluation/eval_case.md) | table | unknown | — | → `evaluation.eval_dataset`, → `orchestration.artifact`, → `evaluation.eval_dataset_version` |
| [`eval_case_expected_filter`](../../relations/evaluation/eval_case_expected_filter.md) | table | unknown | — | → `evaluation.eval_case` |
| [`eval_case_provenance`](../../relations/evaluation/eval_case_provenance.md) | table | unknown | — | → `orchestration.artifact`, → `evaluation.eval_case`, → `evidence.source_capture` |
| [`eval_case_relevance`](../../relations/evaluation/eval_case_relevance.md) | table | unknown | — | → `evaluation.eval_case`, → `retrieval.projection_target` |
| [`eval_dataset`](../../relations/evaluation/eval_dataset.md) | table | unknown | — | — |
| [`eval_dataset_version`](../../relations/evaluation/eval_dataset_version.md) | table | unknown | Immutable dataset version; verification.v1 rows require a frozen artifact-backed manifest… | → `orchestration.artifact`, → `evaluation.eval_dataset` |
| [`eval_label`](../../relations/evaluation/eval_label.md) | table | unknown | — | → `orchestration.artifact`, → `evaluation.eval_case`, → `evaluation.review_decision` |
| [`eval_run`](../../relations/evaluation/eval_run.md) | table | unknown | — | → `orchestration.attempt`, → `orchestration.capability_version`, → `evaluation.eval_dataset`, → `evaluation.eval_dataset_version` |
| [`eval_run_case_output`](../../relations/evaluation/eval_run_case_output.md) | table | unknown | — | → `evaluation.eval_case`, → `evaluation.eval_run` |
| [`eval_score`](../../relations/evaluation/eval_score.md) | table | unknown | — | → `evaluation.eval_case`, → `orchestration.artifact`, → `evaluation.eval_run` |
| [`experiment`](../../relations/evaluation/experiment.md) | table | unknown | — | → `evaluation.eval_dataset_version` |
| [`experiment_arm`](../../relations/evaluation/experiment_arm.md) | table | unknown | — | → `orchestration.artifact`, → `evaluation.experiment` |
| [`gate`](../../relations/evaluation/gate.md) | table | unknown | — | — |
| [`gate_binding`](../../relations/evaluation/gate_binding.md) | table | unknown | — | → `evaluation.gate` |
| [`gate_result`](../../relations/evaluation/gate_result.md) | table | unknown | — | → `evaluation.eval_run`, → `evaluation.gate`, → `orchestration.work_item` |
| [`grader`](../../relations/evaluation/grader.md) | table | unknown | — | — |
| [`grader_version`](../../relations/evaluation/grader_version.md) | table | unknown | — | → `evaluation.grader`, → `orchestration.artifact` |
| [`judge_output`](../../relations/evaluation/judge_output.md) | table | unknown | — | → `evaluation.grader_version`, → `evaluation.eval_run_case_output` |
| [`metric_definition`](../../relations/evaluation/metric_definition.md) | table | unknown | — | — |
| [`metric_observation`](../../relations/evaluation/metric_observation.md) | table | unknown | — | → `evaluation.eval_case`, → `evaluation.eval_run`, → `evaluation.metric_definition` |
| [`promotion_gate_result`](../../relations/evaluation/promotion_gate_result.md) | table | unknown | — | → `evaluation.eval_run`, → `evaluation.promotion_gate_version` |
| [`promotion_gate_version`](../../relations/evaluation/promotion_gate_version.md) | table | unknown | — | — |
| [`regression`](../../relations/evaluation/regression.md) | table | unknown | — | → `evaluation.eval_run`, → `evaluation.gate` |
| [`regression_baseline`](../../relations/evaluation/regression_baseline.md) | table | unknown | — | → `evaluation.promotion_gate_result`, → `retrieval.vector_space_version` |
| [`review_decision`](../../relations/evaluation/review_decision.md) | table | unknown | — | → `evaluation.eval_label`, → `evaluation.review_task` |
| [`review_task`](../../relations/evaluation/review_task.md) | table | unknown | — | → `staging.candidate`, → `orchestration.capability_version`, → `evidence.claim_conflict`, → `evidence.claim` |
| [`verification_benchmark_arm_publication`](../../relations/evaluation/verification_benchmark_arm_publication.md) | table | unknown | — | → `orchestration.artifact`, → `evaluation.experiment_arm`, → `evaluation.verification_benchmark_run`, → `knowledge_service.operation` |
| [`verification_benchmark_checkpoint`](../../relations/evaluation/verification_benchmark_checkpoint.md) | table | unknown | — | → `evaluation.verification_benchmark_run` |
| [`verification_benchmark_comparison`](../../relations/evaluation/verification_benchmark_comparison.md) | table | unknown | — | → `orchestration.artifact`, → `evaluation.verification_benchmark_run`, → `knowledge_service.operation` |
| [`verification_benchmark_run`](../../relations/evaluation/verification_benchmark_run.md) | table | unknown | — | → `orchestration.artifact`, → `knowledge_service.operation` |

Functions: [`enforce_verification_benchmark_checkpoint_immutable`](../../functions/evaluation/enforce_verification_benchmark_checkpoint_immutable.md), [`enforce_verification_benchmark_comparison_lifecycle`](../../functions/evaluation/enforce_verification_benchmark_comparison_lifecycle.md), [`enforce_verification_benchmark_run_lifecycle`](../../functions/evaluation/enforce_verification_benchmark_run_lifecycle.md), [`guard_benchmark_publication_dependency`](../../functions/evaluation/guard_benchmark_publication_dependency.md), [`guard_verification_benchmark_comparison_operation_success`](../../functions/evaluation/guard_verification_benchmark_comparison_operation_success.md), [`guard_verification_benchmark_comparison_step_success`](../../functions/evaluation/guard_verification_benchmark_comparison_step_success.md), [`guard_verification_benchmark_comparison_success_receipt`](../../functions/evaluation/guard_verification_benchmark_comparison_success_receipt.md), [`guard_verification_benchmark_comparison_terminal_artifact`](../../functions/evaluation/guard_verification_benchmark_comparison_terminal_artifact.md), [`guard_verification_freeze`](../../functions/evaluation/guard_verification_freeze.md), [`validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md), [`validate_verification_benchmark_arm_publication`](../../functions/evaluation/validate_verification_benchmark_arm_publication.md), [`validate_verification_benchmark_checkpoint`](../../functions/evaluation/validate_verification_benchmark_checkpoint.md), [`validate_verification_benchmark_comparison`](../../functions/evaluation/validate_verification_benchmark_comparison.md), [`validate_verification_benchmark_comparison_claim`](../../functions/evaluation/validate_verification_benchmark_comparison_claim.md), [`validate_verification_benchmark_comparison_custody`](../../functions/evaluation/validate_verification_benchmark_comparison_custody.md), [`validate_verification_benchmark_comparison_semantic_binding`](../../functions/evaluation/validate_verification_benchmark_comparison_semantic_binding.md), [`validate_verification_benchmark_run`](../../functions/evaluation/validate_verification_benchmark_run.md), [`validate_verification_dataset_manifest`](../../functions/evaluation/validate_verification_dataset_manifest.md), [`verification_case_artifacts_are_admitted`](../../functions/evaluation/verification_case_artifacts_are_admitted.md), [`verify_sealed_benchmark_arm_publications`](../../functions/evaluation/verify_sealed_benchmark_arm_publications.md).

Types: [`types/evaluation.md`](../../types/evaluation.md).
