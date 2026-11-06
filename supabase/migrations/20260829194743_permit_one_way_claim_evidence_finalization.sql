begin;

-- Extraction creates the evidence link before an independent verifier exists.
-- Permit exactly one transition that attaches the verifier's verdict, authority
-- assessment, and run; after that the link is immutable. Deletes are never allowed.
drop trigger claim_evidence_link_immutable on evidence.claim_evidence_link;

create or replace function evidence.enforce_claim_evidence_finalization() returns trigger
language plpgsql
set search_path=''
as $$
begin
  if tg_op='DELETE' then
    raise exception 'claim evidence links are append-only'
      using errcode='restrict_violation';
  end if;
  if old.claim_id=new.claim_id
     and old.locator_id=new.locator_id
     and old.role=new.role
     and old.verified_by_run_id is null
     and new.verified_by_run_id is not null
     and new.support_verdict is not null
     and new.authority_assessment is not null then
    return new;
  end if;
  raise exception 'claim evidence link permits only one verifier finalization transition'
    using errcode='restrict_violation';
end;
$$;

create trigger claim_evidence_link_immutable
  before update or delete on evidence.claim_evidence_link
  for each row execute function evidence.enforce_claim_evidence_finalization();

commit;
