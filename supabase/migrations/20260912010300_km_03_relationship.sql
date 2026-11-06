-- Knowledge model v2: relationship. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';
create table corpus.relationship (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null references taxonomy.relationship_kind(code),
  from_entity_id uuid not null references corpus.entity(id),
  to_entity_id uuid not null references corpus.entity(id),
  qualifier text not null default '',
  episode integer not null default 1 check (episode >= 1),
  properties jsonb not null default '{}'::jsonb,
  primary_claim_id uuid references evidence.claim(id),
  k_from bigint not null, k_to bigint,
  created_at timestamptz not null default now(),
  check (from_entity_id <> to_entity_id), check (k_to is null or k_to > k_from)
);
create table corpus.media_appearance (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  media_work_id uuid not null references corpus.media_work(id),
  entity_id uuid not null references corpus.entity(id),
  role text not null check (role in ('speaker','host','guest','interviewee','panelist','subject','demonstrated','depicted','logo','screen_recording','mentioned','sponsor')),
  start_ms integer, end_ms integer,
  locator_id uuid references evidence.locator(id),
  method text not null check (method in ('platform_metadata','speaker_diarization','asr_ner','vision_model','ocr','manual','claim')),
  confidence numeric(5,4) check (confidence between 0 and 1),
  primary_claim_id uuid references evidence.claim(id),
  created_at timestamptz not null default now(),
  check (end_ms is null or (start_ms is not null and end_ms >= start_ms))
);
create unique index relationship_current_uq on corpus.relationship(tenant_id,kind,from_entity_id,to_entity_id,qualifier,episode) where k_to is null;
create index relationship_from_idx on corpus.relationship(tenant_id,from_entity_id,kind) where k_to is null;
create index relationship_to_idx on corpus.relationship(tenant_id,to_entity_id,kind) where k_to is null;
create function corpus.check_relationship_kinds() returns trigger language plpgsql set search_path='' as $$
declare f text; t text; r taxonomy.relationship_kind;
begin
 select kind into strict f from corpus.entity where tenant_id=new.tenant_id and id=new.from_entity_id;
 select kind into strict t from corpus.entity where tenant_id=new.tenant_id and id=new.to_entity_id;
 select * into strict r from taxonomy.relationship_kind where code=new.kind;
 if not(f=any(r.from_kinds)) or not(t=any(r.to_kinds)) then raise exception 'invalid relationship endpoint kinds' using errcode='23514'; end if;
 if new.kind='version_of' and (f,t) not in (('product_version','product'),('ai_model_version','ai_model'),('library_release','library'),('ai_protocol_version','ai_protocol')) then raise exception 'invalid version pair' using errcode='23514'; end if;
 return new;
end $$;
create trigger relationship_kinds before insert or update on corpus.relationship for each row execute function corpus.check_relationship_kinds();

create function corpus.check_relationship_properties() returns trigger language plpgsql set search_path='' as $$
begin
 if not temporal.payload_valid(new.properties,(select property_schema from taxonomy.relationship_kind where code=new.kind)) then raise exception 'relationship properties violate JSON schema';end if;return new;
end $$;
-- The trigger is attached after the temporal validator is installed in km_04.

commit;
