-- Migration 3: first-class technology entities (library, repo, product, paper)
-- + appearance link tables. Replaces today's free-text
-- `organization.flagship_products` with structured rows.
--
-- Naming convention for new entities: PK column is literally `slug text`
-- (lowercase-hyphen). Link tables reference these via `<entity>_slug`. This
-- diverges from legacy entities (person/org/session/video) which retain their
-- snake_case `<entity>_id` PKs but now have a parallel `slug` column.

-- ============================================================================
-- library
-- ============================================================================
create table if not exists public.library (
  slug                       text primary key,
  name                       text not null,
  kind                       text,
  category                   text,
  domain_layer               text,
  homepage_url               text,
  docs_url                   text,
  github_url                 text,
  pypi_name                  text,
  npm_name                   text,
  huggingface_id             text,
  license                    text,
  language                   text,
  tagline                    text,
  description                text,
  organization_id            text references public.organization(organization_id) on delete set null,
  latest_version             text,
  first_release_at           date,
  latest_release_at          date,
  github_stars               int,
  github_forks               int,
  github_watchers            int,
  github_open_issues         int,
  pypi_monthly_downloads     bigint,
  npm_weekly_downloads       bigint,
  popularity_score           numeric generated always as (
    coalesce(github_stars, 0)
    + coalesce(github_forks, 0) * 3
    + coalesce(pypi_monthly_downloads, 0) / 100
    + coalesce(npm_weekly_downloads, 0) / 25
  ) stored,
  is_open_source             boolean not null default false,
  tags                       text[] not null default '{}',
  search_text                text,
  embedding                  extensions.vector(1536),
  fts                        tsvector generated always as (
    setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(tagline, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'C')
  ) stored,
  metadata                   jsonb not null default '{}'::jsonb,
  last_harvested_at          timestamptz,
  created_at                 timestamptz not null default timezone('utc', now()),
  updated_at                 timestamptz not null default timezone('utc', now()),
  constraint library_kind_check check (
    kind is null or kind in ('sdk','framework','model','dataset','tool','runtime','router','vector_db','observability','benchmark','protocol','agent_platform','library','cli','plugin','extension')
  )
);
create index if not exists library_fts_idx on public.library using gin (fts);
create index if not exists library_embedding_hnsw on public.library
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
create index if not exists library_kind_idx on public.library (kind);
create index if not exists library_category_idx on public.library (category);
create index if not exists library_domain_layer_idx on public.library (domain_layer);
create index if not exists library_organization_idx on public.library (organization_id);
create index if not exists library_popularity_idx on public.library (popularity_score desc nulls last);
create index if not exists library_tags_gin on public.library using gin (tags);
create index if not exists library_metadata_gin on public.library using gin (metadata jsonb_path_ops);

-- ============================================================================
-- repo (a GitHub-style code repository; can back a library or stand alone)
-- ============================================================================
create table if not exists public.repo (
  slug                  text primary key,
  library_slug          text references public.library(slug) on delete set null,
  organization_id       text references public.organization(organization_id) on delete set null,
  github_org            text not null,
  github_repo           text not null,
  github_url            text not null unique,
  default_branch        text,
  description           text,
  topics                text[] not null default '{}',
  primary_language      text,
  stars                 int,
  forks                 int,
  watchers              int,
  open_issues           int,
  last_pushed_at        timestamptz,
  created_at_github     timestamptz,
  license               text,
  is_official           boolean not null default false,
  is_archived           boolean not null default false,
  metadata              jsonb not null default '{}'::jsonb,
  last_harvested_at     timestamptz,
  created_at            timestamptz not null default timezone('utc', now()),
  updated_at            timestamptz not null default timezone('utc', now())
);
create index if not exists repo_library_idx on public.repo (library_slug);
create index if not exists repo_organization_idx on public.repo (organization_id);
create index if not exists repo_topics_gin on public.repo using gin (topics);
create index if not exists repo_metadata_gin on public.repo using gin (metadata jsonb_path_ops);
create index if not exists repo_stars_idx on public.repo (stars desc nulls last);

