-- M3: rebalance person.fts so role/identity beats noisy bio prose, then
-- rewrite explore_people to (a) accept role_buckets / org_ids facets,
-- (b) surface org/role on the row so cards can render properly, and
-- (c) build snippets from the matched field instead of always bio.
--
-- Plus a new explore_people_facets RPC that returns counts for the
-- three person-specific filter dimensions in one round trip.
--
-- ────────────────────────────────────────────────────────────────────
-- person.fts re-weighting
-- ────────────────────────────────────────────────────────────────────
-- Old weights surfaced bio at C alongside short identifiers like
-- role_title and notable_for. Bio is much longer, so ts_rank_cd kept
-- letting bios drown out direct title hits ("OpenAI" matched a passing
-- footnote in someone's bio at the same rank as actual OpenAI staff).
--
-- New weights:
--   A = full_name + tag_line                (canonical identity)
--   B = role_title + notable_for            (what they do — short text)
--   C = expertise_or_focus_area             (mid-length topical)
--   D = bio + slug + expertise_tags + handles + first/last name + city/country
--                                           (long prose & metadata)
--
-- (We don't include role_bucket in the FTS because Postgres forbids a
-- generated column referencing another generated column. role_bucket
-- adds no incremental signal anyway — its source field role_title is
-- already in B.)

set search_path = public, extensions;

drop index if exists public.person_fts_idx;
alter table public.person drop column if exists fts;
alter table public.person add column fts tsvector
generated always as (
  setweight(to_tsvector('english',
    coalesce(full_name, '')
    || ' ' || coalesce(tag_line, '')
  ), 'A') ||
  setweight(to_tsvector('english',
    coalesce(role_title, '')
    || ' ' || coalesce(notable_for, '')
  ), 'B') ||
  setweight(to_tsvector('english',
    coalesce(expertise_or_focus_area, '')
  ), 'C') ||
  setweight(to_tsvector('english',
    coalesce(bio, '')
    || ' ' || coalesce(slug, '')
    || ' ' || public.immutable_array_to_string(coalesce(expertise_tags, '{}'::text[]), ' ')
    || ' ' || coalesce(twitter_handle, '')
    || ' ' || coalesce(github_username, '')
    || ' ' || coalesce(first_name, '')
    || ' ' || coalesce(last_name, '')
    || ' ' || coalesce(city, '')
    || ' ' || coalesce(country, '')
  ), 'D')
) stored;

create index if not exists person_fts_idx on public.person using gin (fts);

comment on column public.person.fts is
  'FTS (A=full_name+tag_line, B=role_title+notable_for, C=expertise_or_focus_area, D=bio+slug+expertise_tags+handles+first/last_name+city+country). Re-balanced 2026-04 so identity/role beats long bio prose.';

-- ────────────────────────────────────────────────────────────────────
-- explore_people — drop & recreate (signature changed)
-- ────────────────────────────────────────────────────────────────────
-- New params:
--   role_buckets text[]  filter via person.role_bucket = any(role_buckets)
--   org_ids      text[]  filter via person.primary_org_id::text = any(org_ids)
--
-- New output columns: org_id, org_name, role_bucket
-- (other explore_<kind> RPCs leave these null — the TS row schema
-- treats them as optional.)
--
-- headline_src now concatenates the short identifying fields ahead of
-- bio so ts_headline picks up the actual matched phrase, not always
-- a bio sentence.

drop function if exists public.explore_people(text, text[], text[], text[], text, int, int);

create or replace function public.explore_people(
  q             text     default null,
  layers        text[]   default null,  -- ignored: person has no domain_layer column
  categories    text[]   default null,  -- ignored: person has no category column
  tags          text[]   default null,
  sort          text     default 'relevance',
  limit_count   int      default 24,
  offset_count  int      default 0,
  role_buckets  text[]   default null,
  org_ids       text[]   default null
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
  out_tags      text[],
  org_id        text,
  org_name      text,
  role_bucket   text
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
      -- Short identifiers first so ts_headline highlights the
      -- discriminating phrase instead of always a bio sentence.
      concat_ws(
        ' … ',
        nullif(p.role_title, ''),
        nullif(p.tag_line, ''),
        nullif(p.notable_for, ''),
        nullif(p.bio, '')
      )                                     as headline_src,
      p.fts                                 as fts,
      0::real                               as popularity,
      p.updated_at                          as recent_at,
      null::text                            as layer,
      null::text                            as category,
      p.expertise_tags                      as out_tags,
      p.primary_org_id::text                as org_id,
      p.role_bucket                         as role_bucket
    from public.person p, tsq
    where (tsq.q is null or p.fts @@ tsq.q)
      and (tags is null or array_length(tags, 1) is null
           or p.expertise_tags && tags)
      and (role_buckets is null or array_length(role_buckets, 1) is null
           or p.role_bucket = any(role_buckets))
      and (org_ids is null or array_length(org_ids, 1) is null
           or p.primary_org_id::text = any(org_ids))
  ),
  ranked as (
    select
      f.entity_id, f.slug, f.title, f.subtitle, f.image_url, f.description,
      case when tsq.q is null then null
           else ts_headline(
             'english', f.headline_src, tsq.q,
             'StartSel=<mark>,StopSel=</mark>,MaxFragments=2,MaxWords=20,MinWords=5,ShortWord=3,FragmentDelimiter=" … "'
           )
      end as snippet,
      case when tsq.q is null then null
           else ts_rank_cd(f.fts, tsq.q) end as rank,
      f.popularity, f.recent_at,
      count(*) over ()                      as total_count,
      f.layer, f.category, f.out_tags,
      f.org_id, f.role_bucket
    from filtered f, tsq
  ),
  ranked_with_org as (
    select
      r.*,
      o.name as org_name
    from ranked r
    left join public.organization o on o.organization_id::text = r.org_id
  )
  select
    entity_id, slug, title, subtitle, image_url, description, snippet,
    rank, popularity, recent_at, total_count,
    layer, category, out_tags,
    org_id, org_name, role_bucket
  from ranked_with_org
  order by
    case when sort = 'recent'     then recent_at end desc nulls last,
    case when sort = 'alpha'      then title end asc,
    case when sort = 'popularity' or sort is null then popularity end desc,
    case when sort = 'relevance'  then rank end desc nulls last,
    title asc
  limit greatest(least(coalesce(limit_count, 24), 100), 1)
  offset greatest(coalesce(offset_count, 0), 0);
$$;

grant execute on function public.explore_people(text, text[], text[], text[], text, int, int, text[], text[])
  to anon, authenticated;

comment on function public.explore_people(text, text[], text[], text[], text, int, int, text[], text[]) is
  'Per-entity FTS for /explore/people. Filters: tags (expertise_tags && tags), role_buckets (= any), org_ids (primary_org_id = any). Output now includes org_id/org_name/role_bucket. Snippet built from role_title|tag_line|notable_for|bio so the highlighted phrase reflects the actual match.';

-- ────────────────────────────────────────────────────────────────────
-- explore_people_facets — sidebar counts in one round trip
-- ────────────────────────────────────────────────────────────────────
-- Returns jsonb: { role_buckets:[{value,count}], orgs:[{id,name,slug,logo_url,count}], tags:[{value,count}] }
--
-- Faceting strategy: each facet group applies all *other* selected
-- filters (so picking "Founder" still narrows the company list to
-- companies that have founders, etc.) but not the self filter — that
-- way the user can always see and switch their own selections.

create or replace function public.explore_people_facets(
  q             text     default null,
  tags          text[]   default null,
  role_buckets  text[]   default null,
  org_ids       text[]   default null,
  facet_limit   int      default 30
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with tsq as (
    select case when coalesce(trim(q), '') = '' then null
                else websearch_to_tsquery('english', q) end as q
  ),
  base as (
    select
      p.person_id,
      p.role_bucket,
      p.primary_org_id,
      p.expertise_tags
    from public.person p, tsq
    where (tsq.q is null or p.fts @@ tsq.q)
  ),
  -- Role facet: apply tag + org filters (not role).
  role_facets as (
    select b.role_bucket as value, count(*)::int as n
    from base b
    where (tags is null or array_length(tags, 1) is null
           or b.expertise_tags && tags)
      and (org_ids is null or array_length(org_ids, 1) is null
           or b.primary_org_id::text = any(org_ids))
    group by b.role_bucket
  ),
  -- Org facet: apply tag + role filters (not org).
  org_facets as (
    select b.primary_org_id as id, count(*)::int as n
    from base b
    where b.primary_org_id is not null
      and (tags is null or array_length(tags, 1) is null
           or b.expertise_tags && tags)
      and (role_buckets is null or array_length(role_buckets, 1) is null
           or b.role_bucket = any(role_buckets))
    group by b.primary_org_id
    order by n desc, b.primary_org_id
    limit facet_limit
  ),
  org_facets_named as (
    select
      o.organization_id::text as id,
      coalesce(o.name, o.slug) as name,
      o.slug,
      o.logo_url,
      f.n
    from org_facets f
    join public.organization o on o.organization_id = f.id
  ),
  -- Tags facet: apply role + org filters (not tag).
  tag_input as (
    select unnest(b.expertise_tags) as tag
    from base b
    where (role_buckets is null or array_length(role_buckets, 1) is null
           or b.role_bucket = any(role_buckets))
      and (org_ids is null or array_length(org_ids, 1) is null
           or b.primary_org_id::text = any(org_ids))
  ),
  tag_facets as (
    select tag as value, count(*)::int as n
    from tag_input
    where tag is not null and length(tag) > 0
    group by tag
    order by n desc, tag
    limit facet_limit
  )
  select jsonb_build_object(
    'role_buckets', coalesce(
      (select jsonb_agg(jsonb_build_object('value', value, 'count', n) order by n desc, value)
       from role_facets where value is not null),
      '[]'::jsonb
    ),
    'orgs', coalesce(
      (select jsonb_agg(jsonb_build_object(
                'id', id, 'name', name, 'slug', slug,
                'logo_url', logo_url, 'count', n
              ) order by n desc, name)
       from org_facets_named),
      '[]'::jsonb
    ),
    'tags', coalesce(
      (select jsonb_agg(jsonb_build_object('value', value, 'count', n) order by n desc, value)
       from tag_facets),
      '[]'::jsonb
    )
  );
$$;

grant execute on function public.explore_people_facets(text, text[], text[], text[], int)
  to anon, authenticated;

comment on function public.explore_people_facets(text, text[], text[], text[], int) is
  'Sidebar facet counts for /explore/people. Returns jsonb {role_buckets, orgs, tags}. Each facet applies all other selected filters but not its own, so users can always switch their own selections.';
