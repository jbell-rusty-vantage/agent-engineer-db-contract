-- Backfill `person.primary_org_id` by scanning role_title / tag_line /
-- bio / notable_for for any organization name (>= 3 chars) that appears
-- with word boundaries. When multiple orgs match, the longest name wins
-- so e.g. "Google DeepMind" beats "Google".
--
-- Today only 3/285 person rows have a primary_org_id set. A dry-run of
-- this match strategy resolves ~237/285 (~83%), which unblocks a real
-- "Company" filter on /explore/people.
--
-- Wrapped in a re-callable maintenance function so we can re-run it
-- after future enrichment passes (it never overwrites a non-null
-- primary_org_id, so re-running is safe).

set search_path = public, extensions;

create or replace function public.backfill_person_primary_org()
returns integer
language plpgsql
security invoker
set search_path = ''
as $$
declare
  affected integer;
begin
  with hits as (
    select
      p.person_id,
      o.organization_id,
      row_number() over (
        partition by p.person_id
        -- Longest name wins (more specific match), then alphabetical
        -- as a deterministic tiebreaker.
        order by length(o.name) desc, o.name asc
      ) as rn
    from public.person p
    join public.organization o
      on length(o.name) >= 3
     and concat_ws(' ',
           coalesce(p.role_title, ''),
           coalesce(p.tag_line, ''),
           coalesce(p.bio, ''),
           coalesce(p.notable_for, '')
         ) ~* ('\m' || regexp_replace(o.name, '([().+*?\\\[\]^$|{}-])', '\\\1', 'g') || '\M')
    where p.primary_org_id is null
  ),
  upd as (
    update public.person p
    set primary_org_id = h.organization_id
    from hits h
    where p.person_id = h.person_id
      and h.rn = 1
    returning 1
  )
  select count(*)::int into affected from upd;
  return affected;
end;
$$;

comment on function public.backfill_person_primary_org() is
  'Resolve person.primary_org_id by word-boundary regex matching organization.name in role_title/tag_line/bio/notable_for. Longest name wins. Idempotent (only fills nulls). Returns rows updated.';

-- Service-role only — this is a maintenance function, not an API.
revoke all on function public.backfill_person_primary_org() from public, anon, authenticated;
grant execute on function public.backfill_person_primary_org() to service_role;

-- Run the backfill now.
select public.backfill_person_primary_org();
