-- Migration B: expand existing fts columns to add D-weight metadata
-- (tags, slugs, handles, ticker symbols, package names, ids).
--
-- Postgres can't ALTER the expression of a generated column, so for each
-- table the pattern is:
--   1. drop the dependent GIN index
--   2. drop the column
--   3. add the new generated column
--   4. recreate the GIN index
--
-- This rewrites each table on disk. On the current data volume that's a
-- short lock; for much larger tables you'd want to do this off-hours.
--
-- Standard weighting (the same convention used in Migration A):
--   A = primary identifier (title / canonical name / headline)
--   B = secondary identifier (tagline, summary, aliases, npm/pypi names)
--   C = long-form prose (description, body_md, abstract, overview, bio)
--   D = metadata (tags, slug, handles, ticker symbols, ids, kind, layer)
--
-- Tables touched (size-ascending, smallest first so we fail fast on the
-- cheap rewrites): organization, person, event, library, product, paper,
-- report, course, course_module, news_item, youtube_video.
--
-- The immutable_array_to_string helper from Migration A is required to use
-- text[] columns inside generated columns (PG 16+ marks the built-in as
-- STABLE). It must already exist; we re-create it idempotently here as a
-- belt-and-braces measure so this migration is self-contained.

create or replace function public.immutable_array_to_string(arr text[], delim text)
returns text
language sql
immutable
parallel safe
set search_path = ''
as $$
  select array_to_string(arr, delim);
$$;

-------------------------------------------------------------------------------
-- organization
-------------------------------------------------------------------------------

drop index if exists public.organization_fts_idx;
alter table public.organization drop column if exists fts;
alter table public.organization add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english',
    coalesce(overview, '')
    || ' ' || coalesce(primary_ai_focus, '')
    || ' ' || coalesce(legal_entity_name, '')
  ), 'B') ||
  setweight(to_tsvector('english',
    coalesce(flagship_products, '')
    || ' ' || coalesce(website_domain, '')
    || ' ' || coalesce(organization_type, '')
    || ' ' || coalesce(headquarters_city, '')
    || ' ' || coalesce(headquarters_country, '')
  ), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || public.immutable_array_to_string(coalesce(categories, '{}'::text[]), ' ')
    || ' ' || public.immutable_array_to_string(coalesce(domain_layers, '{}'::text[]), ' ')
    || ' ' || coalesce(ticker_symbol, '')
    || ' ' || coalesce(github_org, '')
    || ' ' || coalesce(twitter_handle, '')
  ), 'D')
) stored;
create index if not exists organization_fts_idx on public.organization using gin (fts);
comment on column public.organization.fts is
  'FTS (A=name, B=overview+primary_ai_focus+legal_entity_name, C=flagship_products+website_domain+organization_type+headquarters_city+headquarters_country, D=slug+tags+categories+domain_layers+ticker_symbol+github_org+twitter_handle).';

-------------------------------------------------------------------------------
-- person
-------------------------------------------------------------------------------

drop index if exists public.person_fts_idx;
alter table public.person drop column if exists fts;
alter table public.person add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(full_name, '')), 'A') ||
  setweight(to_tsvector('english',
    coalesce(first_name, '')
    || ' ' || coalesce(last_name, '')
    || ' ' || coalesce(tag_line, '')
  ), 'B') ||
  setweight(to_tsvector('english',
    coalesce(bio, '')
    || ' ' || coalesce(expertise_or_focus_area, '')
    || ' ' || coalesce(role_title, '')
    || ' ' || coalesce(notable_for, '')
  ), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(expertise_tags, '{}'::text[]), ' ')
    || ' ' || coalesce(twitter_handle, '')
    || ' ' || coalesce(github_username, '')
    || ' ' || coalesce(country, '')
  ), 'D')
) stored;
create index if not exists person_fts_idx on public.person using gin (fts);
comment on column public.person.fts is
  'FTS (A=full_name, B=first_name+last_name+tag_line, C=bio+expertise_or_focus_area+role_title+notable_for, D=slug+expertise_tags+twitter_handle+github_username+country).';

-------------------------------------------------------------------------------
-- event
-------------------------------------------------------------------------------

drop index if exists public.event_fts_idx;
alter table public.event drop column if exists fts;
alter table public.event add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(tagline, '')), 'B') ||
  setweight(to_tsvector('english',
    coalesce(description, '')
    || ' ' || coalesce(venue, '')
    || ' ' || coalesce(city, '')
    || ' ' || coalesce(country, '')
  ), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(topic_tags, '{}'::text[]), ' ')
    || ' ' || coalesce(series, '')
  ), 'D')
) stored;
create index if not exists event_fts_idx on public.event using gin (fts);
comment on column public.event.fts is
  'FTS (A=name, B=tagline, C=description+venue+city+country, D=slug+topic_tags+series).';

-------------------------------------------------------------------------------
-- library
-------------------------------------------------------------------------------

drop index if exists public.library_fts_idx;
alter table public.library drop column if exists fts;
alter table public.library add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english',
    coalesce(tagline, '')
    || ' ' || coalesce(npm_name, '')
    || ' ' || coalesce(pypi_name, '')
    || ' ' || coalesce(huggingface_id, '')
  ), 'B') ||
  setweight(to_tsvector('english',
    coalesce(description, '')
    || ' ' || coalesce(language, '')
  ), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || coalesce(category, '')
    || ' ' || coalesce(kind, '')
    || ' ' || coalesce(domain_layer, '')
  ), 'D')
) stored;
create index if not exists library_fts_idx on public.library using gin (fts);
comment on column public.library.fts is
  'FTS (A=name, B=tagline+npm_name+pypi_name+huggingface_id, C=description+language, D=slug+tags+category+kind+domain_layer).';

