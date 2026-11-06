begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(1);
set local app.tenant_id='00000000-0000-7000-8000-000000000001';
do $$
declare artifact uuid; doc uuid; version uuid; faithful uuid; projected uuid; node uuid; run uuid; summary uuid;
begin
 insert into orchestration.artifact(artifact_type,sha256,bucket_class,storage_bucket,object_path) values('source_capture',repeat('1',64),'source_captures','test','km-summary-'||util.uuidv7()) returning id into artifact;
 insert into content.document(document_type_code,canonical_title) values('official_docs_page','Summary fixture') returning id into doc;
 insert into content.document_version(document_id,version_label,manifest_sha256) values(doc,'1',repeat('1',64)) returning id into version;
 insert into content.document_representation(document_version_id,artifact_id,representation_kind,representation_class,media_type,content_sha256) values(version,artifact,'plain_text','faithful_normalization','text/plain',repeat('1',64)) returning id into faithful;
 insert into content.document_node(representation_id,ordinal,stable_local_key,node_kind,inline_text,normalized_content_sha256) values(faithful,0,'p1','paragraph','Source text',repeat('1',64)) returning id into node;
 insert into content.transformation_run(transformation_kind,contract_version,parameters_sha256,idempotency_key) values('summarize','1',repeat('1',64),'km-summary-'||util.uuidv7()) returning id into run;
 insert into content.transformation_input(transformation_run_id,ordinal,role,representation_id) values(run,0,'source',faithful);
 insert into content.document_representation(document_version_id,artifact_id,representation_kind,representation_class,media_type,content_sha256,transformation_run_id) values(version,artifact,'summary','semantic_projection','text/plain',repeat('1',64),run) returning id into projected;
 begin
  insert into content.document_summary(document_version_id,representation_id,derived_from_representation_id,transformation_run_id,summary_kind,scope,text,token_count,content_sha256) values(version,projected,faithful,run,'abstract','document','Summary',1,repeat('1',64));
  set constraints all immediate;
  raise exception 'summary without source accepted';
 exception when check_violation then null;end;
 set constraints all deferred;
 insert into content.document_summary(document_version_id,representation_id,derived_from_representation_id,transformation_run_id,summary_kind,scope,text,token_count,content_sha256,coverage_ratio) values(version,projected,faithful,run,'abstract','document','Summary',1,repeat('1',64),1) returning id into summary;
 insert into content.document_summary_source(summary_id,node_id) values(summary,node);
 set constraints all immediate;
 if(select count(*) from api.summary_evidence(summary))<>1 then raise exception 'summary did not resolve to faithful nodes';end if;
 update content.document_summary set lifecycle='superseded' where id=summary;
 if not exists(select 1 from content.document_representation where id=projected) then raise exception 'supersession deleted representation';end if;
end $$;
select pass('knowledge_model_summary invariants hold');
select * from finish();
rollback;
