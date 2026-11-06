-- Close downstream artifact-reference bypasses without changing legacy rows.
-- A verification consumer may only adopt bytes that completed the canonical
-- same-tenant CAS registration and immutable metadata contract.
begin;
set local lock_timeout='10s';
set local statement_timeout='120s';

create or replace function orchestration.verification_artifact_is_admitted(
 p_tenant_id uuid,
 p_artifact_id uuid,
 p_artifact_type text default null,
 p_sha256 text default null
) returns boolean
language sql stable set search_path='' as $$
 select exists(
  select 1
  from orchestration.artifact a
  join orchestration.verification_artifact_metadata m
   on m.tenant_id=a.tenant_id and m.artifact_id=a.id
  where a.tenant_id=p_tenant_id
   and a.id=p_artifact_id
   and a.verification_contract_version='verification.v1'
   and a.storage_state='available'
   and (p_artifact_type is null or a.artifact_type=p_artifact_type)
   and (p_sha256 is null or a.sha256=p_sha256)
 )
$$;

create or replace function evidence.verification_locator_artifacts_are_admitted(
 p_tenant_id uuid,
 p_capture_id uuid,
 p_representation_artifact_id uuid
) returns boolean
language sql stable set search_path='' as $$
 select exists(
  select 1
  from evidence.source_capture c
  where c.tenant_id=p_tenant_id
   and c.id=p_capture_id
   and orchestration.verification_artifact_is_admitted(
    p_tenant_id,c.artifact_id,'source_capture',c.content_sha256)
   and orchestration.verification_artifact_is_admitted(
    p_tenant_id,p_representation_artifact_id,null,null)
   and (
    p_representation_artifact_id=c.artifact_id
    or exists(
     select 1
     from orchestration.verification_artifact_metadata m
     join orchestration.artifact_lineage l
      on l.tenant_id=m.tenant_id
      and l.from_artifact_id=m.artifact_id
      and l.to_artifact_id=c.artifact_id
      and l.relation_kind='generated'
      and l.activity_id=m.producer_activity_id
      and l.activity_version=m.producer_version
      and l.transformation_signature=m.transformation_signature
     where m.tenant_id=p_tenant_id
      and m.artifact_id=p_representation_artifact_id
      and c.artifact_id=any(m.parent_artifact_ids)
      and m.transformation_signature is not null
    )
   )
 )
$$;

create or replace function orchestration.verification_provider_artifacts_are_admitted(
 p_tenant_id uuid,
 p_request_artifact_id uuid,
 p_request_sha256 text,
 p_response_artifact_id uuid
) returns boolean
language sql stable set search_path='' as $$
 select
  p_request_artifact_id is not null
  and orchestration.verification_artifact_is_admitted(
   p_tenant_id,p_request_artifact_id,'verification_provider_request',p_request_sha256)
  and (
   p_response_artifact_id is null
   or (
    p_request_artifact_id is not null
    and orchestration.verification_artifact_is_admitted(
     p_tenant_id,p_response_artifact_id,'verification_provider_response_envelope',null)
    and exists(
     select 1
     from orchestration.verification_artifact_metadata m
     where m.tenant_id=p_tenant_id
      and m.artifact_id=p_response_artifact_id
      and array_lower(m.parent_artifact_ids,1)=1
      and cardinality(m.parent_artifact_ids)=2
      and m.parent_artifact_ids[1]=p_request_artifact_id
      and orchestration.verification_artifact_is_admitted(
       p_tenant_id,m.parent_artifact_ids[2],'verification_provider_raw_response',null)
    )
   )
  )
$$;

create or replace function evaluation.verification_case_artifacts_are_admitted(
 p_tenant_id uuid,
 p_dataset_id uuid,
 p_dataset_version_id uuid,
 p_input_artifact_id uuid,
 p_gold_artifact_id uuid
) returns boolean
language sql stable set search_path='' as $$
 select exists(
  select 1
  from evaluation.eval_dataset_version v
  where v.tenant_id=p_tenant_id
   and v.id=p_dataset_version_id
   and v.dataset_id=p_dataset_id
   and v.contract_version='verification.v1'
   and orchestration.verification_artifact_is_admitted(
    p_tenant_id,p_input_artifact_id,'evaluation_case_input',null)
   and (
    (v.label_provenance in('synthetic','agent_generated')
     and orchestration.verification_artifact_is_admitted(
      p_tenant_id,p_gold_artifact_id,'evaluation_case_input',null))
    or
    (v.label_provenance in('human_reviewed','human_adjudicated')
     and orchestration.verification_artifact_is_admitted(
      p_tenant_id,p_gold_artifact_id,'evaluation_gold_label',null))
   )
 )
