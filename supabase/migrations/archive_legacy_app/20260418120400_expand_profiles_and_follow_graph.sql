-- Migration 5: expand `profiles` for course recommendations + analytics, add a
-- generic `profile_followed_entity` follow graph (people / orgs / libraries /
-- products / events / papers / news_items / categories / domain_layers), and
-- widen the saved_items + notes entity_type whitelists to cover the new
-- entity kinds (incl. news_item from Migration 6).

alter table public.profiles
  add column if not exists username text unique,
  add column if not exists headline text,
  add column if not exists location text,
  add column if not exists country text,
  add column if not exists timezone text,
  add column if not exists current_role_title text,
  add column if not exists current_org_id text references public.organization(organization_id) on delete set null,
  add column if not exists experience_level text,
  add column if not exists expertise_tags text[] not null default '{}',
  add column if not exists interest_tags text[] not null default '{}',
  add column if not exists goals text[] not null default '{}',
  add column if not exists linked_accounts jsonb not null default '{}'::jsonb,
  add column if not exists home_layer text,
  add column if not exists onboarding_status text not null default 'pending',
  add column if not exists is_public boolean not null default false,
  add column if not exists xp_total int not null default 0,
  add column if not exists metadata jsonb not null default '{}'::jsonb;

alter table public.profiles drop constraint if exists profiles_experience_level_check;
alter table public.profiles add constraint profiles_experience_level_check
  check (experience_level is null or experience_level in ('junior','mid','senior','staff','principal','founder','exec','student','researcher'));

alter table public.profiles drop constraint if exists profiles_onboarding_status_check;
alter table public.profiles add constraint profiles_onboarding_status_check
  check (onboarding_status in ('pending','in_progress','complete','skipped'));

alter table public.profiles drop constraint if exists profiles_username_format_check;
alter table public.profiles add constraint profiles_username_format_check
  check (username is null or username ~ '^[a-z0-9][a-z0-9_-]{2,38}$');

create index if not exists profiles_username_idx on public.profiles (username) where username is not null;
create index if not exists profiles_expertise_gin on public.profiles using gin (expertise_tags);
create index if not exists profiles_interests_gin on public.profiles using gin (interest_tags);
create index if not exists profiles_goals_gin on public.profiles using gin (goals);
create index if not exists profiles_metadata_gin on public.profiles using gin (metadata jsonb_path_ops);
create index if not exists profiles_country_idx on public.profiles (country);
create index if not exists profiles_current_org_idx on public.profiles (current_org_id);
create index if not exists profiles_xp_idx on public.profiles (xp_total desc);

-- Allow public reads of opted-in (is_public = true) profiles, in addition to
-- the existing owner-only policies.
drop policy if exists "profiles_select_public" on public.profiles;
create policy "profiles_select_public"
on public.profiles
for select
to anon, authenticated
using (is_public = true);

-- ============================================================================
-- profile_followed_entity (generic follow graph)
-- ============================================================================
create table if not exists public.profile_followed_entity (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  entity_kind  text not null,
  entity_id    text not null,
  created_at   timestamptz not null default timezone('utc', now()),
  primary key (user_id, entity_kind, entity_id),
  constraint profile_followed_entity_kind_check check (
    entity_kind in (
      'person','organization','session','youtube_video',
      'library','product','event','paper','report','news_item',
      'repo','category','domain_layer'
    )
  )
);
create index if not exists profile_followed_entity_lookup
  on public.profile_followed_entity (entity_kind, entity_id);
create index if not exists profile_followed_entity_user_idx
  on public.profile_followed_entity (user_id, created_at desc);

alter table public.profile_followed_entity enable row level security;
drop policy if exists "profile_followed_entity_manage_own" on public.profile_followed_entity;
create policy "profile_followed_entity_manage_own"
on public.profile_followed_entity
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

-- ============================================================================
-- Widen saved_items + notes entity_type whitelists.
-- ============================================================================
alter table public.saved_items drop constraint if exists saved_items_entity_type_check;
alter table public.saved_items add constraint saved_items_entity_type_check
  check (entity_type in (
    'person','organization','session','youtube_video',
    'library','product','event','paper','report','news_item','repo'
  ));

alter table public.notes drop constraint if exists notes_entity_type_check;
alter table public.notes add constraint notes_entity_type_check
  check (
    entity_type is null
    or entity_type in (
      'person','organization','session','youtube_video',
      'library','product','event','paper','report','news_item','repo'
    )
  );

comment on table public.profile_followed_entity is 'Generic follow graph: users can follow any entity kind (people, orgs, libraries, products, events, papers, news_items, categories, domain_layers). Powers personalized feeds.';
comment on column public.profiles.linked_accounts is 'Optional JSON like {"github":"foo","x":"@bar","linkedin":"...","huggingface":"..."}.';
comment on column public.profiles.is_public is 'When true, profile is readable by anyone; when false (default) only owner can read it.';
comment on column public.profiles.xp_total is 'Lifetime XP for gamification (course completions + challenge attempts + module quizzes).';
