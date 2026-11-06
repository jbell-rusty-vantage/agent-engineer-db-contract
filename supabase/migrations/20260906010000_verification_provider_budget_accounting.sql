-- Durable, tenant-scoped reservation ledger for bounded verification provider pilots.
-- Reservation rows are immutable identities; an uncertain dispatched attempt retains its
-- reservation until a later reconciliation supplies provider evidence.
begin;

create table orchestration.verification_provider_budget (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  budget_key text not null check (budget_key ~ '^[a-z0-9][a-z0-9._-]{0,119}$'),
  ceiling_cost_micros bigint not null check (ceiling_cost_micros > 0 and ceiling_cost_micros <= 20000000),
  reserved_cost_micros bigint not null default 0 check (reserved_cost_micros >= 0),
  settled_cost_micros bigint not null default 0 check (settled_cost_micros >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, budget_key),
  unique (tenant_id, id),
  check (reserved_cost_micros + settled_cost_micros <= ceiling_cost_micros)
);

create trigger verification_provider_budget_set_updated_at
  before update on orchestration.verification_provider_budget
  for each row execute function util.set_updated_at();

create table orchestration.verification_provider_attempt (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  budget_id uuid not null,
  request_sha256 text not null check (request_sha256 ~ '^[0-9a-f]{64}$'),
  attempt_ordinal integer not null check (attempt_ordinal >= 0 and attempt_ordinal <= 8),
  provider_id text not null check (provider_id ~ '^[a-z0-9][a-z0-9._-]{0,119}$'),
  model text not null check (length(model) between 1 and 160),
  reservation_cost_micros bigint not null check (reservation_cost_micros > 0),
  state text not null check (state in ('reserved','dispatched','settled','uncertain','cancelled')),
  estimated_cost_micros bigint check (estimated_cost_micros >= 0),
  actual_cost_micros bigint check (actual_cost_micros >= 0),
  request_artifact_id uuid references orchestration.artifact(id),
  response_artifact_id uuid references orchestration.artifact(id),
  created_at timestamptz not null default now(),
  dispatched_at timestamptz,
  reconciled_at timestamptz,
  unique (tenant_id, id),
  unique (tenant_id, request_sha256, attempt_ordinal),
  foreign key (tenant_id, budget_id) references orchestration.verification_provider_budget(tenant_id, id),
  check ((state = 'reserved' and dispatched_at is null and reconciled_at is null and actual_cost_micros is null)
      or (state = 'dispatched' and dispatched_at is not null and reconciled_at is null and actual_cost_micros is null)
      or (state = 'uncertain' and dispatched_at is not null and reconciled_at is null and actual_cost_micros is null)
      or (state = 'cancelled' and dispatched_at is null and reconciled_at is not null and actual_cost_micros is null)
      or (state = 'settled' and dispatched_at is not null and reconciled_at is not null and actual_cost_micros is not null))
);

create index verification_provider_attempt_budget_idx on orchestration.verification_provider_attempt (tenant_id, budget_id, created_at desc);

create or replace function orchestration.verification_provider_attempt_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'verification provider attempts are append-only' using errcode = 'restrict_violation'; end if;
  if new.tenant_id <> old.tenant_id or new.budget_id <> old.budget_id or new.request_sha256 <> old.request_sha256
     or new.attempt_ordinal <> old.attempt_ordinal or new.provider_id <> old.provider_id or new.model <> old.model
     or new.reservation_cost_micros <> old.reservation_cost_micros or new.created_at <> old.created_at
     or old.state in ('settled','cancelled') then
    raise exception 'verification provider attempt immutable identity' using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

create trigger verification_provider_attempt_immutable
  before update or delete on orchestration.verification_provider_attempt
  for each row execute function orchestration.verification_provider_attempt_guard();

commit;
