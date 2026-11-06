-- Unit 01: Progress schema and RLS.
--
-- Adds course-scoped module completion while keeping standalone
-- module_completion as the global/standalone completion record.

-- ============================================================================
-- course_module_completion: per-user, per-course, per-module completion record
-- ============================================================================
create table if not exists public.course_module_completion (
  user_id            uuid not null references public.profiles(id) on delete cascade,
  course_id          uuid not null references public.course(course_id) on delete cascade,
  module_id          uuid not null references public.course_module(module_id) on delete cascade,
  course_version     text not null,
  module_version     text not null,
  completed_at       timestamptz not null default timezone('utc', now()),
  attempts           int not null default 1,
  quiz_responses     jsonb not null default '{}'::jsonb,
  quiz_score         numeric,
  time_spent_seconds int,
  metadata           jsonb not null default '{}'::jsonb,
  primary key (user_id, course_id, module_id)
);

create index if not exists course_module_completion_user_course_idx
  on public.course_module_completion (user_id, course_id);
create index if not exists course_module_completion_course_module_idx
  on public.course_module_completion (course_id, module_id);
create index if not exists course_module_completion_user_completed_idx
  on public.course_module_completion (user_id, completed_at desc);

alter table public.course_module_completion enable row level security;

-- FOR ALL covers SELECT for authenticated users; keep one owner policy to avoid
-- multiple permissive policies for the same role/action.
drop policy if exists "course_module_completion_modify_own" on public.course_module_completion;
create policy "course_module_completion_modify_own" on public.course_module_completion
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

comment on table public.course_module_completion is
  'Per-user, per-course, per-module completion record. Course-scoped progress source of truth; course_enrollment.progress is a cache. Owner-RLS.';
comment on column public.course_module_completion.course_version is
  'Copied course.version at completion time for audit/debug readability.';
comment on column public.course_module_completion.module_version is
  'Copied course_module.version at completion time for audit/debug readability.';

-- ============================================================================
-- module_completion: standalone/global completion version audit
-- ============================================================================
alter table public.module_completion
  add column if not exists module_version text;

update public.module_completion mc
   set module_version = cm.version
  from public.course_module cm
 where mc.module_id = cm.module_id
   and mc.module_version is null;

comment on column public.module_completion.module_version is
  'Copied course_module.version at standalone completion time. Nullable until all write paths supply it; a later unit can enforce NOT NULL.';
