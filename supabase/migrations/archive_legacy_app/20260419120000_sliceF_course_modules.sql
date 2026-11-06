-- Migration 12 (Slice F): Course modules — atomic, versioned learning units.
--
-- Source of truth lives in the vault under
-- aiwiki/.../06_courses/<bucket>/<slug>/module.md ; this table is a projection
-- for app-side lookup, search, ordering, and progress tracking.
--
-- Adds:
--   course_module           — the module itself, (slug, version) unique
--   module_uses_artifact    — link to corpus artifact, optional chunk-level pin
--   course_module_requires  — FK-clean prerequisite graph
--   course_module_review    — append-only review audit trail
--   module_completion       — per-user quiz attempts + time-on-task
--
-- See aiwiki/docs/08-data-model.md "Course / challenge schema decisions
-- (locked 2026-04-19)" for the rationale behind each column.

-- ============================================================================
-- course_module
-- ============================================================================
create table if not exists public.course_module (
  module_id            uuid primary key default gen_random_uuid(),
  slug                 text not null,
  version              text not null default '0.1.0',
  title                text not null,
  body_md              text not null,
  body_kind            text,
  duration_min         int,
  difficulty           text,
  status               text not null default 'draft',
  is_latest_published  boolean not null default false,
  domain_buckets       text[] not null default '{}',
  learning_objectives  jsonb not null default '[]'::jsonb,
  mini_quiz            jsonb not null default '[]'::jsonb,
  authors              jsonb not null default '[]'::jsonb,
  source_path          text,
  content_hash         text,
  search_text          text,
  embedding            extensions.vector(1536),
  metadata             jsonb not null default '{}'::jsonb,
  fts                  tsvector generated always as (
                          setweight(to_tsvector('english', coalesce(title, '')), 'A')
                          || setweight(to_tsvector('english', coalesce(search_text, '')), 'B')
                          || setweight(to_tsvector('english', coalesce(body_md, '')), 'C')
                        ) stored,
  created_at           timestamptz not null default timezone('utc', now()),
  updated_at           timestamptz not null default timezone('utc', now()),
  unique (slug, version),
  constraint course_module_status_check check (
    status in ('draft', 'review', 'published', 'deprecated')
  ),
  constraint course_module_body_kind_check check (
    body_kind is null
    or body_kind in ('concept', 'walkthrough', 'reading', 'demo', 'challenge_set')
  ),
  constraint course_module_difficulty_check check (
    difficulty is null
    or difficulty in ('beginner', 'intermediate', 'advanced')
  )
);

create unique index if not exists course_module_slug_latest_uniq
  on public.course_module (slug)
  where is_latest_published;
create index if not exists course_module_slug_idx        on public.course_module (slug);
create index if not exists course_module_status_idx      on public.course_module (status);
create index if not exists course_module_buckets_gin     on public.course_module using gin (domain_buckets);
create index if not exists course_module_metadata_gin    on public.course_module using gin (metadata jsonb_path_ops);
create index if not exists course_module_fts_gin         on public.course_module using gin (fts);
create index if not exists course_module_embedding_hnsw  on public.course_module
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;

drop trigger if exists set_course_module_updated_at on public.course_module;
create trigger set_course_module_updated_at
before update on public.course_module
for each row execute procedure public.set_updated_at();

-- BEFORE trigger: when a row is set as is_latest_published, demote prior
-- latest for the same slug in the same transaction so the partial unique
-- index is always satisfied at statement end.
create or replace function public.maintain_course_module_latest()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.course_module
     set is_latest_published = false
   where slug = new.slug
     and module_id <> new.module_id
     and is_latest_published = true;
  return new;
end;
$$;

drop trigger if exists course_module_maintain_latest on public.course_module;
create trigger course_module_maintain_latest
before insert or update of is_latest_published, status on public.course_module
for each row when (new.is_latest_published is true)
execute procedure public.maintain_course_module_latest();

alter table public.course_module enable row level security;
drop policy if exists "course_module_public_read" on public.course_module;
create policy "course_module_public_read" on public.course_module
  for select
  using (status = 'published' or (select auth.role()) = 'service_role');

comment on table public.course_module is
  'Atomic, versioned learning unit (10–30 min). Source of truth lives in aiwiki Markdown under 06_courses/<bucket>/<slug>/; this table is a projection for the app. (slug, version) unique; is_latest_published + the partial unique index resolves "current version of slug" without a window function.';
comment on column public.course_module.is_latest_published is
  'Maintained-by-trigger flag: true on at most one row per slug. Importer flips this on publish; the BEFORE trigger demotes prior latest in the same transaction.';
comment on column public.course_module.body_kind is
  'concept | walkthrough | reading | demo | challenge_set — per 06-courses-and-components.md.';
comment on column public.course_module.source_path is
  'Path to the Markdown source in the vault (e.g. aiwiki/.../06_courses/evaluations/eval-gepa-basics/module.md). Used for round-trip auditing.';
comment on column public.course_module.content_hash is
  'sha256 of canonical body_md. Lets us detect drift between vault and DB and trigger re-review.';
comment on column public.course_module.metadata is
  'Open-ended JSONB pocket for tags (library_slugs, org_slugs, topic_tags, …). Filterable via @> and indexed via GIN(jsonb_path_ops) — same pattern as every other entity table.';

