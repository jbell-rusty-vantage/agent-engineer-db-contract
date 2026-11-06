begin;

create table evidence.claim_evidence_assessment (
  id                     uuid primary key default util.uuidv7(),
  claim_evidence_link_id uuid not null references evidence.claim_evidence_link(id) on delete cascade,
  run_id                 uuid not null references evidence.verification_run(id) on delete cascade,
  verdict                evidence.support_verdict not null,
  authority_assessment   jsonb not null,
  rationale              text,
  replay_signature_match boolean not null,
  created_at             timestamptz not null default now(),
  unique(claim_evidence_link_id,run_id)
);
create index claim_evidence_assessment_run_idx on evidence.claim_evidence_assessment(run_id);

-- The extraction link itself is append-only. Every verification or revalidation
-- appends an assessment instead of overwriting the original relation.
drop trigger claim_evidence_link_immutable on evidence.claim_evidence_link;
create trigger claim_evidence_link_immutable
  before update or delete on evidence.claim_evidence_link
  for each row execute function util.reject_mutation();
create trigger claim_evidence_assessment_immutable
  before update or delete on evidence.claim_evidence_assessment
  for each row execute function util.reject_mutation();

create or replace function evidence.enforce_assessment_producer_not_verifier() returns trigger
language plpgsql
set search_path=''
as $$
declare
  v_producer text;
  v_verifier text;
begin
  select pa.agent_deployment_id into v_producer
  from evidence.claim_evidence_link cel
  join evidence.claim c on c.id=cel.claim_id
  join orchestration.attempt pa on pa.id=c.producer_attempt_id
  where cel.id=new.claim_evidence_link_id;

  select va.agent_deployment_id into v_verifier
  from evidence.verification_run vr
  join orchestration.attempt va on va.id=vr.verifier_attempt_id
  where vr.id=new.run_id;

  if v_producer=v_verifier then
    raise exception 'producer deployment may not assess its own claim evidence'
      using errcode='restrict_violation';
  end if;
  return new;
end;
$$;
create trigger claim_evidence_assessment_independence
  before insert on evidence.claim_evidence_assessment
  for each row execute function evidence.enforce_assessment_producer_not_verifier();

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
      and vf.verdict='directly_supported'
      and vf.replay_signature_match is true
      and vr.ended_at is not null
      and cel.role<>'context'
      and cea.verdict='directly_supported'
      and cea.replay_signature_match is true
      and cea.authority_assessment is not null
  ) then
    raise exception 'verified claim requires directly supported same-run finding and append-only evidence assessment'
      using errcode='check_violation';
  end if;
  return new;
end;
$$;

alter table evidence.claim_evidence_assessment enable row level security;
create policy bounded_role_access on evidence.claim_evidence_assessment
  as permissive for all
  to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
  using(true) with check(true);
grant select,insert on evidence.claim_evidence_assessment to executor_service,pipeline_agent;
grant select on evidence.claim_evidence_assessment to verifier_agent,app_reader;

comment on table evidence.claim_evidence_assessment is 'Append-only, run-scoped verifier assessment of one immutable claim/evidence link.';
comment on column evidence.claim_evidence_link.support_verdict is 'Legacy projection; new verification writes use evidence.claim_evidence_assessment.';
comment on column evidence.claim_evidence_link.authority_assessment is 'Legacy projection; new verification writes use evidence.claim_evidence_assessment.';
comment on column evidence.claim_evidence_link.verified_by_run_id is 'Legacy projection; new verification writes use evidence.claim_evidence_assessment.';

commit;