-- ============================================================================
-- product (commercial / hosted product offering, often by a company)
-- ============================================================================
create table if not exists public.product (
  slug                  text primary key,
  name                  text not null,
  organization_id       text references public.organization(organization_id) on delete set null,
  kind                  text,
  tagline               text,
  description           text,
  homepage_url          text,
  pricing_url           text,
  docs_url              text,
  categories            text[] not null default '{}',
  domain_layer          text,
  pricing_model         text,
  launch_date           date,
  is_flagship           boolean not null default false,
  tags                  text[] not null default '{}',
  search_text           text,
  embedding             extensions.vector(1536),
  fts                   tsvector generated always as (
    setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(tagline, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'C')
  ) stored,
  metadata              jsonb not null default '{}'::jsonb,
  last_enriched_at      timestamptz,
  created_at            timestamptz not null default timezone('utc', now()),
  updated_at            timestamptz not null default timezone('utc', now()),
  constraint product_kind_check check (
    kind is null or kind in ('api','platform','saas','model','ide','extension','hardware','studio','playground','benchmark','community','protocol','marketplace','agent','data','observability')
  ),
  constraint product_pricing_model_check check (
    pricing_model is null or pricing_model in ('free','freemium','usage_based','seat_based','enterprise','open_source','contact_sales')
  )
);
create index if not exists product_fts_idx on public.product using gin (fts);
create index if not exists product_embedding_hnsw on public.product
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
create index if not exists product_organization_idx on public.product (organization_id);
create index if not exists product_kind_idx on public.product (kind);
create index if not exists product_categories_gin on public.product using gin (categories);
create index if not exists product_tags_gin on public.product using gin (tags);
create index if not exists product_metadata_gin on public.product using gin (metadata jsonb_path_ops);

-- ============================================================================
-- paper (arxiv / venue-published research paper)
-- ============================================================================
create table if not exists public.paper (
  slug                  text primary key,
  arxiv_id              text unique,
  doi                   text,
  title                 text not null,
  abstract              text,
  url                   text,
  pdf_url               text,
  published_on          date,
  venue                 text,
  authors               jsonb not null default '[]'::jsonb,
  categories            text[] not null default '{}',
  domain_layer          text,
  tags                  text[] not null default '{}',
  citation_count        int,
  popularity_score      numeric generated always as (coalesce(citation_count, 0)) stored,
  search_text           text,
  embedding             extensions.vector(1536),
  fts                   tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(abstract, '')), 'B')
  ) stored,
  metadata              jsonb not null default '{}'::jsonb,
  last_harvested_at     timestamptz,
  created_at            timestamptz not null default timezone('utc', now()),
  updated_at            timestamptz not null default timezone('utc', now())
);
create index if not exists paper_fts_idx on public.paper using gin (fts);
create index if not exists paper_embedding_hnsw on public.paper
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
create index if not exists paper_published_idx on public.paper (published_on desc nulls last);
create index if not exists paper_categories_gin on public.paper using gin (categories);
create index if not exists paper_tags_gin on public.paper using gin (tags);
create index if not exists paper_authors_gin on public.paper using gin (authors jsonb_path_ops);
create index if not exists paper_metadata_gin on public.paper using gin (metadata jsonb_path_ops);
create index if not exists paper_popularity_idx on public.paper (popularity_score desc nulls last);

-- ============================================================================
-- updated_at triggers
-- ============================================================================
drop trigger if exists set_library_updated_at on public.library;
create trigger set_library_updated_at before update on public.library
  for each row execute procedure public.set_updated_at();
drop trigger if exists set_repo_updated_at on public.repo;
create trigger set_repo_updated_at before update on public.repo
  for each row execute procedure public.set_updated_at();
drop trigger if exists set_product_updated_at on public.product;
create trigger set_product_updated_at before update on public.product
  for each row execute procedure public.set_updated_at();
drop trigger if exists set_paper_updated_at on public.paper;
create trigger set_paper_updated_at before update on public.paper
  for each row execute procedure public.set_updated_at();

-- ============================================================================
-- Link tables (7)
-- ============================================================================
create table if not exists public.library_appeared_in_video (
  library_slug   text not null references public.library(slug) on delete cascade,
  video_id       text not null references public.youtube_video(video_id) on delete cascade,
  evidence       jsonb not null default '[]'::jsonb,
  confidence     numeric,
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (library_slug, video_id)
);
create index if not exists lib_in_video_video_idx on public.library_appeared_in_video (video_id);

create table if not exists public.library_appeared_in_session (
  library_slug   text not null references public.library(slug) on delete cascade,
  session_id     text not null references public.session(session_id) on delete cascade,
  evidence       jsonb not null default '[]'::jsonb,
  confidence     numeric,
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (library_slug, session_id)
);
create index if not exists lib_in_session_session_idx on public.library_appeared_in_session (session_id);

create table if not exists public.library_uses_library (
  parent_library_slug   text not null references public.library(slug) on delete cascade,
  child_library_slug    text not null references public.library(slug) on delete cascade,
  dep_kind              text,
  created_at            timestamptz not null default timezone('utc', now()),
  primary key (parent_library_slug, child_library_slug),
  constraint library_uses_no_self_loop check (parent_library_slug <> child_library_slug)
);
create index if not exists lib_uses_lib_child_idx on public.library_uses_library (child_library_slug);

