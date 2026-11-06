begin;

create or replace function evidence.enforce_verified_claim_gate() returns trigger
language plpgsql
set search_path=''
as $$
begin
  if new.status<>'verified' or (tg_op='UPDATE' and old.status='verified') then
    return new;
  end if;
  if new.producer_attempt_id is null then
    raise exception 'verified claim requires producer attempt provenance'
      using errcode='check_violation';
  end if;
  if not exists (
    select 1
    from evidence.verification_finding vf
    join evidence.verification_run vr on vr.id=vf.run_id
    join evidence.claim_evidence_link cel
      on cel.claim_id=vf.claim_id and cel.verified_by_run_id=vr.id
    where vf.claim_id=new.id
      and vf.verdict='directly_supported'
      and vf.replay_signature_match is true
      and vr.ended_at is not null
      and cel.role<>'context'
      and cel.support_verdict='directly_supported'
      and cel.authority_assessment is not null
  ) then
    raise exception 'verified claim requires directly supported same-run finding and evidence with replay and authority assessment'
      using errcode='check_violation';
  end if;
  return new;
end;
$$;

comment on function evidence.enforce_verified_claim_gate() is
  'Promotes only fully and directly supported atomic claims; partial or qualified results require a narrowed or superseding claim.';

commit;
