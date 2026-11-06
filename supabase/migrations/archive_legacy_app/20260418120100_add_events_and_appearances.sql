-- Migration 2: events (conferences) + appearance / sponsorship link tables.
-- Wires session.event_id and youtube_video.event_id FKs that were
-- pre-allocated in Migration 1.
--
-- Seeds known AIE editions (World's Fair 2024/2025/2026, Code Summit NYC 2026,
-- AIE Europe). Backfill of session.event_id and youtube_video.event_id is
-- left to a follow-up TS script (date-window + title-regex heuristics).

create table if not exists public.event (
  event_id              text primary key,
  slug                  text unique not null,
  name                  text not null,
  series                text,
  edition               int,
  start_date            date,
  end_date              date,
  city                  text,
  country               text,
  region                text,
  venue                 text,
  website_url           text,
  agenda_url            text,
  youtube_playlist_url  text,
  tagline               text,
  description           text,
  topic_tags            text[] not null default '{}',
  attendee_count        int,
  speaker_count         int,
  session_count         int,
  is_aie_official       boolean not null default false,
  search_text           text,
  embedding             extensions.vector(1536),
  fts                   tsvector generated always as (
    setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(tagline, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'C')
  ) stored,
  metadata              jsonb not null default '{}'::jsonb,
  created_at            timestamptz not null default timezone('utc', now()),
  updated_at            timestamptz not null default timezone('utc', now())
);

create index if not exists event_fts_idx on public.event using gin (fts);
create index if not exists event_embedding_hnsw_idx
  on public.event using hnsw (embedding extensions.vector_cosine_ops)
  where embedding is not null;
create index if not exists event_series_idx on public.event (series);
create index if not exists event_dates_idx on public.event (start_date desc nulls last);
create index if not exists event_topic_tags_gin on public.event using gin (topic_tags);
create index if not exists event_metadata_gin on public.event using gin (metadata jsonb_path_ops);
create index if not exists event_country_idx on public.event (country);

drop trigger if exists set_event_updated_at on public.event;
create trigger set_event_updated_at before update on public.event
  for each row execute procedure public.set_updated_at();

-- Wire FKs that were pre-allocated in Migration 1.
alter table public.session
  drop constraint if exists session_event_id_fkey;
alter table public.session
  add constraint session_event_id_fkey
  foreign key (event_id) references public.event(event_id) on delete set null;

alter table public.youtube_video
  drop constraint if exists youtube_video_event_id_fkey;
alter table public.youtube_video
  add constraint youtube_video_event_id_fkey
  foreign key (event_id) references public.event(event_id) on delete set null;

-- Person / event attendance (multi-role: a person can be both speaker and host).
create table if not exists public.person_attended_event (
  person_id        text not null references public.person(person_id) on delete cascade,
  event_id         text not null references public.event(event_id) on delete cascade,
  role             text not null default 'attendee',
  affiliation_org  text references public.organization(organization_id) on delete set null,
  match_method     text,
  created_at       timestamptz not null default timezone('utc', now()),
  primary key (person_id, event_id, role),
  constraint person_attended_event_role_check check (
    role in ('attendee','speaker','workshop_lead','host','organizer','sponsor_rep','press','panelist','judge')
  )
);
create index if not exists person_attended_event_event_idx on public.person_attended_event (event_id);
create index if not exists person_attended_event_role_idx on public.person_attended_event (role);
create index if not exists person_attended_event_affiliation_idx on public.person_attended_event (affiliation_org);

-- Organization sponsorship of events.
create table if not exists public.organization_sponsored_event (
  organization_id  text not null references public.organization(organization_id) on delete cascade,
  event_id         text not null references public.event(event_id) on delete cascade,
  tier             text,
  amount_usd       bigint,
  notes            text,
  created_at       timestamptz not null default timezone('utc', now()),
  primary key (organization_id, event_id),
  constraint org_sponsored_event_tier_check check (
    tier is null or tier in ('title','platinum','gold','silver','bronze','community','booth','exhibitor','media','partner')
  )
);
create index if not exists org_sponsored_event_event_idx on public.organization_sponsored_event (event_id);
create index if not exists org_sponsored_event_tier_idx on public.organization_sponsored_event (tier);