create table if not exists public.product_appeared_in_video (
  product_slug   text not null references public.product(slug) on delete cascade,
  video_id       text not null references public.youtube_video(video_id) on delete cascade,
  evidence       jsonb not null default '[]'::jsonb,
  confidence     numeric,
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (product_slug, video_id)
);
create index if not exists prod_in_video_video_idx on public.product_appeared_in_video (video_id);

create table if not exists public.paper_appeared_in_video (
  paper_slug     text not null references public.paper(slug) on delete cascade,
  video_id       text not null references public.youtube_video(video_id) on delete cascade,
  evidence       jsonb not null default '[]'::jsonb,
  confidence     numeric,
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (paper_slug, video_id)
);
create index if not exists paper_in_video_video_idx on public.paper_appeared_in_video (video_id);

create table if not exists public.paper_authored_by (
  paper_slug     text not null references public.paper(slug) on delete cascade,
  person_id      text not null references public.person(person_id) on delete cascade,
  ord            int not null default 0,
  is_corresponding boolean not null default false,
  affiliation_org text references public.organization(organization_id) on delete set null,
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (paper_slug, person_id)
);
create index if not exists paper_authored_by_person_idx on public.paper_authored_by (person_id);

create table if not exists public.repo_for_library (
  repo_slug      text not null references public.repo(slug) on delete cascade,
  library_slug   text not null references public.library(slug) on delete cascade,
  role           text not null default 'canonical',
  created_at     timestamptz not null default timezone('utc', now()),
  primary key (repo_slug, library_slug),
  constraint repo_for_library_role_check check (role in ('canonical','mirror','example','related','fork'))
);
create index if not exists repo_for_library_lib_idx on public.repo_for_library (library_slug);

-- ============================================================================
-- RLS read-only-for-users on every new content table
-- ============================================================================
alter table public.library enable row level security;
alter table public.repo enable row level security;
alter table public.product enable row level security;
alter table public.paper enable row level security;
alter table public.library_appeared_in_video enable row level security;
alter table public.library_appeared_in_session enable row level security;
alter table public.library_uses_library enable row level security;
alter table public.product_appeared_in_video enable row level security;
alter table public.paper_appeared_in_video enable row level security;
alter table public.paper_authored_by enable row level security;
alter table public.repo_for_library enable row level security;

drop policy if exists "library_public_read" on public.library;
create policy "library_public_read" on public.library for select using (true);
drop policy if exists "repo_public_read" on public.repo;
create policy "repo_public_read" on public.repo for select using (true);
drop policy if exists "product_public_read" on public.product;
create policy "product_public_read" on public.product for select using (true);
drop policy if exists "paper_public_read" on public.paper;
create policy "paper_public_read" on public.paper for select using (true);
drop policy if exists "library_appeared_in_video_public_read" on public.library_appeared_in_video;
create policy "library_appeared_in_video_public_read" on public.library_appeared_in_video for select using (true);
drop policy if exists "library_appeared_in_session_public_read" on public.library_appeared_in_session;
create policy "library_appeared_in_session_public_read" on public.library_appeared_in_session for select using (true);
drop policy if exists "library_uses_library_public_read" on public.library_uses_library;
create policy "library_uses_library_public_read" on public.library_uses_library for select using (true);
drop policy if exists "product_appeared_in_video_public_read" on public.product_appeared_in_video;
create policy "product_appeared_in_video_public_read" on public.product_appeared_in_video for select using (true);
drop policy if exists "paper_appeared_in_video_public_read" on public.paper_appeared_in_video;
create policy "paper_appeared_in_video_public_read" on public.paper_appeared_in_video for select using (true);
drop policy if exists "paper_authored_by_public_read" on public.paper_authored_by;
create policy "paper_authored_by_public_read" on public.paper_authored_by for select using (true);
drop policy if exists "repo_for_library_public_read" on public.repo_for_library;
create policy "repo_for_library_public_read" on public.repo_for_library for select using (true);

comment on table public.library is 'SDKs / frameworks / models / tools / vector DBs / etc. Slug PK = canonical identifier.';
comment on table public.repo is 'GitHub-style source repository. May back a library (library_slug) or stand alone (org-only). Slug e.g. agenta-ai-agenta.';
comment on table public.product is 'Commercial / hosted product offering. Many orgs ship multiple products.';
comment on table public.paper is 'Research paper (arxiv / venue / blog post). Authors stored as jsonb for fast denorm reads + paper_authored_by for joinable structure.';
comment on column public.library.popularity_score is 'github_stars + 3*github_forks + pypi_monthly_downloads/100 + npm_weekly_downloads/25.';
comment on column public.paper.popularity_score is 'Currently equals citation_count; can evolve to weighted formula.';
