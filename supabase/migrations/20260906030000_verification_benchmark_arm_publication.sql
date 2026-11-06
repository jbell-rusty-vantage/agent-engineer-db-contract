-- Publish a completed offline benchmark as one truthful verification.v1 eval run per real arm.
begin;

create table evaluation.verification_benchmark_arm_publication (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.default_tenant_id(),
 benchmark_run_id uuid not null,
 operation_id uuid not null,
 benchmark_arm_id text not null check(length(benchmark_arm_id) between 1 and 255 and btrim(benchmark_arm_id)<>''),
 experiment_arm_id uuid not null,
 eval_run_id uuid not null,
 publication_manifest_artifact_id uuid not null,
 publication_manifest_sha256 text not null check(publication_manifest_sha256 ~ '^[0-9a-f]{64}$'),
 configuration_artifact_id uuid not null,
 configuration_sha256 text not null check(configuration_sha256 ~ '^[0-9a-f]{64}$'),
 policy_artifact_id uuid not null,
 policy_sha256 text not null check(policy_sha256 ~ '^[0-9a-f]{64}$'),
 target_code_ref text not null check(length(target_code_ref) between 1 and 4096 and btrim(target_code_ref)<>''),
 terminal_status text not null check(terminal_status in('succeeded','failed','review','abstained')),
 created_at timestamptz not null default clock_timestamp(),
 unique(tenant_id,id),
 unique(tenant_id,benchmark_run_id,benchmark_arm_id),
 unique(tenant_id,benchmark_run_id,experiment_arm_id),
 unique(tenant_id,eval_run_id),
 foreign key(tenant_id,benchmark_run_id) references evaluation.verification_benchmark_run(tenant_id,id) on delete restrict,
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,experiment_arm_id) references evaluation.experiment_arm(tenant_id,id) on delete restrict,
 foreign key(tenant_id,eval_run_id) references evaluation.eval_run(tenant_id,id) on delete restrict,
 foreign key(tenant_id,publication_manifest_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,configuration_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,policy_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict
);

create or replace function evaluation.validate_verification_benchmark_arm_publication() returns trigger
language plpgsql set search_path='' as $$
declare benchmark evaluation.verification_benchmark_run%rowtype; operation knowledge_service.operation%rowtype;
begin
 select * into benchmark from evaluation.verification_benchmark_run where tenant_id=new.tenant_id and id=new.benchmark_run_id;
 if benchmark.id is null or benchmark.status<>'sealed' or benchmark.operation_id<>new.operation_id then
  raise exception 'benchmark arm publication requires its exact sealed benchmark operation' using errcode='foreign_key_violation';
 end if;
 select * into operation from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id;
 if operation.id is null then raise exception 'benchmark arm publication operation missing' using errcode='foreign_key_violation'; end if;
 if not exists(select 1 from jsonb_array_elements(benchmark.checkpoint_plan) item where item->>'armId'=new.benchmark_arm_id) then
  raise exception 'benchmark arm publication is outside the persisted checkpoint plan' using errcode='foreign_key_violation';
 end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.publication_manifest_artifact_id,'verification_run_manifest',new.publication_manifest_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.configuration_artifact_id,'evaluation_arm_manifest',new.configuration_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.policy_artifact_id,'verification_policy',new.policy_sha256) then
  raise exception 'benchmark arm publication artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(
  select 1 from evaluation.eval_run r
  join evaluation.experiment_arm arm on arm.tenant_id=r.tenant_id and arm.id=r.experiment_arm_id
  join evaluation.experiment experiment on experiment.tenant_id=arm.tenant_id and experiment.id=arm.experiment_id
  join evaluation.eval_dataset_version version on version.tenant_id=experiment.tenant_id and version.id=experiment.dataset_version_id
  where r.tenant_id=new.tenant_id and r.id=new.eval_run_id
   and r.verification_contract_version='verification.v1'
   and r.dataset_id=version.dataset_id and r.dataset_version_id=version.id and r.experiment_arm_id=new.experiment_arm_id
   and arm.configuration_artifact_id=new.configuration_artifact_id and arm.configuration_sha256=new.configuration_sha256
   and arm.configuration->>'armId'=new.benchmark_arm_id
   and r.run_manifest_artifact_id=new.publication_manifest_artifact_id and r.policy_artifact_id=new.policy_artifact_id
   and r.target_code_ref=new.target_code_ref and r.target_kind='code_ref' and r.status=new.terminal_status
   and r.mission_id is not distinct from operation.mission_id and r.work_item_id is not distinct from operation.work_item_id and r.attempt_id is not distinct from operation.attempt_id
   and r.started_at=benchmark.started_at and r.ended_at=benchmark.completed_at
 ) then raise exception 'benchmark arm publication eval run binding mismatch' using errcode='foreign_key_violation'; end if;
 return new;
