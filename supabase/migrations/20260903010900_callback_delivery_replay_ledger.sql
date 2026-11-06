-- Immutable, tenant-scoped replay ledger for authenticated A2A callbacks.
begin;

create table knowledge_service.callback_delivery (
 callback_id uuid primary key,
 tenant_id uuid not null default util.default_tenant_id(),
 task_id uuid not null,
 operation_id uuid not null,
 correlation_id text not null,
 causation_id text,
 signing_key_reference text not null,
 receiver_identity text not null,
 payload_sha256 text not null check(payload_sha256 ~ '^sha256:[0-9a-f]{64}$'),
 signature text not null check(signature ~ '^sha256=[0-9a-f]{64}$'),
 occurred_at timestamptz not null,
 received_at timestamptz not null default clock_timestamp(),
 unique(tenant_id,callback_id),
 foreign key(tenant_id,operation_id)
   references knowledge_service.operation(tenant_id,id) on delete restrict,
 check(occurred_at >= received_at - interval '5 minutes'),
 check(occurred_at <= received_at + interval '30 seconds')
);

create index callback_delivery_operation_idx
 on knowledge_service.callback_delivery(tenant_id,operation_id,received_at);

create trigger callback_delivery_immutable before update or delete
 on knowledge_service.callback_delivery for each row
 execute function util.reject_mutation();

alter table knowledge_service.callback_delivery enable row level security;
create policy bounded_role_access on knowledge_service.callback_delivery
 for all to executor_service,control_plane
 using(tenant_id=util.current_tenant_id())
 with check(tenant_id=util.current_tenant_id());

grant select,insert on knowledge_service.callback_delivery
 to executor_service,control_plane;
revoke update,delete on knowledge_service.callback_delivery
 from executor_service,control_plane;
revoke all on knowledge_service.callback_delivery
 from public,anon,authenticated,pipeline_agent,verifier_agent,app_reader;

comment on table knowledge_service.callback_delivery is
 'Append-only authenticated A2A callback receipt and cross-restart replay ledger; payloads and secrets are never stored.';

commit;
