-- Migration D: pg_trgm extension + trigram GIN indexes for fuzzy search.
--
-- The fts columns added in Migrations A/B handle exact / morphological /
-- multi-token search ("agent orchestration" matches "orchestrating agents").
-- They do NOT handle:
--   - typos:                  "anthorpic" should still find "Anthropic"
--   - partial substrings:     "openai" should match in the middle of a string
--   - prefix-as-you-type:     instant search where the user has typed 3 chars
--
-- pg_trgm closes that gap. Three things become fast and indexable:
--   col ILIKE '%foo%'             -- partial substring (case-insensitive)
--   col % 'foo'                   -- similarity > pg_trgm.similarity_threshold
--   col <-> 'foo'                 -- ascending similarity distance (use in ORDER BY)
--
-- Indexed columns are the user-typed identifiers ONLY (names, slugs, handles,
-- ticker symbols, package names, github org/repo). NOT bodies — trigram on
-- long prose is large and rarely useful (FTS already handles that).
--
-- Each index uses `gin (lower(col) gin_trgm_ops)` so a query like
--   where lower(col) ilike '%' || lower($1) || '%'
-- can use the index. Lower-casing on both sides removes the case dimension.

create extension if not exists pg_trgm with schema extensions;

-------------------------------------------------------------------------------
-- person
-------------------------------------------------------------------------------

create index if not exists person_full_name_trgm
  on public.person using gin (lower(full_name) extensions.gin_trgm_ops)
  where full_name is not null;
create index if not exists person_slug_trgm
  on public.person using gin (lower(slug) extensions.gin_trgm_ops);
create index if not exists person_twitter_handle_trgm
  on public.person using gin (lower(twitter_handle) extensions.gin_trgm_ops)
  where twitter_handle is not null;
create index if not exists person_github_username_trgm
  on public.person using gin (lower(github_username) extensions.gin_trgm_ops)
  where github_username is not null;

-------------------------------------------------------------------------------
-- organization
-------------------------------------------------------------------------------

create index if not exists organization_name_trgm
  on public.organization using gin (lower(name) extensions.gin_trgm_ops)
  where name is not null;
create index if not exists organization_slug_trgm
  on public.organization using gin (lower(slug) extensions.gin_trgm_ops);
create index if not exists organization_ticker_trgm
  on public.organization using gin (lower(ticker_symbol) extensions.gin_trgm_ops)
  where ticker_symbol is not null;
create index if not exists organization_github_org_trgm
  on public.organization using gin (lower(github_org) extensions.gin_trgm_ops)
  where github_org is not null;
create index if not exists organization_twitter_handle_trgm
  on public.organization using gin (lower(twitter_handle) extensions.gin_trgm_ops)
  where twitter_handle is not null;

-------------------------------------------------------------------------------
-- library — alternate names matter most ("langchain" vs npm name vs pypi name)
-------------------------------------------------------------------------------

create index if not exists library_name_trgm
  on public.library using gin (lower(name) extensions.gin_trgm_ops);
create index if not exists library_slug_trgm
  on public.library using gin (lower(slug) extensions.gin_trgm_ops);
create index if not exists library_npm_name_trgm
  on public.library using gin (lower(npm_name) extensions.gin_trgm_ops)
  where npm_name is not null;
create index if not exists library_pypi_name_trgm
  on public.library using gin (lower(pypi_name) extensions.gin_trgm_ops)
  where pypi_name is not null;

-------------------------------------------------------------------------------
-- product / event / paper / news_item / report / course / course_module
-------------------------------------------------------------------------------

create index if not exists product_name_trgm
  on public.product using gin (lower(name) extensions.gin_trgm_ops);
create index if not exists product_slug_trgm
  on public.product using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists event_name_trgm
  on public.event using gin (lower(name) extensions.gin_trgm_ops);
create index if not exists event_slug_trgm
  on public.event using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists paper_title_trgm
  on public.paper using gin (lower(title) extensions.gin_trgm_ops);
