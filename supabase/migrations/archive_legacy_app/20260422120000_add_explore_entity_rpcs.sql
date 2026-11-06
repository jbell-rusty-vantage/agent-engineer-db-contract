-- M2 / U3.3: per-entity-kind Explore RPCs.
--
-- Powers `/explore/[type]` pages with weighted FTS + facet filters +
-- ts_headline highlights + ts_rank_cd ordering. One RPC per kind so each
-- can use its own column shape, but every RPC returns the same
-- `(entity_id, slug, title, subtitle, image_url, description, snippet,
--   rank, popularity, recent_at, total_count, layer, category, tags)`
-- so the TS layer is uniform.
--
-- Each RPC applies the FTS predicate via the table's generated `fts`
-- column (GIN-indexed). When `q` is non-empty, results are ranked by
-- `ts_rank_cd(fts, websearch_to_tsquery('english', q))` and snippets are
-- generated via ts_headline; otherwise the requested sort takes over.
--
-- Optional facet args:
--   layers      text[]  AND'd via `domain_layer = any(layers)` (or
--                       `domain_layers && layers` for multi-layer tables)
--   categories  text[]  AND'd via `category = any(categories)` (or
--                       `categories && categories` for multi-cat tables)
--   tags        text[]  AND'd via `tags && tags`
--   sort        text    'relevance' | 'popularity' | 'recent' | 'alpha'
--                       (default 'relevance' when q is non-empty, else
--                       'popularity'; falls back to 'alpha' when there is
--                       no popularity signal for that kind)
--   limit_count int     default 24, max 100
--   offset_count int    default 0
--
-- Security: SECURITY INVOKER so RLS public-read policies still apply.
-- All target tables ship with `public_read` policies.

set search_path = public, extensions;

