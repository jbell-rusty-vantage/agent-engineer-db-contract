-- U0.6 — profiles.is_admin column + admin RLS for the publish-flow tables.
--
-- Resolves Q10: a single admin (you) gates publish/review actions while every
-- script keeps using SUPABASE_SERVICE_ROLE_KEY (which bypasses RLS by design).
-- Helper `assertAdmin()` lives in `lib/auth/roles.ts` (Server Action layer).

alter table public.profiles
  add column if not exists is_admin boolean not null default false;

comment on column public.profiles.is_admin is
  'Single-bit admin flag. Gates curator/publish actions on course / course_module / challenge / course_module_review. Set manually via SQL.';

create index if not exists profiles_is_admin_idx
  on public.profiles (id)
  where is_admin = true;

-- ============================================================================
-- Admin write RLS for publish-flow tables.
--
-- Reads stay open via the existing `*_public_read` policies. Writes from
-- the anon / authenticated roles are *only* allowed when the caller has
-- profiles.is_admin = true. service_role still bypasses RLS, so the
-- upsert-* scripts in aiengineerapp/scripts/ keep working unchanged.
-- ============================================================================

-- course
drop policy if exists "course_admin_write" on public.course;
create policy "course_admin_write"
on public.course
for all
to authenticated
using (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
)
with check (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
);

-- course_module
drop policy if exists "course_module_admin_write" on public.course_module;
create policy "course_module_admin_write"
on public.course_module
for all
to authenticated
using (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
)
with check (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
);

-- challenge
drop policy if exists "challenge_admin_write" on public.challenge;
create policy "challenge_admin_write"
on public.challenge
for all
to authenticated
using (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
)
with check (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
);

-- course_module_review — replace the over-broad authenticated insert
-- with an admin-only equivalent (curators only).
drop policy if exists "course_module_review_authenticated_insert" on public.course_module_review;
drop policy if exists "course_module_review_admin_write" on public.course_module_review;
create policy "course_module_review_admin_write"
on public.course_module_review
for all
to authenticated
using (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
)
with check (
  exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and is_admin = true
  )
);

-- One-shot grant for the project owner. Uncomment + replace email and run
-- once via psql or the SQL editor. Left commented so re-running this
-- migration is a true no-op.
-- update public.profiles set is_admin = true where email = 'owner@example.com';
