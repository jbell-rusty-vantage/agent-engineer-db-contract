-- Knowledge model v2: temporal. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';
create table temporal.knowledge_head (
  tenant_id uuid primary key default util.current_tenant_id(),
  knowledge_seq bigint not null default 0, updated_at timestamptz not null default now());
create table temporal.knowledge_batch (
  tenant_id uuid not null default util.current_tenant_id(), knowledge_seq bigint not null,
  recorded_at timestamptz not null default now(),
  receipt_id uuid not null references orchestration.operation_receipt(id),
  operation_id uuid references knowledge_service.operation(id),
  idempotency_key text not null, input_digest text not null check (input_digest ~ '^[0-9a-f]{64}$'),
  summary jsonb not null default '{}'::jsonb,
  primary key (tenant_id, knowledge_seq), unique (tenant_id, idempotency_key));
create table temporal.extent (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  source_text text, precision text not null check (precision in ('instant','day','month','quarter','year','relative','unknown')),
  earliest timestamptz, latest timestamptz, timezone text,
  locator_id uuid references evidence.locator(id),
  check (earliest is null or latest is null or latest >= earliest));
create table temporal.stream (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null references temporal.stream_kind(code),
  subject_entity_id uuid references corpus.entity(id),
  subject_relationship_id uuid references corpus.relationship(id),
  scope_key text not null default '',
  created_at timestamptz not null default now(),
  check (num_nonnulls(subject_entity_id, subject_relationship_id) = 1),
  unique nulls not distinct (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key));
create table temporal.event (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null references temporal.event_kind(code),
  subject_entity_id uuid not null references corpus.entity(id),
  object_entity_id uuid references corpus.entity(id),
  relationship_id uuid references corpus.relationship(id),
  dedupe_key text, created_at timestamptz not null default now(),
  unique nulls not distinct (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key));
create table temporal.event_occurrence (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  event_id uuid not null references temporal.event(id),
  occurred_during tstzrange not null check (not isempty(occurred_during)),
  occurrence_mode text not null check (occurrence_mode in ('actual','scheduled','cancelled')),
  belief text not null default 'accepted' check (belief in ('accepted','disputed','unknown')),
  extent_id uuid references temporal.extent(id), primary_claim_id uuid references evidence.claim(id),
  payload jsonb not null default '{}'::jsonb,
  k_from bigint not null, k_to bigint, created_at timestamptz not null default now(),
  check (k_to is null or k_to > k_from));
create table temporal.segment (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  stream_id uuid not null references temporal.stream(id),
  valid_during tstzrange not null check (not isempty(valid_during) and lower_inc(valid_during) and not upper_inc(valid_during) and not lower_inf(valid_during)),
  belief text not null default 'accepted' check (belief in ('accepted','disputed','unknown')),
  temporal_basis text not null check (temporal_basis in ('explicit','carry_forward','observation_bounded','unresolved')),
  status text, amount numeric(20,6), currency char(3), unit text,
  ref_entity_id uuid references corpus.entity(id),
  payload jsonb not null default '{}'::jsonb,
  extent_id uuid references temporal.extent(id),
  caused_by_event_id uuid references temporal.event(id),
  replaces_segment_id uuid references temporal.segment(id),
  primary_claim_id uuid references evidence.claim(id),
  k_from bigint not null, k_to bigint, created_at timestamptz not null default now(),
  check (k_to is null or k_to > k_from), check (replaces_segment_id is null or replaces_segment_id <> id),
  check (temporal_basis in ('observation_bounded','unresolved') or extent_id is not null),
  exclude using gist (stream_id with =, valid_during with &&) where (k_to is null)
);
alter table temporal.knowledge_head add column open_xid xid8, add column open_k bigint;
alter table temporal.segment add column specification_id uuid references corpus.ai_model_version_spec(id);
alter table temporal.event_occurrence add check(lower_inc(occurred_during) and not upper_inc(occurred_during) and not lower_inf(occurred_during));
create unique index event_occurrence_current_uq on temporal.event_occurrence(event_id) where k_to is null;
create index segment_stream_current_idx on temporal.segment(stream_id) where k_to is null;
create index segment_valid_gist on temporal.segment using gist(valid_during) where k_to is null;
create function temporal.current_k() returns bigint language sql stable security definer set search_path='' as $$
 select open_k from temporal.knowledge_head where tenant_id=util.current_tenant_id() and open_xid=pg_current_xact_id_if_assigned()