create index if not exists paper_slug_trgm
  on public.paper using gin (lower(slug) extensions.gin_trgm_ops);
create index if not exists paper_arxiv_id_trgm
  on public.paper using gin (lower(arxiv_id) extensions.gin_trgm_ops)
  where arxiv_id is not null;

create index if not exists news_item_title_trgm
  on public.news_item using gin (lower(title) extensions.gin_trgm_ops);
create index if not exists news_item_slug_trgm
  on public.news_item using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists report_title_trgm
  on public.report using gin (lower(title) extensions.gin_trgm_ops);
create index if not exists report_slug_trgm
  on public.report using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists course_title_trgm
  on public.course using gin (lower(title) extensions.gin_trgm_ops);
create index if not exists course_slug_trgm
  on public.course using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists course_module_title_trgm
  on public.course_module using gin (lower(title) extensions.gin_trgm_ops);
create index if not exists course_module_slug_trgm
  on public.course_module using gin (lower(slug) extensions.gin_trgm_ops);

-------------------------------------------------------------------------------
-- youtube_video / session / repo
-------------------------------------------------------------------------------

create index if not exists youtube_video_title_trgm
  on public.youtube_video using gin (lower(title) extensions.gin_trgm_ops)
  where title is not null;
create index if not exists youtube_video_slug_trgm
  on public.youtube_video using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists session_title_trgm
  on public.session using gin (lower(title) extensions.gin_trgm_ops)
  where title is not null;
create index if not exists session_slug_trgm
  on public.session using gin (lower(slug) extensions.gin_trgm_ops);

create index if not exists repo_github_repo_trgm
  on public.repo using gin (lower(github_repo) extensions.gin_trgm_ops);
create index if not exists repo_slug_trgm
  on public.repo using gin (lower(slug) extensions.gin_trgm_ops);

-------------------------------------------------------------------------------
-- profiles (user-facing entity, useful for @-mention search)
-------------------------------------------------------------------------------

create index if not exists profiles_username_trgm
  on public.profiles using gin (lower(username) extensions.gin_trgm_ops)
  where username is not null;
create index if not exists profiles_display_name_trgm
  on public.profiles using gin (lower(display_name) extensions.gin_trgm_ops)
  where display_name is not null;

-------------------------------------------------------------------------------
-- Fuzzy-search RPC: search_fuzzy(prefix, kind?, limit_count?)
-- Returns the best trigram-similarity matches across user-typed identifier
-- columns. Optimised for instant search / "did you mean" UX where the user
-- has typed 2-5 characters.
--
-- Threshold of 0.15 is intentionally permissive. Tighten with a where
-- clause on similarity > X if needed.
-------------------------------------------------------------------------------