-------------------------------------------------------------------------------
-- product
-------------------------------------------------------------------------------

drop index if exists public.product_fts_idx;
alter table public.product drop column if exists fts;
alter table public.product add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(tagline, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || public.immutable_array_to_string(coalesce(categories, '{}'::text[]), ' ')
    || ' ' || coalesce(kind, '')
    || ' ' || coalesce(pricing_model, '')
    || ' ' || coalesce(domain_layer, '')
  ), 'D')
) stored;
create index if not exists product_fts_idx on public.product using gin (fts);
comment on column public.product.fts is
  'FTS (A=name, B=tagline, C=description, D=slug+tags+categories+kind+pricing_model+domain_layer).';

-------------------------------------------------------------------------------
-- paper
-------------------------------------------------------------------------------

drop index if exists public.paper_fts_idx;
alter table public.paper drop column if exists fts;
alter table public.paper add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(abstract, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(venue, '')), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || public.immutable_array_to_string(coalesce(categories, '{}'::text[]), ' ')
    || ' ' || coalesce(arxiv_id, '')
    || ' ' || coalesce(doi, '')
  ), 'D')
) stored;
create index if not exists paper_fts_idx on public.paper using gin (fts);
comment on column public.paper.fts is
  'FTS (A=title, B=abstract, C=venue, D=slug+tags+categories+arxiv_id+doi).';

-------------------------------------------------------------------------------
-- report
-------------------------------------------------------------------------------

drop index if exists public.report_fts_idx;
alter table public.report drop column if exists fts;
alter table public.report add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(summary, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(body_md, '')), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || coalesce(bucket, '')
    || ' ' || coalesce(report_kind, '')
    || ' ' || coalesce(domain_layer, '')
  ), 'D')
) stored;
create index if not exists report_fts_idx on public.report using gin (fts);
comment on column public.report.fts is
  'FTS (A=title, B=summary, C=body_md, D=slug+tags+bucket+report_kind+domain_layer).';

-------------------------------------------------------------------------------
-- course
-------------------------------------------------------------------------------

drop index if exists public.course_fts_gin;
drop index if exists public.course_fts_idx;
alter table public.course drop column if exists fts;
alter table public.course add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(summary, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(narrative_md, '')), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || coalesce(domain_bucket, '')
    || ' ' || coalesce(domain_layer, '')
  ), 'D')
) stored;
create index if not exists course_fts_idx on public.course using gin (fts);
comment on column public.course.fts is
  'FTS (A=title, B=summary, C=narrative_md, D=slug+domain_bucket+domain_layer).';

-------------------------------------------------------------------------------
-- course_module
-------------------------------------------------------------------------------

drop index if exists public.course_module_fts_gin;
drop index if exists public.course_module_fts_idx;
alter table public.course_module drop column if exists fts;
alter table public.course_module add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(search_text, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(body_md, '')), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(domain_buckets, '{}'::text[]), ' ')
    || ' ' || coalesce(difficulty, '')
    || ' ' || coalesce(body_kind, '')
  ), 'D')
) stored;
create index if not exists course_module_fts_idx on public.course_module using gin (fts);
comment on column public.course_module.fts is
  'FTS (A=title, B=search_text, C=body_md, D=slug+domain_buckets+difficulty+body_kind).';

-------------------------------------------------------------------------------
-- news_item
-------------------------------------------------------------------------------

drop index if exists public.news_item_fts_idx;
alter table public.news_item drop column if exists fts;
alter table public.news_item add column fts tsvector
generated always as (
  setweight(to_tsvector('english',
    coalesce(title, '') || ' ' || coalesce(headline, '')
  ), 'A') ||
  setweight(to_tsvector('english', coalesce(summary, '')), 'B') ||
  setweight(to_tsvector('english',
    coalesce(body_md, '') || ' ' || coalesce(source_name, '')
  ), 'C') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || public.immutable_array_to_string(coalesce(categories, '{}'::text[]), ' ')
    || ' ' || coalesce(kind, '')
    || ' ' || coalesce(domain_layer, '')
    || ' ' || coalesce(funding_round, '')
  ), 'D')
) stored;
create index if not exists news_item_fts_idx on public.news_item using gin (fts);
comment on column public.news_item.fts is
  'FTS (A=title+headline, B=summary, C=body_md+source_name, D=slug+tags+categories+kind+domain_layer+funding_round).';

-------------------------------------------------------------------------------
-- youtube_video
-------------------------------------------------------------------------------

drop index if exists public.youtube_video_fts_idx;
alter table public.youtube_video drop column if exists fts;
alter table public.youtube_video add column fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
  setweight(to_tsvector('english',
    coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || coalesce(category, '')
    || ' ' || coalesce(language, '')
    || ' ' || coalesce(domain_layer, '')
  ), 'D')
) stored;
create index if not exists youtube_video_fts_idx on public.youtube_video using gin (fts);
comment on column public.youtube_video.fts is
  'FTS (A=title, B=description, D=slug+tags+category+language+domain_layer).';
