begin;
set local lock_timeout='15s';

alter table orchestration.artifact add column custody_registered_at timestamptz not null default clock_timestamp();
create function orchestration.guard_artifact_registration_clock() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='INSERT' then new.custody_registered_at:=clock_timestamp();
 elsif new.custody_registered_at is distinct from old.custody_registered_at then
  raise exception 'artifact custody registration clock is immutable' using errcode='23001';
 end if;
 return new;
end $$;
create trigger artifact_registration_clock before insert or update on orchestration.artifact for each row execute function orchestration.guard_artifact_registration_clock();

create table knowledge_service.checkpoint_scope (
 tenant_id uuid not null,
 id uuid not null,
 scope jsonb not null check(jsonb_typeof(scope)='object'),
 parent_scope_id uuid,
 head_checkpoint_id uuid,
 revision bigint not null default 0 check(revision>=0),
 created_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,id),
 foreign key(tenant_id,parent_scope_id) references knowledge_service.checkpoint_scope(tenant_id,id),
 check((head_checkpoint_id is null)=(revision=0)),
 check(scope ?& array['tenantId','runId','producerAttemptId','sessionId','sandboxId','namespace']),
 check(scope->>'tenantId' is not distinct from tenant_id::text),
 check(scope->>'parentScopeId' is not distinct from parent_scope_id::text)
);
create table knowledge_service.scoped_checkpoint (
 tenant_id uuid not null,
 id uuid not null,
 scope_id uuid not null,
 parent_checkpoint_id uuid,
 revision bigint not null check(revision>0),
 idempotency_key text not null check(length(btrim(idempotency_key)) between 1 and 256),
 request_digest text not null check(request_digest ~ '^sha256:[0-9a-f]{64}$'),
 manifest_artifact_id uuid not null,
 manifest_handle jsonb not null check(jsonb_typeof(manifest_handle)='object'),
 mode text not null check(mode in('archive','continuation')),
 committed_at timestamptz not null default date_trunc('milliseconds',clock_timestamp()),
 primary key(tenant_id,id),
 unique(tenant_id,scope_id,id),
 unique(tenant_id,scope_id,revision),
 unique(tenant_id,scope_id,idempotency_key),
 foreign key(tenant_id,scope_id) references knowledge_service.checkpoint_scope(tenant_id,id),
 foreign key(tenant_id,scope_id,parent_checkpoint_id) references knowledge_service.scoped_checkpoint(tenant_id,scope_id,id),
 foreign key(tenant_id,manifest_artifact_id) references orchestration.artifact(tenant_id,id),
 check(manifest_handle->>'artifactId' is not distinct from manifest_artifact_id::text),
 check(manifest_handle->>'tenantId' is not distinct from tenant_id::text)
);
alter table knowledge_service.checkpoint_scope add constraint checkpoint_scope_head_fk
 foreign key(tenant_id,id,head_checkpoint_id) references knowledge_service.scoped_checkpoint(tenant_id,scope_id,id) deferrable initially deferred;
create table knowledge_service.checkpoint_artifact_reference (
 tenant_id uuid not null,
 checkpoint_id uuid not null,
 artifact_id uuid not null,
 primary key(tenant_id,checkpoint_id,artifact_id),
 foreign key(tenant_id,checkpoint_id) references knowledge_service.scoped_checkpoint(tenant_id,id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id)
);
create table orchestration.artifact_tombstone (
 tenant_id uuid not null,
 artifact_id uuid not null,
 reason text not null check(length(btrim(reason)) between 1 and 2000),
 retired_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,artifact_id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id)
);

