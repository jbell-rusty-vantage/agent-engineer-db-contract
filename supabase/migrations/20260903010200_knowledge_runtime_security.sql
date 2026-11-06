-- Knowledge preparation service: restart-safe runtime, publication guards,
-- fail-closed tenant context, narrow retrieval RPC, RLS and grants.
begin;

create table knowledge_service.operation (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(),
 operation_kind text not null, idempotency_key text not null, ownership_mode text not null default 'standalone' check(ownership_mode in ('standalone','mission_control','eve')),
 external_run_id text, mission_id uuid, work_item_id uuid, attempt_id uuid, correlation_id uuid not null, causation_id uuid,
 actor_identity text not null, capability_version_id uuid references orchestration.capability_version(id) on delete restrict,
 request jsonb not null, request_sha256 text not null check(request_sha256 ~ '^[0-9a-f]{64}$'), status text not null default 'queued' check(status in
 ('proposed','queued','running','needs_review','succeeded','failed','cancelled','quarantined','superseded')),
 row_version bigint not null default 0, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), completed_at timestamptz,
 unique(tenant_id,id), unique(tenant_id,idempotency_key),
 foreign key(tenant_id,work_item_id) references orchestration.work_item(tenant_id,id) on delete restrict,
 foreign key(tenant_id,attempt_id) references orchestration.attempt(tenant_id,id) on delete restrict,
 check((status in ('succeeded','failed','cancelled','superseded'))=(completed_at is not null))
);
create table knowledge_service.operation_step (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), operation_id uuid not null,
 step_key text not null, step_kind text not null, input jsonb not null, input_sha256 text not null check(input_sha256 ~ '^[0-9a-f]{64}$'),
 status text not null default 'queued', attempt_count integer not null default 0, max_attempts integer not null default 3,
 available_at timestamptz not null default now(), row_version bigint not null default 0, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(), completed_at timestamptz, unique(tenant_id,id), unique(tenant_id,operation_id,step_key),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict
);
create table knowledge_service.operation_event (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), operation_id uuid not null,
 step_id uuid, event_kind text not null, from_state text, to_state text, actor_identity text not null, correlation_id uuid not null,
 causation_id uuid, guarded_sha256 text, payload jsonb not null default '{}'::jsonb, occurred_at timestamptz not null default now(),
 unique(tenant_id,id),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,step_id) references knowledge_service.operation_step(tenant_id,id) on delete restrict
);
create table knowledge_service.receipt (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), operation_id uuid not null,
 step_id uuid, receipt_kind text not null, idempotency_key text not null, executor_identity text not null,
 input_sha256 text not null check(input_sha256 ~ '^[0-9a-f]{64}$'), output_sha256 text check(output_sha256 is null or output_sha256 ~ '^[0-9a-f]{64}$'),
 outcome text not null, body jsonb not null, signature text, created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,idempotency_key),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,step_id) references knowledge_service.operation_step(tenant_id,id) on delete restrict
);
create table knowledge_service.outbox (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), operation_id uuid not null,
 event_id uuid not null, topic text not null, payload jsonb not null,
 payload_sha256 text not null check(payload_sha256 ~ '^[0-9a-f]{64}$'), available_at timestamptz not null default now(),
 delivery_attempts integer not null default 0, published_at timestamptz, archived_at timestamptz, last_error text, created_at timestamptz not null default now(),
 unique(tenant_id,id), foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,event_id) references knowledge_service.operation_event(tenant_id,id) on delete restrict
);
create table knowledge_service.lease (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), operation_step_id uuid not null,
 holder_identity text not null, lease_token uuid not null default gen_random_uuid(), fencing_token bigint generated always as identity,
 acquired_at timestamptz not null default now(), heartbeat_at timestamptz not null default now(), expires_at timestamptz not null,
 released_at timestamptz, unique(tenant_id,id), unique(tenant_id,operation_step_id), unique(lease_token),
 foreign key(tenant_id,operation_step_id) references knowledge_service.operation_step(tenant_id,id) on delete restrict,
 check(expires_at>acquired_at), check(released_at is null or released_at>=acquired_at)
);
create table knowledge_service.review_subject (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), operation_id uuid not null,
 subject_kind text not null check(subject_kind in ('source_vetting','conversion','representation','domain_mapping','chunking','projection','content_promotion','publication','regression_waiver','injection_security','retrieval_anomaly')),
 subject_ref jsonb not null, guarded_sha256 text not null check(guarded_sha256 ~ '^[0-9a-f]{64}$'),
 eligible_roles text[] not null, quorum_required integer not null default 1 check(quorum_required>0), expires_at timestamptz,
 created_at timestamptz not null default now(), unique(tenant_id,id), foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict
);
create table knowledge_service.review_decision (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), review_subject_id uuid not null,
 guarded_sha256 text not null check(guarded_sha256 ~ '^[0-9a-f]{64}$'), reviewer_identity text not null, reviewer_role text not null,
 decision text not null check(decision in ('approve','reject','defer','request_changes')), rationale text not null,
 created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,review_subject_id,reviewer_identity),
 foreign key(tenant_id,review_subject_id) references knowledge_service.review_subject(tenant_id,id) on delete restrict
);

