begin;

-- Status verified means policy-admitted official knowledge. It is not a synonym
-- for directly_supported. History authorization already accepts qualified and
-- derived assessments; this gate must not reject the same official verdicts.

create or replace function evidence.enforce_verified_claim_gate() returns trigger
language plpgsql
set search_path=''
as $$
begin
  if new.status<>'verified' or (tg_op='UPDATE' and old.status='verified') then return new; end if;
  if not exists (
    select 1
    from evidence.verification_finding vf
    join evidence.verification_run vr on vr.id=vf.run_id
    join evidence.claim_evidence_link cel on cel.claim_id=vf.claim_id
    join evidence.claim_evidence_assessment cea
      on cea.claim_evidence_link_id=cel.id and cea.run_id=vr.id
    where vf.claim_id=new.id
      and vf.verdict in ('directly_supported','supported_with_qualification','derived_verified')
      and cea.verdict=vf.verdict
      and vf.replay_signature_match is true
      and vr.ended_at is not null
      and cel.role<>'context'
      and cea.replay_signature_match is true
      and cea.authority_assessment is not null
  ) then
    raise exception 'verified claim requires an official same-run finding and append-only evidence assessment'
      using errcode='check_violation';
  end if;
  return new;
end;
$$;

comment on function evidence.enforce_verified_claim_gate() is
  'Promotes policy-admitted official claims. Status verified is not a synonym for directly_supported. Qualified and derived same-run findings and assessments qualify; unofficial verdicts do not.';

commit;
