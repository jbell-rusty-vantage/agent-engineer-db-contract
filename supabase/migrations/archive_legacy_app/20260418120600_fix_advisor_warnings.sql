-- Migration 7 (housekeeping): fix advisor warnings introduced/exposed by the
-- previous 6 migrations.
--
-- 1. RLS initplan: wrap auth.role() in (select auth.role()) on report +
--    news_item so the function is evaluated once per query, not per row.
-- 2. Combine the two profiles SELECT policies into a single one (owner OR
--    public) to silence the multiple_permissive_policies warning.
-- 3. Add covering indexes for the 8 pre-existing unindexed foreign keys.

-- 1. Fix auth_rls_initplan on report
drop policy if exists "report_public_read" on public.report;
create policy "report_public_read" on public.report
  for select
  using (status = 'published' or (select auth.role()) = 'service_role');

-- 1. Fix auth_rls_initplan on news_item
drop policy if exists "news_item_public_read" on public.news_item;
create policy "news_item_public_read" on public.news_item
  for select
  using (status = 'published' or (select auth.role()) = 'service_role');

-- 2. Collapse the two SELECT policies on profiles into one.
drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_select_public" on public.profiles;
create policy "profiles_select_own_or_public"
on public.profiles
for select
to anon, authenticated
using (
  is_public = true
  or (select auth.uid()) = id
);

-- 3. Cover the 8 unindexed FKs (all pre-existing pre-our-work).
create index if not exists organization_has_ceo_person_id_idx
  on public.organization_has_ceo (person_id);
create index if not exists paper_authored_by_affiliation_org_idx
  on public.paper_authored_by (affiliation_org);
create index if not exists person_appeared_in_video_video_id_idx
  on public.person_appeared_in_video (video_id);
create index if not exists person_employed_by_organization_id_idx
  on public.person_employed_by (organization_id);
create index if not exists person_founded_organization_organization_id_idx
  on public.person_founded_organization (organization_id);
create index if not exists person_presented_at_session_session_id_idx
  on public.person_presented_at_session (session_id);
create index if not exists session_recorded_as_video_video_id_idx
  on public.session_recorded_as_video (video_id);
create index if not exists youtube_video_channel_id_idx
  on public.youtube_video (channel_id);