create index knowledge_operation_queue_idx on knowledge_service.operation(tenant_id,status,created_at) where status in ('queued','running');
create index knowledge_step_queue_idx on knowledge_service.operation_step(tenant_id,status,available_at) where status='queued';
create index knowledge_outbox_pending_idx on knowledge_service.outbox(tenant_id,available_at) where published_at is null and archived_at is null;
create index knowledge_lease_expiry_idx on knowledge_service.lease(tenant_id,expires_at) where released_at is null;

do $$ declare t text; begin
 foreach t in array array['operation_event','receipt','review_subject','review_decision'] loop
  execute format('create trigger %I_immutable before update or delete on knowledge_service.%I for each row execute function util.reject_mutation()',t,t);
 end loop;
end $$;

create function knowledge_service.guard_operation_terminal() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'operation state cannot be deleted' using errcode='restrict_violation'; end if;
 if old.status in ('succeeded','failed','cancelled','superseded') then raise exception 'terminal operation state is immutable' using errcode='restrict_violation'; end if;
 new.row_version:=old.row_version+1; new.updated_at:=now(); return new;
end $$;
create trigger operation_terminal_guard before update or delete on knowledge_service.operation for each row execute function knowledge_service.guard_operation_terminal();
create trigger operation_step_terminal_guard before update or delete on knowledge_service.operation_step for each row execute function knowledge_service.guard_operation_terminal();

-- Supersession always points from a newly inserted row to an already-existing,
-- no-newer predecessor. Because these rows are immutable, this makes the graph
-- one-way and acyclic without a mutable "current" pointer.
create function util.validate_predecessor() returns trigger language plpgsql set search_path='' as $$
declare predecessor_created timestamptz; predecessor_tenant uuid; predecessor_id uuid; begin
 predecessor_id := (to_jsonb(new)->>tg_argv[0])::uuid;
 if predecessor_id is null then return new; end if;
 execute format('select tenant_id,created_at from %I.%I where id=$1',tg_table_schema,tg_table_name)
 into predecessor_tenant,predecessor_created using predecessor_id;
 if predecessor_tenant is null or predecessor_tenant<>new.tenant_id then
  raise exception 'supersession predecessor must exist in the same tenant' using errcode='foreign_key_violation';
 end if;
 if predecessor_id=new.id or predecessor_created>new.created_at then
  raise exception 'supersession must point one-way to an older row' using errcode='check_violation';
 end if;
 return new;
end $$;
do $$ declare target text; parts text[]; begin
 foreach target in array array[
  'content.document:supersedes_id','content.document_version:supersedes_id','content.document_representation:supersedes_id',
  'retrieval.vector_store:supersedes_id','retrieval.vector_store_document:supersedes_id','retrieval.chunk_set:supersedes_id',
  'retrieval.space_publication:predecessor_id'
 ] loop
  parts:=string_to_array(target,':');
  execute format('create trigger predecessor_direction before insert on %s for each row execute function util.validate_predecessor(%L)',parts[1],parts[2]);
 end loop;
end $$;

-- Replace legacy partial comparisons with column-complete guards. The only
-- legal amendment sets a successor once, to a newer same-tenant row.
alter table orchestration.artifact add constraint artifact_tenant_successor_fk
 foreign key(tenant_id,superseded_by_id) references orchestration.artifact(tenant_id,id) on delete restrict;
