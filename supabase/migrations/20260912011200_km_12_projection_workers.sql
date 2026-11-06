-- Knowledge model v2: projection_workers. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';

create function temporal.emit_outbox(p_topic text,p_k bigint,p_payload jsonb) returns uuid language plpgsql security definer set search_path='' as $$
declare op uuid; ev uuid; result uuid; t uuid:=util.current_tenant_id(); key text:='km:'||p_topic||':'||p_k; digest text:=encode(extensions.digest(p_payload::text,'sha256'),'hex');
begin
 insert into knowledge_service.operation(tenant_id,operation_kind,idempotency_key,ownership_mode,correlation_id,actor_identity,request,request_sha256,status,completed_at) values(t,'knowledge_projection',key,'standalone',util.uuidv7(),'knowledge-model-v2',p_payload,digest,'succeeded',now()) on conflict(tenant_id,idempotency_key) do nothing returning id into op;
 if op is null then select id into op from knowledge_service.operation where tenant_id=t and idempotency_key=key; select id into result from knowledge_service.outbox where tenant_id=t and operation_id=op and topic=p_topic; return result; end if;
 insert into knowledge_service.operation_event(tenant_id,operation_id,event_kind,actor_identity,correlation_id,payload) values(t,op,p_topic,'knowledge-model-v2',op,p_payload) returning id into ev;
 insert into knowledge_service.outbox(tenant_id,operation_id,event_id,topic,payload,payload_sha256) values(t,op,ev,p_topic,p_payload,digest) returning id into result;
 return result;
end $$;
create function corpus.rebuild_entity_projections(p_k bigint default null) returns bigint language plpgsql security definer set search_path='' as $$
declare k bigint; n bigint;
begin
 select coalesce(p_k,knowledge_seq) into k from temporal.knowledge_head where tenant_id=util.current_tenant_id();
 if k is null then return 0; end if;
 if k<>(select knowledge_seq from temporal.knowledge_head where tenant_id=util.current_tenant_id()) then raise exception 'projection rebuild requires current sealed head'; end if;
 update corpus.entity e set display_name=coalesce((select f.payload->>'display_name' from api.entity_at(e.id,now(),k) f where f.stream_kind='entity_name' limit 1),e.display_name),summary=coalesce((select s.text from content.document d join content.document_version v on v.document_id=d.id join content.document_summary s on s.document_version_id=v.id where d.work_entity_id=e.id and d.document_type_code='entity_profile' and s.summary_kind='abstract' and s.lifecycle='active' order by s.created_at desc limit 1),e.summary),projection_knowledge_seq=k,updated_at=clock_timestamp() where e.tenant_id=util.current_tenant_id();
 get diagnostics n=row_count;
 perform temporal.emit_outbox('projection.rebuilt',k,jsonb_build_object('knowledge_seq',k,'entities',n));
 return n;
end $$;
create function evidence.rebuild_source_state() returns bigint language plpgsql security definer set search_path='' as $$
declare n bigint;
begin
 update evidence.source s set first_seen_at=x.first_seen,last_seen_at=x.last_seen,capture_count=x.captures,last_encounter_kind=x.last_kind,last_capture_id=x.last_capture,failure_streak=x.failures,state_knowledge_seq=(select knowledge_seq from temporal.knowledge_head where tenant_id=s.tenant_id)
 from(select source_id,min(encountered_at) first_seen,max(encountered_at) last_seen,count(*) filter(where encounter_kind='captured') captures,(array_agg(encounter_kind order by encountered_at desc,id desc))[1] last_kind,(array_agg(capture_id order by encountered_at desc,id desc) filter(where capture_id is not null))[1] last_capture,
 (select count(*)::integer from evidence.source_encounter f where f.source_id=e.source_id and f.encounter_kind in ('failed','blocked') and f.encountered_at>coalesce((select max(z.encountered_at) from evidence.source_encounter z where z.source_id=e.source_id and z.encounter_kind in ('captured','unchanged')),'-infinity')) failures
 from evidence.source_encounter e where tenant_id=util.current_tenant_id() group by source_id)x where s.id=x.source_id and s.tenant_id=util.current_tenant_id();
 get diagnostics n=row_count;return n;