create function knowledge_service.guard_checkpoint_scope() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'checkpoint scopes are retained' using errcode='23001'; end if;
 if new.tenant_id is distinct from old.tenant_id or new.id is distinct from old.id or new.scope is distinct from old.scope or new.parent_scope_id is distinct from old.parent_scope_id or new.created_at is distinct from old.created_at then
  raise exception 'checkpoint scope identity is immutable' using errcode='23001';
 end if;
 if new.revision<>old.revision+1 or not exists(select 1 from knowledge_service.scoped_checkpoint c where c.tenant_id=new.tenant_id and c.scope_id=new.id and c.id=new.head_checkpoint_id and c.revision=new.revision and c.parent_checkpoint_id is not distinct from old.head_checkpoint_id) then
  raise exception 'checkpoint head requires the next committed revision' using errcode='23514';
 end if;
 return new;
end $$;
create trigger checkpoint_scope_guard before update or delete on knowledge_service.checkpoint_scope for each row execute function knowledge_service.guard_checkpoint_scope();
create trigger scoped_checkpoint_immutable before update or delete on knowledge_service.scoped_checkpoint for each row execute function util.reject_mutation();
create trigger checkpoint_artifact_reference_immutable before update or delete on knowledge_service.checkpoint_artifact_reference for each row execute function util.reject_mutation();
create trigger artifact_tombstone_immutable before update or delete on orchestration.artifact_tombstone for each row execute function util.reject_mutation();

create function knowledge_service.guard_scoped_checkpoint() returns trigger language plpgsql set search_path='' as $$
declare scope_row knowledge_service.checkpoint_scope;
begin
 select * into scope_row from knowledge_service.checkpoint_scope where tenant_id=new.tenant_id and id=new.scope_id for update;
 if not found or new.parent_checkpoint_id is distinct from scope_row.head_checkpoint_id or new.revision<>scope_row.revision+1 then
  raise exception 'checkpoint parent must match current scope head' using errcode='23514';
 end if;
 return new;
end $$;
create trigger scoped_checkpoint_admission before insert on knowledge_service.scoped_checkpoint for each row execute function knowledge_service.guard_scoped_checkpoint();
create function knowledge_service.require_checkpoint_commit() returns trigger language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from knowledge_service.checkpoint_artifact_reference r where r.tenant_id=new.tenant_id and r.checkpoint_id=new.id and r.artifact_id=new.manifest_artifact_id)
  or not exists(select 1 from knowledge_service.checkpoint_scope s where s.tenant_id=new.tenant_id and s.id=new.scope_id and s.revision>=new.revision) then
  raise exception 'checkpoint requires manifest custody and committed head' using errcode='23514';
 end if;
 return new;
end $$;
create constraint trigger scoped_checkpoint_complete after insert on knowledge_service.scoped_checkpoint
 deferrable initially deferred for each row execute function knowledge_service.require_checkpoint_commit();

create function knowledge_service.guard_checkpoint_reference() returns trigger language plpgsql set search_path='' as $$
begin
 perform 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.artifact_id and a.storage_state='available' for update;
 if not found or exists(select 1 from orchestration.artifact_tombstone t where t.tenant_id=new.tenant_id and t.artifact_id=new.artifact_id) then
  raise exception 'checkpoint requires available live artifact custody' using errcode='23514';
 end if;
 return new;
end $$;
create trigger checkpoint_reference_admission before insert on knowledge_service.checkpoint_artifact_reference for each row execute function knowledge_service.guard_checkpoint_reference();

