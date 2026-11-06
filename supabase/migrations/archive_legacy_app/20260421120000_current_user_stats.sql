-- U0.4 — current_streak_days() function + current_user_stats view.
--
-- Resolves Q7 from `aiengineerapp/.cursor/plans/06-open-questions.md`:
-- streak is *derived* from `score_event` rows, not stored on `profiles`.
--
-- Pure SQL, `stable`, `security invoker` so RLS scopes the caller to
-- their own `score_event` rows automatically.

create or replace function public.current_streak_days(p_user_id uuid)
returns int
language sql
stable
security invoker
set search_path = ''
as $$
  with daily as (
    select distinct (date_trunc('day', created_at at time zone 'utc'))::date as d
    from public.score_event
    where user_id = p_user_id
  ),
  numbered as (
    -- Number rows newest-first; consecutive day-deltas == row offset means
    -- the streak is unbroken back to that point.
    select d,
           row_number() over (order by d desc) as rn,
           (current_date at time zone 'utc')::date - d as gap
    from daily
    where d <= (current_date at time zone 'utc')::date
  )
  select coalesce(
    (select count(*)::int
       from numbered
       where gap = rn - 1),
    0
  );
$$;

comment on function public.current_streak_days(uuid) is
  'Counts contiguous UTC days backwards from today where >=1 score_event exists for the user. Resolves Q7.';

-- View that the shell rail (U1.3) and home greeting (U5.1) read.
-- security_invoker = true => callers see only profiles + score_events RLS allows.
create or replace view public.current_user_stats
with (security_invoker = true) as
  select p.id as user_id,
         p.xp_total,
         public.current_streak_days(p.id) as streak_days
  from public.profiles p;

comment on view public.current_user_stats is
  'Per-user XP + derived streak. One row per profile, RLS filters to caller.';

grant select on public.current_user_stats to authenticated;