$$;
create function temporal.stamp_k() returns trigger language plpgsql set search_path='' as $$
begin
 if temporal.current_k() is null or new.tenant_id<>util.current_tenant_id() then raise exception 'no open tenant knowledge batch' using errcode='25000'; end if;
 new.k_from:=temporal.current_k(); new.k_to:=null; return new;
end $$;
create function temporal.guard_k() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'history cannot be deleted' using errcode='23001'; end if;
 if temporal.current_k() is null or old.tenant_id<>util.current_tenant_id() or old.k_to is not null or new.k_to is distinct from temporal.current_k() or to_jsonb(new)-'k_to'<>to_jsonb(old)-'k_to' then raise exception 'only closure in an open tenant batch is allowed' using errcode='23001'; end if;
 return new;
end $$;
create function temporal.require_sealed_batch() returns trigger language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from temporal.knowledge_batch where tenant_id=new.tenant_id and knowledge_seq=new.k_from) or (new.k_to is not null and not exists(select 1 from temporal.knowledge_batch where tenant_id=new.tenant_id and knowledge_seq=new.k_to)) then raise exception 'unsealed knowledge batch' using errcode='23514'; end if;
 return null;
end $$;
do $$ declare t text; begin
 foreach t in array array['temporal.segment','temporal.event_occurrence','corpus.relationship'] loop
 execute format('create trigger stamp_k before insert on %s for each row execute function temporal.stamp_k()',t);
 execute format('create trigger guard_k before update or delete on %s for each row execute function temporal.guard_k()',t);
 execute format('create constraint trigger sealed_batch after insert or update on %s deferrable initially deferred for each row execute function temporal.require_sealed_batch()',t);
 end loop;
end $$;
create function temporal.begin_batch(p_expected_head bigint default null) returns bigint language plpgsql security definer set search_path='' as $$
declare h temporal.knowledge_head; t uuid:=util.current_tenant_id();
begin
 insert into temporal.knowledge_head(tenant_id) values(t) on conflict do nothing;
 select * into strict h from temporal.knowledge_head where tenant_id=t for update;
 if h.open_xid is not null then raise exception 'knowledge batch already open'; end if;
 if p_expected_head is not null and p_expected_head<>h.knowledge_seq then raise exception 'rebase_required' using errcode='40001'; end if;
 update temporal.knowledge_head set open_xid=pg_current_xact_id(),open_k=knowledge_seq+1 where tenant_id=t;
 return h.knowledge_seq+1;
end $$;
create function temporal.make_extent(p_source_text text,p_precision text,p_locator uuid default null,p_earliest timestamptz default null,p_latest timestamptz default null,p_timezone text default null) returns uuid language plpgsql security definer set search_path='' as $$
declare result uuid;
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 if p_locator is not null and not exists(select 1 from evidence.locator where tenant_id=util.current_tenant_id() and id=p_locator) then raise exception 'locator tenant mismatch'; end if;
 insert into temporal.extent(source_text,precision,locator_id,earliest,latest,timezone) values(p_source_text,p_precision,p_locator,p_earliest,p_latest,p_timezone) returning id into result;
 return result;
end $$;
create function temporal.close_segment(p_segment uuid) returns void language plpgsql security definer set search_path='' as $$
begin
 update temporal.segment set k_to=temporal.current_k() where id=p_segment and tenant_id=util.current_tenant_id() and k_to is null;
 if not found then raise exception 'current segment not found'; end if;
