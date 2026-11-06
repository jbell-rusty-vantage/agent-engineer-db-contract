-- Migration 1: enhance core entities (person, organization, session, youtube_video)
-- with canonical slugs, analytics fields, Slice-A categorization, updated_at
-- triggers, and read-only-for-users RLS.
--
-- Existing PKs (snake_case text) are preserved to avoid FK churn across the 8
-- relationship tables; a parallel `slug` column (lowercase-hyphen) becomes the
-- user-facing canonical identifier for URLs, chunk metadata, and dossier
-- filenames. YouTube video_ids are intentionally NOT lowercased: they are
-- case-sensitive in YouTube URLs.

-- person additions
alter table public.person
  add column if not exists slug text,
  add column if not exists twitter_handle text,
  add column if not exists github_username text,
  add column if not exists personal_website text,
  add column if not exists country text,
  add column if not exists city text,
  add column if not exists timezone text,
  add column if not exists seniority_level text,
  add column if not exists expertise_tags text[] not null default '{}',
  add column if not exists primary_org_id text references public.organization(organization_id) on delete set null,
  add column if not exists is_speaker boolean not null default false,
  add column if not exists is_founder boolean not null default false,
  add column if not exists notable_for text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists updated_at timestamptz not null default timezone('utc', now()),
  add column if not exists last_enriched_at timestamptz;

update public.person
  set slug = lower(regexp_replace(person_id, '_', '-', 'g'))
  where slug is null;
alter table public.person alter column slug set not null;
create unique index if not exists person_slug_uniq on public.person (slug);
create index if not exists person_expertise_tags_gin on public.person using gin (expertise_tags);
create index if not exists person_metadata_gin on public.person using gin (metadata jsonb_path_ops);
create index if not exists person_country_idx on public.person (country);
create index if not exists person_primary_org_idx on public.person (primary_org_id);
create index if not exists person_is_speaker_idx on public.person (is_speaker) where is_speaker;
create index if not exists person_is_founder_idx on public.person (is_founder) where is_founder;

-- organization additions
alter table public.organization
  add column if not exists slug text,
  add column if not exists parent_org_id text references public.organization(organization_id) on delete set null,
  add column if not exists org_kind text,
  add column if not exists stage text,
  add column if not exists funding_total_usd bigint,
  add column if not exists last_funding_round text,
  add column if not exists last_funding_at date,
  add column if not exists valuation_usd bigint,
  add column if not exists founded_year int,
  add column if not exists headquarters_city text,
  add column if not exists headquarters_country text,
  add column if not exists region text,
  add column if not exists headcount_band text,
  add column if not exists logo_url text,
  add column if not exists twitter_handle text,
  add column if not exists github_org text,
  add column if not exists linkedin_url text,
  add column if not exists careers_url text,
  add column if not exists crunchbase_url text,
  add column if not exists homepage_url text,
  add column if not exists docs_url text,
  add column if not exists blog_url text,
  add column if not exists status_url text,
  add column if not exists legal_entity_name text,
  add column if not exists ticker_symbol text,
  add column if not exists business_model text,
  add column if not exists is_ai_first boolean not null default false,
  add column if not exists is_ai_innovator boolean not null default false,
  add column if not exists is_aie_sponsor boolean not null default false,
  add column if not exists categories text[] not null default '{}',
  add column if not exists domain_layers text[] not null default '{}',
  add column if not exists tags text[] not null default '{}',
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists updated_at timestamptz not null default timezone('utc', now()),
  add column if not exists last_enriched_at timestamptz;

update public.organization
  set slug = lower(regexp_replace(organization_id, '_', '-', 'g'))
  where slug is null;
