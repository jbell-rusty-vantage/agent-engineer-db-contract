-- v2 of person.primary_org_id backfill.
--
-- v1 (in 20260424120000) collapsed role_title/tag_line/bio/notable_for
-- into one haystack and picked the longest matching org name. That gave
-- a false positive for e.g. Ilan Bigio whose role_title says
-- "Founding member, Developer Experience (OpenAI)" but whose bio links
-- a youtube.com video — "YouTube" (7 chars) beat "OpenAI" (6 chars).
--
-- v2 ranks matches by FIELD priority before length:
--   1. role_title  (most reliable — current affiliation)
--   2. tag_line    (also strong)
--   3. notable_for (weaker but still curated)
--   4. bio         (last resort — often tangential mentions)
--
-- Within a field, longer name still wins (so "Google DeepMind" beats
-- "Google" in role_title).
--
-- We clear all v1 values first so v2 can fix mistakes.

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
      case
        when coalesce(p.role_title, '')  ~* ('\m' || regexp_replace(o.name, '([().+*?\\\[\]^$|{}-])', '\\\1', 'g') || '\M') then 1
        when coalesce(p.tag_line, '')    ~* ('\m' || regexp_replace(o.name, '([().+*?\\\[\]^$|{}-])', '\\\1', 'g') || '\M') then 2
        when coalesce(p.notable_for, '') ~* ('\m' || regexp_replace(o.name, '([().+*?\\\[\]^$|{}-])', '\\\1', 'g') || '\M') then 3
        when coalesce(p.bio, '')         ~* ('\m' || regexp_replace(o.name, '([().+*?\\\[\]^$|{}-])', '\\\1', 'g') || '\M') then 4
        else null
      end as field_rank
    from public.person p
    join public.organization o
      on length(o.name) >= 3
     and concat_ws(' ',
           coalesce(p.role_title, ''),
           coalesce(p.tag_line, ''),
           coalesce(p.notable_for, ''),
           coalesce(p.bio, '')
         ) ~* ('\m' || regexp_replace(o.name, '([().+*?\\\[\]^$|{}-])', '\\\1', 'g') || '\M')
    where p.primary_org_id is null
  ),
  ranked as (
    select
      h.person_id,
      h.organization_id,
      row_number() over (
        partition by h.person_id
        -- Field priority first (1 best), then longest org name, then
        -- alphabetical for determinism.
        order by h.field_rank asc, length((select name from public.organization where organization_id = h.organization_id)) desc,
                 (select name from public.organization where organization_id = h.organization_id) asc
      ) as rn
    from hits h
    where h.field_rank is not null
  ),
  upd as (
    update public.person p
    set primary_org_id = r.organization_id
    from ranked r
    where p.person_id = r.person_id
      and r.rn = 1
    returning 1
  )
  select count(*)::int into affected from upd;
  return affected;
end;
$$;

-- Clear v1 values and re-run with v2 logic. Safe: we only ever set
-- this from text-match heuristics, never from a real source of truth.
update public.person set primary_org_id = null;
select public.backfill_person_primary_org();