-- RLS read-only-for-users.
alter table public.event enable row level security;
alter table public.person_attended_event enable row level security;
alter table public.organization_sponsored_event enable row level security;

drop policy if exists "event_public_read" on public.event;
create policy "event_public_read" on public.event for select using (true);

drop policy if exists "person_attended_event_public_read" on public.person_attended_event;
create policy "person_attended_event_public_read" on public.person_attended_event for select using (true);

drop policy if exists "organization_sponsored_event_public_read" on public.organization_sponsored_event;
create policy "organization_sponsored_event_public_read" on public.organization_sponsored_event for select using (true);

-- Seed known AI Engineer editions. Idempotent via on conflict.
-- Dates / counts are best-known-public; refine via backfill scripts later.
insert into public.event (event_id, slug, name, series, edition, start_date, end_date, city, country, region, venue, website_url, tagline, is_aie_official, topic_tags)
values
  ('aie-summit-2023-sf',     'aie-summit-2023-sf',     'AI Engineer Summit 2023',           'aie-summit',      1, '2023-10-08', '2023-10-10', 'San Francisco', 'United States', 'na',     null, 'https://www.ai.engineer', 'Inaugural AI Engineer Summit',                              true, '{founders,llm-apps}'),
  ('aie-world-fair-2024',    'aie-world-fair-2024',    'AI Engineer World''s Fair 2024',    'aie-world-fair',  1, '2024-06-25', '2024-06-27', 'San Francisco', 'United States', 'na',     null, 'https://www.ai.engineer', 'The world''s fair for AI engineers',                       true, '{rag,agents,evaluations,coding-agents}'),
  ('aie-summit-2025-nyc',    'aie-summit-2025-nyc',    'AI Engineer Summit NYC 2025',       'aie-summit',      2, '2025-02-19', '2025-02-22', 'New York',      'United States', 'na',     null, 'https://www.ai.engineer', 'Agents take center stage',                                 true, '{agents,reasoning,coding-agents}'),
  ('aie-world-fair-2025',    'aie-world-fair-2025',    'AI Engineer World''s Fair 2025',    'aie-world-fair',  2, '2025-06-03', '2025-06-05', 'San Francisco', 'United States', 'na',     null, 'https://www.ai.engineer', 'The flagship AIE conference',                              true, '{agents,evaluations,rag,mcp,a2a,coding-agents}'),
  ('aie-code-summit-2025',   'aie-code-summit-2025',   'AI Engineer Code Summit 2025',      'aie-code-summit', 1, '2025-11-20', '2025-11-22', 'New York',      'United States', 'na',     null, 'https://www.ai.engineer', 'AIE focused on coding agents and dev tooling',             true, '{coding-agents,dev-tooling}'),
  ('aie-world-fair-2026',    'aie-world-fair-2026',    'AI Engineer World''s Fair 2026',    'aie-world-fair',  3, '2026-06-09', '2026-06-11', 'San Francisco', 'United States', 'na',     null, 'https://www.ai.engineer', 'The flagship AIE conference',                              true, '{agents,evaluations,rag,mcp,coding-agents,voice}'),
  ('aie-europe-2026',        'aie-europe-2026',        'AI Engineer Europe 2026',           'aie-europe',      1, '2026-04-01', '2026-04-03', 'London',        'United Kingdom', 'emea',  null, 'https://www.ai.engineer', 'European edition of the AI Engineer conference',           true, '{agents,evaluations,rag}')
on conflict (event_id) do nothing;

comment on table public.event is 'Conferences / gatherings (AIE World''s Fair, Summit, Europe, external). For news items / launches / breakthroughs see news_item.';
comment on column public.event.is_aie_official is 'True for AI Engineer official events (World''s Fair, Summits, Code Summits, Europe). False for external conferences.';
comment on column public.event.series is 'Slug for the recurring conference series; rows in the same series share this value across editions.';
