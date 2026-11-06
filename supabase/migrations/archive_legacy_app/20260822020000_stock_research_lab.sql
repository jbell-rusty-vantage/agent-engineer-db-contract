-- Mission 001: source-grounded, paper-trading-only company research lab.
-- Writes are service-role only. Learners can read only their own runs; all
-- state transitions are performed by authenticated server actions which
-- derive user_id from the verified session.

create table if not exists public.research_lab_run (
  run_id              uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.profiles(id) on delete cascade,
  challenge_slug      text not null default 'source-grounded-stock-research-lab',
  ticker              text not null,
  as_of               timestamptz not null,
  status              text not null default 'queued',
  evidence_bundle     jsonb not null default '[]'::jsonb,
  recommendation      jsonb,
  idempotency_key     text not null,
  scheduled_for       timestamptz,
  decided_at          timestamptz,
  decided_by          uuid references public.profiles(id) on delete set null,
  decision            text,
  failure_reason      text,
  created_at          timestamptz not null default timezone('utc', now()),
  updated_at          timestamptz not null default timezone('utc', now()),
  constraint research_lab_run_ticker_check
    check (ticker ~ '^[A-Z][A-Z0-9.-]{0,9}$'),
  constraint research_lab_run_status_check
    check (status in ('queued', 'researching', 'awaiting_approval', 'approved', 'rejected', 'failed')),
  constraint research_lab_run_decision_check
    check (decision is null or decision in ('approved', 'rejected')),
  constraint research_lab_run_decision_state_check
    check (
      (status in ('approved', 'rejected') and decision = status and decided_at is not null and decided_by is not null)
      or
      (status not in ('approved', 'rejected') and decision is null and decided_at is null and decided_by is null)
    ),
  constraint research_lab_run_no_execution_payload_check
    check (
      recommendation is null
      or (
        coalesce(recommendation ->> 'mode', '') = 'paper_trade_only'
        and not (recommendation ?| array['broker', 'brokerage_token', 'order_id', 'execution_endpoint'])
      )
    ),
  unique (user_id, idempotency_key)
);

create index if not exists research_lab_run_user_created_idx
  on public.research_lab_run (user_id, created_at desc);
create index if not exists research_lab_run_schedule_idx
  on public.research_lab_run (scheduled_for)
  where status = 'queued' and scheduled_for is not null;

drop trigger if exists set_research_lab_run_updated_at on public.research_lab_run;
create trigger set_research_lab_run_updated_at
before update on public.research_lab_run
for each row execute procedure public.set_updated_at();

alter table public.research_lab_run enable row level security;

drop policy if exists "research_lab_run_select_own" on public.research_lab_run;
create policy "research_lab_run_select_own" on public.research_lab_run
  for select to authenticated
  using ((select auth.uid()) = user_id);

revoke insert, update, delete on public.research_lab_run from anon, authenticated;
grant select on public.research_lab_run to authenticated;
grant select, insert, update, delete on public.research_lab_run to service_role;

comment on table public.research_lab_run is
  'Auditable research-learning episodes. Recommendations are structurally limited to paper_trade_only and require an authenticated human decision.';
