-- Person avatars: prefer Sessionize headshot, then ai.engineer image/URL (aligns
-- with DossierHero + lib/db/entity-summary pickImage). Replaces only Sessionize
-- in RPCs; UI shows initials when both are null or image load fails.
-- Applied after 20260423120000 so search_all / search_fuzzy keep this behavior.

set search_path = public, extensions;

-- ============================================================================
-- explore_people: image_url fallback
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
      coalesce(
        p.sessionize_profile_picture_url,
        p.ai_engineer_url
      )                                    as image_url,
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

-- ============================================================================
-- search_all: person image_url (same coalesce; signature unchanged)
-- ============================================================================
create or replace function public.search_all(
  q             text,
  limit_count   int     default 20,
  kinds         text[]  default null
)
returns table (
  entity_kind text,
  entity_id   text,
  slug        text,
  title       text,
  subtitle    text,
  image_url   text,
  snippet     text,
  rank        real
)
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select websearch_to_tsquery('english', coalesce(q, '')) as q
  ),
  hits as (
    select
      'organization'::text as entity_kind,
      o.organization_id::text as entity_id,
      o.slug,
      o.name as title,
      o.primary_ai_focus as subtitle,
      o.logo_url as image_url,
      coalesce(o.overview, o.flagship_products, '') as headline_src,
      o.fts as fts
    from public.organization o, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'organization' = any(kinds))
      and o.fts @@ tsq.q

    union all
    select 'person', p.person_id::text, p.slug,
      coalesce(p.full_name, p.first_name || ' ' || p.last_name, p.slug),
      coalesce(p.tag_line, p.role_title),
      coalesce(p.sessionize_profile_picture_url, p.ai_engineer_url),
      coalesce(p.bio, p.notable_for, ''),
      p.fts
    from public.person p, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'person' = any(kinds))
      and p.fts @@ tsq.q

    union all
    select 'event', e.event_id::text, e.slug,
      e.name, e.tagline,
      null::text,
      coalesce(e.description, e.venue, ''), e.fts
    from public.event e, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'event' = any(kinds))
      and e.fts @@ tsq.q

    union all
    select 'library', l.slug, l.slug,
      l.name, l.tagline,
      null::text,
      coalesce(l.description, ''), l.fts
    from public.library l, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'library' = any(kinds))
      and l.fts @@ tsq.q

    union all
    select 'product', pr.slug, pr.slug,
      pr.name, pr.tagline,
      null::text,
      coalesce(pr.description, ''), pr.fts
    from public.product pr, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'product' = any(kinds))
      and pr.fts @@ tsq.q

    union all
    select 'paper', pa.slug, pa.slug,
      pa.title, pa.venue,
      null::text,
      coalesce(pa.abstract, ''), pa.fts
    from public.paper pa, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'paper' = any(kinds))
      and pa.fts @@ tsq.q

    union all
    select 'report', r.report_id::text, r.slug,
      r.title, r.report_kind,
      null::text,
      coalesce(r.summary, r.body_md, ''), r.fts
    from public.report r, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'report' = any(kinds))
      and r.fts @@ tsq.q

    union all
    select 'course', c.course_id::text, c.slug,
      c.title, c.domain_bucket,
      null::text,
      coalesce(c.summary, c.narrative_md, ''), c.fts
    from public.course c, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'course' = any(kinds))
      and c.fts @@ tsq.q
      and c.is_latest_published

    union all
    select 'course_module', cm.module_id::text, cm.slug,
      cm.title, cm.difficulty,
      null::text,
      coalesce(cm.search_text, cm.body_md, ''), cm.fts
    from public.course_module cm, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'course_module' = any(kinds))
      and cm.fts @@ tsq.q
      and cm.is_latest_published

    union all
    select 'news_item', n.news_item_id::text, n.slug,
      coalesce(n.headline, n.title), n.kind,
      n.hero_image_url,
      coalesce(n.summary, n.body_md, ''), n.fts
    from public.news_item n, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'news_item' = any(kinds))
      and n.fts @@ tsq.q
      and n.status = 'published'

    union all
    select 'youtube_video', yv.video_id::text, yv.slug,
      yv.title, yv.category,
      yv.thumbnail_url,
      coalesce(yv.description, ''), yv.fts
    from public.youtube_video yv, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'youtube_video' = any(kinds))
      and yv.fts @@ tsq.q

    union all
    select 'session', s.session_id::text, s.slug,
      coalesce(s.title, s.slug), s.track,
      null::text,
      coalesce(s.description, s.extended_description, ''), s.fts
    from public.session s, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'session' = any(kinds))
      and s.fts @@ tsq.q

    union all
    select 'repo', rp.slug, rp.slug,
      rp.github_org || '/' || rp.github_repo, rp.primary_language,
      null::text,
      coalesce(rp.description, ''), rp.fts
    from public.repo rp, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'repo' = any(kinds))
      and rp.fts @@ tsq.q

    union all
    select 'image', im.image_id::text, im.image_id::text,
      coalesce(im.title, im.alt), im.attribution,
      null::text,
      coalesce(im.caption, im.alt, ''), im.fts
    from public.image im, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'image' = any(kinds))
      and im.fts @@ tsq.q

    union all
    select 'notes', nt.id::text, nt.id::text,
      nt.title, nt.entity_type,
      null::text,
      coalesce(nt.content_text, ''), nt.fts
    from public.notes nt, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'notes' = any(kinds))
      and nt.fts @@ tsq.q
  )
  select
    h.entity_kind,
    h.entity_id,
    h.slug,
    h.title,
    h.subtitle,
    h.image_url,
    ts_headline(
      'english',
      h.headline_src,
      tsq.q,
      'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" \u2026 "'
    ) as snippet,
    ts_rank_cd(h.fts, tsq.q) as rank
  from hits h, tsq
  order by rank desc, h.title
  limit greatest(coalesce(limit_count, 20), 1);
