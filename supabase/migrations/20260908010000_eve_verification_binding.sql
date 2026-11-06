-- Immutable, tenant-scoped binding between an API-verified Eve runtime attestation and a KS verification operation.
-- The envelope is retained for offline authorization replay; signature verification remains at the API boundary.
begin;
set local lock_timeout = '10s';
set local statement_timeout = '120s';

do $$ begin
 if not exists(select 1 from pg_constraint where conrelid='orchestration.mission'::regclass and contype='u' and conkey=(select array_agg(attnum order by attnum) from pg_attribute where attrelid='orchestration.mission'::regclass and attname in ('tenant_id','id'))) then
   alter table orchestration.mission add constraint mission_eve_binding_tenant_id_uq unique (tenant_id, id);
 end if;
end $$;

create table knowledge_service.eve_operation_binding (
  tenant_id uuid not null default util.default_tenant_id(),
  operation_id uuid not null,
  idempotency_key text not null check (idempotency_key = btrim(idempotency_key) and char_length(idempotency_key) between 1 and 512),
  grant_id text not null check (grant_id = btrim(grant_id) and char_length(grant_id) between 1 and 255),
  use_case text not null check (use_case in ('verifyClaims','verifyReport')),
  request_sha256 text not null check (request_sha256 ~ '^[0-9a-f]{64}$'),
  actor_identity text not null check (actor_identity = btrim(actor_identity) and char_length(actor_identity) between 3 and 512),
  mission_id uuid not null,
  work_item_id uuid not null,
  attempt_id uuid not null,
  agent_deployment_id text not null check (agent_deployment_id = btrim(agent_deployment_id) and char_length(agent_deployment_id) between 1 and 255),
  capability_version text not null check (capability_version = btrim(capability_version) and char_length(capability_version) between 1 and 255),
  original_external_execution jsonb not null,
  issuer text not null check (issuer = btrim(issuer) and char_length(issuer) between 1 and 255),
  original_key_id text not null check (original_key_id = btrim(original_key_id) and char_length(original_key_id) between 1 and 255),
  original_jti text not null check (original_jti = btrim(original_jti) and char_length(original_jti) between 1 and 255),
  original_payload_sha256 text not null check (original_payload_sha256 ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default clock_timestamp(),
  primary key (tenant_id, operation_id),
  unique (tenant_id, idempotency_key),
  foreign key (tenant_id, attempt_id) references orchestration.attempt(tenant_id, id) on delete restrict,
  foreign key (tenant_id, work_item_id) references orchestration.work_item(tenant_id, id) on delete restrict,
  foreign key (tenant_id, mission_id) references orchestration.mission(tenant_id, id) on delete restrict,
  check (original_external_execution ?& array['runtime','runId','sessionId','turnId','toolCallId'] and original_external_execution->>'runtime' = 'eve')
);

create table knowledge_service.eve_operation_invocation (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  operation_id uuid not null,
  issuer text not null check (issuer = btrim(issuer) and char_length(issuer) between 1 and 255),
  key_id text not null check (key_id = btrim(key_id) and char_length(key_id) between 1 and 255),
  jti text not null check (jti = btrim(jti) and char_length(jti) between 1 and 255),
  invocation_kind text not null check (invocation_kind in ('original','retry')),
  envelope jsonb not null,
  envelope_sha256 text not null check (envelope_sha256 ~ '^[0-9a-f]{64}$'),
  lineage_sha256 text not null check (lineage_sha256 ~ '^[0-9a-f]{64}$'),
  observed_external_execution jsonb not null,
  issued_at timestamptz not null,
  expires_at timestamptz not null,
  accepted_at timestamptz not null default clock_timestamp(),
  foreign key (tenant_id, operation_id) references knowledge_service.eve_operation_binding(tenant_id, operation_id) on delete restrict,
  unique (issuer, jti),
  check (expires_at > issued_at),
  check (envelope ?& array['payload','signatureBase64']),
  check (observed_external_execution ?& array['runtime','runId','sessionId','turnId','toolCallId'] and observed_external_execution->>'runtime' = 'eve')
);

create index eve_operation_binding_attempt_idx on knowledge_service.eve_operation_binding (tenant_id, attempt_id, created_at);
create index eve_operation_invocation_binding_idx on knowledge_service.eve_operation_invocation (tenant_id, operation_id, accepted_at);

create trigger eve_operation_binding_immutable before update or delete on knowledge_service.eve_operation_binding for each row execute function util.reject_mutation();
create trigger eve_operation_invocation_immutable before update or delete on knowledge_service.eve_operation_invocation for each row execute function util.reject_mutation();

alter table knowledge_service.eve_operation_binding enable row level security;
alter table knowledge_service.eve_operation_invocation enable row level security;
create policy eve_operation_binding_control_plane on knowledge_service.eve_operation_binding for all to control_plane using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
create policy eve_operation_invocation_control_plane on knowledge_service.eve_operation_invocation for all to control_plane using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
grant select,insert on knowledge_service.eve_operation_binding,knowledge_service.eve_operation_invocation to control_plane;
revoke all on knowledge_service.eve_operation_binding,knowledge_service.eve_operation_invocation from public,anon,authenticated,pipeline_agent,verifier_agent,app_reader;
revoke update,delete on knowledge_service.eve_operation_binding,knowledge_service.eve_operation_invocation from control_plane;
comment on table knowledge_service.eve_operation_binding is 'Immutable first-lineage binding for API-verified Eve verification requests. It grants no authority itself.';
comment on table knowledge_service.eve_operation_invocation is 'Append-only full public Eve attestation envelopes, including signature, for offline authorization replay. It grants no authority itself.';
commit;