end $$;
create function temporal.assert_state(p_entity uuid,p_stream_kind text,p_valid_during tstzrange,p_scope_key text default '',p_status text default null,p_amount numeric default null,p_currency text default null,p_unit text default null,p_ref_entity uuid default null,p_payload jsonb default '{}',p_extent uuid default null,p_claim uuid default null,p_temporal_basis text default 'explicit',p_relationship uuid default null,p_belief text default 'accepted',p_specification uuid default null) returns uuid language plpgsql security definer set search_path='' as $$
declare st uuid; result uuid; old temporal.segment; piece tstzrange; sk temporal.stream_kind; subject text; t uuid:=util.current_tenant_id();
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 select * into strict sk from temporal.stream_kind where code=p_stream_kind;
 if sk.subject_mode='entity' then
  if p_relationship is not null then raise exception 'entity stream cannot target relationship'; end if;
  select kind into strict subject from corpus.entity where id=p_entity and tenant_id=t;
  if not(subject=any(sk.subject_kinds)) then raise exception 'stream does not admit entity kind' using errcode='23514'; end if;
 else
  if p_entity is not null then raise exception 'relationship stream cannot target entity'; end if;
  select r.kind into strict subject from corpus.relationship r join taxonomy.relationship_kind k on k.code=r.kind where r.id=p_relationship and r.tenant_id=t and r.k_to is null and k.temporal;
  if sk.code<>'relationship_active' and not(subject=any(sk.subject_kinds)) then raise exception 'stream does not admit relationship kind' using errcode='23514'; end if;
 end if;
 insert into temporal.stream(kind,subject_entity_id,subject_relationship_id,scope_key) values(p_stream_kind,p_entity,p_relationship,p_scope_key) on conflict do nothing;
 select id into strict st from temporal.stream where tenant_id=t and kind=p_stream_kind and subject_entity_id is not distinct from p_entity and subject_relationship_id is not distinct from p_relationship and scope_key=p_scope_key;
 if exists(select 1 from temporal.segment where stream_id=st and k_to is null and valid_during=p_valid_during and status is not distinct from p_status and amount is not distinct from p_amount and currency is not distinct from p_currency and unit is not distinct from p_unit and ref_entity_id is not distinct from p_ref_entity and payload=p_payload and extent_id is not distinct from p_extent and primary_claim_id is not distinct from p_claim and belief=p_belief and temporal_basis=p_temporal_basis and specification_id is not distinct from p_specification) then
  select id into result from temporal.segment where stream_id=st and k_to is null and valid_during=p_valid_during; return result;
 end if;
 for old in select * from temporal.segment where stream_id=st and k_to is null and valid_during && p_valid_during for update loop
  if old.k_from=temporal.current_k() then raise exception 'overlapping assertions in one batch; consolidate before admission'; end if;
  perform temporal.close_segment(old.id);
  for piece in select unnest(tstzmultirange(old.valid_during)-tstzmultirange(p_valid_during)) loop
   insert into temporal.segment(stream_id,valid_during,belief,temporal_basis,status,amount,currency,unit,ref_entity_id,payload,extent_id,caused_by_event_id,replaces_segment_id,primary_claim_id,specification_id)
   values(st,piece,old.belief,old.temporal_basis,old.status,old.amount,old.currency,old.unit,old.ref_entity_id,old.payload,old.extent_id,old.caused_by_event_id,old.id,old.primary_claim_id,old.specification_id);
  end loop;
 end loop;
 insert into temporal.segment(stream_id,valid_during,belief,temporal_basis,status,amount,currency,unit,ref_entity_id,payload,extent_id,replaces_segment_id,primary_claim_id,specification_id)
 values(st,p_valid_during,p_belief,p_temporal_basis,p_status,p_amount,p_currency,p_unit,p_ref_entity,p_payload,p_extent,old.id,p_claim,p_specification) returning id into result;
 return result;
end $$;
create function temporal.assert_relationship(p_kind text,p_from uuid,p_to uuid,p_valid_during tstzrange default null,p_qualifier text default '',p_episode integer default 1,p_properties jsonb default '{}',p_extent uuid default null,p_claim uuid default null) returns uuid language plpgsql security definer set search_path='' as $$
declare result uuid; is_temporal boolean;
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 select temporal into strict is_temporal from taxonomy.relationship_kind where code=p_kind;
 select id into result from corpus.relationship where tenant_id=util.current_tenant_id() and kind=p_kind and from_entity_id=p_from and to_entity_id=p_to and qualifier=p_qualifier and episode=p_episode and k_to is null;
 if result is null then
  insert into corpus.relationship(kind,from_entity_id,to_entity_id,qualifier,episode,properties,primary_claim_id) values(p_kind,p_from,p_to,p_qualifier,p_episode,p_properties,p_claim) returning id into result;
 elsif not exists(select 1 from corpus.relationship where id=result and properties=p_properties) then raise exception 'relationship identity exists with different properties; create a correction';
 end if;
 if is_temporal then
  if p_valid_during is null then raise exception 'temporal relationship requires world interval'; end if;
  perform temporal.assert_state(null,'relationship_active',p_valid_during,p_status=>'active',p_extent=>p_extent,p_claim=>p_claim,p_relationship=>result);
 elsif p_valid_during is not null then raise exception 'non-temporal relationship rejects a temporal interval';
 end if;
 return result;
