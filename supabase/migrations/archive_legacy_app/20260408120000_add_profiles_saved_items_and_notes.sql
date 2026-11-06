create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  avatar_url text,
  bio text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.saved_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  entity_type text not null,
  entity_id text not null,
  entity_title text not null,
  entity_subtitle text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint saved_items_entity_type_check
    check (entity_type in ('person', 'organization', 'session', 'youtube_video')),
  constraint saved_items_user_entity_unique unique (user_id, entity_type, entity_id)
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  content_json jsonb not null default '{"type":"doc","content":[]}'::jsonb,
  content_text text not null default '',
  entity_type text,
  entity_id text,
  entity_title text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint notes_title_not_blank check (char_length(trim(title)) > 0),
  constraint notes_entity_type_check
    check (
      entity_type is null
      or entity_type in ('person', 'organization', 'session', 'youtube_video')
    ),
  constraint notes_entity_reference_check
    check (
      (entity_type is null and entity_id is null)
      or (entity_type is not null and entity_id is not null)
    )
);

create index if not exists saved_items_user_id_idx on public.saved_items(user_id, created_at desc);
create index if not exists saved_items_entity_lookup_idx on public.saved_items(entity_type, entity_id);
create index if not exists notes_user_id_idx on public.notes(user_id, updated_at desc);
create index if not exists notes_entity_lookup_idx
  on public.notes(user_id, entity_type, entity_id)
  where entity_type is not null and entity_id is not null;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row
execute procedure public.set_updated_at();

drop trigger if exists set_notes_updated_at on public.notes;
create trigger set_notes_updated_at
before update on public.notes
for each row
execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.saved_items enable row level security;
alter table public.notes enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using ((select auth.uid()) = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "saved_items_manage_own" on public.saved_items;
create policy "saved_items_manage_own"
on public.saved_items
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "notes_manage_own" on public.notes;
create policy "notes_manage_own"
on public.notes
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

insert into public.profiles (id, email, display_name)
select
  users.id,
  users.email,
  coalesce(users.raw_user_meta_data ->> 'full_name', split_part(users.email, '@', 1))
from auth.users as users
on conflict (id) do update
set
  email = excluded.email,
  display_name = coalesce(public.profiles.display_name, excluded.display_name);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, display_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update
  set
    email = excluded.email,
    avatar_url = coalesce(public.profiles.avatar_url, excluded.avatar_url);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();