end $$;
create function retrieval.project_entity_timeline(p_k bigint default null) returns bigint language plpgsql security definer set search_path='' as $$
declare k bigint; p uuid; e record; target uuid; body text; n bigint:=0;
begin
 select coalesce(p_k,knowledge_seq) into k from temporal.knowledge_head where tenant_id=util.current_tenant_id(); if k is null then return 0; end if;
 insert into retrieval.projection_procedure(slug,version,description) values('entity_timeline_v2',1,'Sealed temporal graph sentences with explicit knowledge sequence') on conflict(slug,version) do nothing;
 select id into strict p from retrieval.projection_procedure where slug='entity_timeline_v2' and version=1;
 for e in select id,display_name from corpus.entity where tenant_id=util.current_tenant_id() loop
  select string_agg(e.display_name||': '||coalesce(x.details->>'kind',x.item_kind)||' '||x.world_interval::text||' '||x.details::text,E'\n' order by lower(x.world_interval),x.item_id) into body from api.entity_timeline(e.id,'0001-01-01'::timestamptz,'9999-12-31'::timestamptz,k)x where x.item_kind<>'unknown';
  if body is null then continue; end if;
  insert into retrieval.projection_target(target_kind,entity_id) values('entity',e.id) on conflict do nothing;
  select id into strict target from retrieval.projection_target where tenant_id=util.current_tenant_id() and target_kind='entity' and entity_id=e.id;
  insert into retrieval.search_projection(projection_target_id,projection_procedure_id,purpose,source_text,embedding_text,source_text_sha256,contextual_prefix_sha256,embedding_text_sha256,support_manifest,content_kind,visibility,classification,generator_identity)
  values(target,p,'entity_timeline',body,body,encode(extensions.digest(body,'sha256'),'hex'),encode(extensions.digest('','sha256'),'hex'),encode(extensions.digest(body,'sha256'),'hex'),jsonb_build_array(jsonb_build_object('entity_id',e.id,'knowledge_seq',k)),'timeline','internal','public','knowledge-model-v2') on conflict do nothing;
  n:=n+1;
 end loop;return n;
