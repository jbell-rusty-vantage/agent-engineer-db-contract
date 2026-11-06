-- Migration C: search_all(q, limit_count, kinds) RPC.
--
-- One stop for the global Cmd-K / search bar in the app. UNION ALL across
-- every FTS-enabled table, ranked with ts_rank_cd, snippet via ts_headline.
--
-- Per-row return shape:
--   entity_kind text  -- 'organization' | 'person' | 'event' | ...
--   entity_id   text  -- pk of the row (uuid or slug, stringified)
--   slug        text  -- url-safe slug for routing
--   title       text  -- display title (name / full_name / headline / ...)
--   subtitle    text  -- short context line (tagline / role / kind / venue)
--   snippet     text  -- ts_headline excerpt with <mark>...</mark> wrappers
--   rank        real  -- ts_rank_cd score; higher is better
--
-- Security: SECURITY INVOKER + set search_path = '' so RLS still applies
-- (notes only return rows owned by the calling user; news_item respects its
-- "published" filter; everything else is public_read).
--
-- Same pattern used by the existing public.match_chunks RPC.
--
-- Optional `kinds` parameter lets the client narrow the search to a subset
-- of entity kinds (e.g. {'library','product'} for a "find a tool" UI).
-- NULL or empty array means "search everything".

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
      coalesce(o.overview, o.flagship_products, '') as headline_src,
      o.fts as fts
    from public.organization o, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'organization' = any(kinds))
      and o.fts @@ tsq.q

    union all
    select 'person', p.person_id::text, p.slug,
      coalesce(p.full_name, p.first_name || ' ' || p.last_name, p.slug),
      coalesce(p.tag_line, p.role_title),
      coalesce(p.bio, p.notable_for, ''),
      p.fts
    from public.person p, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'person' = any(kinds))
      and p.fts @@ tsq.q

    union all
    select 'event', e.event_id::text, e.slug,
      e.name, e.tagline,
      coalesce(e.description, e.venue, ''), e.fts
    from public.event e, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'event' = any(kinds))
      and e.fts @@ tsq.q

    union all
    select 'library', l.slug, l.slug,
      l.name, l.tagline,
      coalesce(l.description, ''), l.fts
    from public.library l, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'library' = any(kinds))
      and l.fts @@ tsq.q

    union all
    select 'product', pr.slug, pr.slug,
      pr.name, pr.tagline,
      coalesce(pr.description, ''), pr.fts
    from public.product pr, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'product' = any(kinds))
      and pr.fts @@ tsq.q

    union all
    select 'paper', pa.slug, pa.slug,
      pa.title, pa.venue,
      coalesce(pa.abstract, ''), pa.fts
    from public.paper pa, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'paper' = any(kinds))
      and pa.fts @@ tsq.q

    union all
    select 'report', r.report_id::text, r.slug,
      r.title, r.report_kind,
      coalesce(r.summary, r.body_md, ''), r.fts
    from public.report r, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'report' = any(kinds))
      and r.fts @@ tsq.q

    union all
    select 'course', c.course_id::text, c.slug,
      c.title, c.domain_bucket,
      coalesce(c.summary, c.narrative_md, ''), c.fts
    from public.course c, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'course' = any(kinds))
      and c.fts @@ tsq.q
      and c.is_latest_published

    union all
    select 'course_module', cm.module_id::text, cm.slug,
      cm.title, cm.difficulty,
      coalesce(cm.search_text, cm.body_md, ''), cm.fts
    from public.course_module cm, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'course_module' = any(kinds))
      and cm.fts @@ tsq.q
      and cm.is_latest_published

    union all
    select 'news_item', n.news_item_id::text, n.slug,
      coalesce(n.headline, n.title), n.kind,
      coalesce(n.summary, n.body_md, ''), n.fts
    from public.news_item n, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'news_item' = any(kinds))
      and n.fts @@ tsq.q
      and n.status = 'published'

    union all
    select 'youtube_video', yv.video_id::text, yv.slug,
      yv.title, yv.category,
      coalesce(yv.description, ''), yv.fts
    from public.youtube_video yv, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'youtube_video' = any(kinds))
      and yv.fts @@ tsq.q

    union all
    select 'session', s.session_id::text, s.slug,
      coalesce(s.title, s.slug), s.track,
      coalesce(s.description, s.extended_description, ''), s.fts
    from public.session s, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'session' = any(kinds))
      and s.fts @@ tsq.q

    union all
    select 'repo', rp.slug, rp.slug,
      rp.github_org || '/' || rp.github_repo, rp.primary_language,
      coalesce(rp.description, ''), rp.fts
    from public.repo rp, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'repo' = any(kinds))
      and rp.fts @@ tsq.q

    union all
    select 'image', im.image_id::text, im.image_id::text,
      coalesce(im.title, im.alt), im.attribution,
      coalesce(im.caption, im.alt, ''), im.fts
    from public.image im, tsq
    where (kinds is null or array_length(kinds, 1) is null or 'image' = any(kinds))
      and im.fts @@ tsq.q

    union all
    -- notes are RLS-restricted to the calling user via notes_manage_own
    select 'notes', nt.id::text, nt.id::text,
      nt.title, nt.entity_type,
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
  'Cross-entity full-text search. Runs websearch_to_tsquery against every fts column, ranks with ts_rank_cd, returns (entity_kind, entity_id, slug, title, subtitle, snippet, rank). RLS is honoured (notes are owner-scoped; news_item filters to status=''published''; courses to is_latest_published). Pass `kinds` to narrow to a subset (e.g. ARRAY[''library'',''product''] for a tool finder).';

-- Allow PostgREST to RPC this. Only authenticated/anon by default — service
-- role can already do anything.
grant execute on function public.search_all(text, int, text[]) to anon, authenticated;
