-- Canonical, artifact-backed case and evidence identities for the bounded
-- verification read surface. These rows do not infer or alias evaluation,
-- finding, judgment, or locator identities.
begin;

create table evidence.verification_case_run (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  verification_run_id uuid not null,
  case_key text not null check (length(case_key) between 1 and 255 and btrim(case_key)<>''),
  input_artifact_id uuid not null,
  input_sha256 text not null check (input_sha256 ~ '^[0-9a-f]{64}$'),
  result_artifact_id uuid not null,
  result_sha256 text not null check (result_sha256 ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  unique (tenant_id,id),
  unique (tenant_id,verification_run_id,case_key),
  foreign key (tenant_id,verification_run_id)
    references evidence.verification_run(tenant_id,id) on delete restrict,
  foreign key (tenant_id,input_artifact_id)
    references orchestration.artifact(tenant_id,id) on delete restrict,
  foreign key (tenant_id,result_artifact_id)
    references orchestration.artifact(tenant_id,id) on delete restrict
);

create table evidence.verification_case_evidence (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  case_run_id uuid not null,
  evidence_key text not null check (length(evidence_key) between 1 and 255 and btrim(evidence_key)<>''),
  ordinal integer not null check (ordinal between 0 and 255),
  artifact_id uuid not null,
  artifact_sha256 text not null check (artifact_sha256 ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  unique (tenant_id,id),
  unique (tenant_id,case_run_id,evidence_key),
  unique (tenant_id,case_run_id,ordinal),
  foreign key (tenant_id,case_run_id)
    references evidence.verification_case_run(tenant_id,id) on delete restrict,
  foreign key (tenant_id,artifact_id)
    references orchestration.artifact(tenant_id,id) on delete restrict
);

create or replace function evidence.validate_verification_case_run() returns trigger
language plpgsql set search_path='' as $$
begin
  if not exists (
    select 1 from evidence.verification_run run
    where run.tenant_id=new.tenant_id
      and run.id=new.verification_run_id
      and run.contract_version='verification.v1'
  ) then
    raise exception 'verification case requires a same-tenant verification.v1 run'
      using errcode='foreign_key_violation';
  end if;

  if not orchestration.verification_artifact_is_admitted(
    new.tenant_id,new.input_artifact_id,null,new.input_sha256
  ) then
    raise exception 'verification case input artifact must be an available metadata-backed same-tenant verification artifact with an exact digest'
      using errcode='foreign_key_violation';
  end if;

  if not orchestration.verification_artifact_is_admitted(
    new.tenant_id,new.result_artifact_id,null,new.result_sha256
  ) then
    raise exception 'verification case result artifact must be an available metadata-backed same-tenant verification artifact with an exact digest'
      using errcode='foreign_key_violation';
  end if;

  return new;
end;
$$;

create or replace function evidence.validate_verification_case_evidence() returns trigger
language plpgsql set search_path='' as $$
begin
  if not orchestration.verification_artifact_is_admitted(
    new.tenant_id,new.artifact_id,null,new.artifact_sha256
  ) then
    raise exception 'verification case evidence artifact must be an available metadata-backed same-tenant verification artifact with an exact digest'
      using errcode='foreign_key_violation';
  end if;

  return new;
end;
$$;

create trigger verification_case_run_validate
  before insert on evidence.verification_case_run
  for each row execute function evidence.validate_verification_case_run();
create trigger verification_case_evidence_validate
  before insert on evidence.verification_case_evidence
  for each row execute function evidence.validate_verification_case_evidence();
create trigger verification_case_run_immutable
  before update or delete on evidence.verification_case_run
  for each row execute function util.reject_mutation();
create trigger verification_case_evidence_immutable
  before update or delete on evidence.verification_case_evidence
  for each row execute function util.reject_mutation();

alter table evidence.verification_case_run enable row level security;
alter table evidence.verification_case_evidence enable row level security;
create policy bounded_role_access on evidence.verification_case_run for all
  to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
  using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
create policy bounded_role_access on evidence.verification_case_evidence for all
  to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
  using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());

revoke all on evidence.verification_case_run,evidence.verification_case_evidence from public,anon,authenticated;
grant select,insert on evidence.verification_case_run,evidence.verification_case_evidence
  to executor_service,pipeline_agent,verifier_agent,control_plane;
grant select on evidence.verification_case_run,evidence.verification_case_evidence to app_reader;

comment on table evidence.verification_case_run is
  'Immutable artifact-backed verification case result. It does not alias evaluation score/output identities.';
comment on table evidence.verification_case_evidence is
  'Immutable artifact-only evidence reference for a verification case. Finding, judgment, locator, and evaluation aliases are intentionally absent.';

commit;


