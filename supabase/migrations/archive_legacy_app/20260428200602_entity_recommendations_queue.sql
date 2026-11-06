-- Entity recommendation queue and materialized user recommendations.
--
-- Adds a durable outbox for recommendation-affecting interactions and a
-- ready-to-render recommendation table owned by the background processor.

create table if not exists public.entity_interaction_event (
  event_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  event_type text not null,
  entity_kind text not null,
  entity_id text not null,
  entity_title text,
  entity_subtitle text,
  occurred_at timestamptz not null default timezone('utc', now()),
  queued_at timestamptz,
  processed_at timestamptz,
  status text not null default 'pending',
  attempt_count int not null default 0,
  error text,
  metadata jsonb not null default '{}'::jsonb,
  constraint entity_interaction_event_type_check check (
    event_type in (
      'entity.saved',
      'entity.unsaved',
      'entity.followed',
      'entity.unfollowed'
    )
  ),
  constraint entity_interaction_event_status_check check (
    status in ('pending', 'queued', 'processing', 'processed', 'failed')
  ),
  constraint entity_interaction_event_attempt_nonnegative check (attempt_count >= 0)
);

create index if not exists entity_interaction_event_user_time_idx
  on public.entity_interaction_event (user_id, occurred_at desc);

create index if not exists entity_interaction_event_status_time_idx
  on public.entity_interaction_event (status, occurred_at asc);

create index if not exists entity_interaction_event_entity_idx
  on public.entity_interaction_event (entity_kind, entity_id);

alter table public.entity_interaction_event enable row level security;

drop policy if exists "entity_interaction_event_select_own" on public.entity_interaction_event;

comment on table public.entity_interaction_event is
  'Durable outbox/event log for user interactions that affect entity recommendations.';
comment on column public.entity_interaction_event.status is
  'Processing status for queue dispatch and recommendation recompute recovery.';
comment on column public.entity_interaction_event.metadata is
  'Optional producer metadata for debugging and future recommendation signals.';

create table if not exists public.user_entity_recommendation (
  user_id uuid not null references public.profiles(id) on delete cascade,
  entity_kind text not null,
  entity_id text not null,
  rank int not null,
  score double precision not null,
  title text not null,
  subtitle text,
  image_url text,
  href text not null,
  reason_codes text[] not null default '{}',
  algorithm_version text not null,
  computed_at timestamptz not null default timezone('utc', now()),
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  primary key (user_id, entity_kind, entity_id),
  constraint user_entity_recommendation_rank_positive check (rank > 0),
  constraint user_entity_recommendation_score_nonnegative check (score >= 0),
  constraint user_entity_recommendation_kind_check check (
    entity_kind in (
      'person',
      'organization',
      'library',
      'paper',
      'session',
      'youtube_video'
    )
  )
);

create index if not exists user_entity_recommendation_user_rank_idx
  on public.user_entity_recommendation (user_id, rank asc);

create index if not exists user_entity_recommendation_user_score_idx
  on public.user_entity_recommendation (user_id, score desc);

create index if not exists user_entity_recommendation_expiry_idx
  on public.user_entity_recommendation (expires_at)
  where expires_at is not null;

alter table public.user_entity_recommendation enable row level security;

drop policy if exists "user_entity_recommendation_select_own" on public.user_entity_recommendation;
create policy "user_entity_recommendation_select_own"
on public.user_entity_recommendation
for select
to authenticated
using ((select auth.uid()) = user_id);

comment on table public.user_entity_recommendation is
  'Materialized, ranked, ready-to-render entity recommendations for each user.';
comment on column public.user_entity_recommendation.reason_codes is
  'Explainable reason codes emitted by the recommendation scorer.';
comment on column public.user_entity_recommendation.metadata is
  'Display and scoring metadata used for debugging and future algorithm versions.';

create or replace function public.replace_user_entity_recommendations(
  p_user_id uuid,
  p_rows jsonb
)
returns integer
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_inserted integer := 0;
begin
  delete from public.user_entity_recommendation
  where user_id = p_user_id;

  insert into public.user_entity_recommendation (
    user_id,
    entity_kind,
    entity_id,
    rank,
    score,
    title,
    subtitle,
    image_url,
    href,
    reason_codes,
    algorithm_version,
    metadata
  )
  select
    p_user_id,
    r.entity_kind,
    r.entity_id,
    r.rank,
    r.score,
    r.title,
    r.subtitle,
    r.image_url,
    r.href,
    coalesce(
      array(
        select jsonb_array_elements_text(coalesce(r.reason_codes, '[]'::jsonb))
      ),
      '{}'::text[]
    ),
    r.algorithm_version,
    coalesce(r.metadata, '{}'::jsonb)
  from jsonb_to_recordset(coalesce(p_rows, '[]'::jsonb)) as r(
    entity_kind text,
    entity_id text,
    rank int,
    score double precision,
    title text,
    subtitle text,
    image_url text,
    href text,
    reason_codes jsonb,
    algorithm_version text,
    metadata jsonb
  );

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$$;

revoke all on function public.replace_user_entity_recommendations(uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.replace_user_entity_recommendations(uuid, jsonb)
  to service_role;

comment on function public.replace_user_entity_recommendations(uuid, jsonb) is
  'Service-role-only atomic replacement for a user recommendation snapshot.';