-- ============================================================================
-- explore_people
-- ============================================================================
create or replace function public.explore_people(
  q             text     default null,
  layers        text[]   default null,  -- ignored: person has no domain_layer column
  categories    text[]   default null,  -- ignored: person has no category column
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0
)
returns table (
  entity_id     text,
  slug          text,
  title         text,
  subtitle      text,
  image_url     text,
  description   text,
  snippet       text,
  rank          real,
  popularity    real,
  recent_at     timestamptz,
  total_count   bigint,
  layer         text,
  category      text,
  out_tags      text[]
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  filtered as (
    select
      p.person_id::text                     as entity_id,
      p.slug                                as slug,
      coalesce(p.full_name, p.slug)         as title,
      coalesce(p.tag_line, p.role_title)    as subtitle,
      p.sessionize_profile_picture_url      as image_url,
      coalesce(p.notable_for, p.bio)        as description,
      coalesce(p.bio, p.notable_for, '')    as headline_src,
      p.fts                                 as fts,
      0::real                               as popularity,
      p.updated_at                          as recent_at,
      null::text                            as layer,
      null::text                            as category,
      p.expertise_tags                      as out_tags
    from public.person p, tsq
    where (tsq.q is null or p.fts @@ tsq.q)
      and (tags is null or array_length(tags, 1) is null
           or p.expertise_tags && tags)
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                      as total_count,
      f.layer, f.category, f.out_tags
    from filtered f, tsq
  )
  select *
  from ranked
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then popularity end desc,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_people(text, text[], text[], text[], text, int, int)
  to anon, authenticated;

comment on function public.explore_people(text, text[], text[], text[], text, int, int) is
  'Per-entity FTS for /explore/people. Filters: tags (against expertise_tags). Sort: relevance|popularity|recent|alpha. Returns ts_headline snippet and ts_rank_cd rank when q is non-empty.';

-- ============================================================================
-- explore_organizations
-- ============================================================================
create or replace function public.explore_organizations(
  q             text     default null,
  layers        text[]   default null,
  categories    text[]   default null,
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0
)
returns table (
  entity_id     text,
  slug          text,
  title         text,
  subtitle      text,
  image_url     text,
  description   text,
  snippet       text,
  rank          real,
  popularity    real,
  recent_at     timestamptz,
  total_count   bigint,
  layer         text,
  category      text,
  out_tags      text[]
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  filtered as (
    select
      o.organization_id::text                       as entity_id,
      o.slug                                        as slug,
      coalesce(o.name, o.slug)                      as title,
      coalesce(o.primary_ai_focus, o.organization_type) as subtitle,
      o.logo_url                                    as image_url,
      coalesce(o.overview, o.flagship_products)     as description,
      coalesce(o.overview, o.flagship_products, '') as headline_src,
      o.fts                                         as fts,
      coalesce(o.funding_total_usd::real, 0)        as popularity,
      o.updated_at                                  as recent_at,
      coalesce(o.domain_layers[1], null)            as layer,
      coalesce(o.categories[1], null)               as category,
      o.tags                                        as out_tags
    from public.organization o, tsq
    where (tsq.q is null or o.fts @@ tsq.q)
      and (layers is null or array_length(layers, 1) is null
           or o.domain_layers && layers)
      and (categories is null or array_length(categories, 1) is null
           or o.categories && categories)
      and (tags is null or array_length(tags, 1) is null
           or o.tags && tags)
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                              as total_count,
      f.layer, f.category, f.out_tags
    from filtered f, tsq
  )
  select *
  from ranked
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then popularity end desc,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_organizations(text, text[], text[], text[], text, int, int)
  to anon, authenticated;

comment on function public.explore_organizations(text, text[], text[], text[], text, int, int) is
  'Per-entity FTS for /explore/organizations. Filters: layers (against domain_layers), categories (against categories), tags (against tags).';

-- ============================================================================
-- explore_libraries
-- ============================================================================
create or replace function public.explore_libraries(
  q             text     default null,
  layers        text[]   default null,
  categories    text[]   default null,
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0
)
returns table (
  entity_id     text,
  slug          text,
  title         text,
  subtitle      text,
  image_url     text,
  description   text,
  snippet       text,
  rank          real,
  popularity    real,
  recent_at     timestamptz,
  total_count   bigint,
  layer         text,
  category      text,
  out_tags      text[]
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  filtered as (
    select
      l.slug                                  as entity_id,
      l.slug                                  as slug,
      coalesce(l.name, l.slug)                as title,
      coalesce(l.tagline, l.kind)             as subtitle,
      null::text                              as image_url,
      l.description                           as description,
      coalesce(l.description, l.tagline, '')  as headline_src,
      l.fts                                   as fts,
      coalesce(l.popularity_score::real, 0)   as popularity,
      l.latest_release_at::timestamptz        as recent_at,
      l.domain_layer                          as layer,
      l.category                              as category,
      l.tags                                  as out_tags
    from public.library l, tsq
    where (tsq.q is null or l.fts @@ tsq.q)
      and (layers is null or array_length(layers, 1) is null
           or l.domain_layer = any(layers))
      and (categories is null or array_length(categories, 1) is null
           or l.category = any(categories))
      and (tags is null or array_length(tags, 1) is null
           or l.tags && tags)
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                        as total_count,
      f.layer, f.category, f.out_tags
    from filtered f, tsq
  )
  select *
  from ranked
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then popularity end desc,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_libraries(text, text[], text[], text[], text, int, int)
  to anon, authenticated;

comment on function public.explore_libraries(text, text[], text[], text[], text, int, int) is
  'Per-entity FTS for /explore/libraries. Popularity = stars+forks*3+downloads. Filters: layers, categories, tags.';

-- ============================================================================
-- explore_papers
-- ============================================================================
create or replace function public.explore_papers(
  q             text     default null,
  layers        text[]   default null,
  categories    text[]   default null,
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0
)
returns table (
  entity_id     text,
  slug          text,
  title         text,
  subtitle      text,
  image_url     text,
  description   text,
  snippet       text,
  rank          real,
  popularity    real,
  recent_at     timestamptz,
  total_count   bigint,
  layer         text,
  category      text,
  out_tags      text[]
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  filtered as (
    select
      pa.slug                                 as entity_id,
      pa.slug                                 as slug,
      pa.title                                as title,
      coalesce(pa.venue, pa.arxiv_id)         as subtitle,
      null::text                              as image_url,
      pa.abstract                             as description,
      coalesce(pa.abstract, '')               as headline_src,
      pa.fts                                  as fts,
      coalesce(pa.popularity_score::real, 0)  as popularity,
      pa.published_on::timestamptz            as recent_at,
      pa.domain_layer                         as layer,
      coalesce(pa.categories[1], null)        as category,
      pa.tags                                 as out_tags
    from public.paper pa, tsq
    where (tsq.q is null or pa.fts @@ tsq.q)
      and (layers is null or array_length(layers, 1) is null
           or pa.domain_layer = any(layers))
      and (categories is null or array_length(categories, 1) is null
           or pa.categories && categories)
      and (tags is null or array_length(tags, 1) is null
           or pa.tags && tags)
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                        as total_count,
      f.layer, f.category, f.out_tags
    from filtered f, tsq
  )
  select *
  from ranked
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then popularity end desc,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_papers(text, text[], text[], text[], text, int, int)
  to anon, authenticated;

comment on function public.explore_papers(text, text[], text[], text[], text, int, int) is
  'Per-entity FTS for /explore/papers. Popularity = citation_count. recent_at = published_on.';

-- ============================================================================
-- explore_sessions (talks)
-- ============================================================================
create or replace function public.explore_sessions(
  q             text     default null,
  layers        text[]   default null,
  categories    text[]   default null,
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0
)
returns table (
  entity_id     text,
  slug          text,
  title         text,
  subtitle      text,
  image_url     text,
  description   text,
  snippet       text,
  rank          real,
  popularity    real,
  recent_at     timestamptz,
  total_count   bigint,
  layer         text,
  category      text,
  out_tags      text[]
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  filtered as (
    select
      s.session_id::text                      as entity_id,
      s.slug                                  as slug,
      coalesce(s.title, s.slug)               as title,
      coalesce(s.track, s.session_format)     as subtitle,
      null::text                              as image_url,
      coalesce(s.description, s.extended_description) as description,
      coalesce(s.description, s.extended_description, '') as headline_src,
      s.fts                                   as fts,
      0::real                                 as popularity,
      s.scheduled_at                          as recent_at,
      s.domain_layer                          as layer,
      s.category                              as category,
      s.tags                                  as out_tags
    from public.session s, tsq
    where (tsq.q is null or s.fts @@ tsq.q)
      and (layers is null or array_length(layers, 1) is null
           or s.domain_layer = any(layers))
      and (categories is null or array_length(categories, 1) is null
           or s.category = any(categories))
      and (tags is null or array_length(tags, 1) is null
           or s.tags && tags)
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                        as total_count,
      f.layer, f.category, f.out_tags
    from filtered f, tsq
  )
  select *
  from ranked
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then recent_at end desc nulls last,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_sessions(text, text[], text[], text[], text, int, int)
  to anon, authenticated;

comment on function public.explore_sessions(text, text[], text[], text[], text, int, int) is
  'Per-entity FTS for /explore/sessions (conference talks). Sessions have no popularity column; popularity sort falls back to recent_at.';

-- ============================================================================
-- explore_youtube_videos
-- ============================================================================
create or replace function public.explore_youtube_videos(
  q             text     default null,
  layers        text[]   default null,
  categories    text[]   default null,
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0
)
returns table (
  entity_id     text,
  slug          text,
  title         text,
  subtitle      text,
  image_url     text,
  description   text,
  snippet       text,
  rank          real,
  popularity    real,
  recent_at     timestamptz,
  total_count   bigint,
  layer         text,
  category      text,
  out_tags      text[]
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  filtered as (
    select
      yv.video_id                                       as entity_id,
      yv.slug                                           as slug,
      coalesce(yv.title, yv.slug)                       as title,
      yc.channel_title                                  as subtitle,
      yv.thumbnail_url                                  as image_url,
      yv.description                                    as description,
      coalesce(yv.description, '')                      as headline_src,
      yv.fts                                            as fts,
      coalesce(yv.popularity_score::real, yv.view_count::real, 0) as popularity,
      yv.published_at                                   as recent_at,
      yv.domain_layer                                   as layer,
      yv.category                                       as category,
      yv.tags                                           as out_tags
    from public.youtube_video yv
      left join public.youtube_channel yc on yc.channel_id = yv.channel_id,
      tsq
    where (tsq.q is null or yv.fts @@ tsq.q)
      and (layers is null or array_length(layers, 1) is null
           or yv.domain_layer = any(layers))
      and (categories is null or array_length(categories, 1) is null
           or yv.category = any(categories))
      and (tags is null or array_length(tags, 1) is null
           or yv.tags && tags)
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                                  as total_count,
      f.layer, f.category, f.out_tags
    from filtered f, tsq
  )
  select *
  from ranked
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then popularity end desc,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_youtube_videos(text, text[], text[], text[], text, int, int)
  to anon, authenticated;

comment on function public.explore_youtube_videos(text, text[], text[], text[], text, int, int) is
  'Per-entity FTS for /explore/youtube_videos. Popularity = popularity_score (else view_count). Subtitle joins youtube_channel.channel_title.';