$$;

-- Refuse convergence if a previously accepted verification.v1 consumer points
-- at an unmarked, unavailable, metadata-free, wrong-type, or wrong-digest row.
-- Legacy rows are deliberately outside this preflight.
do $$
begin
 if exists(
  select 1 from evidence.source_capture c
  join evidence.source s on s.tenant_id=c.tenant_id and s.id=c.source_id
  left join orchestration.artifact a on a.tenant_id=c.tenant_id and a.id=c.artifact_id
  where s.verification_contract_version='verification.v1'
   and (not orchestration.verification_artifact_is_admitted(c.tenant_id,c.artifact_id,'source_capture',c.content_sha256)
    or a.media_type is distinct from c.media_type)
 ) then raise exception 'verification consumer preflight: v1 source capture has an inadmissible artifact binding'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evidence.locator l
  where l.verification_contract_version='verification.v1'
   and not evidence.verification_locator_artifacts_are_admitted(l.tenant_id,l.capture_id,l.representation_artifact_id)
 ) then raise exception 'verification consumer preflight: v1 locator has inadmissible capture or representation lineage'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evidence.verification_run r
  where r.contract_version='verification.v1' and (
   not orchestration.verification_artifact_is_admitted(r.tenant_id,r.policy_artifact_id,'verification_policy',r.policy_artifact_sha256)
   or not orchestration.verification_artifact_is_admitted(r.tenant_id,r.run_manifest_artifact_id,'verification_run_manifest',r.manifest_sha256)
   or not orchestration.verification_artifact_is_admitted(r.tenant_id,r.bundle_artifact_id,'verification_bundle',null)
   or not orchestration.verification_artifact_is_admitted(r.tenant_id,r.deterministic_result_artifact_id,'deterministic_verification_result',null)
  )
 ) then raise exception 'verification consumer preflight: v1 run has inadmissible artifact bindings'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evaluation.eval_dataset_version v
  where v.contract_version='verification.v1'
   and not orchestration.verification_artifact_is_admitted(v.tenant_id,v.manifest_artifact_id,'evaluation_dataset_manifest',v.manifest_sha256)
 ) then raise exception 'verification consumer preflight: v1 dataset version has an inadmissible manifest artifact'
  using errcode='foreign_key_violation'; end if;

 if exists(
 select 1 from evaluation.eval_case c
  where c.verification_contract_version='verification.v1'
   and not evaluation.verification_case_artifacts_are_admitted(
    c.tenant_id,c.dataset_id,c.dataset_version_id,c.input_manifest_artifact_id,c.gold_artifact_id)
 ) then raise exception 'verification consumer preflight: v1 evaluation case has inadmissible input or expectation artifacts'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evaluation.eval_label l
  where l.verification_contract_version='verification.v1'
   and not orchestration.verification_artifact_is_admitted(l.tenant_id,l.label_artifact_id,'evaluation_gold_label',l.label_sha256)
 ) then raise exception 'verification consumer preflight: v1 evaluation label has an inadmissible artifact'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evaluation.grader_version g
  where g.verification_contract_version='verification.v1'
   and not orchestration.verification_artifact_is_admitted(g.tenant_id,g.manifest_artifact_id,'grader_manifest',g.manifest_sha256)
 ) then raise exception 'verification consumer preflight: v1 grader version has an inadmissible manifest artifact'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evaluation.experiment_arm a
  where a.verification_contract_version='verification.v1'
   and not orchestration.verification_artifact_is_admitted(a.tenant_id,a.configuration_artifact_id,'evaluation_arm_manifest',a.configuration_sha256)
 ) then raise exception 'verification consumer preflight: v1 experiment arm has an inadmissible configuration artifact'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evaluation.eval_run r
  where r.verification_contract_version='verification.v1' and (
   not orchestration.verification_artifact_is_admitted(r.tenant_id,r.run_manifest_artifact_id,'verification_run_manifest',null)
   or not orchestration.verification_artifact_is_admitted(r.tenant_id,r.policy_artifact_id,'verification_policy',null)
  )
 ) then raise exception 'verification consumer preflight: v1 evaluation run has inadmissible artifact bindings'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from evaluation.eval_score s
  where s.verification_contract_version='verification.v1'
   and not orchestration.verification_artifact_is_admitted(s.tenant_id,s.result_artifact_id,'deterministic_verification_result',s.result_sha256)
 ) then raise exception 'verification consumer preflight: v1 evaluation score has an inadmissible result artifact'
  using errcode='foreign_key_violation'; end if;

 if exists(
  select 1 from orchestration.verification_provider_attempt p
  where not orchestration.verification_provider_artifacts_are_admitted(
   p.tenant_id,p.request_artifact_id,p.request_sha256,p.response_artifact_id)
 ) then raise exception 'verification consumer preflight: provider accounting has inadmissible request or response-envelope lineage'
  using errcode='foreign_key_violation'; end if;
