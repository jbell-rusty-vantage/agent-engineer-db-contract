-- Multi-consumer-safe transactional outbox claims and normalized evidence packets.
begin;

alter table knowledge_service.operation_event
  add constraint operation_event_tenant_id_operation_uq unique (tenant_id,id,operation_id);

alter table knowledge_service.outbox
  add column claim_owner text,
  add column claim_token uuid,
  add column claimed_at timestamptz,
  add column visibility_expires_at timestamptz,
  add column max_delivery_attempts integer not null default 12
    check (max_delivery_attempts between 1 and 1000),
  add constraint outbox_claim_shape_ck check (
    (claim_owner is null and claim_token is null and claimed_at is null and visibility_expires_at is null)
    or
    (claim_owner is not null and length(btrim(claim_owner)) > 0 and claim_token is not null
      and claimed_at is not null and visibility_expires_at is not null
      and visibility_expires_at > claimed_at)
  ),
  add constraint outbox_event_operation_fk
    foreign key (tenant_id,event_id,operation_id)
    references knowledge_service.operation_event(tenant_id,id,operation_id) on delete restrict;

create unique index knowledge_outbox_claim_token_uq
  on knowledge_service.outbox(claim_token) where claim_token is not null;
create index knowledge_outbox_claimable_idx
  on knowledge_service.outbox
    (tenant_id,available_at,visibility_expires_at,created_at,id)
  where published_at is null and archived_at is null;
create index knowledge_outbox_event_idx
  on knowledge_service.outbox(tenant_id,event_id,operation_id);

create function knowledge_service.guard_outbox_mutation() returns trigger
language plpgsql set search_path='' as $$
begin
  if tg_op='DELETE' then
    raise exception 'outbox messages cannot be deleted' using errcode='restrict_violation';
  end if;
  if (new.id,new.tenant_id,new.operation_id,new.event_id,new.topic,new.payload,
      new.payload_sha256,new.created_at,new.max_delivery_attempts)
     is distinct from
     (old.id,old.tenant_id,old.operation_id,old.event_id,old.topic,old.payload,
      old.payload_sha256,old.created_at,old.max_delivery_attempts) then
    raise exception 'outbox event linkage and payload are immutable' using errcode='restrict_violation';
  end if;
  if old.published_at is not null or old.archived_at is not null then
    raise exception 'terminal outbox messages are immutable' using errcode='restrict_violation';
  end if;
  return new;
end $$;
create trigger outbox_mutation_guard before update or delete on knowledge_service.outbox
  for each row execute function knowledge_service.guard_outbox_mutation();

create function knowledge_service.claim_outbox(
  p_claim_owner text,
  p_limit integer default 50,
  p_visibility_timeout_ms integer default 30000,
  p_operation_id uuid default null
) returns table (
  id uuid, operation_id uuid, event_id uuid, topic text, payload jsonb,
  payload_sha256 text, delivery_attempts integer, claim_owner text,
  claim_token uuid, claimed_at timestamptz, visibility_expires_at timestamptz
)
language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id();
begin
  if v_tenant is null then
    raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege';
  end if;
  if coalesce(length(btrim(p_claim_owner)),0)=0 or length(p_claim_owner)>256 then
    raise exception 'claim owner is required and must be at most 256 characters' using errcode='invalid_parameter_value';
  end if;
  if p_limit not between 1 and 100 or p_visibility_timeout_ms not between 1000 and 900000 then
    raise exception 'claim limit or visibility timeout is outside the admitted range' using errcode='invalid_parameter_value';
  end if;

  -- Permanently exhausted messages are poison items; archive before selecting.
  update knowledge_service.outbox o set
    archived_at=clock_timestamp(),
    last_error=coalesce(o.last_error,'delivery_attempts_exhausted'),
    claim_owner=null,claim_token=null,claimed_at=null,visibility_expires_at=null
  where o.tenant_id=v_tenant and o.published_at is null and o.archived_at is null
    and o.delivery_attempts>=o.max_delivery_attempts
    and (o.claim_token is null or o.visibility_expires_at<=clock_timestamp());

  return query
  with selected as (
    select o.id from knowledge_service.outbox o
    where o.tenant_id=v_tenant
      and (p_operation_id is null or o.operation_id=p_operation_id)
      and o.published_at is null and o.archived_at is null
      and o.available_at<=clock_timestamp()
      and o.delivery_attempts<o.max_delivery_attempts
      and (o.claim_token is null or o.visibility_expires_at<=clock_timestamp())
    order by o.available_at,o.created_at,o.id
    for update skip locked limit p_limit
  ), claimed as (
    update knowledge_service.outbox o set
      claim_owner=p_claim_owner,
      claim_token=gen_random_uuid(),
      claimed_at=clock_timestamp(),
      visibility_expires_at=clock_timestamp()
        + make_interval(secs=>p_visibility_timeout_ms::double precision/1000.0),
      delivery_attempts=o.delivery_attempts+1
    from selected s where o.id=s.id
    returning o.*
  )
  select c.id,c.operation_id,c.event_id,c.topic,c.payload,c.payload_sha256,
    c.delivery_attempts,c.claim_owner,c.claim_token,c.claimed_at,c.visibility_expires_at
  from claimed c order by c.available_at,c.created_at,c.id;
