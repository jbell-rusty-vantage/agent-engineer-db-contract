begin;

-- These columns are required to make extraction replay and verifier independence
-- structural rather than prompt-level promises. The preflight audit confirmed no
-- existing null values in the live database.
alter table evidence.claim alter column producer_attempt_id set not null;
alter table evidence.source_capture alter column produced_by_attempt_id set not null;
alter table evidence.extraction_signature alter column produced_by_attempt_id set not null;
alter table evidence.locator alter column selected_content_sha256 set not null;

create table evidence.claim_product_version (
  claim_id          uuid not null references evidence.claim(id) on delete cascade,
  product_version_id uuid not null references corpus.product_version(id) on delete cascade,
  role_in_claim     text not null default 'subject'
    check (role_in_claim in ('subject','object','context','qualifier','comparison')),
  primary key (claim_id,product_version_id,role_in_claim)
);
create index claim_product_version_target_idx on evidence.claim_product_version(product_version_id);

-- Normalize association roles so comparative claims are accepted consistently.
do $$
declare relation_name text;
declare constraint_name text;
begin
  foreach relation_name in array array[
    'claim_library','claim_repository','claim_person','claim_organization','claim_paper',
    'claim_talk','claim_video','claim_product','claim_concept','claim_dataset','claim_benchmark',
    'claim_ai_model_version','claim_protocol_version','claim_mcp_server_version',
    'claim_agent_skill_version','claim_technical_record','claim_case_study'
  ] loop
    select con.conname into constraint_name
    from pg_constraint con
    join pg_class cls on cls.oid=con.conrelid
    join pg_namespace nsp on nsp.oid=cls.relnamespace
    where nsp.nspname='evidence' and cls.relname=relation_name and con.contype='c'
      and pg_get_constraintdef(con.oid) like '%role_in_claim%'
    limit 1;
    if constraint_name is not null then
      execute format('alter table evidence.%I drop constraint %I',relation_name,constraint_name);
    end if;
    execute format(
      'alter table evidence.%I add constraint %I check (role_in_claim in (''subject'',''object'',''context'',''qualifier'',''comparison''))',
      relation_name,relation_name||'_role_in_claim_check');
    constraint_name:=null;
  end loop;
end;
$$;

-- Locators, evidence links, and findings are append-only audit records. Corrections
-- create replacement rows/conflicts rather than rewriting what was assessed.
create trigger locator_immutable
  before update or delete on evidence.locator
  for each row execute function util.reject_mutation();
create trigger claim_evidence_link_immutable
  before update or delete on evidence.claim_evidence_link
  for each row execute function util.reject_mutation();
create trigger verification_finding_immutable
  before update or delete on evidence.verification_finding
  for each row execute function util.reject_mutation();

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
    where vf.claim_id=new.id
      and vf.verdict in ('directly_supported','partially_supported','supported_with_qualification')
      and vf.replay_signature_match is true
      and vr.ended_at is not null
  ) then
    raise exception 'verified claim requires a completed independent supporting finding with replay match'
      using errcode='check_violation';
  end if;
  if not exists (
    select 1 from evidence.claim_evidence_link cel
    where cel.claim_id=new.id and cel.role<>'context'
      and cel.support_verdict in ('directly_supported','partially_supported','supported_with_qualification')
      and cel.verified_by_run_id is not null
      and cel.authority_assessment is not null
  ) then
    raise exception 'verified claim requires verified non-context evidence and authority assessment'
      using errcode='check_violation';
  end if;
  return new;
end;
$$;

create trigger claim_verified_gate
  before insert or update of status on evidence.claim
  for each row execute function evidence.enforce_verified_claim_gate();

alter table evidence.claim_product_version enable row level security;
create policy bounded_role_access on evidence.claim_product_version
  as permissive for all
  to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
  using(true) with check(true);
grant select,insert on evidence.claim_product_version to executor_service,pipeline_agent;
grant select on evidence.claim_product_version to verifier_agent,app_reader;

comment on table evidence.claim_product_version is 'Typed claim association for an exact SaaS or product release/version.';

commit;
