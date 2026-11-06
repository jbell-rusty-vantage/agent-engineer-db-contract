begin;

-- A claim's assertion and producer identity are immutable. Corrections create an
-- atomized, narrowed, or superseding claim and move lifecycle status separately.
create trigger claim_content_provenance_immutable
  before update of tenant_id,claim_type,statement,structured,composite,atomized_from_id,
    producer_attempt_id,created_by_receipt_id,created_at
  on evidence.claim
  for each row execute function util.reject_mutation();

-- Draft/proposed cleanup remains possible, but once reviewed or lifecycle-marked
-- a claim is preserved for audit history.
create trigger claim_reviewed_preserved
  before delete on evidence.claim
  for each row when (old.status<>'proposed')
  execute function util.reject_mutation();

commit;
