-- Migration 4: report table — bucket landscapes, event recaps, vendor surveys,
-- trend pieces, deep-dives. DB projection of the vault `report.md` template
-- (aiwiki/ai-intelligence-vault/ai-intelligence/_templates/report.md).
--
-- Drafts visible only to service_role; published reports visible to everyone.

create table if not exists public.report (
  report_id            uuid primary key default gen_random_uuid(),
  slug                 text unique not null,
  title                text not null,
  report_kind          text not null,
  status               text not null default 'draft',
  bucket               text,
  domain_layer         text,
  event_id             text references public.event(event_id) on delete set null,
  organization_id      text references public.organization(organization_id) on delete set null,
  published_at         timestamptz,
  summary              text,
  body_md              text,
  authors              jsonb not null default '[]'::jsonb,
  cited_video_ids      text[] not null default '{}',
  cited_org_ids        text[] not null default '{}',
  cited_library_slugs  text[] not null default '{}',
  cited_paper_slugs    text[] not null default '{}',
  tags                 text[] not null default '{}',
  search_text          text,
  embedding            extensions.vector(1536),
  fts                  tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(summary, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(body_md, '')), 'C')
  ) stored,
  metadata             jsonb not null default '{}'::jsonb,
  created_at           timestamptz not null default timezone('utc', now()),
  updated_at           timestamptz not null default timezone('utc', now()),
  constraint report_kind_check check (
    report_kind in ('bucket_landscape','event_recap','vendor_survey','trend','annual_state','comparison','deep_dive','market_map','timeline','retrospective')
  ),
  constraint report_status_check check (status in ('draft','review','published','archived'))
);

create index if not exists report_fts_idx on public.report using gin (fts);
create index if not exists report_embedding_hnsw on public.report
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
create index if not exists report_bucket_idx on public.report (bucket);
create index if not exists report_kind_idx on public.report (report_kind);
create index if not exists report_status_idx on public.report (status);
create index if not exists report_event_idx on public.report (event_id);
create index if not exists report_organization_idx on public.report (organization_id);
create index if not exists report_published_at_idx on public.report (published_at desc nulls last) where status = 'published';
create index if not exists report_tags_gin on public.report using gin (tags);
create index if not exists report_cited_orgs_gin on public.report using gin (cited_org_ids);
create index if not exists report_cited_libraries_gin on public.report using gin (cited_library_slugs);
create index if not exists report_cited_videos_gin on public.report using gin (cited_video_ids);
create index if not exists report_metadata_gin on public.report using gin (metadata jsonb_path_ops);

drop trigger if exists set_report_updated_at on public.report;
create trigger set_report_updated_at before update on public.report
  for each row execute procedure public.set_updated_at();

alter table public.report enable row level security;
drop policy if exists "report_public_read" on public.report;
create policy "report_public_read" on public.report
  for select
  using (status = 'published' or auth.role() = 'service_role');

comment on table public.report is 'Bucket / event / vendor / trend reports. DB projection of the vault report.md template. Draft rows visible only to service role.';
comment on column public.report.cited_org_ids is 'Plain text[] of organization_id values cited; intentionally not FK-constrained so cite churn does not break the report.';
