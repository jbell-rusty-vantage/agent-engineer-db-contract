-- Durable, fenced state for the admitted offline multi-arm benchmark runner.
-- `evaluation.eval_run` remains optional until a real aggregate multi-arm
-- evaluation mapping is available; this table never invents an arm alias.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_run_manifest','Immutable terminal manifest for a durable offline verification benchmark run')
on conflict(code) do update set description=excluded.description;

create table evaluation.verification_benchmark_run (
 id uuid primary key,
 tenant_id uuid not null default util.default_tenant_id(),
 operation_id uuid not null,
 dataset_artifact_id uuid not null,
 dataset_sha256 text not null check(dataset_sha256 ~ '^[0-9a-f]{64}$'),
 experiment_artifact_id uuid not null,
 experiment_sha256 text not null check(experiment_sha256 ~ '^[0-9a-f]{64}$'),
 runner_version text not null check(length(runner_version) between 1 and 255),
 network_policy text not null check(network_policy='offline'),
 random_seed integer not null,
 repetitions integer not null check(repetitions between 1 and 10),
 checkpoint_plan jsonb not null,
 checkpoint_plan_sha256 text not null check(checkpoint_plan_sha256 ~ '^[0-9a-f]{64}$'),
 expected_checkpoint_count integer not null check(expected_checkpoint_count between 1 and 160000),
 started_at timestamptz not null,
 completed_at timestamptz,
 run_manifest_artifact_id uuid,
 run_manifest_sha256 text check(run_manifest_sha256 is null or run_manifest_sha256 ~ '^[0-9a-f]{64}$'),
 status text not null check(status in('running','completed','sealed')),
 created_at timestamptz not null default clock_timestamp(),
 unique(tenant_id,id),
 unique(tenant_id,operation_id),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,dataset_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,experiment_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,run_manifest_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 constraint verification_benchmark_run_plan_shape_ck check(
   jsonb_typeof(checkpoint_plan)='array' and jsonb_array_length(checkpoint_plan)=expected_checkpoint_count
 ),
 constraint verification_benchmark_run_lifecycle_ck check(
   (status='running' and completed_at is null and run_manifest_artifact_id is null and run_manifest_sha256 is null)
   or (status='completed' and completed_at is not null and run_manifest_artifact_id is null and run_manifest_sha256 is null)
   or (status='sealed' and completed_at is not null and run_manifest_artifact_id is not null and run_manifest_sha256 is not null)
 )
);

create table evaluation.verification_benchmark_checkpoint (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.default_tenant_id(),
 benchmark_run_id uuid not null,
 checkpoint_context_sha256 text not null check(checkpoint_context_sha256 ~ '^[0-9a-f]{64}$'),
 checkpoint_sha256 text not null check(checkpoint_sha256 ~ '^[0-9a-f]{64}$'),
 result_sha256 text not null check(result_sha256 ~ '^[0-9a-f]{64}$'),
 result jsonb not null,
 completed_at timestamptz not null,
 created_at timestamptz not null default clock_timestamp(),
 unique(tenant_id,id),
 unique(tenant_id,benchmark_run_id,checkpoint_context_sha256),
 foreign key(tenant_id,benchmark_run_id) references evaluation.verification_benchmark_run(tenant_id,id) on delete restrict
);

