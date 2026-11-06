-- Migration A: add tsvector + GIN FTS to the four entity tables that don't
-- have one yet (session, repo, image, notes). Mirrors the generated-column
-- pattern already used on person/organization/youtube_video/event/library/
-- product/paper/report/course/course_module/news_item.
--
-- Weighting convention (standardised across the codebase):
--   A = primary identifier the user types (title / canonical name)
--   B = secondary identifier or short description (tagline, summary, aliases)
--   C = long-form prose (description, body_md, abstract, overview, bio)
--   D = metadata, classifiers, handles (tags, categories, slug, kind, handles)
--
-- D-weight bumps a row when the only match is on its tags/handles, but never
-- outranks a true title/description match.

-------------------------------------------------------------------------------
-- 0. Helper: immutable_array_to_string
-- Postgres 16 downgraded array_to_string() from IMMUTABLE to STABLE because
-- the result of array_to_string(anyarray, text) can depend on locale for
-- non-text element types (timestamps, etc.). For text[] arrays the output is
-- deterministic, so we wrap it in an IMMUTABLE function that's safe to use
-- inside generated columns. Used by every fts column that flattens an array.
-------------------------------------------------------------------------------

create or replace function public.immutable_array_to_string(arr text[], delim text)
returns text
language sql
immutable
parallel safe
set search_path = ''
as $$
  select array_to_string(arr, delim);
$$;

comment on function public.immutable_array_to_string(text[], text) is
  'IMMUTABLE wrapper around array_to_string for text[] arrays. Required because PG 16+ marks the built-in as STABLE (locale-dependent for non-text types), which prevents its use inside GENERATED columns. Safe for text[] only.';

-------------------------------------------------------------------------------
-- session
-------------------------------------------------------------------------------

alter table public.session add column if not exists fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(extended_description, '')), 'C') ||
  setweight(to_tsvector('english',
    public.immutable_array_to_string(coalesce(tags, '{}'::text[]), ' ')
    || ' ' || coalesce(category, '')
    || ' ' || coalesce(track, '')
    || ' ' || coalesce(level, '')
    || ' ' || coalesce(language, '')
    || ' ' || coalesce(room, '')
    || ' ' || coalesce(slug, '')
  ), 'D')
) stored;

create index if not exists session_fts_idx on public.session using gin (fts);

comment on column public.session.fts is
  'Full-text search vector (weights: A=title, B=description, C=extended_description, D=tags/category/track/level/language/room/slug). Use websearch_to_tsquery via PostgREST .textSearch() or the search_all() RPC.';

-------------------------------------------------------------------------------
-- repo
-------------------------------------------------------------------------------

alter table public.repo add column if not exists fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(github_repo, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(github_org, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(primary_language, '')), 'C') ||
  setweight(to_tsvector('english',
    public.immutable_array_to_string(coalesce(topics, '{}'::text[]), ' ')
    || ' ' || coalesce(slug, '')
    || ' ' || coalesce(license, '')
  ), 'D')
) stored;

create index if not exists repo_fts_idx on public.repo using gin (fts);

comment on column public.repo.fts is
  'Full-text search vector (weights: A=github_repo, B=description+github_org, C=primary_language, D=topics+slug+license).';

-------------------------------------------------------------------------------
-- image
-------------------------------------------------------------------------------

alter table public.image add column if not exists fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(alt, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(caption, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(attribution, '')), 'C') ||
  setweight(to_tsvector('english',
    coalesce(mime_type, '') || ' ' || coalesce(source, '')
  ), 'D')
) stored;

create index if not exists image_fts_idx on public.image using gin (fts);

comment on column public.image.fts is
  'Full-text search vector (weights: A=alt+title, B=caption, C=attribution, D=mime_type+source). Lets the asset library be searched by description, not just by attached entity.';

-------------------------------------------------------------------------------
-- notes
-- RLS already restricts notes_manage_own; the FTS column inherits row-level
-- visibility automatically (RLS is row-level, not column-level), so users
-- only search across their own notes.
-------------------------------------------------------------------------------

alter table public.notes add column if not exists fts tsvector
generated always as (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(content_text, '')), 'B') ||
  setweight(to_tsvector('english',
    coalesce(entity_type, '') || ' ' || coalesce(entity_title, '')
  ), 'D')
) stored;

create index if not exists notes_fts_idx on public.notes using gin (fts);

comment on column public.notes.fts is
  'Full-text search vector (weights: A=title, B=content_text, D=entity_type+entity_title). Per-user search; RLS restricts results to the calling user via notes_manage_own.';