create or replace function orchestration.artifact_guard() returns trigger language plpgsql set search_path='' as $$
declare successor_created timestamptz; begin
 if tg_op='DELETE' then raise exception 'orchestration.artifact is append-only' using errcode='restrict_violation'; end if;
 if (to_jsonb(new)-'superseded_by_id') is distinct from (to_jsonb(old)-'superseded_by_id')
    or old.superseded_by_id is not null or new.superseded_by_id is null or new.superseded_by_id=new.id then
  raise exception 'artifact is immutable; only a first successor assignment is allowed' using errcode='restrict_violation';
 end if;
 select created_at into successor_created from orchestration.artifact where tenant_id=old.tenant_id and id=new.superseded_by_id;
 if successor_created is null or successor_created<=old.created_at then raise exception 'artifact successor must be newer and same-tenant' using errcode='check_violation'; end if;
 return new;
end $$;
alter table retrieval.vector_item add constraint vector_item_tenant_successor_fk
 foreign key(tenant_id,superseded_by_id) references retrieval.vector_item(tenant_id,id) on delete restrict;
create or replace function retrieval.vector_item_guard() returns trigger language plpgsql set search_path='' as $$
declare successor_created timestamptz; begin
 if tg_op='DELETE' then raise exception 'retrieval.vector_item is append-only' using errcode='restrict_violation'; end if;
 if (to_jsonb(new)-'superseded_by_id') is distinct from (to_jsonb(old)-'superseded_by_id')
    or old.superseded_by_id is not null or new.superseded_by_id is null or new.superseded_by_id=new.id then
  raise exception 'vector item is immutable; only a first successor assignment is allowed' using errcode='restrict_violation';
 end if;
 select created_at into successor_created from retrieval.vector_item where tenant_id=old.tenant_id and id=new.superseded_by_id;
 if successor_created is null or successor_created<=old.created_at then raise exception 'vector successor must be newer and same-tenant' using errcode='check_violation'; end if;
 return new;
end $$;

-- Active rows transition; terminal results remain immutable.
drop trigger embedding_run_immutable on retrieval.embedding_run;
drop trigger chunk_set_immutable on retrieval.chunk_set;
drop trigger space_publication_immutable on retrieval.space_publication;
create function retrieval.guard_terminal_status() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception '% cannot be deleted',tg_table_name using errcode='restrict_violation'; end if;
 if old.status in ('succeeded','failed','cancelled','superseded','published','withdrawn') then raise exception 'terminal % is immutable',tg_table_name using errcode='restrict_violation'; end if;
 return new;
end $$;
create trigger embedding_run_terminal_guard before update or delete on retrieval.embedding_run for each row execute function retrieval.guard_terminal_status();
create trigger chunk_set_terminal_guard before update or delete on retrieval.chunk_set for each row execute function retrieval.guard_terminal_status();

create function retrieval.validate_embedding_item() returns trigger language plpgsql set search_path='' as $$
declare expected integer; begin
 select r.expected_dimensions into expected from retrieval.embedding_run r where r.tenant_id=new.tenant_id and r.id=new.embedding_run_id;
 if expected is null or new.dimensions<>expected or new.dimensions<>1536 then
  raise exception 'embedding dimensions %, expected % and canonical physical dimension 1536',new.dimensions,expected using errcode='check_violation';
 end if; return new;
end $$;
create trigger embedding_item_dimensions before insert on retrieval.embedding_item for each row execute function retrieval.validate_embedding_item();

create function retrieval.guard_space_publication() returns trigger language plpgsql set search_path='' as $$
declare v_dims int; v_precision text; v_decision text; v_gate_passed boolean; v_actual bigint;
begin
 if tg_op='DELETE' then raise exception 'publications cannot be deleted' using errcode='restrict_violation'; end if;
 if old.status in ('published','superseded','withdrawn') then raise exception 'terminal publication is immutable' using errcode='restrict_violation'; end if;
 if new.status='published' then
  select dims,precision into v_dims,v_precision from retrieval.vector_space_version where tenant_id=new.tenant_id and id=new.vector_space_version_id;
  select decision into v_decision from retrieval.content_promotion_decision where tenant_id=new.tenant_id and id=new.publication_decision_id and (expires_at is null or expires_at>now());
  select passed into v_gate_passed from evaluation.promotion_gate_result where tenant_id=new.tenant_id and id=new.evaluation_result_id;
  select count(*) into v_actual from retrieval.vector_item_embedding_1536 where tenant_id=new.tenant_id and vector_space_version_id=new.vector_space_version_id;
  if v_dims<>1536 or v_precision<>'halfvec' or v_decision<>'accept' or v_gate_passed is distinct from true or v_actual<>new.expected_item_count then
   raise exception 'publication gate failed (dims %, precision %, decision %, gate %, embeddings %/%)',v_dims,v_precision,v_decision,v_gate_passed,v_actual,new.expected_item_count using errcode='check_violation';
  end if;
 end if; return new;
