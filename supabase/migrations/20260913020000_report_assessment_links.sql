-- Verification happens after rendering/sealing and must not mutate report content.
begin;
set local lock_timeout='15s';
create table research.report_assessment (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 report_artifact_id uuid not null,
 report_digest text not null check(report_digest ~ '^[0-9a-f]{64}$'),
 verification_run_id uuid,
 result_artifact_id uuid not null,
 created_at timestamptz not null default now(),
 unique(tenant_id,report_version_id,result_artifact_id),
 foreign key(tenant_id,report_version_id) references research.report_package(tenant_id,report_version_id),
 foreign key(tenant_id,report_artifact_id) references orchestration.artifact(tenant_id,id),
 foreign key(tenant_id,result_artifact_id) references orchestration.artifact(tenant_id,id),
 foreign key(tenant_id,verification_run_id) references evidence.verification_run(tenant_id,id)
);
create function research.guard_report_assessment() returns trigger
language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from research.report_package_seal where report_version_id=new.report_version_id) then
  raise exception 'REPORT_ASSESSMENT_REQUIRES_SEAL' using errcode='23514';
 end if;
 if not exists(select 1 from research.report_artifact r join orchestration.artifact a on a.id=r.artifact_id
  where r.report_version_id=new.report_version_id and r.role='markdown' and a.id=new.report_artifact_id and a.sha256=new.report_digest) then
  raise exception 'REPORT_ASSESSMENT_DIGEST_MISMATCH' using errcode='23514';
 end if;
 if not exists(select 1 from orchestration.artifact where id=new.result_artifact_id and tenant_id=new.tenant_id and storage_state='available') then
  raise exception 'REPORT_ASSESSMENT_RESULT_UNAVAILABLE' using errcode='23514';
 end if;
 return new;
end $$;
create trigger report_assessment_guard before insert on research.report_assessment for each row execute function research.guard_report_assessment();
create trigger report_assessment_immutable before update or delete on research.report_assessment for each row execute function util.reject_mutation();
alter table research.report_assessment enable row level security;
create policy bounded_role_access on research.report_assessment to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
 using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select on research.report_assessment to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader;
grant insert on research.report_assessment to executor_service,control_plane;
revoke all on research.report_assessment from anon,authenticated;
revoke all on function research.guard_report_assessment() from public;
comment on table research.report_assessment is 'Append-only post-seal assessment artifact binding to exact report bytes. Assessment authority, verdict and allowed uses remain in verification/policy artifacts, never inferred from this link.';
commit;