alter table public.organization alter column slug set not null;
create unique index if not exists organization_slug_uniq on public.organization (slug);
create index if not exists organization_categories_gin on public.organization using gin (categories);
create index if not exists organization_domain_layers_gin on public.organization using gin (domain_layers);
create index if not exists organization_tags_gin on public.organization using gin (tags);
create index if not exists organization_metadata_gin on public.organization using gin (metadata jsonb_path_ops);
create index if not exists organization_kind_idx on public.organization (org_kind);
create index if not exists organization_country_idx on public.organization (headquarters_country);
create index if not exists organization_stage_idx on public.organization (stage);
create index if not exists organization_is_ai_first_idx on public.organization (is_ai_first) where is_ai_first;
create index if not exists organization_is_ai_innovator_idx on public.organization (is_ai_innovator) where is_ai_innovator;
create index if not exists organization_parent_idx on public.organization (parent_org_id);

-- session additions (event_id FK is wired in Migration 2)
alter table public.session
  add column if not exists slug text,
  add column if not exists event_id text,
  add column if not exists track text,
  add column if not exists room text,
  add column if not exists session_format text,
  add column if not exists scheduled_at timestamptz,
  add column if not exists duration_minutes int,
  add column if not exists slides_url text,
  add column if not exists code_repo_url text,
  add column if not exists category text,
  add column if not exists domain_layer text,
  add column if not exists tags text[] not null default '{}',
  add column if not exists language text not null default 'en',
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists updated_at timestamptz not null default timezone('utc', now());

update public.session
  set slug = 'session-' || session_id
  where slug is null;
alter table public.session alter column slug set not null;
create unique index if not exists session_slug_uniq on public.session (slug);
create index if not exists session_category_idx on public.session (category);
create index if not exists session_domain_layer_idx on public.session (domain_layer);
create index if not exists session_event_idx on public.session (event_id);
create index if not exists session_format_idx on public.session (session_format);
create index if not exists session_tags_gin on public.session using gin (tags);
create index if not exists session_metadata_gin on public.session using gin (metadata jsonb_path_ops);

-- youtube_video additions (Slice A category/domain_layer + analytics)
alter table public.youtube_video
  add column if not exists slug text,
  add column if not exists event_id text,
  add column if not exists category text,
  add column if not exists domain_layer text,
  add column if not exists tags text[] not null default '{}',
  add column if not exists language text not null default 'en',
  add column if not exists is_short boolean not null default false,
  add column if not exists transcript_status text not null default 'none',
  add column if not exists summary_status text not null default 'none',
  add column if not exists chapters jsonb,
  add column if not exists popularity_score numeric generated always as (
    coalesce(view_count, 0)
    + coalesce(like_count, 0) * 50
    + coalesce(comment_count, 0) * 200
  ) stored,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists last_enriched_at timestamptz,
  add column if not exists updated_at timestamptz not null default timezone('utc', now());

-- YouTube IDs are case-sensitive (e.g. `X4dEHRzBLmc`, `_zdroS0Hc74`); preserve case.
update public.youtube_video
  set slug = video_id
  where slug is null;
alter table public.youtube_video alter column slug set not null;
create unique index if not exists youtube_video_slug_uniq on public.youtube_video (slug);
create index if not exists youtube_video_category_idx on public.youtube_video (category);
create index if not exists youtube_video_domain_layer_idx on public.youtube_video (domain_layer);
create index if not exists youtube_video_event_idx on public.youtube_video (event_id);
create index if not exists youtube_video_popularity_idx on public.youtube_video (popularity_score desc nulls last);
create index if not exists youtube_video_published_at_idx on public.youtube_video (published_at desc nulls last);
create index if not exists youtube_video_tags_gin on public.youtube_video using gin (tags);
create index if not exists youtube_video_metadata_gin on public.youtube_video using gin (metadata jsonb_path_ops);

-- Status check constraints (text + check beats enums for migration ergonomics)
alter table public.youtube_video drop constraint if exists youtube_video_transcript_status_check;
alter table public.youtube_video add constraint youtube_video_transcript_status_check
  check (transcript_status in ('none','auto','manual','reviewed'));
alter table public.youtube_video drop constraint if exists youtube_video_summary_status_check;
alter table public.youtube_video add constraint youtube_video_summary_status_check
  check (summary_status in ('none','draft','reviewed','published'));

