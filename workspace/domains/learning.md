---
id: "dom:learning"
kind: domain
lens: ours
schemas: [learning]
aliases: [learners, enrollment, attempts, submissions, grading, mastery, appeals, credits]
relations: [learning.enrollment, learning.release_adoption, learning.attempt, learning.submission, learning.evidence_item, learning.evidence_grant, learning.grading_run, learning.criterion_result, learning.assessment_result, learning.mastery_decision, learning.appeal, learning.credit, learning.equivalence_request, learning.environment_session]
functions: [product.band, product.band_rank, product.finalize, product.policy]
tasks: [search-my-notes]
summary: "What learners do (lens ours): enroll in an offer, adopt a release, attempt activities, submit evidence, get graded, appeal, earn credit."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# Learning (enrollment, attempts, assessment)

What learners do (lens ours): enroll in an offer, adopt a release, attempt activities, submit evidence, get graded, appeal, earn credit.

> curated (model_assisted, unreviewed) — `learning.enrollment` ties a learner to a `authoring.distribution_offer`;
> `learning.release_adoption` records which frozen release they follow (`adopt_release`).
> `learning.attempt` → `learning.submission` → `learning.evidence_item` (revision, artifact,
> message, file set, deployment or external reference, hashed) is the proof trail;
> `learning.evidence_grant` lets a learner share evidence with a reviewer.
> `learning.grading_run` and `learning.criterion_result` are the worker's grading
> (`record_grading`); `learning.assessment_result` is finalized by `product.finalize` under
> the workspace policy (`access.policy_version`) either automatically or after human review
> (`finalize_result`). `learning.mastery_decision`, `learning.appeal` (`open_appeal`,
> `resolve_appeal`), `learning.credit` and `learning.equivalence_request`
> (`propose_equivalence`, `decide_equivalence`) complete the loop;
> `learning.environment_session` (`request_environment`) provisions a harness or browser
> runtime.
> 
> Read progress through the `progress` and `get_result` operations (`ops/progress.md`,
> `ops/get_result.md`); there are no app_reader views over learning rows. Private learner
> notes are not here: they are `library.passage` rows with lens private. Trap: an agent
> acting through a harness grant may propose but not record human review outcomes.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`learning.enrollment`](../relations/learning/enrollment.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, learner_id, distribution_id); RLS | helpers only |
| [`learning.release_adoption`](../relations/learning/release_adoption.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, enrollment_id, id), (tenant_id, workspace_id, enrollment_id, sequence_no), (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.attempt`](../relations/learning/attempt.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.submission`](../relations/learning/submission.md) | table | PK (id); unique (tenant_id, workspace_id, attempt_id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.evidence_item`](../relations/learning/evidence_item.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, submission_id, item_key); RLS | helpers only |
| [`learning.evidence_grant`](../relations/learning/evidence_grant.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.grading_run`](../relations/learning/grading_run.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.criterion_result`](../relations/learning/criterion_result.md) | table | PK (id); unique (tenant_id, workspace_id, grading_run_id, criterion_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.assessment_result`](../relations/learning/assessment_result.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, submission_id, sequence_no); RLS | helpers only |
| [`learning.mastery_decision`](../relations/learning/mastery_decision.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.appeal`](../relations/learning/appeal.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.credit`](../relations/learning/credit.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.equivalence_request`](../relations/learning/equivalence_request.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`learning.environment_session`](../relations/learning/environment_session.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |

## Functions

[`product.band`](../functions/product/band.md), [`product.band_rank`](../functions/product/band_rank.md), [`product.finalize`](../functions/product/finalize.md), [`product.policy`](../functions/product/policy.md)

## Named queries

[`q:ours.works_authored`](../queries/README.md)

## Tasks

[`search-my-notes`](../tasks/search-my-notes.md)

Schemas: [`learning`](../schemas/learning/README.md).
