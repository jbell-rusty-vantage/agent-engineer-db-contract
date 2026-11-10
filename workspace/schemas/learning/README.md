---
id: "sch:learning"
kind: schema
name: learning
lens: ours
domains: [learning]
relations: 14
functions: 0
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# learning

Lens `ours`. Domains: [`learning`](../../domains/learning.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`appeal`](../../relations/learning/appeal.md) | table | unknown | — | → `auth.users`, → `learning.submission`, → `learning.assessment_result` |
| [`assessment_result`](../../relations/learning/assessment_result.md) | table | unknown | — | → `orchestration.artifact`, → `authoring.work_revision`, → `learning.submission` |
| [`attempt`](../../relations/learning/attempt.md) | table | unknown | — | → `auth.users`, → `curriculum.requirement_option`, → `authoring.release_item`, → `learning.release_adoption` |
| [`credit`](../../relations/learning/credit.md) | table | unknown | — | → `auth.users`, → `curriculum.requirement`, → `curriculum.release_transition`, → `learning.release_adoption` |
| [`criterion_result`](../../relations/learning/criterion_result.md) | table | unknown | — | → `auth.users`, → `learning.grading_run` |
| [`enrollment`](../../relations/learning/enrollment.md) | table | unknown | — | → `auth.users`, → `authoring.distribution`, → `authoring.workspace` |
| [`environment_session`](../../relations/learning/environment_session.md) | table | unknown | — | → `auth.users`, → `authoring.work_revision`, → `authoring.work` |
| [`equivalence_request`](../../relations/learning/equivalence_request.md) | table | unknown | — | → `auth.users`, → `learning.enrollment`, → `authoring.work_revision` |
| [`evidence_grant`](../../relations/learning/evidence_grant.md) | table | unknown | — | → `auth.users`, → `access.guardian_link`, → `learning.enrollment` |
| [`evidence_item`](../../relations/learning/evidence_item.md) | table | unknown | — | → `orchestration.artifact`, → `authoring.deployment`, → `authoring.file_set`, → `conversation.message` |
| [`grading_run`](../../relations/learning/grading_run.md) | table | unknown | — | → `authoring.work_revision`, → `orchestration.artifact`, → `learning.submission` |
| [`mastery_decision`](../../relations/learning/mastery_decision.md) | table | unknown | — | → `auth.users`, → `authoring.work_revision`, → `authoring.workspace` |
| [`release_adoption`](../../relations/learning/release_adoption.md) | table | unknown | — | → `auth.users`, → `authoring.distribution_offer`, → `curriculum.release_transition`, → `learning.enrollment` |
| [`submission`](../../relations/learning/submission.md) | table | unknown | — | → `auth.users`, → `orchestration.artifact`, → `learning.attempt` |

Functions: none.

Types: none.
