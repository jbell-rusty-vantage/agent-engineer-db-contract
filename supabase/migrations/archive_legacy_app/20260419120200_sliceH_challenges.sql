-- Migration 14 (Slice H): Challenges + scoring spine.
--
-- Challenges are runtime-stateful learning artifacts (sandboxed code, hidden
-- tests, rubric-based judging). They reference course / module loosely; their
-- own table because of the runtime state (attempts, scores).
--
-- Adds:
--   challenge    — the challenge spec (CHECK runtime, judge_prompt + version)
--   attempt      — one per submission, scoring_config jsonb for reproducibility
--   score_event  — append-only XP ledger, unique on (user, kind, ref) to
--                  prevent double-awarding on replays.
--
-- Also closes the deferred FK from course.capstone_challenge_id to
-- challenge(challenge_id) now that the table exists.
--
-- See aiwiki/docs/08-data-model.md "Course / challenge schema decisions
-- (locked 2026-04-19)" for rationale.

-- ============================================================================
-- challenge
-- ============================================================================
create table if not exists public.challenge (
  challenge_id          uuid primary key default gen_random_uuid(),
  slug                  text not null unique,
  course_id             uuid references public.course(course_id) on delete set null,
  module_id             uuid references public.course_module(module_id) on delete set null,
  title                 text not null,
  task_md               text not null,
  rubric_md             text not null,
  runtime               text not null,
  deps_json             jsonb not null default '{}'::jsonb,
  starter_code          text,
  tests_blob            text,
  judge_model           text,
  judge_prompt_md       text,
  judge_rubric_version  text,
  est_minutes           int,
  status                text not null default 'draft',
  metadata              jsonb not null default '{}'::jsonb,
  created_at            timestamptz not null default timezone('utc', now()),
  updated_at            timestamptz not null default timezone('utc', now()),
  constraint challenge_runtime_check check (runtime in ('python', 'node', 'bash')),
  constraint challenge_status_check  check (status  in ('draft', 'review', 'published', 'deprecated'))
);

create index if not exists challenge_course_idx   on public.challenge (course_id) where course_id is not null;
create index if not exists challenge_module_idx   on public.challenge (module_id) where module_id is not null;
create index if not exists challenge_status_idx   on public.challenge (status);
create index if not exists challenge_metadata_gin on public.challenge using gin (metadata jsonb_path_ops);

drop trigger if exists set_challenge_updated_at on public.challenge;
create trigger set_challenge_updated_at
before update on public.challenge
for each row execute procedure public.set_updated_at();

alter table public.challenge enable row level security;
drop policy if exists "challenge_public_read" on public.challenge;
create policy "challenge_public_read" on public.challenge
  for select
  using (status = 'published' or (select auth.role()) = 'service_role');

comment on table public.challenge is
  'Runtime-stateful learning artifact (sandbox + tests + rubric judge). Optional FKs to course/module so a challenge can stand alone or anchor a course capstone.';
comment on column public.challenge.judge_prompt_md is
  'Versioned judge prompt. Pairs with judge_rubric_version so an attempt can be re-scored with the exact prompt + rubric originally used.';

-- Now that challenge exists, close the deferred FK from
-- course.capstone_challenge_id to challenge(challenge_id).
alter table public.course
  drop constraint if exists course_capstone_challenge_id_fkey;
alter table public.course
  add constraint course_capstone_challenge_id_fkey
  foreign key (capstone_challenge_id)
  references public.challenge(challenge_id)
  on delete set null;

-- ============================================================================
-- attempt
-- ============================================================================
create table if not exists public.attempt (
  attempt_id         uuid primary key default gen_random_uuid(),
  user_id            uuid not null references public.profiles(id) on delete cascade,
  challenge_id       uuid not null references public.challenge(challenge_id) on delete cascade,
  started_at         timestamptz not null default timezone('utc', now()),
  finished_at        timestamptz,
  code_blob          text,
  tests_pass         int,
  tests_total        int,
  judge_score        numeric,
  judge_feedback     text,
  composite_score    numeric,
  scoring_config     jsonb not null default '{}'::jsonb,
  sandbox_provider   text,
  sandbox_session_id text,
  created_at         timestamptz not null default timezone('utc', now())
);

create index if not exists attempt_user_idx
  on public.attempt (user_id, started_at desc);
create index if not exists attempt_challenge_idx
  on public.attempt (challenge_id, composite_score desc nulls last);
create index if not exists attempt_finished_idx
  on public.attempt (challenge_id, finished_at desc) where finished_at is not null;

alter table public.attempt enable row level security;
-- FOR ALL covers SELECT for authenticated; no separate select policy needed
-- (otherwise the advisor flags multiple_permissive_policies).
drop policy if exists "attempt_modify_own" on public.attempt;
create policy "attempt_modify_own" on public.attempt
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

comment on table public.attempt is
  'One per submission. composite_score is denormalized cache; scoring_config jsonb stores the weight set used so we can rederive when weights change. sandbox_provider + sandbox_session_id correlate with e2b/etc. session logs.';

-- ============================================================================
-- score_event
-- ============================================================================
create table if not exists public.score_event (
  score_event_id  uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  kind            text not null,
  points          int  not null default 0,
  ref_kind        text,
  ref_id          uuid,
  source_attempt  uuid references public.attempt(attempt_id) on delete set null,
  metadata        jsonb not null default '{}'::jsonb,
  created_at      timestamptz not null default timezone('utc', now()),
  constraint score_event_kind_check check (
    kind in ('module-quiz', 'course-completion', 'challenge-attempt', 'manual-grant')
  ),
  constraint score_event_ref_kind_check check (
    ref_kind is null
    or ref_kind in ('module', 'course', 'challenge', 'attempt')
  )
);

-- Prevent double-awarding XP for the same (user, kind, ref): one ledger row
-- per (kind, ref). Replays should UPSERT, not INSERT.
create unique index if not exists score_event_dedup_uniq
  on public.score_event (user_id, kind, ref_kind, ref_id)
  where ref_kind is not null and ref_id is not null;

create index if not exists score_event_user_idx
  on public.score_event (user_id, created_at desc);
create index if not exists score_event_kind_idx        on public.score_event (kind);
create index if not exists score_event_source_attempt_idx
  on public.score_event (source_attempt) where source_attempt is not null;

alter table public.score_event enable row level security;
drop policy if exists "score_event_select_own" on public.score_event;
create policy "score_event_select_own" on public.score_event
  for select to authenticated using ((select auth.uid()) = user_id);

comment on table public.score_event is
  'Append-only XP ledger across module quizzes / course completions / challenge attempts. Unique on (user_id, kind, ref_kind, ref_id) prevents double-awarding when a user replays a quiz or re-attempts a challenge — the importer should UPSERT, not INSERT. Read owner-RLS; writes go through service_role.';