create function orchestration.guard_artifact_tombstone() returns trigger language plpgsql security definer set search_path='' as $$
declare artifact_row orchestration.artifact; dependency record; referenced boolean;
begin
 select * into artifact_row from orchestration.artifact where tenant_id=new.tenant_id and id=new.artifact_id for update;
 if not found then raise exception 'artifact not found' using errcode='23503'; end if;
 if artifact_row.custody_registered_at>clock_timestamp()-interval '30 days' then raise exception 'artifact minimum retention has not elapsed' using errcode='23514'; end if;
 for dependency in
  select ns.nspname schema_name,cl.relname table_name,
   string_agg(format('r.%I is not distinct from a.%I',local_col.attname,parent_col.attname),' and ' order by cols.ordinality) join_condition
  from pg_catalog.pg_constraint c
  join pg_catalog.pg_class cl on cl.oid=c.conrelid
  join pg_catalog.pg_namespace ns on ns.oid=cl.relnamespace
  cross join lateral unnest(c.conkey,c.confkey) with ordinality cols(local_num,parent_num,ordinality)
  join pg_catalog.pg_attribute local_col on local_col.attrelid=c.conrelid and local_col.attnum=cols.local_num
  join pg_catalog.pg_attribute parent_col on parent_col.attrelid=c.confrelid and parent_col.attnum=cols.parent_num
  where c.contype='f' and c.confrelid='orchestration.artifact'::regclass
   and c.conrelid<>'orchestration.artifact_tombstone'::regclass
   and not(c.conrelid='orchestration.verification_artifact_metadata'::regclass and c.conkey @> array[(select attnum from pg_catalog.pg_attribute where attrelid=c.conrelid and attname='artifact_id')]::smallint[])
  group by c.oid,ns.nspname,cl.relname
 loop
  execute format('select exists(select 1 from %I.%I r join orchestration.artifact a on %s where a.tenant_id=$1 and a.id=$2)',dependency.schema_name,dependency.table_name,dependency.join_condition) into referenced using new.tenant_id,new.artifact_id;
  if referenced then raise exception 'artifact has retained canonical references' using errcode='23514'; end if;
 end loop;
 return new;
end $$;
revoke all on function orchestration.guard_artifact_tombstone() from public;
create trigger artifact_tombstone_admission before insert on orchestration.artifact_tombstone for each row execute function orchestration.guard_artifact_tombstone();

create function orchestration.apply_artifact_tombstone() returns trigger language plpgsql security definer set search_path='' as $$
begin
 update orchestration.artifact set storage_state='failed',available_at=null,registration_error_class='retired' where tenant_id=new.tenant_id and id=new.artifact_id;
 return new;
end $$;
revoke all on function orchestration.apply_artifact_tombstone() from public;
create trigger artifact_tombstone_apply after insert on orchestration.artifact_tombstone for each row execute function orchestration.apply_artifact_tombstone();
create function orchestration.prevent_artifact_resurrection() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if exists(select 1 from orchestration.artifact_tombstone where tenant_id=new.tenant_id and artifact_id=new.id)
  and (new.storage_state<>'failed' or new.registration_error_class is distinct from 'retired' or new.available_at is not null) then
  raise exception 'retired artifact cannot regain custody' using errcode='23514';
 end if;
 return new;
end $$;
revoke all on function orchestration.prevent_artifact_resurrection() from public;
create trigger artifact_no_resurrection before update on orchestration.artifact for each row execute function orchestration.prevent_artifact_resurrection();

-- Serialize new canonical references against retirement without rejecting legitimate pending registrations.
create function orchestration.guard_retired_artifact_reference() returns trigger language plpgsql security definer set search_path='' as $$
declare binding jsonb; conditions text:=''; referenced record; value_json jsonb:=to_jsonb(new);
begin
 for binding in select * from jsonb_array_elements(tg_argv[0]::jsonb) loop
  if value_json->>(binding->>'local') is null then return new; end if;
  conditions:=conditions||case when conditions='' then '' else ' and ' end||format('a.%I::text=$1->>%L',binding->>'parent',binding->>'local');
 end loop;
 if tg_op='UPDATE' and not exists(select 1 from jsonb_array_elements(tg_argv[0]::jsonb) b where to_jsonb(old)->(b->>'local') is distinct from value_json->(b->>'local')) then return new; end if;
 execute 'select a.tenant_id,a.id,a.storage_state,a.registration_error_class from orchestration.artifact a where '||conditions||' for share of a' into referenced using value_json;
 if referenced.id is not null and ((referenced.storage_state='failed' and referenced.registration_error_class='retired')
  or exists(select 1 from orchestration.artifact_tombstone t where t.tenant_id=referenced.tenant_id and t.artifact_id=referenced.id)) then
  raise exception 'canonical reference cannot bind a retired artifact' using errcode='23514';
 end if;
 return new;