end $$;

create function knowledge_service.ack_outbox(
  p_outbox_id uuid,p_claim_owner text,p_claim_token uuid
) returns boolean
language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id();
begin
  if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
  update knowledge_service.outbox set published_at=clock_timestamp(),last_error=null
  where tenant_id=v_tenant and id=p_outbox_id and published_at is null and archived_at is null
    and claim_owner=p_claim_owner and claim_token=p_claim_token
    and visibility_expires_at>clock_timestamp();
  if not found then raise exception 'stale or foreign outbox claim' using errcode='object_not_in_prerequisite_state'; end if;
  return true;
end $$;

create function knowledge_service.nack_outbox(
  p_outbox_id uuid,p_claim_owner text,p_claim_token uuid,p_error_class text,
  p_retry_delay_ms integer default 0
) returns boolean
language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id();
begin
  if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
  if coalesce(length(btrim(p_error_class)),0)=0 or length(p_error_class)>256
     or p_retry_delay_ms not between 0 and 86400000 then
    raise exception 'error class or retry delay is invalid' using errcode='invalid_parameter_value';
  end if;
  update knowledge_service.outbox set
    last_error=p_error_class,
    available_at=clock_timestamp()+make_interval(secs=>p_retry_delay_ms::double precision/1000.0),
    archived_at=case when delivery_attempts>=max_delivery_attempts then clock_timestamp() else null end,
    claim_owner=null,claim_token=null,claimed_at=null,visibility_expires_at=null
  where tenant_id=v_tenant and id=p_outbox_id and published_at is null and archived_at is null
    and claim_owner=p_claim_owner and claim_token=p_claim_token
    and visibility_expires_at>clock_timestamp();
  if not found then raise exception 'stale or foreign outbox claim' using errcode='object_not_in_prerequisite_state'; end if;
  return true;
end $$;

create function knowledge_service.extend_outbox_claim(
  p_outbox_id uuid,p_claim_owner text,p_claim_token uuid,p_visibility_timeout_ms integer
) returns timestamptz
language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id(); v_expiry timestamptz;
begin
  if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
  if p_visibility_timeout_ms not between 1000 and 900000 then
    raise exception 'visibility timeout is outside the admitted range' using errcode='invalid_parameter_value';
  end if;
  update knowledge_service.outbox set
    visibility_expires_at=clock_timestamp()+make_interval(secs=>p_visibility_timeout_ms::double precision/1000.0)
  where tenant_id=v_tenant and id=p_outbox_id and published_at is null and archived_at is null
    and claim_owner=p_claim_owner and claim_token=p_claim_token
    and visibility_expires_at>clock_timestamp()
  returning visibility_expires_at into v_expiry;
  if v_expiry is null then raise exception 'stale or foreign outbox claim' using errcode='object_not_in_prerequisite_state'; end if;
  return v_expiry;
end $$;

