-- Research starter channels: Channel 1 —* Video.
--
-- public.research_starter_videos already stored denormalized channel_id /
-- handle / title. There was no channel row and no FK, so videos from a second
-- source (Matthew Berman, later others) could not be distinguished as a
-- catalog. AI Engineer (@aiDotEngineer) remains the primary pre-research
-- source; other channels are stored but stay out of the Worlds Fair queue
-- because claim/qualification still require bucket ai-engineer-transcripts.

begin;

create table if not exists public.research_starter_channels (
  channel_id text primary key,
  handle text not null,
  title text not null,
  description text,
  custom_url text,
  channel_url text,
  thumbnail_url text,
  subscriber_count bigint,
  video_count bigint,
  uploads_playlist_id text,
  transcript_bucket text not null,
  transcript_path_prefix text not null,
  is_primary_research_source boolean not null default false,
  source text,
  catalog_fetched_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint research_starter_channels_handle_format
    check (handle ~ '^@[^[:space:]]+$'),
  constraint research_starter_channels_id_nonempty
    check (btrim(channel_id) <> ''),
  constraint research_starter_channels_title_nonempty
    check (btrim(title) <> ''),
  constraint research_starter_channels_bucket_nonempty
    check (btrim(transcript_bucket) <> ''),
  constraint research_starter_channels_prefix_nonempty
    check (btrim(transcript_path_prefix) <> '' and transcript_path_prefix !~ '^/|/$')
);

comment on table public.research_starter_channels is
  'YouTube channels whose videos are ingested into research_starter_videos. One channel has many videos. AI Engineer is the primary pre-research source.';

comment on column public.research_starter_channels.channel_id is
  'YouTube channel id (UC…). Primary key; research_starter_videos.channel_id references this.';

comment on column public.research_starter_channels.handle is
  'YouTube handle including leading @, e.g. @aiDotEngineer.';

comment on column public.research_starter_channels.transcript_bucket is
  'Private Storage bucket for this channel''s caption files.';

comment on column public.research_starter_channels.transcript_path_prefix is
  'Object-key prefix inside the bucket, e.g. ai-dot-engineer or matthew-berman. Path is {prefix}/{video_id}.txt.';

comment on column public.research_starter_channels.is_primary_research_source is
  'True only for the AI Engineer Worlds Fair catalog. Pre-research claim still keys off transcript_bucket = ai-engineer-transcripts.';

create unique index if not exists research_starter_channels_handle_lower_idx
  on public.research_starter_channels (lower(handle));

create unique index if not exists research_starter_channels_one_primary_idx
  on public.research_starter_channels (is_primary_research_source)
  where is_primary_research_source;

drop trigger if exists set_research_starter_channels_updated_at
  on public.research_starter_channels;
create trigger set_research_starter_channels_updated_at
  before update on public.research_starter_channels
  for each row execute procedure public.set_updated_at();

alter table public.research_starter_channels enable row level security;

revoke all on public.research_starter_channels from public, anon, authenticated;
grant all on public.research_starter_channels to postgres, service_role;

-- Heal the existing AI Engineer catalog into a channel row, then lock the FK.
insert into public.research_starter_channels (
  channel_id,
  handle,
  title,
  description,
  channel_url,
  transcript_bucket,
  transcript_path_prefix,
  is_primary_research_source,
  source,
  catalog_fetched_at,
  metadata
)
select
  v.channel_id,
  coalesce(
    nullif(btrim(v.channel_handle), ''),
    case
      when v.channel_id = 'UCLKPca3kwwd-B59HNr-_lvA' then '@aiDotEngineer'
      else '@' || v.channel_id
    end
  ),
  coalesce(
    nullif(btrim(v.channel_title), ''),
    case
      when v.channel_id = 'UCLKPca3kwwd-B59HNr-_lvA' then 'AI Engineer'
      else v.channel_id
    end
  ),
  case
    when v.channel_id = 'UCLKPca3kwwd-B59HNr-_lvA' then
      'We turn high signal in-person events for the top AI engineers, founders, leaders, and researchers in the world into the best free learning opportunities for millions around the world here on YouTube.'
    else null
  end,
  'https://www.youtube.com/channel/' || v.channel_id,
  case
    when v.channel_id = 'UCLKPca3kwwd-B59HNr-_lvA' then 'ai-engineer-transcripts'
    else 'ai-engineer-transcripts'
  end,
  case
    when v.channel_id = 'UCLKPca3kwwd-B59HNr-_lvA' then 'ai-dot-engineer'
    else v.channel_id
  end,
  v.channel_id = 'UCLKPca3kwwd-B59HNr-_lvA',
  'youtube_data_api_v3',
  timezone('utc', now()),
  jsonb_build_object(
    'healed_from', 'research_starter_videos',
    'healed_video_count', count(*)
  )
from public.research_starter_videos v
where v.channel_id is not null
  and btrim(v.channel_id) <> ''
group by v.channel_id, v.channel_handle, v.channel_title
on conflict (channel_id) do update
set
  handle = excluded.handle,
  title = excluded.title,
  transcript_bucket = excluded.transcript_bucket,
  transcript_path_prefix = excluded.transcript_path_prefix,
  is_primary_research_source = excluded.is_primary_research_source,
  updated_at = timezone('utc', now());

alter table public.research_starter_videos
  drop constraint if exists research_starter_videos_channel_id_fkey,
  add constraint research_starter_videos_channel_id_fkey
  foreign key (channel_id)
  references public.research_starter_channels (channel_id)
  on update cascade
  on delete restrict;

comment on column public.research_starter_videos.channel_id is
  'YouTube channel id. FK to research_starter_channels.channel_id (Channel 1—* Video).';

comment on table public.research_starter_videos is
  'YouTube videos for the research starter catalog. Each video belongs to one research_starter_channels row. Transcript bytes live in the channel''s Storage bucket.';

-- Bucket already created in Studio for Matthew Berman; keep local resets in sync.
insert into storage.buckets (id, name, public)
values ('matthew-berman-transcripts', 'matthew-berman-transcripts', false)
on conflict (id) do update
set public = false;

drop policy if exists "matthew_berman_transcripts_select_authenticated"
  on storage.objects;
create policy "matthew_berman_transcripts_select_authenticated"
  on storage.objects
  for select
  to authenticated
  using (bucket_id = 'matthew-berman-transcripts');

commit;