end $$;

create or replace function evidence.validate_capture_artifact() returns trigger
language plpgsql set search_path='' as $$
declare source_contract text;
begin
 select s.verification_contract_version into source_contract
 from evidence.source s where s.tenant_id=new.tenant_id and s.id=new.source_id;
 if source_contract='verification.v1' then
  if not orchestration.verification_artifact_is_admitted(
    new.tenant_id,new.artifact_id,'source_capture',new.content_sha256)
   or not exists(select 1 from orchestration.artifact a
    where a.tenant_id=new.tenant_id and a.id=new.artifact_id and a.media_type=new.media_type) then
   raise exception 'verification.v1 capture requires an available marked metadata-backed same-tenant source artifact with matching bytes and media type'
    using errcode='foreign_key_violation';
  end if;
 elsif not exists(select 1 from orchestration.artifact a
  where a.tenant_id=new.tenant_id and a.id=new.artifact_id
   and a.sha256=new.content_sha256 and a.media_type=new.media_type
   and a.artifact_type='source_capture') then
  raise exception 'capture must bind a same-tenant registered source artifact with matching bytes'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

create or replace function evidence.validate_locator_capture_lineage() returns trigger
language plpgsql set search_path='' as $$
begin
 if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
 if not evidence.verification_locator_artifacts_are_admitted(
  new.tenant_id,new.capture_id,new.representation_artifact_id) then
  raise exception 'verification.v1 locator requires available marked metadata-backed capture and representation artifacts with exact registered lineage'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

create or replace function evidence.validate_verification_run() returns trigger
language plpgsql set search_path='' as $$
declare producer_deployment text; verifier_deployment text; item_mission uuid;
begin
 if new.contract_version is distinct from 'verification.v1' then return new; end if;
 select agent_deployment_id into producer_deployment from orchestration.attempt
  where tenant_id=new.tenant_id and id=new.producer_attempt_id;
 select agent_deployment_id into verifier_deployment from orchestration.attempt
  where tenant_id=new.tenant_id and id=new.verifier_attempt_id;
 if producer_deployment is null or verifier_deployment is null or producer_deployment=verifier_deployment then
  raise exception 'producer and verifier deployments must be present and distinct' using errcode='restrict_violation';
 end if;
 if new.work_item_id is not null then
  select mission_id into item_mission from orchestration.work_item where tenant_id=new.tenant_id and id=new.work_item_id;
  if item_mission is null or (new.mission_id is not null and new.mission_id<>item_mission) then
   raise exception 'verification mission/work-item lineage mismatch' using errcode='foreign_key_violation';
  end if;
 end if;
 if not orchestration.verification_artifact_is_admitted(
  new.tenant_id,new.policy_artifact_id,'verification_policy',new.policy_artifact_sha256) then
  raise exception 'verification policy artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not orchestration.verification_artifact_is_admitted(
  new.tenant_id,new.run_manifest_artifact_id,'verification_run_manifest',new.manifest_sha256) then
  raise exception 'verification manifest artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not orchestration.verification_artifact_is_admitted(
   new.tenant_id,new.bundle_artifact_id,'verification_bundle',null)
  or not orchestration.verification_artifact_is_admitted(
   new.tenant_id,new.deterministic_result_artifact_id,'deterministic_verification_result',null) then
  raise exception 'verification bundle/result artifact registration missing' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

create or replace function evaluation.validate_verification_dataset_manifest() returns trigger
language plpgsql set search_path='' as $$
begin
 if new.contract_version is distinct from 'verification.v1' then return new; end if;
 if not orchestration.verification_artifact_is_admitted(
  new.tenant_id,new.manifest_artifact_id,'evaluation_dataset_manifest',new.manifest_sha256) then
  raise exception 'verification dataset version requires an available marked metadata-backed same-tenant dataset manifest artifact with matching digest'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