end $$;
create function temporal.assert_event(p_kind text,p_subject uuid,p_occurred_during tstzrange,p_mode text default 'actual',p_object uuid default null,p_relationship uuid default null,p_dedupe_key text default null,p_extent uuid default null,p_claim uuid default null,p_payload jsonb default '{}',p_belief text default 'accepted') returns uuid language plpgsql security definer set search_path='' as $$
declare e uuid; result uuid; subject text; ek temporal.event_kind; t uuid:=util.current_tenant_id();
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 select * into strict ek from temporal.event_kind where code=p_kind;
 select kind into strict subject from corpus.entity where id=p_subject and tenant_id=t;
 if not(subject=any(ek.subject_kinds)) then raise exception 'event subject kind mismatch' using errcode='23514'; end if;
 if p_object is not null and not exists(select 1 from corpus.entity where id=p_object and tenant_id=t and kind=any(ek.object_kinds)) then raise exception 'event object kind mismatch'; end if;
 insert into temporal.event(kind,subject_entity_id,object_entity_id,relationship_id,dedupe_key) values(p_kind,p_subject,p_object,p_relationship,p_dedupe_key) on conflict do nothing;
 select id into strict e from temporal.event where tenant_id=t and kind=p_kind and subject_entity_id=p_subject and object_entity_id is not distinct from p_object and relationship_id is not distinct from p_relationship and dedupe_key is not distinct from p_dedupe_key;
 select id into result from temporal.event_occurrence where event_id=e and k_to is null and occurred_during=p_occurred_during and occurrence_mode=p_mode and payload=p_payload and belief=p_belief and extent_id is not distinct from p_extent and primary_claim_id is not distinct from p_claim;
 if result is not null then return result; end if;
 update temporal.event_occurrence set k_to=temporal.current_k() where event_id=e and k_to is null;
 insert into temporal.event_occurrence(event_id,occurred_during,occurrence_mode,extent_id,primary_claim_id,payload,belief) values(e,p_occurred_during,p_mode,p_extent,p_claim,p_payload,p_belief) returning id into result;
 return result;
end $$;
create function temporal.payload_valid(p_value jsonb,p_schema jsonb) returns boolean language plpgsql immutable set search_path='' as $$
declare prop record; required text;
begin
 if jsonb_typeof(p_value)<>'object' then return false; end if;
 for required in select jsonb_array_elements_text(coalesce(p_schema->'required','[]')) loop if not(p_value?required) or p_value->required='null'::jsonb then return false; end if; end loop;
 for prop in select * from jsonb_each(coalesce(p_schema->'properties','{}')) loop if p_value?prop.key and prop.value?'type' and jsonb_typeof(p_value->prop.key)<>prop.value->>'type' then return false; end if; end loop;
 return true;
end $$;
create function temporal.commit_batch(p_receipt uuid,p_idempotency_key text,p_input_digest text,p_summary jsonb default '{}') returns bigint language plpgsql security definer set search_path='' as $$
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
 return k;
end $$;


create extension if not exists pg_jsonschema with schema extensions;
create or replace function temporal.payload_valid(p_value jsonb,p_schema jsonb) returns boolean language sql immutable set search_path='' as $$select jsonb_typeof(p_value)='object' and extensions.jsonb_matches_schema(p_schema::json,p_value)$$;
create function temporal.require_closed_head() returns trigger language plpgsql set search_path='' as $$
begin
 if exists(select 1 from temporal.knowledge_head where tenant_id=new.tenant_id and open_xid is not null) then raise exception 'knowledge batch must be sealed before commit' using errcode='23514';end if;return null;
end $$;
create constraint trigger closed_head after insert or update on temporal.knowledge_head deferrable initially deferred for each row execute function temporal.require_closed_head();

create trigger relationship_properties before insert or update on corpus.relationship for each row execute function corpus.check_relationship_properties();
commit;