end $$;
revoke all on function orchestration.guard_retired_artifact_reference() from public;
do $$
declare dependency record;
begin
 for dependency in
  select ns.nspname schema_name,cl.relname table_name,c.conname,
   jsonb_agg(jsonb_build_object('local',local_col.attname,'parent',parent_col.attname) order by cols.ordinality) bindings
  from pg_catalog.pg_constraint c join pg_catalog.pg_class cl on cl.oid=c.conrelid
  join pg_catalog.pg_namespace ns on ns.oid=cl.relnamespace
  cross join lateral unnest(c.conkey,c.confkey) with ordinality cols(local_num,parent_num,ordinality)
  join pg_catalog.pg_attribute local_col on local_col.attrelid=c.conrelid and local_col.attnum=cols.local_num
  join pg_catalog.pg_attribute parent_col on parent_col.attrelid=c.confrelid and parent_col.attnum=cols.parent_num
  where c.contype='f' and c.confrelid='orchestration.artifact'::regclass
   and c.conrelid<>'orchestration.artifact_tombstone'::regclass
   and not(c.conrelid='orchestration.verification_artifact_metadata'::regclass and c.conkey @> array[(select attnum from pg_catalog.pg_attribute where attrelid=c.conrelid and attname='artifact_id')]::smallint[])
  group by c.oid,ns.nspname,cl.relname,c.conname
 loop
  execute format('create trigger %I before insert or update on %I.%I for each row execute function orchestration.guard_retired_artifact_reference(%L)',
   'artifact_retirement_'||substr(md5(dependency.schema_name||'.'||dependency.table_name||'.'||dependency.conname),1,24),dependency.schema_name,dependency.table_name,dependency.bindings::text);
 end loop;
end $$;

create function orchestration.guard_registered_storage_delete() returns trigger language plpgsql security definer set search_path='' as $$
begin
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(old.bucket_id||'/'||old.name,0));
 if exists(select 1 from orchestration.artifact a where a.storage_bucket=old.bucket_id and a.object_path=old.name
  and not exists(select 1 from orchestration.artifact_tombstone t where t.tenant_id=a.tenant_id and t.artifact_id=a.id)) then
  raise exception 'storage object retains live artifact registrations' using errcode='23514';
 end if;
 return old;
end $$;
revoke all on function orchestration.guard_registered_storage_delete() from public;
drop trigger if exists registered_storage_delete_guard on storage.objects;
create trigger registered_storage_delete_guard before delete on storage.objects for each row execute function orchestration.guard_registered_storage_delete();

alter table knowledge_service.checkpoint_scope enable row level security;
alter table knowledge_service.scoped_checkpoint enable row level security;
alter table knowledge_service.checkpoint_artifact_reference enable row level security;
alter table orchestration.artifact_tombstone enable row level security;
create policy checkpoint_scope_tenant on knowledge_service.checkpoint_scope for all to executor_service using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy scoped_checkpoint_tenant on knowledge_service.scoped_checkpoint for all to executor_service using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy checkpoint_reference_tenant on knowledge_service.checkpoint_artifact_reference for all to executor_service using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy artifact_tombstone_tenant on orchestration.artifact_tombstone for all to executor_service using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert,update on knowledge_service.checkpoint_scope to executor_service;
grant select,insert on knowledge_service.scoped_checkpoint,knowledge_service.checkpoint_artifact_reference,orchestration.artifact_tombstone to executor_service;
comment on table knowledge_service.scoped_checkpoint is 'Standalone KS durable workspace custody; no mission workflow acceptance or scheduler ownership.';
commit;
