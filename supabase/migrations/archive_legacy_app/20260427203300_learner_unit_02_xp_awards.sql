-- Unit 02 — XP award RPC.
--
-- score_event is owner-readable only; writes are intentionally service-role
-- server paths. This RPC keeps the ledger insert and profiles.xp_total cache
-- increment in a single database statement.

create or replace function public.award_xp_event(
  p_user_id uuid,
  p_kind text,
  p_ref_kind text,
  p_ref_id uuid,
  p_points integer,
  p_metadata jsonb default '{}'::jsonb,
  p_source_attempt uuid default null
)
returns table (
  awarded boolean,
  score_event_id uuid,
  points integer
)
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  v_points integer := greatest(coalesce(p_points, 0), 0);
  v_score_event_id uuid;
  v_persisted_points integer;
begin
  if p_user_id is null
    or p_kind is null
    or p_ref_kind is null
    or p_ref_id is null
  then
    raise exception 'award_xp_event requires non-null user, kind, ref kind, and ref id'
      using errcode = '22023';
  end if;

  insert into public.score_event (
    user_id,
    kind,
    ref_kind,
    ref_id,
    points,
    metadata,
    source_attempt
  )
  values (
    p_user_id,
    p_kind,
    p_ref_kind,
    p_ref_id,
    v_points,
    coalesce(p_metadata, '{}'::jsonb),
    p_source_attempt
  )
  on conflict (user_id, kind, ref_kind, ref_id)
    where ref_kind is not null and ref_id is not null
  do nothing
  returning public.score_event.score_event_id, public.score_event.points
  into v_score_event_id, v_persisted_points;

  if v_score_event_id is not null then
    update public.profiles
    set xp_total = public.profiles.xp_total + v_persisted_points
    where public.profiles.id = p_user_id;

    awarded := true;
    score_event_id := v_score_event_id;
    points := v_persisted_points;
    return next;
    return;
  end if;

  select se.score_event_id, se.points
  into v_score_event_id, v_persisted_points
  from public.score_event se
  where se.user_id = p_user_id
    and se.kind = p_kind
    and se.ref_kind = p_ref_kind
    and se.ref_id = p_ref_id
  limit 1;

  if v_score_event_id is null then
    raise exception 'award_xp_event conflict row was not visible after duplicate award'
      using errcode = '40001';
  end if;

  awarded := false;
  score_event_id := v_score_event_id;
  points := v_persisted_points;
  return next;
  return;
end;
$$;

revoke all on function public.award_xp_event(uuid, text, text, uuid, integer, jsonb, uuid)
  from public, anon, authenticated;
grant execute on function public.award_xp_event(uuid, text, text, uuid, integer, jsonb, uuid)
  to service_role;

comment on function public.award_xp_event(uuid, text, text, uuid, integer, jsonb, uuid) is
  'Service-role XP award path. Inserts one score_event per (user, kind, ref) and increments profiles.xp_total only when a new ledger row is inserted.';
