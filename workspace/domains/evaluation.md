---
id: "dom:evaluation"
kind: domain
schemas: [evaluation]
aliases: [eval, graders, review tasks, gates]
relations: [evaluation.eval_dataset, evaluation.eval_case, evaluation.eval_run, evaluation.eval_score, evaluation.grader, evaluation.review_task, evaluation.experiment, evaluation.verification_benchmark_run, evaluation.gate]
functions: [evaluation.enforce_verification_benchmark_checkpoint_immutable, evaluation.enforce_verification_benchmark_comparison_lifecycle, evaluation.enforce_verification_benchmark_run_lifecycle, evaluation.guard_benchmark_publication_dependency, evaluation.guard_verification_benchmark_comparison_operation_success, evaluation.guard_verification_benchmark_comparison_step_success, evaluation.guard_verification_benchmark_comparison_success_receipt, evaluation.guard_verification_benchmark_comparison_terminal_artifact, evaluation.guard_verification_freeze, evaluation.validate_verification_artifact_consumer, evaluation.validate_verification_benchmark_arm_publication, evaluation.validate_verification_benchmark_checkpoint, evaluation.validate_verification_benchmark_comparison, evaluation.validate_verification_benchmark_comparison_claim, evaluation.validate_verification_benchmark_comparison_custody, evaluation.validate_verification_benchmark_comparison_semantic_binding, evaluation.validate_verification_benchmark_run, evaluation.validate_verification_dataset_manifest, evaluation.verification_case_artifacts_are_admitted, evaluation.verify_sealed_benchmark_arm_publications]
tasks: [stage-uncertain-candidate]
summary: "Datasets, graders, review tasks, and verification benchmarks."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Evaluation

Datasets, graders, review tasks, and verification benchmarks.

> curated (model_assisted, unreviewed) — Evaluation owns datasets, cases, graders, runs, scores, review tasks, experiments,
> promotion gates, and verification benchmark ledgers. `api.review_queue` exposes
> `evaluation.review_task` to `app_reader`. Review tasks may point at a staging
> candidate, an entity merge, or a ranking result.
> 
> This domain measures systems; it does not store industry facts. A grader score is
> not a `temporal.segment`. Verification benchmark runs compare sealed verification
> arms and are distinct from the component's `knowledge_verification.verification_run`
> (the sealed verification run). `evaluation.experiment` and `evaluation.experiment_arm` are the A/B
> envelope used by the proving ground; they do not admit corpus identities.
> 
> Agents creating review work should prefer the staging and evidence domains, then
> let evaluation attach a human or judge task. Do not treat `evaluation.eval_score`
> as admitted knowledge. Gate results (`evaluation.gate`, `evaluation.gate_result`)
> decide promotion of a system, not publication of a fact.
> 
> Invariant: a score without a grader version is not comparable. Trap: using
> `evaluation.metric_observation` as if it were `ranking.metric_observation` — they
> are different schemas. When identity is uncertain, `stage-uncertain-candidate`
> plus `q:staging.unresolved` is the agent path; evaluation may later attach a
> `evaluation.review_task` to that candidate. Do not ingest eval scores as
> temporal facts. `evaluation.verification_benchmark_run` compares sealed
> verification arms; ask the knowledge_verification component when the question is
> “was this run sealed,” not “did arm B beat arm A.”

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`evaluation.eval_dataset`](../relations/evaluation/eval_dataset.md) | table | PK (id); unique (tenant_id, slug), (tenant_id, id); RLS | `control_plane` |
| [`evaluation.eval_case`](../relations/evaluation/eval_case.md) | table | PK (id); unique (dataset_id, external_key), (tenant_id, id); RLS | `control_plane` |
| [`evaluation.eval_run`](../relations/evaluation/eval_run.md) | table | PK (id); unique (tenant_id, id); RLS | `control_plane` |
| [`evaluation.eval_score`](../relations/evaluation/eval_score.md) | table | PK (id); unique (run_id, case_id); RLS | `control_plane` |
| [`evaluation.grader`](../relations/evaluation/grader.md) | table | PK (id); unique (tenant_id, id), (tenant_id, slug); RLS | `control_plane` |
| [`evaluation.review_task`](../relations/evaluation/review_task.md) | table | PK (id); RLS | `control_plane` |
| [`evaluation.experiment`](../relations/evaluation/experiment.md) | table | PK (id); unique (tenant_id, id); RLS | `control_plane` |
| [`evaluation.verification_benchmark_run`](../relations/evaluation/verification_benchmark_run.md) | table | PK (id); unique (tenant_id, id), (tenant_id, operation_id); RLS | `control_plane` |
| [`evaluation.gate`](../relations/evaluation/gate.md) | table | PK (id); unique (slug); RLS | `control_plane` |

