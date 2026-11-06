-- 0016 | Restore the corpus/knowledge dependency rule.
--
-- Rule 1 of the architecture: corpus and knowledge never reference staging,
-- research, ranking, retrieval, curriculum or evaluation. They may reference
-- evidence.claim (provenance on facts) and orchestration.operation_receipt
-- (which mutation created the row). That is what keeps their grants, RLS and
-- migration cadence independent of the evaluation lifecycle.
--
-- 0014 broke it by adding review_task_id foreign keys to corpus.entity_merge and
-- knowledge.record_reconciliation. Fable's document specifies those columns in
-- its table sketches while also stating the rule that forbids them, so the
-- document contradicts itself here; the rule is the load-bearing half.
--
-- The link is not lost. evaluation.review_task already carries it in the
-- permitted direction through its subject arc:
--     review_task_entity_merge_id_fkey          -> corpus.entity_merge
--     review_task_record_reconciliation_id_fkey -> knowledge.record_reconciliation
-- So the upward columns were redundant as well as illegal, and are dropped
-- rather than merely unconstrained.
--
-- evidence.conflict_reconciliation.review_task_id is deliberately kept: rule 1
-- constrains corpus and knowledge only, and evidence is permitted to reference
-- the review queue.

begin;

alter table corpus.entity_merge
  drop constraint if exists entity_merge_review_task_fk;
alter table corpus.entity_merge
  drop column if exists review_task_id;

alter table knowledge.record_reconciliation
  drop constraint if exists record_reconciliation_review_task_fk;
alter table knowledge.record_reconciliation
  drop column if exists review_task_id;

comment on table corpus.entity_merge is
  'Merge history for canonical entities. The review that authorized a merge is found through evaluation.review_task.entity_merge_id, never by a column here -- corpus must not reference evaluation.';

comment on table knowledge.record_reconciliation is
  'Reconciliation decisions between knowledge records. The authorizing review is found through evaluation.review_task.record_reconciliation_id.';

commit;
