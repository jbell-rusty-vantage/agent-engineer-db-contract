-- Add `person.role_bucket` — a STORED generated column that classifies
-- `role_title` into a small enumerated set so /explore/people can offer
-- a "Role" facet despite role_title being free text with 252 distinct
-- values across 285 rows.
--
-- Buckets and live distribution at migration time (285 rows):
--   founder_csuite     103
--   engineer            67
--   devrel_community    36
--   researcher          24
--   product             18
--   investor             3
--   design               3
--   business_gtm         2
--   other               29
--
-- Generated column => always in sync with role_title, no maintenance.
-- Indexed for the facet COUNT() and equality filter.
--
-- The classifier order matters: `\mfounder\M` is checked before
-- `\mengineer\M` because "Co-founder & Engineering Lead" should bucket
-- as Founder, not Engineer.

set search_path = public, extensions;

alter table public.person
  add column role_bucket text generated always as (
    case
      when coalesce(role_title, '') ~* '\m(co[- ]?founder|founder|ceo|cto|coo|cpo|chief)\M'
        then 'founder_csuite'
      when coalesce(role_title, '') ~* '\m(developer\s+(advocate|relations?|experience)|devrel|evangelist|community)\M'
        then 'devrel_community'
      when coalesce(role_title, '') ~* '\m(research(er)?|scientist|professor|phd)\M'
        then 'researcher'
      when coalesce(role_title, '') ~* '\m(product\s+(manager|lead|director)|head of product|\mpm\M)\M'
        then 'product'
      when coalesce(role_title, '') ~* '\m(solutions?\s+(architect|engineer)|forward[- ]?deployed|field\s+engineer)\M'
        then 'solutions'
      when coalesce(role_title, '') ~* '\m(engineer|engineering|architect|tech(nical)?\s+lead|sde|swe|mts|member of technical staff|tlm|software)\M'
        then 'engineer'
      when coalesce(role_title, '') ~* '\m(design(er)?|ux|ui)\M'
        then 'design'
      when coalesce(role_title, '') ~* '\m(investor|ventures?|partner|angel|\mvc\M)\M'
        then 'investor'
      when coalesce(role_title, '') ~* '\m(marketing|sales|growth|operat|business|strateg)\M'
        then 'business_gtm'
      else 'other'
    end
  ) stored;

create index if not exists person_role_bucket_idx
  on public.person (role_bucket);

comment on column public.person.role_bucket is
  'Derived classifier over role_title. One of: founder_csuite, devrel_community, researcher, product, solutions, engineer, design, investor, business_gtm, other. Generated column — always in sync.';
