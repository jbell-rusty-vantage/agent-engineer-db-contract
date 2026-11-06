-- Migration 13 (Slice G): Domain courses — opinionated paths through several
-- course-modules that cover a full bucket end-to-end + capstone challenge.
--
-- course.capstone_challenge_id is created without an FK here; the FK to
-- public.challenge is added in Slice H once the challenge table exists.
--
-- Adds:
--   course                   — the course itself, (slug, version) unique
--   course_module_in_course  — ordered membership, unique(course_id, ord)
--   course_enrollment        — per-user enrollment + free-form progress jsonb
--
-- See aiwiki/docs/08-data-model.md "Course / challenge schema decisions
-- (locked 2026-04-19)" for the rationale.

-- ============================================================================
-- course
-- ============================================================================
create table if not exists public.course (
  course_id              uuid primary key default gen_random_uuid(),
  slug                   text not null,
  version                text not null default '0.1.0',
  title                  text not null,
  domain_bucket          text not null,
  domain_layer           text,
  summary                text,
  narrative_md           text,
  est_hours              numeric,
  status                 text not null default 'draft',
  is_latest_published    boolean not null default false,
  capstone_challenge_id  uuid,
  authors                jsonb not null default '[]'::jsonb,
  search_text            text,
  embedding              extensions.vector(1536),
  metadata               jsonb not null default '{}'::jsonb,
  fts                    tsvector generated always as (
                            setweight(to_tsvector('english', coalesce(title, '')), 'A')
                            || setweight(to_tsvector('english', coalesce(summary, '')), 'B')
                            || setweight(to_tsvector('english', coalesce(narrative_md, '')), 'C')
                          ) stored,
  created_at             timestamptz not null default timezone('utc', now()),
  updated_at             timestamptz not null default timezone('utc', now()),
  unique (slug, version),
  constraint course_status_check check (
    status in ('draft', 'review', 'published', 'deprecated')
  )
);

create unique index if not exists course_slug_latest_uniq
  on public.course (slug)
  where is_latest_published;
create index if not exists course_slug_idx          on public.course (slug);
create index if not exists course_status_idx        on public.course (status);
create index if not exists course_bucket_idx        on public.course (domain_bucket);
create index if not exists course_layer_idx         on public.course (domain_layer) where domain_layer is not null;
create index if not exists course_metadata_gin      on public.course using gin (metadata jsonb_path_ops);
create index if not exists course_fts_gin           on public.course using gin (fts);
create index if not exists course_embedding_hnsw    on public.course
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
create index if not exists course_capstone_idx      on public.course (capstone_challenge_id) where capstone_challenge_id is not null;

drop trigger if exists set_course_updated_at on public.course;
create trigger set_course_updated_at
before update on public.course
for each row execute procedure public.set_updated_at();

create or replace function public.maintain_course_latest()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.course
     set is_latest_published = false
   where slug = new.slug
     and course_id <> new.course_id
     and is_latest_published = true;
  return new;
end;
$$;

drop trigger if exists course_maintain_latest on public.course;
create trigger course_maintain_latest
before insert or update of is_latest_published, status on public.course
for each row when (new.is_latest_published is true)
execute procedure public.maintain_course_latest();

alter table public.course enable row level security;
drop policy if exists "course_public_read" on public.course;
create policy "course_public_read" on public.course
  for select
  using (status = 'published' or (select auth.role()) = 'service_role');

comment on table public.course is
  'Domain course: ordered path through several course_modules with a capstone challenge. (slug, version) unique; is_latest_published trigger-maintained for "current version" lookups. capstone_challenge_id FK is added in the Slice H migration once challenge exists.';
comment on column public.course.is_latest_published is
  'Maintained-by-trigger flag: true on at most one row per slug. Same pattern as course_module.is_latest_published.';

-- ============================================================================
-- course_module_in_course
-- ============================================================================
create table if not exists public.course_module_in_course (
  course_id      uuid not null references public.course(course_id) on delete cascade,
  module_id      uuid not null references public.course_module(module_id) on delete restrict,
  ord            int  not null,
  role           text,
  pinned_version text,
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (course_id, module_id),
  constraint course_module_in_course_role_check check (
    role is null
    or role in ('intro', 'core', 'optional', 'capstone-prep', 'capstone')
  ),
  constraint course_module_in_course_ord_nonneg check (ord >= 0)
);

create unique index if not exists course_module_in_course_ord_uniq
  on public.course_module_in_course (course_id, ord);
create index if not exists course_module_in_course_module_idx
  on public.course_module_in_course (module_id);

alter table public.course_module_in_course enable row level security;
drop policy if exists "course_module_in_course_public_read" on public.course_module_in_course;
create policy "course_module_in_course_public_read" on public.course_module_in_course
  for select using (true);

comment on table public.course_module_in_course is
  'Ordered membership of modules in a course. unique(course_id, ord) prevents duplicate slot. pinned_version optionally locks to a specific module version (NULL = follow course_module.is_latest_published). on delete restrict on module_id so removing a module that is in use fails loudly.';

-- ============================================================================
-- course_enrollment
-- ============================================================================
create table if not exists public.course_enrollment (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  course_id    uuid not null references public.course(course_id) on delete cascade,
  started_at   timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  progress     jsonb not null default '{}'::jsonb,
  primary key (user_id, course_id)
);

create index if not exists course_enrollment_course_idx
  on public.course_enrollment (course_id);
create index if not exists course_enrollment_user_idx
  on public.course_enrollment (user_id, started_at desc);

alter table public.course_enrollment enable row level security;
-- FOR ALL covers SELECT for authenticated; no separate select policy needed
-- (otherwise the advisor flags multiple_permissive_policies).
drop policy if exists "course_enrollment_modify_own" on public.course_enrollment;
create policy "course_enrollment_modify_own" on public.course_enrollment
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

comment on table public.course_enrollment is
  'Per-user enrollment + free-form progress jsonb. Owner-RLS: only the enrolled user can read or write their row.';
