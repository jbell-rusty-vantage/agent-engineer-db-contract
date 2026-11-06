-- Durable, immutable evidence for reference-orchestrated vector-store ingestion.
-- Mission Control/Eve may dispatch prerequisite operations; this service only
-- marks a document indexed after proving the entire canonical resource chain.
begin;

create table retrieval.vector_store_ingestion_run (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  operation_id uuid not null,
  vector_store_id uuid not null,
  actor_identity text not null,
  request_sha256 text not null check(request_sha256 ~ '^[0-9a-f]{64}$'),
  manifest jsonb not null,
  created_at timestamptz not null default now(),
  unique(tenant_id,id),
  unique(tenant_id,operation_id),
  foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
  foreign key(tenant_id,vector_store_id) references retrieval.vector_store(tenant_id,id) on delete restrict
);

create table retrieval.vector_store_ingestion_checkpoint (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  ingestion_run_id uuid not null,
  stage text not null check(stage in ('prepared','embedded','indexed')),
  evidence_sha256 text not null check(evidence_sha256 ~ '^[0-9a-f]{64}$'),
  evidence jsonb not null,
  created_at timestamptz not null default now(),
  unique(tenant_id,id),
  unique(tenant_id,ingestion_run_id,stage),
  foreign key(tenant_id,ingestion_run_id) references retrieval.vector_store_ingestion_run(tenant_id,id) on delete restrict
);

create function retrieval.validate_vector_store_ingestion_operation() returns trigger
language plpgsql set search_path='' as $$
begin
  if not exists(
    select 1 from knowledge_service.operation o
    where o.tenant_id=new.tenant_id and o.id=new.operation_id
      and o.operation_kind='vector_store_ingestion'
      and o.actor_identity=new.actor_identity
      and o.status in ('running','succeeded')
  ) then
    raise exception 'active vector_store_ingestion operation with matching actor is required'
      using errcode='insufficient_privilege';
  end if;
  return new;
end $$;

create trigger vector_store_ingestion_operation_guard before insert
  on retrieval.vector_store_ingestion_run for each row
  execute function retrieval.validate_vector_store_ingestion_operation();
create trigger vector_store_ingestion_run_immutable before update or delete
  on retrieval.vector_store_ingestion_run for each row execute function util.reject_mutation();
create trigger vector_store_ingestion_checkpoint_immutable before update or delete
  on retrieval.vector_store_ingestion_checkpoint for each row execute function util.reject_mutation();

alter table retrieval.vector_store_ingestion_run enable row level security;
alter table retrieval.vector_store_ingestion_run force row level security;
alter table retrieval.vector_store_ingestion_checkpoint enable row level security;
alter table retrieval.vector_store_ingestion_checkpoint force row level security;
create policy bounded_role_access on retrieval.vector_store_ingestion_run
  for all to executor_service,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy bounded_role_access on retrieval.vector_store_ingestion_checkpoint
  for all to executor_service,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on retrieval.vector_store_ingestion_run,retrieval.vector_store_ingestion_checkpoint to executor_service,control_plane;
revoke update,delete on retrieval.vector_store_ingestion_run,retrieval.vector_store_ingestion_checkpoint from executor_service,control_plane;

commit;
