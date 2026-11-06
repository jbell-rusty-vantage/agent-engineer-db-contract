begin;

-- Pending, synthetic rows prove SQL visibility only; no review or content admission is asserted.
do $$
declare
  tenant uuid; artifact uuid; document uuid; version uuid; representation uuid;
  node uuid; procedure uuid; chunk_set uuid; chunk uuid; content_digest text;
  ordinal integer;
begin
  for ordinal in 1..2 loop
    tenant := util.uuidv7();
    perform set_config('test.content_link_tenant_' || ordinal, tenant::text, true);
    perform set_config('app.tenant_id', tenant::text, true);
    content_digest := encode(extensions.digest(tenant::text, 'sha256'), 'hex');
    insert into orchestration.artifact(tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path)
      values(tenant,'source_capture',content_digest,'source_captures','test','content-link-rls/' || tenant)
      returning id into artifact;
    insert into content.document(tenant_id,document_type_code,canonical_title)
      values(tenant,'official_docs_page','Pending privilege fixture') returning id into document;
    insert into content.document_version(tenant_id,document_id,version_label,manifest_sha256)
      values(tenant,document,'privilege-fixture',content_digest) returning id into version;
    insert into content.document_representation(tenant_id,document_version_id,artifact_id,representation_kind,
        representation_class,media_type,content_sha256,acceptance_state)
      values(tenant,version,artifact,'plain_text','structural_extraction','text/plain',content_digest,'pending')
      returning id into representation;
    insert into content.document_node(tenant_id,representation_id,ordinal,stable_local_key,node_kind,inline_text,normalized_content_sha256)
      values(tenant,representation,0,'fixture','paragraph',tenant::text,content_digest) returning id into node;
    insert into retrieval.chunking_procedure_version(tenant_id,slug,version,supported_content_classes,tokenizer,schema_contract,code_sha256,status)
      values(tenant,'content-link-rls','1','[]','fixture','{}',content_digest,'candidate') returning id into procedure;
    insert into retrieval.chunk_set(tenant_id,representation_id,procedure_version_id,frozen_config,tokenizer,
        input_manifest_sha256,chunk_set_sha256,status)
      values(tenant,representation,procedure,'{}','fixture',content_digest,content_digest,'queued') returning id into chunk_set;
    insert into retrieval.retrieval_chunk(tenant_id,chunk_set_id,ordinal,source_text,embedding_text,source_text_sha256,
        contextual_prefix_sha256,embedding_text_sha256,source_token_count,embedding_token_count,retrieval_role)
      values(tenant,chunk_set,0,tenant::text,tenant::text,content_digest,
        encode(extensions.digest('', 'sha256'),'hex'),content_digest,1,1,'body') returning id into chunk;
    insert into retrieval.chunk_span(tenant_id,chunk_id,ordinal,document_node_id,start_offset,end_offset,selected_text_sha256)
      values(tenant,chunk,0,node,0,length(tenant::text),content_digest);
  end loop;
end;
$$;

do $$
declare relation text; role_name text;
begin
  foreach relation in array array['retrieval.chunking_procedure_version','retrieval.chunk_set','retrieval.retrieval_chunk','retrieval.chunk_span'] loop
    if not has_table_privilege('executor_service',relation,'SELECT') then raise exception 'Missing source read grant: %',relation; end if;
    if has_table_privilege('executor_service',relation,'INSERT') or has_table_privilege('executor_service',relation,'UPDATE') then
      raise exception 'Source read migration granted writes: %',relation;
    end if;
    foreach role_name in array array['pipeline_agent','verifier_agent','control_plane','app_reader','anon','authenticated'] loop
      if has_table_privilege(role_name,relation,'SELECT') then raise exception 'Unexpected source read grant: % %',role_name,relation; end if;
    end loop;
  end loop;
end;
$$;

set local role executor_service;
reset app.tenant_id;
do $$
declare relation text; visible bigint; tenant_context text; fixture_tenants uuid[];
begin
  fixture_tenants := array[current_setting('test.content_link_tenant_1')::uuid,current_setting('test.content_link_tenant_2')::uuid];
  foreach relation in array array['retrieval.chunking_procedure_version','retrieval.chunk_set','retrieval.retrieval_chunk','retrieval.chunk_span'] loop
    execute format('select count(*) from %s where tenant_id=any($1)',relation) into visible using fixture_tenants;
    if visible<>0 then raise exception 'Missing tenant context disclosed rows: %',relation; end if;
  end loop;
  foreach tenant_context in array array[fixture_tenants[1]::text,fixture_tenants[2]::text,
      util.uuidv7()::text,'','malformed','00000000-0000-0000-0000-000000000000'] loop
    perform set_config('app.tenant_id',tenant_context,true);
    foreach relation in array array['retrieval.chunking_procedure_version','retrieval.chunk_set','retrieval.retrieval_chunk','retrieval.chunk_span'] loop
      execute format('select count(*) from %s where tenant_id=any($1)',relation) into visible using fixture_tenants;
      if visible <> (case when tenant_context in (fixture_tenants[1]::text,fixture_tenants[2]::text) then 1 else 0 end) then
        raise exception 'Prepared source tenant visibility mismatch: % context % count %',relation,tenant_context,visible;
      end if;
      if tenant_context in (fixture_tenants[1]::text,fixture_tenants[2]::text) then
        execute format('select count(*) from %s where tenant_id=any($1) and tenant_id<>util.current_tenant_id()',relation)
          into visible using fixture_tenants;
        if visible<>0 then raise exception 'Foreign tenant rows disclosed: %',relation; end if;
      end if;
    end loop;
  end loop;
  perform set_config('app.tenant_id',fixture_tenants[1]::text,true);
  foreach relation in array array['retrieval.chunking_procedure_version','retrieval.chunk_set','retrieval.retrieval_chunk','retrieval.chunk_span'] loop
    begin
      execute format('insert into %s default values',relation);
      raise exception 'Executor inserted prepared source: %',relation;
    exception when insufficient_privilege then null;
    end;
    begin
      execute format('update %s set tenant_id=tenant_id where false',relation);
      raise exception 'Executor updated prepared source: %',relation;
    exception when insufficient_privilege then null;
    end;
  end loop;
end;
$$;

rollback;