end $$;
create trigger verification_benchmark_arm_publication_validate before insert or update on evaluation.verification_benchmark_arm_publication
 for each row execute function evaluation.validate_verification_benchmark_arm_publication();

create or replace function evaluation.verify_sealed_benchmark_arm_publications() returns trigger
language plpgsql set search_path='' as $$
declare expected_count integer; actual_count integer;
begin
 if new.status<>'sealed' then return new; end if;
 select count(distinct item->>'armId') into expected_count from jsonb_array_elements(new.checkpoint_plan) item;
 select count(*) into actual_count from evaluation.verification_benchmark_arm_publication where tenant_id=new.tenant_id and benchmark_run_id=new.id;
 if actual_count<>expected_count or exists(select 1 from jsonb_array_elements(new.checkpoint_plan) item where not exists(select 1 from evaluation.verification_benchmark_arm_publication p where p.tenant_id=new.tenant_id and p.benchmark_run_id=new.id and p.benchmark_arm_id=item->>'armId')) then
  raise exception 'sealed benchmark requires one publication for each planned arm' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create constraint trigger verification_benchmark_run_arm_publications_complete
 after update of status on evaluation.verification_benchmark_run deferrable initially deferred
 for each row execute function evaluation.verify_sealed_benchmark_arm_publications();

create or replace function evaluation.guard_benchmark_publication_dependency() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_table_name='eval_run' and exists(select 1 from evaluation.verification_benchmark_arm_publication p where p.tenant_id=old.tenant_id and p.eval_run_id=old.id) then
  raise exception 'published benchmark evaluation runs are immutable' using errcode='restrict_violation';
 end if;
 if tg_table_name='eval_dataset_version' and exists(select 1 from evaluation.verification_benchmark_arm_publication p join evaluation.eval_run r on r.tenant_id=p.tenant_id and r.id=p.eval_run_id where r.tenant_id=old.tenant_id and r.dataset_version_id=old.id) then
  raise exception 'published benchmark dataset versions are immutable' using errcode='restrict_violation';
 end if;
 if tg_table_name='experiment' and exists(select 1 from evaluation.verification_benchmark_arm_publication p join evaluation.experiment_arm a on a.tenant_id=p.tenant_id and a.id=p.experiment_arm_id where a.tenant_id=old.tenant_id and a.experiment_id=old.id) then
  raise exception 'published benchmark experiments are immutable' using errcode='restrict_violation';
 end if;
 return coalesce(new,old);
end $$;
create trigger eval_run_benchmark_publication_immutable before update or delete on evaluation.eval_run for each row execute function evaluation.guard_benchmark_publication_dependency();
create trigger eval_dataset_version_benchmark_publication_immutable before update or delete on evaluation.eval_dataset_version for each row execute function evaluation.guard_benchmark_publication_dependency();
create trigger experiment_benchmark_publication_immutable before update or delete on evaluation.experiment for each row execute function evaluation.guard_benchmark_publication_dependency();
create trigger verification_benchmark_arm_publication_immutable before update or delete on evaluation.verification_benchmark_arm_publication for each row execute function util.reject_mutation();

alter table evaluation.verification_benchmark_arm_publication enable row level security;
create policy bounded_role_access on evaluation.verification_benchmark_arm_publication for all to control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on evaluation.verification_benchmark_arm_publication to control_plane;
commit;
