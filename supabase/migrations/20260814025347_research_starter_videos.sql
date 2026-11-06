-- Starter catalog for the new research schema.
-- Separate from public.youtube_video so we can ingest the raw AI Engineer
-- channel dump and iterate on relationship tables later.

-- Fresh-replay compatibility. These objects existed before this migration on
-- the original project. Keeping them inside an already-recorded migration
-- makes local resets reproducible without creating a new migration that a
-- production db push could mistake for pending work.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.challenge (
  challenge_id uuid primary key
);

create table if not exists public.attempt (
  attempt_id uuid primary key
);

create table if not exists public.research_starter_videos (
  video_id text primary key,
  title text not null,
  description text,
  published_at timestamptz,
  channel_id text,
  channel_handle text,
  channel_title text,
  duration text,
  duration_seconds integer,
  view_count bigint,
  like_count bigint,
  comment_count bigint,
  thumbnail_url text,
  url text,
  source text,
  catalog_fetched_at timestamptz,
  transcript_status text not null default 'none',
  transcript_bucket text,
  transcript_path text,
  transcript_language text,
  transcript_char_count integer,
  transcript_error text,
  transcript_fetched_at timestamptz,
  transcript_text text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint research_starter_videos_transcript_status_check
    check (transcript_status in ('none', 'pending', 'stored', 'missing', 'error'))
);

create index if not exists research_starter_videos_published_at_idx
  on public.research_starter_videos (published_at desc nulls last);

create index if not exists research_starter_videos_transcript_status_idx
  on public.research_starter_videos (transcript_status);

create index if not exists research_starter_videos_channel_id_idx
  on public.research_starter_videos (channel_id);

comment on table public.research_starter_videos is
  'Raw AI Engineer channel catalog plus transcript storage pointers. Starter table for the research schema; relationship tables come later.';

comment on column public.research_starter_videos.transcript_text is
  'Full caption text when fetched. Canonical file also lives in transcript_bucket/transcript_path.';

comment on column public.research_starter_videos.transcript_path is
  'Object key in the ai-engineer-transcripts bucket, e.g. ai-dot-engineer/<video_id>.txt.';

drop trigger if exists set_research_starter_videos_updated_at
  on public.research_starter_videos;
create trigger set_research_starter_videos_updated_at
  before update on public.research_starter_videos
  for each row execute procedure public.set_updated_at();

alter table public.research_starter_videos enable row level security;

drop policy if exists "research_starter_videos_public_read"
  on public.research_starter_videos;
create policy "research_starter_videos_public_read"
  on public.research_starter_videos
  for select
  to anon, authenticated
  using (true);

insert into storage.buckets (id, name, public)
values ('ai-engineer-transcripts', 'ai-engineer-transcripts', false)
on conflict (id) do update
set public = false;

drop policy if exists "ai_engineer_transcripts_select_authenticated"
  on storage.objects;
create policy "ai_engineer_transcripts_select_authenticated"
  on storage.objects
  for select
  to authenticated
  using (bucket_id = 'ai-engineer-transcripts');
