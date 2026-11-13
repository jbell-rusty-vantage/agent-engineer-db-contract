-- Build 08 loop 4 fixup 1 (lab only): api.attention_due
-- D-56: a trigger with "only": "major" fires only for x.0.0 releases (it fired for every patch release).
-- D-57: a backfill sweep does not satisfy an event trigger (it does not apply the trigger window's selection rules); cadence still counts every sweep.
begin;
create or replace function api.attention_due(p_as_of timestamptz default now())
returns table(policy_id uuid, slug text, watch_level text, reason text, trigger_ref jsonb, last_sweep_at timestamptz, budget_usd_per_run numeric, mission text)
language sql stable security definer set search_path = '' as $$
  with pol as (
    select p.*,
           (select max(s.started_at) from acquisition.attention_sweep s where s.policy_id = p.id and s.started_at <= p_as_of) as last_at,
           (select max(s.started_at) from acquisition.attention_sweep s where s.policy_id = p.id and s.started_at <= p_as_of and s.trigger_kind <> 'backfill') as last_event_at
      from acquisition.attention_policy p
     where p.state = 'active' and p.watch_level <> 'W0' and not exists (select 1 from acquisition.attention_policy q where q.supersedes_id = p.id)
  ), ev as (
    select pol.id as policy_id, e.id as event_id, e.kind, lower(o.occurred_during) as at, coalesce(lib.slug, x.slug) as subject, x.attributes->>'version_label' as version
      from pol cross join lateral jsonb_array_elements(pol.triggers) t
      join temporal.event e on e.kind = t->>'on'
      join temporal.event_occurrence o on o.event_id = e.id and o.k_to is null
      join catalog.entity x on x.id = e.subject_entity_id
      left join catalog.relationship r on r.from_entity_id = x.id and r.kind = 'version_of' and r.k_to is null
      left join catalog.entity lib on lib.id = r.to_entity_id
     where (x.id = any(pol.subject_entity_ids) or lib.id = any(pol.subject_entity_ids))
       and (t->>'only' is distinct from 'major' or coalesce(x.attributes->>'version_label', '') ~ '^[0-9]+\.0\.0$')
       and lower(o.occurred_during) <= p_as_of
       and lower(o.occurred_during) > coalesce(pol.last_event_at, '-infinity'::timestamptz)
       and lower(o.occurred_during) > p_as_of - make_interval(days => coalesce((t->>'window_days')::int, 14))
  )
  select p.id, p.slug, p.watch_level, 'event: ' || string_agg(distinct ev.kind || ' ' || ev.subject || coalesce(' ' || ev.version, ''), ', '),
         jsonb_agg(distinct jsonb_build_object('event_id', ev.event_id, 'kind', ev.kind, 'subject', ev.subject, 'version', ev.version, 'at', ev.at)), p.last_at, p.budget_usd_per_run,
         (select m.slug from orchestration.mission m where m.id = p.mission_id)
    from pol p join ev on ev.policy_id = p.id group by p.id, p.slug, p.watch_level, p.last_at, p.budget_usd_per_run, p.mission_id
  union all
  select p.id, p.slug, p.watch_level, case when p.last_at is null then 'never swept' else 'cadence ' || p.cadence end, '{}'::jsonb, p.last_at, p.budget_usd_per_run,
         (select m.slug from orchestration.mission m where m.id = p.mission_id)
    from pol p where p.cadence is not null and (p.last_at is null or p.last_at + p.cadence::interval <= p_as_of)
     and not exists (select 1 from ev where ev.policy_id = p.id)
$$;
comment on function api.attention_due is 'The contract a Mission Control watch mission calls: which attention policies are due at a time, because a trigger event happened since the last non-backfill sweep inside the trigger window (a trigger with "only": "major" counts x.0.0 releases only), or because the cadence elapsed since any sweep. W0 and paused policies are never due.';
commit;