-- Normalize the typed packet fields used by the persistence adapter while the
-- complete immutable JSON envelope remains the wire-contract authority.
alter table retrieval.evidence_packet
  add column packet_sha256 text generated always as
    (encode(extensions.digest(packet::text,'sha256'),'hex')) stored,
  add column normalized_query text,
  add column authorization_context jsonb,
  add column omitted_results jsonb not null default '[]'::jsonb,
  add column coverage jsonb not null default '[]'::jsonb,
  add column abstention jsonb,
  add column event_ids uuid[] not null default '{}',
  add column receipt_ids uuid[] not null default '{}',
  add constraint evidence_packet_sha256_ck check (packet_sha256 ~ '^[0-9a-f]{64}$');

alter table retrieval.packet_member
  drop constraint packet_member_packet_id_fkey,
  add constraint packet_member_tenant_id_uq unique(tenant_id,id),
  add column vector_item_id uuid,
  add column search_projection_id uuid,
  add column scores jsonb not null default '{}'::jsonb,
  add column channel_explanations text[] not null default '{}',
  add column graph_paths jsonb not null default '[]'::jsonb,
  add column authority text,
  add column assurance text,
  add column fresh_at timestamptz,
  add column contradiction_ids uuid[] not null default '{}',
  add column supersedes_ids uuid[] not null default '{}',
  add column covered_subquery_ids text[] not null default '{}',
  add column artifact_references jsonb not null default '[]'::jsonb,
  add column member_payload jsonb not null default '{}'::jsonb,
  add column member_sha256 text generated always as
    (encode(extensions.digest(member_payload::text,'sha256'),'hex')) stored,
  add constraint packet_member_packet_restrict_fk
    foreign key(tenant_id,packet_id) references retrieval.evidence_packet(tenant_id,id) on delete restrict,
  add constraint packet_member_vector_item_fk
    foreign key(tenant_id,vector_item_id) references retrieval.vector_item(tenant_id,id) on delete restrict,
  add constraint packet_member_projection_fk
    foreign key(tenant_id,search_projection_id) references retrieval.search_projection(tenant_id,id) on delete restrict,
  add constraint packet_member_sha256_ck check (member_sha256 ~ '^[0-9a-f]{64}$');

create index packet_member_vector_item_idx on retrieval.packet_member(tenant_id,vector_item_id)
  where vector_item_id is not null;
create index packet_member_projection_idx on retrieval.packet_member(tenant_id,search_projection_id)
  where search_projection_id is not null;

revoke update,delete on knowledge_service.outbox from executor_service,control_plane,pipeline_agent,verifier_agent,app_reader;
revoke all on function knowledge_service.claim_outbox(text,integer,integer,uuid) from public,anon,authenticated;
revoke all on function knowledge_service.ack_outbox(uuid,text,uuid) from public,anon,authenticated;
revoke all on function knowledge_service.nack_outbox(uuid,text,uuid,text,integer) from public,anon,authenticated;
revoke all on function knowledge_service.extend_outbox_claim(uuid,text,uuid,integer) from public,anon,authenticated;
grant execute on function knowledge_service.claim_outbox(text,integer,integer,uuid) to executor_service,control_plane,service_role;
grant execute on function knowledge_service.ack_outbox(uuid,text,uuid) to executor_service,control_plane,service_role;
grant execute on function knowledge_service.nack_outbox(uuid,text,uuid,text,integer) to executor_service,control_plane,service_role;
grant execute on function knowledge_service.extend_outbox_claim(uuid,text,uuid,integer) to executor_service,control_plane,service_role;

comment on function knowledge_service.claim_outbox(text,integer,integer,uuid) is
  'Atomically claims tenant-scoped due messages with FOR UPDATE SKIP LOCKED and a visibility-timeout fencing token.';
comment on function knowledge_service.ack_outbox(uuid,text,uuid) is
  'Acknowledges only a live claim owned by the supplied consumer and token.';
comment on function knowledge_service.nack_outbox(uuid,text,uuid,text,integer) is
  'Rejects only a live owned claim, applies bounded backoff, and archives exhausted poison messages.';
commit;
