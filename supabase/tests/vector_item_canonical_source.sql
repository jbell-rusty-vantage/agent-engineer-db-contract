begin;

-- Probe the real trigger with the modern row shape. No official vectors or admitted claims are created.
create temporary table vector_trigger_probe (
  tenant_id uuid,space_version_id uuid,embedding_item_id uuid,projection_target_id uuid,search_projection_id uuid
) on commit drop;
create trigger vector_trigger_probe_guard before insert on vector_trigger_probe
  for each row execute function retrieval.enforce_canonical_source();

do $$
declare
  tenant uuid := util.uuidv7();
  mission uuid := util.uuidv7(); work_item uuid := util.uuidv7(); producer_attempt uuid := util.uuidv7();
  exploratory_space uuid := util.uuidv7(); canonical_space uuid := util.uuidv7();
  exploratory_version uuid := util.uuidv7(); canonical_version uuid := util.uuidv7();
  claim uuid := util.uuidv7(); target uuid := util.uuidv7(); projection uuid := util.uuidv7(); procedure uuid := util.uuidv7();
  content_digest text := encode(extensions.digest('trigger candidate','sha256'),'hex');
begin
  perform set_config('app.tenant_id',tenant::text,true);
  insert into orchestration.mission(id,tenant_id,goal) values(mission,tenant,'Rollback-only trigger probe');
  insert into orchestration.work_item(id,tenant_id,mission_id,kind) values(work_item,tenant,mission,'build_vectors');
  insert into orchestration.attempt(id,tenant_id,work_item_id,attempt_no,agent_deployment_id)
    values(producer_attempt,tenant,work_item,1,'vector-trigger-probe');
  insert into retrieval.vector_space(id,tenant_id,slug,purpose,class) values
    (exploratory_space,tenant,'trigger-exploratory','Rollback-only trigger proof','exploratory'),
    (canonical_space,tenant,'trigger-canonical','Rollback-only trigger proof','canonical');
  insert into retrieval.vector_space_version(id,tenant_id,vector_space_id,version,embedding_model,dims,backend,precision) values
    (exploratory_version,tenant,exploratory_space,1,'trigger-fixture',1536,'pgvector','halfvec'),
    (canonical_version,tenant,canonical_space,1,'trigger-fixture',1536,'pgvector','halfvec');

  insert into vector_trigger_probe(tenant_id,space_version_id) values(tenant,exploratory_version);
  begin
    insert into vector_trigger_probe(tenant_id,space_version_id) values(util.uuidv7(),exploratory_version);
    raise exception 'foreign tenant version was accepted';
  exception when restrict_violation then null;
  end;
  begin
    insert into vector_trigger_probe(tenant_id,space_version_id,embedding_item_id) values(tenant,exploratory_version,util.uuidv7());
    raise exception 'missing embedding item was accepted';
  exception when data_exception then null;
  end;
  begin
    insert into vector_trigger_probe(tenant_id,space_version_id) values(tenant,canonical_version);
    raise exception 'canonical vector without target was accepted';
  exception when restrict_violation then null;
  end;

  insert into evidence.claim(id,tenant_id,claim_type,statement,status,producer_attempt_id)
    values(claim,tenant,'capability','Unverified trigger probe','proposed',producer_attempt);
  insert into retrieval.projection_target(id,tenant_id,target_kind,claim_id) values(target,tenant,'claim',claim);
  insert into retrieval.projection_procedure(id,slug,version) values(procedure,'trigger-procedure-'||tenant,1);
  insert into retrieval.search_projection(id,tenant_id,projection_target_id,projection_procedure_id,purpose,source_text,embedding_text,
    source_text_sha256,contextual_prefix_sha256,embedding_text_sha256,content_kind,visibility,classification)
    values(projection,tenant,target,procedure,'Trigger probe','trigger candidate','trigger candidate',content_digest,
      encode(extensions.digest('','sha256'),'hex'),content_digest,'claim','internal','internal');
  begin
    insert into vector_trigger_probe(tenant_id,space_version_id,projection_target_id,search_projection_id)
      values(tenant,canonical_version,target,projection);
    raise exception 'unverified canonical claim was accepted';
  exception when restrict_violation then null;
  end;
  if (select count(*) from vector_trigger_probe)<>1 then raise exception 'trigger probe census differs'; end if;
end;
$$;

rollback;
