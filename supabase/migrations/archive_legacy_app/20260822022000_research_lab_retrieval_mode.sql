alter table public.research_lab_run
  add column if not exists retrieval_mode text not null default 'live',
  add column if not exists retrieval_diagnostics jsonb not null default '{}'::jsonb;

alter table public.research_lab_run
  drop constraint if exists research_lab_run_retrieval_mode_check;

alter table public.research_lab_run
  add constraint research_lab_run_retrieval_mode_check
  check (retrieval_mode in ('live', 'fixture'));

comment on column public.research_lab_run.retrieval_mode is
  'Selects live provider retrieval or the deterministic verifier fixture.';

comment on column public.research_lab_run.retrieval_diagnostics is
  'Auditable counts and timestamps from the retrieval adapter; never stores provider credentials.';
