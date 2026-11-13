-- Build 08 loop 5 fixup 2 (D-76, second half): a rebuilt latest cell (D4-latest-2026-11-13T15) replaces the older latest cell, so the
-- due-list reads the most recent unpinned run of each probe, not every latest-labelled cell separately (after the revalidation
-- reruns the older D3-latest runs kept P10 and P19 due).
create or replace function api.probe_revalidation_due(p_as_of timestamptz default now())
returns table(probe_id uuid, probe text, cell_label text, last_run_at timestamptz, library text, resolved_version text, newest_version text, newest_released_at timestamptz, reason text)
language sql stable security definer set search_path = '' as $$
  with latest_cell as (
    select distinct on (pr.probe_id) pr.probe_id, pr.cell_label, pr.started_at, pr.resolved
      from verification.probe_run pr join verification.probe p on p.id = pr.probe_id
     where p.state = 'active' and pr.started_at <= p_as_of and (pr.cell ->> 'exclude_newer') is null and pr.cell_label like '%latest%'
     order by pr.probe_id, pr.started_at desc
  ), subj as (
    select lc.*, l.id lib_id, l.slug lib_slug, l.display_name lib_name
      from latest_cell lc join verification.probe p on p.id = lc.probe_id join catalog.entity l on l.id = any(p.subject_entity_ids) and l.kind = 'library'
  ), rel as (
    select r.software_id, r.version_label, r.released_at from api.software_releases r where r.released_at <= p_as_of and r.version_label ~ '^\d+\.\d+(\.\d+)?$'
  ), newest as (
    select distinct on (software_id) software_id, version_label, released_at from rel order by software_id, released_at desc, version_label desc
  )
  select s.probe_id, p.slug, s.cell_label, s.started_at, s.lib_slug, s.resolved ->> s.lib_slug, n.version_label, n.released_at,
         format('%s %s released %s; the last %s run (%s) resolved %s', s.lib_name, n.version_label, n.released_at, s.cell_label, s.started_at, coalesce(s.resolved ->> s.lib_slug, 'nothing'))
    from subj s join verification.probe p on p.id = s.probe_id join newest n on n.software_id = s.lib_id
    left join rel had on had.software_id = s.lib_id and had.version_label = (s.resolved ->> s.lib_slug)
   where (s.resolved ->> s.lib_slug) is distinct from n.version_label
     and n.released_at > coalesce(had.released_at, s.started_at)
   order by p.slug, s.lib_slug
$$;
comment on function api.probe_revalidation_due(timestamptz) is 'Loop 5 (D-76): probes whose latest (unpinned) cell resolved a different, older version of a subject library than its newest catalogued release: the probe-revalidation policy rebuilds the latest cell and reruns them.';