create or replace function public.search_fuzzy(
  prefix        text,
  kinds         text[]  default null,
  limit_count   int     default 12
)
returns table (
  entity_kind text,
  entity_id   text,
  slug        text,
  title       text,
  similarity  real
)
language sql
stable
security invoker
-- Include `extensions` so the `%` operator from pg_trgm resolves; matches
-- the pattern used by public.match_chunks for the pgvector operators.
set search_path = public, extensions
as $$
  with normalized as (
    select lower(coalesce(prefix, '')) as q
  ),
  hits as (
    select 'organization'::text as entity_kind,
      o.organization_id::text as entity_id,
      o.slug,
      o.name as title,
      greatest(
        extensions.similarity(lower(o.name), n.q),
        extensions.similarity(lower(o.slug), n.q),
        extensions.similarity(lower(coalesce(o.ticker_symbol, '')), n.q)
      ) as similarity
    from public.organization o, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'organization' = any(kinds))
      and (lower(o.name) % n.q or lower(o.slug) % n.q or lower(coalesce(o.ticker_symbol,'')) % n.q)

    union all
    select 'person', p.person_id::text, p.slug, p.full_name,
      greatest(
        extensions.similarity(lower(coalesce(p.full_name, '')), n.q),
        extensions.similarity(lower(p.slug), n.q),
        extensions.similarity(lower(coalesce(p.twitter_handle, '')), n.q),
        extensions.similarity(lower(coalesce(p.github_username, '')), n.q)
      )
    from public.person p, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'person' = any(kinds))
      and (lower(coalesce(p.full_name,'')) % n.q or lower(p.slug) % n.q
           or lower(coalesce(p.twitter_handle,'')) % n.q
           or lower(coalesce(p.github_username,'')) % n.q)

    union all
    select 'library', l.slug, l.slug, l.name,
      greatest(
        extensions.similarity(lower(l.name), n.q),
        extensions.similarity(lower(l.slug), n.q),
        extensions.similarity(lower(coalesce(l.npm_name, '')), n.q),
        extensions.similarity(lower(coalesce(l.pypi_name, '')), n.q)
      )
    from public.library l, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'library' = any(kinds))
      and (lower(l.name) % n.q or lower(l.slug) % n.q
           or lower(coalesce(l.npm_name,'')) % n.q
           or lower(coalesce(l.pypi_name,'')) % n.q)

    union all
    select 'product', pr.slug, pr.slug, pr.name,
      greatest(extensions.similarity(lower(pr.name), n.q),
               extensions.similarity(lower(pr.slug), n.q))
    from public.product pr, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'product' = any(kinds))
      and (lower(pr.name) % n.q or lower(pr.slug) % n.q)

    union all
    select 'event', e.event_id::text, e.slug, e.name,
      greatest(extensions.similarity(lower(e.name), n.q),
               extensions.similarity(lower(e.slug), n.q))
    from public.event e, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'event' = any(kinds))
      and (lower(e.name) % n.q or lower(e.slug) % n.q)

    union all
    select 'paper', pa.slug, pa.slug, pa.title,
      greatest(extensions.similarity(lower(pa.title), n.q),
               extensions.similarity(lower(pa.slug), n.q),
               extensions.similarity(lower(coalesce(pa.arxiv_id,'')), n.q))
    from public.paper pa, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'paper' = any(kinds))
      and (lower(pa.title) % n.q or lower(pa.slug) % n.q
           or lower(coalesce(pa.arxiv_id,'')) % n.q)

    union all
    select 'youtube_video', yv.video_id::text, yv.slug, yv.title,
      greatest(extensions.similarity(lower(coalesce(yv.title,'')), n.q),
               extensions.similarity(lower(yv.slug), n.q))
    from public.youtube_video yv, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'youtube_video' = any(kinds))
      and (lower(coalesce(yv.title,'')) % n.q or lower(yv.slug) % n.q)

    union all
    select 'repo', rp.slug, rp.slug, rp.github_org || '/' || rp.github_repo,
      greatest(extensions.similarity(lower(rp.github_repo), n.q),
               extensions.similarity(lower(rp.slug), n.q))
    from public.repo rp, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'repo' = any(kinds))
      and (lower(rp.github_repo) % n.q or lower(rp.slug) % n.q)

    union all
    select 'news_item', ni.news_item_id::text, ni.slug, ni.title,
      greatest(extensions.similarity(lower(ni.title), n.q),
               extensions.similarity(lower(ni.slug), n.q))
    from public.news_item ni, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'news_item' = any(kinds))
      and ni.status = 'published'
      and (lower(ni.title) % n.q or lower(ni.slug) % n.q)
  )
  select entity_kind, entity_id, slug, title, similarity
  from hits
  order by similarity desc, title
  limit greatest(coalesce(limit_count, 12), 1);
$$;

comment on function public.search_fuzzy(text, text[], int) is
  'Trigram-based fuzzy search across user-typed identifier columns (names, slugs, handles, package names). Use for instant search / typo tolerance / "did you mean" UX. Complements search_all() which does FTS-based exact/morphological matching.';

grant execute on function public.search_fuzzy(text, text[], int) to anon, authenticated;