create or replace function evaluation.validate_verification_benchmark_run() returns trigger
language plpgsql set search_path='' as $$
declare operation_request jsonb;
begin
 if jsonb_typeof(new.checkpoint_plan)<>'array' or jsonb_array_length(new.checkpoint_plan)<>new.expected_checkpoint_count then
  raise exception 'benchmark checkpoint plan shape mismatch' using errcode='check_violation';
 end if;
 if exists(select 1 from jsonb_array_elements(new.checkpoint_plan) item
   where jsonb_typeof(item)<>'object'
      or item->>'checkpointContextDigest' !~ '^sha256:[0-9a-f]{64}$'
      or item->>'caseId' is null or length(item->>'caseId')=0
      or item->>'armId' is null or length(item->>'armId')=0
      or item->>'repetition' !~ '^[0-9]+$') then
  raise exception 'benchmark checkpoint plan entry invalid' using errcode='check_violation';
 end if;
 if (select count(*) from jsonb_array_elements(new.checkpoint_plan))<>(select count(distinct item->>'checkpointContextDigest') from jsonb_array_elements(new.checkpoint_plan) item) then
  raise exception 'benchmark checkpoint plan duplicate key' using errcode='unique_violation';
 end if;
 select request into operation_request from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id;
 if operation_request is null
    or operation_request->>'kind' <> 'verification_benchmark'
    or operation_request #>> '{input,useCase}' <> 'runBenchmark'
    or operation_request #>> '{input,request,executionMode}' <> 'offline_recorded'
    or operation_request #>> '{input,request,dataset,artifactId}' <> new.dataset_artifact_id::text
    or operation_request #>> '{input,request,dataset,digest}' <> 'sha256:'||new.dataset_sha256
    or operation_request #>> '{input,request,experimentDefinition,artifactId}' <> new.experiment_artifact_id::text
    or operation_request #>> '{input,request,experimentDefinition,digest}' <> 'sha256:'||new.experiment_sha256 then
  raise exception 'benchmark operation admitted input binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.dataset_artifact_id
   and a.sha256=new.dataset_sha256 and a.storage_state='available' and a.artifact_type='evaluation_dataset_manifest') then
  raise exception 'benchmark dataset artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.experiment_artifact_id
   and a.sha256=new.experiment_sha256 and a.storage_state='available' and a.artifact_type='verification_benchmark_experiment') then
  raise exception 'benchmark experiment artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if new.run_manifest_artifact_id is not null and not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.run_manifest_artifact_id
   and a.sha256=new.run_manifest_sha256 and a.storage_state='available' and a.artifact_type='verification_benchmark_run_manifest') then
  raise exception 'benchmark run manifest artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_run_validate before insert or update on evaluation.verification_benchmark_run
 for each row execute function evaluation.validate_verification_benchmark_run();

create or replace function evaluation.validate_verification_benchmark_checkpoint() returns trigger
language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from evaluation.verification_benchmark_run r
  where r.tenant_id=new.tenant_id and r.id=new.benchmark_run_id and r.status in('running','completed')
   and exists(select 1 from jsonb_array_elements(r.checkpoint_plan) item
      where item->>'checkpointContextDigest'='sha256:'||new.checkpoint_context_sha256)) then
  raise exception 'benchmark checkpoint is outside its immutable plan' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_checkpoint_validate before insert on evaluation.verification_benchmark_checkpoint
 for each row execute function evaluation.validate_verification_benchmark_checkpoint();

create or replace function evaluation.enforce_verification_benchmark_run_lifecycle() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'benchmark runs are append-only' using errcode='restrict_violation'; end if;
 if old.status='running' and new.status='completed' and (to_jsonb(new)-array['status','completed_at'])=(to_jsonb(old)-array['status','completed_at']) then return new; end if;
 if old.status='completed' and new.status='sealed' and (to_jsonb(new)-array['status','run_manifest_artifact_id','run_manifest_sha256'])=(to_jsonb(old)-array['status','run_manifest_artifact_id','run_manifest_sha256']) then return new; end if;
 raise exception 'benchmark run permits only complete then seal transitions' using errcode='restrict_violation';
end $$;
create trigger verification_benchmark_run_immutable before update or delete on evaluation.verification_benchmark_run
 for each row execute function evaluation.enforce_verification_benchmark_run_lifecycle();
create or replace function evaluation.enforce_verification_benchmark_checkpoint_immutable() returns trigger
language plpgsql set search_path='' as $$
begin raise exception 'benchmark checkpoints are append-only' using errcode='restrict_violation'; end $$;
create trigger verification_benchmark_checkpoint_immutable before update or delete on evaluation.verification_benchmark_checkpoint
 for each row execute function evaluation.enforce_verification_benchmark_checkpoint_immutable();

alter table evaluation.verification_benchmark_run enable row level security;
alter table evaluation.verification_benchmark_checkpoint enable row level security;
create policy bounded_role_access on evaluation.verification_benchmark_run for all to control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy bounded_role_access on evaluation.verification_benchmark_checkpoint for all to control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert,update on evaluation.verification_benchmark_run,evaluation.verification_benchmark_checkpoint to control_plane;

commit;
