-- Knowledge model v2: content. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';

-- Retain faithful content and runtime lineage; normalize existing document kinds explicitly.
alter table content.document rename column document_kind to document_type_code;
insert into content.document_type(code,family,description,is_primary_source,default_chunking_slug,default_extraction_kinds,default_spaces) select distinct document_type_code,'vendor','Retained source kind: '||document_type_code,true,'structural_heading',array['claim'],array['source_native_sections'] from content.document on conflict do nothing;
alter table content.document add foreign key(document_type_code) references content.document_type(code),add column work_entity_id uuid references corpus.entity(id),add column repository_file_id uuid references corpus.repository_file(id);
insert into content.transformation_kind select distinct transformation_kind,transformation_kind from content.transformation_run on conflict do nothing;
alter table content.transformation_run add foreign key(transformation_kind) references content.transformation_kind(code),add column converter_identity text,add column converter_version text;
alter table content.document_node add column start_ms integer,add column end_ms integer,add column speaker_entity_id uuid references corpus.entity(id),add check(start_ms is null or start_ms>=0),add check(end_ms is null or(start_ms is not null and end_ms>=start_ms));
create table content.document_about_entity (
  tenant_id uuid not null default util.current_tenant_id(),
  document_id uuid not null references content.document(id), entity_id uuid not null references corpus.entity(id),
  role text not null check (role in ('primary','secondary','mention')),
  method text not null check (method in ('extraction','manual','inherited','provider')), confidence numeric(5,4),
  primary key (tenant_id, document_id, entity_id));
create table content.document_summary (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  document_version_id uuid not null references content.document_version(id),
  representation_id uuid not null references content.document_representation(id),              -- class semantic_projection, kind summary
  derived_from_representation_id uuid not null references content.document_representation(id), -- the faithful text
  transformation_run_id uuid not null references content.transformation_run(id),              -- kind summarize
  summary_kind text not null check (summary_kind in ('abstract','executive','technical','key_claims','timeline','entity_centric','section','chunk_group','faq','investor_brief','learner_brief')),
  scope text not null check (scope in ('document','section','chunk_group','entity_view')),
  scope_node_id uuid references content.document_node(id),
  focus_entity_id uuid references corpus.entity(id),
  audience text not null default 'general' check (audience in ('general','investor','engineer','learner')),
  text text not null, language text, token_count integer not null check (token_count > 0),
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  coverage_ratio numeric(5,4) check (coverage_ratio between 0 and 1),
  lifecycle text not null default 'active' check (lifecycle in ('active','superseded','withdrawn')),
  supersedes_id uuid references content.document_summary(id),
  created_at timestamptz not null default now(),
  check (scope <> 'section' or scope_node_id is not null), check (scope <> 'entity_view' or focus_entity_id is not null),
  unique (tenant_id, id));
create table content.document_summary_source (
  tenant_id uuid not null default util.current_tenant_id(),
  summary_id uuid not null references content.document_summary(id),
  node_id uuid not null references content.document_node(id),
  weight numeric(5,4) not null default 1 check (weight between 0 and 1),
  primary key (tenant_id, summary_id, node_id));
create unique index document_summary_active_uq on content.document_summary(tenant_id,document_version_id,summary_kind,scope,coalesce(scope_node_id,'00000000-0000-0000-0000-000000000000'::uuid),coalesce(focus_entity_id,'00000000-0000-0000-0000-000000000000'::uuid),audience) where lifecycle='active';
create function content.check_summary_lineage() returns trigger language plpgsql set search_path='' as $$
declare s content.document_summary; n bigint;
begin
 if tg_table_name='document_summary' then s:=new; else select * into s from content.document_summary where id=coalesce(new.summary_id,old.summary_id); end if;
 if not exists(select 1 from content.document_summary_source ss join content.document_node dn on dn.id=ss.node_id where ss.summary_id=s.id and ss.tenant_id=s.tenant_id and dn.tenant_id=s.tenant_id and dn.representation_id=s.derived_from_representation_id) then raise exception 'summary requires faithful source nodes' using errcode='23514'; end if;
 if not exists(select 1 from content.document_representation r where r.id=s.representation_id and r.tenant_id=s.tenant_id and r.document_version_id=s.document_version_id and r.representation_class='semantic_projection' and r.representation_kind='summary') then raise exception 'summary representation lineage mismatch'; end if;
 if not exists(select 1 from content.document_representation r where r.id=s.derived_from_representation_id and r.tenant_id=s.tenant_id and r.document_version_id=s.document_version_id and r.representation_class in ('source_native','faithful_normalization','structural_extraction')) then raise exception 'summary source must be faithful'; end if;
 if not exists(select 1 from content.transformation_run t where t.id=s.transformation_run_id and t.tenant_id=s.tenant_id and t.transformation_kind='summarize') then raise exception 'summary requires summarize transformation'; end if;
 return null;