$$;

comment on function public.search_all(text, int, text[]) is
  'Cross-entity FTS. Returns (entity_kind, entity_id, slug, title, subtitle, image_url, snippet, rank). For people, image_url is coalesce(sessionize_profile_picture_url, ai_engineer_url).';

-- ============================================================================
-- search_fuzzy: person image_url
-- ============================================================================
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
  image_url   text,
  similarity  real
)
language sql
stable
security invoker
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
      o.logo_url as image_url,
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
      coalesce(p.sessionize_profile_picture_url, p.ai_engineer_url),
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
      null::text,
      greatest(
        extensions.similarity(lower(l.name), n.q),
        extensions.similarity(lower(l.slug), n.q),
        extensions.similarity(lower(coalesce(l.npm_name, '')), n.q),
        extensions.similarity(lower(coalesce(l.pypi_name, '')), n.q)
      )
    from public.library l, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'library' = any(kinds))
      and (lower(l.name) % n.q or lower(l.slug) % n.q
           or lower(coalesce(l.npm_name,'')) % n.q or lower(coalesce(l.pypi_name,'')) % n.q)

    union all
    select 'product', pr.slug, pr.slug, pr.name,
      null::text,
      greatest(extensions.similarity(lower(pr.name), n.q),
               extensions.similarity(lower(pr.slug), n.q))
    from public.product pr, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'product' = any(kinds))
      and (lower(pr.name) % n.q or lower(pr.slug) % n.q)

    union all
    select 'event', e.event_id::text, e.slug, e.name,
      null::text,
      greatest(extensions.similarity(lower(e.name), n.q),
               extensions.similarity(lower(e.slug), n.q))
    from public.event e, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'event' = any(kinds))
      and (lower(e.name) % n.q or lower(e.slug) % n.q)

    union all
    select 'paper', pa.slug, pa.slug, pa.title,
      null::text,
      greatest(extensions.similarity(lower(pa.title), n.q),
               extensions.similarity(lower(pa.slug), n.q),
               extensions.similarity(lower(coalesce(pa.arxiv_id,'')), n.q))
    from public.paper pa, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'paper' = any(kinds))
      and (lower(pa.title) % n.q or lower(pa.slug) % n.q
           or lower(coalesce(pa.arxiv_id,'')) % n.q)

    union all
    select 'youtube_video', yv.video_id::text, yv.slug, yv.title,
      yv.thumbnail_url,
      greatest(extensions.similarity(lower(coalesce(yv.title,'')), n.q),
               extensions.similarity(lower(yv.slug), n.q))
    from public.youtube_video yv, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'youtube_video' = any(kinds))
      and (lower(coalesce(yv.title,'')) % n.q or lower(yv.slug) % n.q)

    union all
    select 'repo', rp.slug, rp.slug, rp.github_org || '/' || rp.github_repo,
      null::text,
      greatest(extensions.similarity(lower(rp.github_repo), n.q),
               extensions.similarity(lower(rp.slug), n.q))
    from public.repo rp, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'repo' = any(kinds))
      and (lower(rp.github_repo) % n.q or lower(rp.slug) % n.q)

    union all
    select 'news_item', ni.news_item_id::text, ni.slug, ni.title,
      ni.hero_image_url,
      greatest(extensions.similarity(lower(ni.title), n.q),
               extensions.similarity(lower(ni.slug), n.q))
    from public.news_item ni, normalized n
    where (kinds is null or array_length(kinds, 1) is null or 'news_item' = any(kinds))
      and ni.status = 'published'
      and (lower(ni.title) % n.q or lower(ni.slug) % n.q)
  )
  select entity_kind, entity_id, slug, title, image_url, similarity
  from hits
  order by similarity desc, title
  limit greatest(coalesce(limit_count, 12), 1);
$$;

comment on function public.search_fuzzy(text, text[], int) is
  'Trigram-based fuzzy search. For people, image_url is coalesce(sessionize_profile_picture_url, ai_engineer_url).';