create or replace function evaluation.validate_verification_artifact_consumer() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_table_name='eval_case' then
  if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
  if not evaluation.verification_case_artifacts_are_admitted(
   new.tenant_id,new.dataset_id,new.dataset_version_id,new.input_manifest_artifact_id,new.gold_artifact_id) then
   raise exception 'verification evaluation case requires admitted input and label-provenance-compatible expectation artifacts from its exact dataset version'
    using errcode='foreign_key_violation';
  end if;
 elsif tg_table_name='eval_label' then
  if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.label_artifact_id,'evaluation_gold_label',new.label_sha256) then
   raise exception 'verification evaluation label requires an admitted gold-label artifact with matching digest'
    using errcode='foreign_key_violation';
  end if;
 elsif tg_table_name='grader_version' then
  if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.manifest_artifact_id,'grader_manifest',new.manifest_sha256) then
   raise exception 'verification grader version requires an admitted grader manifest with matching digest'
    using errcode='foreign_key_violation';
  end if;
 elsif tg_table_name='experiment_arm' then
  if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.configuration_artifact_id,'evaluation_arm_manifest',new.configuration_sha256) then
   raise exception 'verification experiment arm requires an admitted configuration artifact with matching digest'
    using errcode='foreign_key_violation';
  end if;
 elsif tg_table_name='eval_run' then
  if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.run_manifest_artifact_id,'verification_run_manifest',null)
   or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.policy_artifact_id,'verification_policy',null) then
   raise exception 'verification evaluation run requires admitted run-manifest and policy artifacts'
    using errcode='foreign_key_violation';
  end if;
 elsif tg_table_name='eval_score' then
  if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.result_artifact_id,'deterministic_verification_result',new.result_sha256) then
   raise exception 'verification evaluation score requires an admitted deterministic result artifact with matching digest'
    using errcode='foreign_key_violation';
  end if;
 else
  raise exception 'verification artifact consumer trigger attached to unsupported table %',tg_table_name
   using errcode='internal_error';
 end if;
 return new;
end $$;

create or replace function orchestration.validate_verification_provider_artifacts() returns trigger
language plpgsql set search_path='' as $$
begin
 if not orchestration.verification_provider_artifacts_are_admitted(
  new.tenant_id,new.request_artifact_id,new.request_sha256,new.response_artifact_id) then
  raise exception 'verification provider attempt requires an admitted request and exact request-bound response-envelope lineage'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

drop trigger if exists eval_case_artifact_admission on evaluation.eval_case;
create trigger eval_case_artifact_admission before insert or update on evaluation.eval_case
 for each row execute function evaluation.validate_verification_artifact_consumer();
drop trigger if exists eval_label_artifact_admission on evaluation.eval_label;
create trigger eval_label_artifact_admission before insert or update on evaluation.eval_label
 for each row execute function evaluation.validate_verification_artifact_consumer();
drop trigger if exists grader_version_artifact_admission on evaluation.grader_version;
create trigger grader_version_artifact_admission before insert or update on evaluation.grader_version
 for each row execute function evaluation.validate_verification_artifact_consumer();
drop trigger if exists experiment_arm_artifact_admission on evaluation.experiment_arm;
create trigger experiment_arm_artifact_admission before insert or update on evaluation.experiment_arm
 for each row execute function evaluation.validate_verification_artifact_consumer();
drop trigger if exists eval_run_artifact_admission on evaluation.eval_run;
create trigger eval_run_artifact_admission before insert or update on evaluation.eval_run
 for each row execute function evaluation.validate_verification_artifact_consumer();
drop trigger if exists eval_score_artifact_admission on evaluation.eval_score;
create trigger eval_score_artifact_admission before insert or update on evaluation.eval_score
 for each row execute function evaluation.validate_verification_artifact_consumer();
drop trigger if exists verification_provider_attempt_artifact_admission on orchestration.verification_provider_attempt;
create trigger verification_provider_attempt_artifact_admission
 before insert or update on orchestration.verification_provider_attempt
 for each row execute function orchestration.validate_verification_provider_artifacts();

comment on function orchestration.verification_artifact_is_admitted(uuid,uuid,text,text) is
 'True only for an available verification.v1 artifact with immutable same-tenant verification metadata and optional exact type/digest.';

commit;