end $$;
alter table retrieval.space_publication add constraint space_publication_eval_fk foreign key(tenant_id,evaluation_result_id) references evaluation.promotion_gate_result(tenant_id,id) on delete restrict;
create trigger space_publication_guard before update or delete on retrieval.space_publication for each row execute function retrieval.guard_space_publication();

-- Strictly fail closed: absent, empty, malformed, or all-zero context resolves
-- to NULL, causing tenant RLS predicates and RPC filters to match no rows.
create or replace function util.current_tenant_id() returns uuid language plpgsql stable parallel safe set search_path='' as $$
declare v text; parsed uuid; begin
 v:=current_setting('app.tenant_id',true);
 if v is null or btrim(v)='' then return null; end if;
 begin parsed:=v::uuid; exception when invalid_text_representation then return null; end;
 if parsed='00000000-0000-0000-0000-000000000000'::uuid then return null; end if;
 return parsed;
end $$;

-- Refresh policies because some existing tables acquired tenant_id in this migration.
do $$ declare r record; has_tenant boolean; predicate text; begin
 for r in select c.oid,n.nspname s,c.relname t from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where n.nspname in ('orchestration','evidence','taxonomy','corpus','knowledge','staging','ranking','research','retrieval','evaluation','observability','curriculum','content','knowledge_service')
  and c.relkind in ('r','p') and not c.relispartition
 loop
  execute format('alter table %I.%I enable row level security',r.s,r.t);
  execute format('drop policy if exists bounded_role_access on %I.%I',r.s,r.t);
  select exists(select 1 from pg_attribute where attrelid=r.oid and attname='tenant_id' and attnum>0 and not attisdropped) into has_tenant;
  if has_tenant then predicate:='tenant_id = util.current_tenant_id()'; else predicate:='false'; end if;
  execute format('create policy bounded_role_access on %I.%I for all to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader using (%s) with check (%s)',r.s,r.t,predicate,predicate);
 end loop;
end $$;

create or replace function api.search_knowledge_1536(p_vector_space_version_id uuid,p_query extensions.halfvec(1536),p_limit integer default 20)
returns table(vector_item_id uuid,search_projection_id uuid,score double precision,search_text text)
language plpgsql stable security definer set search_path='' as $$
declare t uuid; begin
 t:=util.current_tenant_id();
 if t is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
 if p_limit<1 or p_limit>200 then raise exception 'p_limit must be between 1 and 200' using errcode='invalid_parameter_value'; end if;
 if not exists(select 1 from retrieval.vector_space_version v where v.tenant_id=t and v.id=p_vector_space_version_id and v.dims=1536 and v.precision='halfvec' and v.publication_lifecycle='published') then
  raise exception 'vector space version is not published for the active tenant' using errcode='insufficient_privilege';
 end if;
 return query select vi.id,vi.search_projection_id,1-(e.embedding operator(extensions.<=>) p_query),vi.search_text
 from retrieval.vector_item_embedding_1536 e join retrieval.vector_item vi on vi.tenant_id=e.tenant_id and vi.id=e.vector_item_id
 where e.tenant_id=t and e.vector_space_version_id=p_vector_space_version_id and vi.lifecycle='active'
 order by e.embedding operator(extensions.<=>) p_query limit p_limit;
end $$;
revoke all on function api.search_knowledge_1536(uuid,extensions.halfvec,integer) from public,anon;
grant execute on function api.search_knowledge_1536(uuid,extensions.halfvec,integer) to authenticated,app_reader,service_role;

-- Private, content-addressed storage. No client policies are created: trusted
-- executors use narrow server-side adapters; service_role bypasses Storage RLS.
insert into storage.buckets(id,name,public,file_size_limit) values
 ('source-captures','source-captures',false,1073741824),
 ('content-derivatives','content-derivatives',false,1073741824)
on conflict(id) do update set public=false;

grant usage on schema content,knowledge_service to executor_service,control_plane;
grant select,insert on all tables in schema content to executor_service;
grant select,insert,update on all tables in schema knowledge_service to executor_service,control_plane;
revoke all on schema content,knowledge_service from anon,authenticated,pipeline_agent,verifier_agent,app_reader;
revoke update,delete on all tables in schema content from executor_service,control_plane;
revoke delete on all tables in schema knowledge_service from executor_service,control_plane;

comment on schema knowledge_service is 'Restart-safe standalone operations, steps, events, leases, receipts, outbox and guarded review decisions.';
commit;