## Functions

[`evaluation.enforce_verification_benchmark_checkpoint_immutable`](../functions/evaluation/enforce_verification_benchmark_checkpoint_immutable.md), [`evaluation.enforce_verification_benchmark_comparison_lifecycle`](../functions/evaluation/enforce_verification_benchmark_comparison_lifecycle.md), [`evaluation.enforce_verification_benchmark_run_lifecycle`](../functions/evaluation/enforce_verification_benchmark_run_lifecycle.md), [`evaluation.guard_benchmark_publication_dependency`](../functions/evaluation/guard_benchmark_publication_dependency.md), [`evaluation.guard_verification_benchmark_comparison_operation_success`](../functions/evaluation/guard_verification_benchmark_comparison_operation_success.md), [`evaluation.guard_verification_benchmark_comparison_step_success`](../functions/evaluation/guard_verification_benchmark_comparison_step_success.md), [`evaluation.guard_verification_benchmark_comparison_success_receipt`](../functions/evaluation/guard_verification_benchmark_comparison_success_receipt.md), [`evaluation.guard_verification_benchmark_comparison_terminal_artifact`](../functions/evaluation/guard_verification_benchmark_comparison_terminal_artifact.md), [`evaluation.guard_verification_freeze`](../functions/evaluation/guard_verification_freeze.md), [`evaluation.validate_verification_artifact_consumer`](../functions/evaluation/validate_verification_artifact_consumer.md), [`evaluation.validate_verification_benchmark_arm_publication`](../functions/evaluation/validate_verification_benchmark_arm_publication.md), [`evaluation.validate_verification_benchmark_checkpoint`](../functions/evaluation/validate_verification_benchmark_checkpoint.md), [`evaluation.validate_verification_benchmark_comparison`](../functions/evaluation/validate_verification_benchmark_comparison.md), [`evaluation.validate_verification_benchmark_comparison_claim`](../functions/evaluation/validate_verification_benchmark_comparison_claim.md), [`evaluation.validate_verification_benchmark_comparison_custody`](../functions/evaluation/validate_verification_benchmark_comparison_custody.md), [`evaluation.validate_verification_benchmark_comparison_semantic_binding`](../functions/evaluation/validate_verification_benchmark_comparison_semantic_binding.md), [`evaluation.validate_verification_benchmark_run`](../functions/evaluation/validate_verification_benchmark_run.md), [`evaluation.validate_verification_dataset_manifest`](../functions/evaluation/validate_verification_dataset_manifest.md), [`evaluation.verification_case_artifacts_are_admitted`](../functions/evaluation/verification_case_artifacts_are_admitted.md), [`evaluation.verify_sealed_benchmark_arm_publications`](../functions/evaluation/verify_sealed_benchmark_arm_publications.md)

## Named queries

[`q:staging.unresolved`](../queries/README.md)

## Tasks

[`stage-uncertain-candidate`](../tasks/stage-uncertain-candidate.md)

Schemas: [`evaluation`](../schemas/evaluation/README.md).
