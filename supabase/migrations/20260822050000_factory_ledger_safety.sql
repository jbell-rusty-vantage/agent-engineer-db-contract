-- Safety hardening for the native Eve ledger before production activation.

alter table public.factory_runtime_event
  add column if not exists event_ordinal bigint,
  add column if not exists repository text,
  add column if not exists issue_number bigint,
  add column if not exists sensitivity_class text not null default 'confidential',
  add column if not exists retention_until timestamptz not null
    default (timezone('utc', now()) + interval '30 days');

with ordered as (
  select eve_event_id,
         row_number() over (
           partition by factory_episode_id order by emitted_at, eve_event_id
         ) as ordinal
    from public.factory_runtime_event
)
update public.factory_runtime_event event
   set event_ordinal = ordered.ordinal
  from ordered
 where event.eve_event_id = ordered.eve_event_id
   and event.event_ordinal is null;

alter table public.factory_runtime_event
  alter column event_ordinal set not null,
  drop constraint if exists factory_runtime_event_ordinal_positive,
  drop constraint if exists factory_runtime_event_sensitivity_check,
  add constraint factory_runtime_event_ordinal_positive check (event_ordinal > 0),
  add constraint factory_runtime_event_sensitivity_check check (
    sensitivity_class in ('internal', 'confidential', 'restricted')
  );

create unique index if not exists factory_runtime_event_episode_ordinal_uniq
  on public.factory_runtime_event (factory_episode_id, event_ordinal);

alter table public.factory_runtime_event
  drop constraint if exists factory_runtime_event_factory_episode_id_fkey,
  add constraint factory_runtime_event_factory_episode_id_fkey
    foreign key (factory_episode_id)
    references public.factory_episode(factory_episode_id) on delete restrict;

create or replace function public.reject_immutable_row_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception '% rows are append-only', tg_table_name;
end;
$$;

drop trigger if exists factory_runtime_event_immutable
  on public.factory_runtime_event;
create trigger factory_runtime_event_immutable
before update or delete on public.factory_runtime_event
for each row execute procedure public.reject_immutable_row_change();

create or replace function public.protect_factory_episode_identity_and_terminal()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    if old.terminal_state is not null then
      raise exception 'Terminal factory episodes cannot be deleted';
    end if;
    return old;
  end if;
  if new.factory_task_id is distinct from old.factory_task_id
     or new.environment_version_id is distinct from old.environment_version_id
     or new.factory_candidate_id is distinct from old.factory_candidate_id
     or new.seed is distinct from old.seed
     or new.idempotency_key is distinct from old.idempotency_key
     or new.eve_session_id is distinct from old.eve_session_id
     or new.source_revision is distinct from old.source_revision then
    raise exception 'Factory episode identity is immutable';
  end if;
  if old.terminal_state is not null then
    raise exception 'Terminal factory episodes are immutable';
  end if;
  if new.terminal_state is not null and new.status not in ('completed', 'failed', 'cancelled') then
    raise exception 'Terminal factory episode status is inconsistent';
  end if;
  return new;
end;
$$;

drop trigger if exists protect_factory_episode_identity_and_terminal
  on public.factory_episode;
create trigger protect_factory_episode_identity_and_terminal
before update or delete on public.factory_episode
for each row execute procedure public.protect_factory_episode_identity_and_terminal();

comment on column public.factory_runtime_event.event_ordinal is
  'Episode-local total order allocated under a Postgres advisory lock.';
comment on column public.factory_runtime_event.retention_until is
  'Governed retention boundary; payload erasure requires a separately audited process.';
