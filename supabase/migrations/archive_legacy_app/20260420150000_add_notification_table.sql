-- Migration: notification table + owner-RLS for the M3 bell badge.
--
-- Append-only per-user notifications. Inserted by Server Actions (e.g.
-- follow → 'follow_created') and by background jobs later (M4+ assistant
-- actions, M5 course updates). The `kind` column is open-ended on
-- purpose so feature work can add new notification types without a
-- migration; the bell renders from `title` + `body` regardless of kind.
--
-- Row visibility is owner-only via RLS. Inserts from Server Actions go
-- through the user's own session, so the standard "with check (auth.uid()
-- = user_id)" policy covers both reads and writes. Background jobs use
-- the service-role client which bypasses RLS.
--
-- Realtime subscription is intentionally NOT wired up in v1 — the bell
-- re-fetches the unread count on route change, which is enough for M3.
-- Add a Supabase Realtime channel here if/when we want push-style
-- updates without a navigation event.

create table if not exists public.notification (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null,
  ref_kind text,
  ref_id text,
  title text not null,
  body text,
  url text,
  read_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  constraint notification_title_not_blank check (char_length(trim(title)) > 0)
);

create index if not exists notification_user_unread_idx
  on public.notification (user_id, created_at desc)
  where read_at is null;

create index if not exists notification_user_recent_idx
  on public.notification (user_id, created_at desc);

alter table public.notification enable row level security;

drop policy if exists "notification_owner_all" on public.notification;
create policy "notification_owner_all"
on public.notification
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

comment on table public.notification is
  'Per-user append-only notifications surfaced in the header bell. Inserted by Server Actions (follow_created, etc.) and background jobs. Owner-RLS; service role bypasses for system inserts.';
comment on column public.notification.kind is
  'Open-ended notification kind (e.g. follow_created, course_update). The bell renders title+body regardless; kind is for filtering / analytics.';
comment on column public.notification.ref_kind is
  'Optional polymorphic reference kind (matches lib/schema/entity-kind.ts).';
comment on column public.notification.url is
  'Optional click-through URL (relative path, e.g. /p/shreya).';