end $$;
create constraint trigger summary_lineage after insert or update on content.document_summary deferrable initially deferred for each row execute function content.check_summary_lineage();
create constraint trigger summary_sources after insert or update or delete on content.document_summary_source deferrable initially deferred for each row execute function content.check_summary_lineage();


alter table content.document_representation add constraint representation_kind_v2 check(representation_kind in ('captured_source','structural_document','source_native','markdown','plain_text','html','pdf','json','transcript','diarized_transcript','visual_description','ocr_text','keyframe_sheet','slide_text','thumbnail','summary','code','table','image'));
insert into content.transformation_kind select x,x from unnest(array['platform_captions','diarize','vision_describe','keyframe_extract','slide_extract']) x on conflict do nothing;
insert into evidence.capture_method select x,x from unnest(array['youtube_captions','apify_actor','yt_dlp','whisper_upload']) x on conflict do nothing;
create function content.guard_summary_content() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'summary history cannot be deleted'; end if;
 if to_jsonb(new)-'lifecycle'<>to_jsonb(old)-'lifecycle' or old.lifecycle<>'active' or new.lifecycle not in ('active','superseded','withdrawn') then raise exception 'summary content is immutable; supersede with a new representation'; end if;
 return new;
end $$;
create trigger summary_content_immutable before update or delete on content.document_summary for each row execute function content.guard_summary_content();
create function content.check_summary_sources() returns trigger language plpgsql set search_path='' as $$
declare s content.document_summary;
begin
 if tg_table_name='document_summary' then s:=new; else select * into strict s from content.document_summary where id=new.summary_id; end if;
 if exists(select 1 from content.document_summary_source ss join content.document_node n on n.id=ss.node_id where ss.summary_id=s.id and(n.representation_id<>s.derived_from_representation_id or n.tenant_id<>s.tenant_id)) then raise exception 'summary source node belongs to another representation'; end if;
 if not exists(select 1 from content.transformation_input i where i.tenant_id=s.tenant_id and i.transformation_run_id=s.transformation_run_id and i.representation_id=s.derived_from_representation_id) then raise exception 'summary transformation does not consume faithful representation'; end if;
 if not exists(select 1 from content.document_representation r where r.id=s.representation_id and r.transformation_run_id=s.transformation_run_id and r.content_sha256=s.content_sha256) then raise exception 'summary hash/transformation mismatch'; end if;
 if s.coverage_ratio is not null and s.coverage_ratio<>(select round(count(*)::numeric/nullif((select count(*) from content.document_node where representation_id=s.derived_from_representation_id),0),4) from content.document_summary_source where summary_id=s.id) then raise exception 'summary coverage ratio mismatch'; end if;
 return null;
end $$;
create constraint trigger summary_sources_integrity after insert or update on content.document_summary deferrable initially deferred for each row execute function content.check_summary_sources();
create constraint trigger summary_node_integrity after insert or update on content.document_summary_source deferrable initially deferred for each row execute function content.check_summary_sources();
create function content.check_document_work() returns trigger language plpgsql set search_path='' as $$
declare expected text; actual text;
begin
 select work_entity_kind into expected from content.document_type where code=new.document_type_code;
 if new.work_entity_id is not null then select kind into strict actual from corpus.entity where id=new.work_entity_id and tenant_id=new.tenant_id; if expected is not null and actual<>expected then raise exception 'document type/work entity mismatch'; end if; end if;
 if new.repository_file_id is not null and not exists(select 1 from corpus.repository_file where id=new.repository_file_id and tenant_id=new.tenant_id) then raise exception 'repository file tenant mismatch'; end if;
 return new;
end $$;
create trigger document_work_integrity before insert or update on content.document for each row execute function content.check_document_work();

commit;