end $$;
create function corpus.import_research_starter_catalog(p_receipt uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare c record; v record; channel uuid; work uuid; series uuid; document_id uuid; source_id uuid; n integer:=0; k bigint; t uuid:=util.current_tenant_id();
begin
 if not exists(select 1 from orchestration.operation_receipt r join orchestration.operation_intent i on i.id=r.intent_id where r.id=p_receipt and i.tenant_id=t) then raise exception 'receipt tenant mismatch'; end if;
 k:=temporal.begin_batch();
 for c in select * from public.research_starter_channels order by channel_id loop
  insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('media_channel',c.title,'youtube-'||c.channel_id,p_receipt) on conflict(tenant_id,kind,slug) do nothing;
  select id into strict channel from corpus.entity where tenant_id=t and kind='media_channel' and slug='youtube-'||c.channel_id;
  insert into corpus.media_channel(id,platform_code,external_id,handle,title,url) values(channel,'youtube',c.channel_id,c.handle,c.title,c.channel_url) on conflict(id) do nothing;
  insert into corpus.entity_identifier(entity_id,scheme,value) values(channel,'youtube_channel',c.channel_id) on conflict do nothing;
  if c.uploads_playlist_id is not null then
   insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('media_series',c.title||' uploads','youtube-'||c.uploads_playlist_id,p_receipt) on conflict(tenant_id,kind,slug) do nothing;
   select id into strict series from corpus.entity where tenant_id=t and kind='media_series' and slug='youtube-'||c.uploads_playlist_id;
   insert into corpus.media_series(id,series_kind,platform_code,external_id,title,primary_channel_id) values(series,'playlist','youtube',c.uploads_playlist_id,c.title||' uploads',channel) on conflict(id) do nothing;
   perform temporal.assert_relationship('series_on_channel',series,channel);
  end if;
  for v in select * from public.research_starter_videos where channel_id=c.channel_id order by video_id loop
   insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('media_work',v.title,'youtube-'||v.video_id,p_receipt) on conflict(tenant_id,kind,slug) do nothing;
   select id into strict work from corpus.entity where tenant_id=t and kind='media_work' and slug='youtube-'||v.video_id;
   insert into corpus.media_work(id,media_kind,platform_code,external_id,url,title,channel_id,published_at,duration_ms,language) values(work,'video','youtube',v.video_id,v.url,v.title,channel,v.published_at,v.duration_seconds*1000,v.transcript_language) on conflict(id) do nothing;
   insert into corpus.entity_identifier(entity_id,scheme,value) values(work,'youtube_video',v.video_id) on conflict do nothing;
   perform temporal.assert_relationship('published_on',work,channel);
   if c.uploads_playlist_id is not null then perform temporal.assert_relationship('in_series',work,series); end if;
   if v.transcript_text is not null then
    insert into evidence.source(source_class,canonical_url,publisher,logical_identity,source_kind) values('transcript',v.url,c.title,'youtube:'||v.video_id||':transcript','video_transcript') on conflict(tenant_id,source_class,logical_identity) do nothing;
    select id into strict source_id from evidence.source where tenant_id=t and source_class='transcript' and logical_identity='youtube:'||v.video_id||':transcript';
    if not exists(select 1 from content.document d where d.tenant_id=t and d.work_entity_id=work and d.document_type_code='video_transcript') then
     insert into content.document(document_type_code,canonical_title,canonical_source_id,work_entity_id) values('video_transcript',v.title,source_id,work) returning id into document_id;
     insert into content.document_identifier(document_id,identifier_type,normalized_value,authority) values(document_id,'media_id','youtube:'||v.video_id||':transcript','youtube');
    end if;
   end if;
   n:=n+1;
  end loop;
 end loop;
 perform temporal.commit_batch(p_receipt,'research-starter-catalog:'||k,encode(extensions.digest(n::text,'sha256'),'hex'),jsonb_build_object('videos',n));
 return jsonb_build_object('videos',n,'knowledge_seq',k,'transcript_capture','existing storage remains authoritative; capture requires verified artifact bytes');
end $$;
revoke all on function temporal.emit_outbox(text,bigint,jsonb),corpus.rebuild_entity_projections(bigint),evidence.rebuild_source_state(),retrieval.project_entity_timeline(bigint),corpus.import_research_starter_catalog(uuid) from public,anon,authenticated,service_role,pipeline_agent,verifier_agent,app_reader;
grant execute on function corpus.rebuild_entity_projections(bigint),evidence.rebuild_source_state(),retrieval.project_entity_timeline(bigint),corpus.import_research_starter_catalog(uuid) to executor_service;

create or replace function temporal.commit_batch(p_receipt uuid,p_idempotency_key text,p_input_digest text,p_summary jsonb default '{}') returns bigint language plpgsql security definer set search_path='' as $$
declare k bigint:=temporal.current_k(); t uuid:=util.current_tenant_id();
begin
 if k is null then raise exception 'no open knowledge batch'; end if;
 if not exists(select 1 from orchestration.operation_receipt r join orchestration.operation_intent i on i.id=r.intent_id where r.id=p_receipt and i.tenant_id=t) then raise exception 'receipt tenant mismatch'; end if;
 if exists(select 1 from temporal.segment s join temporal.stream st on st.id=s.stream_id join temporal.stream_kind sk on sk.code=st.kind where s.tenant_id=t and s.k_from=k and (
 (sk.status_values is not null and (s.status is null or not(s.status=any(sk.status_values)))) or
 (sk.requires_amount and (s.amount is null or s.unit is null)) or
 (sk.code in ('model_offering_price','compute_offering_price','valuation') and (s.currency is null or s.currency !~ '^[A-Z]{3}$')) or
 (sk.unit_values is not null and (s.unit is null or not(s.unit=any(sk.unit_values)))) or
 (sk.requires_ref_entity and s.ref_entity_id is null) or
 (sk.code='model_version_spec' and s.specification_id is null) or
 not temporal.payload_valid(s.payload,sk.payload_schema))) then raise exception 'stream slot/payload rules violated' using errcode='23514'; end if;
 insert into temporal.knowledge_batch(tenant_id,knowledge_seq,receipt_id,idempotency_key,input_digest,summary) values(t,k,p_receipt,p_idempotency_key,p_input_digest,p_summary);
 update temporal.knowledge_head set knowledge_seq=k,open_xid=null,open_k=null,updated_at=clock_timestamp() where tenant_id=t;
 perform temporal.emit_outbox('knowledge.batch_sealed',k,jsonb_build_object('knowledge_seq',k,'receipt_id',p_receipt,'summary',p_summary));
 return k;
end $$;

commit;
