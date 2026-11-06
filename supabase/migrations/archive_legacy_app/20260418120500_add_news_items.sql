-- Migration 6: news_item — "what's happening in AI" feed.
-- Distinct from `event` (conference). A news_item is a thing that happened in
-- the world: model release, funding round, leadership change, breakthrough
-- benchmark, paper drop, acquisition. Lean relationships: only three optional
-- FKs; everything else is *_slugs text[] arrays so a single row can mention 5
-- orgs / 3 libraries / 2 papers without spawning join tables.

create table if not exists public.news_item (
  news_item_id          uuid primary key default gen_random_uuid(),
  slug                  text unique not null,
  title                 text not null,
  headline              text,
  kind                  text not null,
  importance            int not null default 3,
  status                text not null default 'published',
  occurred_on           date,
  published_at          timestamptz not null default timezone('utc', now()),
  source_url            text,
  source_name           text,
  source_kind           text,
  thumbnail_url         text,
  hero_image_url        text,
  summary               text,
  body_md               text,

  primary_org_id        text references public.organization(organization_id) on delete set null,
  primary_person_id     text references public.person(person_id) on delete set null,
  announced_at_event_id text references public.event(event_id) on delete set null,

  related_org_slugs     text[] not null default '{}',
  related_person_slugs  text[] not null default '{}',
  related_library_slugs text[] not null default '{}',
  related_product_slugs text[] not null default '{}',
  related_paper_slugs   text[] not null default '{}',
  related_video_ids     text[] not null default '{}',

  categories            text[] not null default '{}',
  domain_layer          text,
  tags                  text[] not null default '{}',
  funding_amount_usd    bigint,
  funding_round         text,
  model_params_b        numeric,

  search_text           text,
  embedding             extensions.vector(1536),
  fts                   tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(headline, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(summary, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(body_md, '')), 'C')
  ) stored,
  metadata              jsonb not null default '{}'::jsonb,
  created_at            timestamptz not null default timezone('utc', now()),
  updated_at            timestamptz not null default timezone('utc', now()),

  constraint news_item_kind_check check (
    kind in (
      'model_release','product_launch','funding','acquisition','leadership_change',
      'breakthrough','benchmark','paper_drop','partnership','open_source',
      'controversy','regulation','shutdown','ipo','earnings','rumor',
      'event_announcement','feature_release','price_change','outage','other'
    )
  ),
  constraint news_item_importance_check check (importance between 1 and 5),
  constraint news_item_status_check check (status in ('draft','published','retracted','scheduled'))
);

create index if not exists news_item_fts_idx          on public.news_item using gin (fts);
create index if not exists news_item_embedding_hnsw   on public.news_item
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
-- Composite index that matches the homepage feed query
-- (where status='published' order by importance desc, occurred_on desc, published_at desc).
create index if not exists news_item_feed_idx
  on public.news_item (status, importance desc, occurred_on desc nulls last, published_at desc);
create index if not exists news_item_kind_idx         on public.news_item (kind);
create index if not exists news_item_primary_org_idx  on public.news_item (primary_org_id);
create index if not exists news_item_primary_person_idx on public.news_item (primary_person_id);
create index if not exists news_item_event_idx        on public.news_item (announced_at_event_id);
create index if not exists news_item_categories_gin   on public.news_item using gin (categories);
create index if not exists news_item_tags_gin         on public.news_item using gin (tags);
create index if not exists news_item_related_orgs_gin on public.news_item using gin (related_org_slugs);
create index if not exists news_item_related_libs_gin on public.news_item using gin (related_library_slugs);
create index if not exists news_item_related_people_gin on public.news_item using gin (related_person_slugs);
create index if not exists news_item_related_products_gin on public.news_item using gin (related_product_slugs);
create index if not exists news_item_related_papers_gin on public.news_item using gin (related_paper_slugs);
create index if not exists news_item_related_videos_gin on public.news_item using gin (related_video_ids);
create index if not exists news_item_metadata_gin     on public.news_item using gin (metadata jsonb_path_ops);

drop trigger if exists set_news_item_updated_at on public.news_item;
create trigger set_news_item_updated_at before update on public.news_item
  for each row execute procedure public.set_updated_at();

alter table public.news_item enable row level security;
drop policy if exists "news_item_public_read" on public.news_item;
create policy "news_item_public_read" on public.news_item
  for select
  using (status = 'published' or auth.role() = 'service_role');

comment on table public.news_item is
  'What''s happening in AI: major model releases, funding, breakthroughs, launches. Distinct from `event` (which is a gathering people attend).';
comment on column public.news_item.importance is
  '1 = trivia (minor blog post), 5 = industry-defining (GPT-5 launch, Anthropic Series F, etc.). Drives feed sorting and editorial highlight rails.';
comment on column public.news_item.kind is
  'High-level taxonomy of what kind of news this is. Drives filter chips in the feed UI.';
comment on column public.news_item.related_org_slugs is
  'Array of organization slugs mentioned. Lookup via `agenta = any(related_org_slugs)`. No FK so cite churn does not break the row.';
comment on column public.news_item.funding_amount_usd is
  'Populated only when kind=funding. Powers funding-round leaderboards and totals.';
comment on column public.news_item.model_params_b is
  'Populated only when kind=model_release. Parameter count in billions, e.g. 405 for Llama 3.1 405B.';