-- updated_at triggers
drop trigger if exists set_person_updated_at on public.person;
create trigger set_person_updated_at before update on public.person for each row execute procedure public.set_updated_at();
drop trigger if exists set_organization_updated_at on public.organization;
create trigger set_organization_updated_at before update on public.organization for each row execute procedure public.set_updated_at();
drop trigger if exists set_session_updated_at on public.session;
create trigger set_session_updated_at before update on public.session for each row execute procedure public.set_updated_at();
drop trigger if exists set_youtube_video_updated_at on public.youtube_video;
create trigger set_youtube_video_updated_at before update on public.youtube_video for each row execute procedure public.set_updated_at();

-- Enable RLS on every content table (read-only-for-users content).
-- The single `*_public_read` policy permits anon + authenticated SELECT; INSERT/
-- UPDATE/DELETE remain service-role-only because no other policies are defined.
alter table public.person enable row level security;
alter table public.organization enable row level security;
alter table public.session enable row level security;
alter table public.youtube_video enable row level security;
alter table public.youtube_channel enable row level security;
alter table public.session_recorded_as_video enable row level security;
alter table public.person_appeared_in_video enable row level security;
alter table public.person_presented_at_session enable row level security;
alter table public.person_employed_by enable row level security;
alter table public.person_founded_organization enable row level security;
alter table public.organization_has_ceo enable row level security;

drop policy if exists "person_public_read" on public.person;
create policy "person_public_read" on public.person for select using (true);

drop policy if exists "organization_public_read" on public.organization;
create policy "organization_public_read" on public.organization for select using (true);

drop policy if exists "session_public_read" on public.session;
create policy "session_public_read" on public.session for select using (true);

drop policy if exists "youtube_video_public_read" on public.youtube_video;
create policy "youtube_video_public_read" on public.youtube_video for select using (true);

drop policy if exists "youtube_channel_public_read" on public.youtube_channel;
create policy "youtube_channel_public_read" on public.youtube_channel for select using (true);

drop policy if exists "session_recorded_as_video_public_read" on public.session_recorded_as_video;
create policy "session_recorded_as_video_public_read" on public.session_recorded_as_video for select using (true);

drop policy if exists "person_appeared_in_video_public_read" on public.person_appeared_in_video;
create policy "person_appeared_in_video_public_read" on public.person_appeared_in_video for select using (true);

drop policy if exists "person_presented_at_session_public_read" on public.person_presented_at_session;
create policy "person_presented_at_session_public_read" on public.person_presented_at_session for select using (true);

drop policy if exists "person_employed_by_public_read" on public.person_employed_by;
create policy "person_employed_by_public_read" on public.person_employed_by for select using (true);

drop policy if exists "person_founded_organization_public_read" on public.person_founded_organization;
create policy "person_founded_organization_public_read" on public.person_founded_organization for select using (true);

drop policy if exists "organization_has_ceo_public_read" on public.organization_has_ceo;
create policy "organization_has_ceo_public_read" on public.organization_has_ceo for select using (true);

comment on column public.person.slug is 'Canonical lowercase-hyphen identifier for URLs, dossier filenames, chunk metadata.';
comment on column public.organization.slug is 'Canonical lowercase-hyphen identifier for URLs, dossier filenames, chunk metadata.';
comment on column public.session.slug is 'Canonical identifier; defaults to "session-<session_id>" until reseeded with a friendlier title-derived slug.';
comment on column public.youtube_video.slug is 'Equal to video_id (case-sensitive). Use lowercase-hyphen for derived slugs only.';
comment on column public.youtube_video.popularity_score is 'view_count + 50*like_count + 200*comment_count. Cheap proxy for "did it land".';
comment on column public.organization.is_ai_first is 'True if AI is the company''s primary product/value (Anthropic, OpenAI, Cohere). False for AI-using companies (Microsoft, AWS).';
comment on column public.organization.is_ai_innovator is 'True for big hardware/software incumbents shipping notable AI products (NVIDIA, Google, Microsoft, Apple, Meta).';