-- ============================================================================
-- module_uses_artifact: module → corpus artifact, optionally pinned to a chunk
-- ============================================================================
create table if not exists public.module_uses_artifact (
  module_id     uuid not null references public.course_module(module_id) on delete cascade,
  artifact_kind text not null,
  artifact_id   text not null,
  chunk_id      uuid references public.chunk(chunk_id) on delete set null,
  role          text,
  ord           int not null default 0,
  created_at    timestamptz not null default timezone('utc', now()),
  primary key (module_id, artifact_kind, artifact_id),
  constraint module_uses_artifact_kind_check check (
    artifact_kind in (
      'video', 'session', 'dossier', 'repo', 'library', 'product',
      'paper', 'slide', 'report', 'news_item', 'chunk'
    )
  ),
  constraint module_uses_artifact_role_check check (
    role is null
    or role in ('primary', 'reference', 'supporting', 'example')
  )
);

create index if not exists module_uses_artifact_kind_id_idx
  on public.module_uses_artifact (artifact_kind, artifact_id);
create index if not exists module_uses_artifact_chunk_idx
  on public.module_uses_artifact (chunk_id) where chunk_id is not null;

alter table public.module_uses_artifact enable row level security;
drop policy if exists "module_uses_artifact_public_read" on public.module_uses_artifact;
create policy "module_uses_artifact_public_read" on public.module_uses_artifact
  for select using (true);

comment on table public.module_uses_artifact is
  'Modules cite corpus artifacts. artifact_kind is CHECK-enumerated; chunk_id optionally pins citation to a specific chunk (timestamp range / paper section). Polymorphic FK shape (artifact_kind, artifact_id) matches public.chunk.';

-- ============================================================================
-- course_module_requires: FK-clean prerequisite graph
-- ============================================================================
create table if not exists public.course_module_requires (
  module_id        uuid not null references public.course_module(module_id) on delete cascade,
  prereq_module_id uuid not null references public.course_module(module_id) on delete restrict,
  created_at       timestamptz not null default timezone('utc', now()),
  primary key (module_id, prereq_module_id),
  constraint course_module_requires_no_self_loop check (module_id <> prereq_module_id)
);

create index if not exists course_module_requires_prereq_idx
  on public.course_module_requires (prereq_module_id);

alter table public.course_module_requires enable row level security;
drop policy if exists "course_module_requires_public_read" on public.course_module_requires;
create policy "course_module_requires_public_read" on public.course_module_requires
  for select using (true);

comment on table public.course_module_requires is
  'FK-clean prerequisite graph. Replaces a loose `prerequisites text[]` so renames/deletes can never silently break a module. prereq uses on delete restrict so you cannot delete a depended-on module.';

-- ============================================================================
-- course_module_review: append-only review audit trail
-- ============================================================================
create table if not exists public.course_module_review (
  review_id    uuid primary key default gen_random_uuid(),
  module_id    uuid not null references public.course_module(module_id) on delete cascade,
  version      text not null,
  reviewer_id  uuid references public.profiles(id) on delete set null,
  decision     text not null,
  notes_md     text,
  created_at   timestamptz not null default timezone('utc', now()),
  constraint course_module_review_decision_check check (
    decision in ('approve', 'request_changes', 'reject', 'withdraw')
  )
);

create index if not exists course_module_review_module_idx
  on public.course_module_review (module_id, created_at desc);
create index if not exists course_module_review_reviewer_idx
  on public.course_module_review (reviewer_id) where reviewer_id is not null;

alter table public.course_module_review enable row level security;
drop policy if exists "course_module_review_public_read" on public.course_module_review;
create policy "course_module_review_public_read" on public.course_module_review
  for select using (true);

drop policy if exists "course_module_review_authenticated_insert" on public.course_module_review;
create policy "course_module_review_authenticated_insert" on public.course_module_review
  for insert
  to authenticated
  with check ((select auth.uid()) = reviewer_id);

comment on table public.course_module_review is
  'Append-only review audit. Every status transition (draft → review → published) records who decided, when, and why. Public-read so the review history is part of the quality signal.';

-- ============================================================================
-- module_completion: per-user, per-module quiz record
-- ============================================================================
create table if not exists public.module_completion (
  user_id            uuid not null references public.profiles(id) on delete cascade,
  module_id          uuid not null references public.course_module(module_id) on delete cascade,
  completed_at       timestamptz not null default timezone('utc', now()),
  quiz_score         numeric,
  quiz_responses     jsonb not null default '[]'::jsonb,
  time_spent_seconds int,
  attempts           int not null default 1,
  primary key (user_id, module_id)
);

create index if not exists module_completion_module_idx
  on public.module_completion (module_id);
create index if not exists module_completion_user_idx
  on public.module_completion (user_id, completed_at desc);

alter table public.module_completion enable row level security;
-- FOR ALL covers SELECT for authenticated; no separate select policy needed
-- (otherwise the advisor flags multiple_permissive_policies).
drop policy if exists "module_completion_modify_own" on public.module_completion;
create policy "module_completion_modify_own" on public.module_completion
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

comment on table public.module_completion is
  'Per-user, per-module completion record. quiz_responses stores the raw [{q_id, chosen, correct, time_ms}] array for item-level analysis; time_spent_seconds calibrates duration_min estimates against reality. Owner-RLS.';
