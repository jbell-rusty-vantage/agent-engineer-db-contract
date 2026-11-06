-- Compact application-stage durability for the stateless pre-research v3 runner.
-- Large inputs and provider responses remain in Supabase Storage; this table
-- intentionally contains metadata and hashes only.

create table if not exists public.research_pre_research_stage_execution (
  stage_execution_id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.research_pre_research_run(run_id) on delete cascade,
  stage text not null,
  status text not null default 'pending',
  attempt_count integer not null default 0,
  lease_owner text,
  lease_token_hash text,
  lease_expires_at timestamptz,
  retry_after timestamptz,
  input_manifest_bucket text,
  input_manifest_path text,
  input_sha256 text,
  output_artifact_kinds text[] not null default '{}',
  completed_artifact_sha256s jsonb not null default '{}'::jsonb,
  model_id text not null default 'zai/glm-5.2',
  prompt_bundle_version text not null default 'pre-research-v3-stateless-1',
  last_error_code text,
  last_error_detail text,
  usage_summary jsonb not null default '{}'::jsonb,
  started_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  constraint research_pre_research_stage_execution_run_stage_key unique (run_id, stage),
  constraint research_pre_research_stage_execution_stage_check check (stage = any (array[
    'transcript_taxonomy', 'web_context', 'organization_research',
    'source_verification', 'curriculum', 'initial_summary',
    'technology_library_summary', 'organization_profile', 'ingestion_intent'
  ])),
  constraint research_pre_research_stage_execution_status_check check (status = any (array[
    'pending', 'leased', 'retry_wait', 'completed', 'dead_letter'
  ])),
  constraint research_pre_research_stage_execution_attempt_check check (attempt_count >= 0),
  constraint research_pre_research_stage_execution_lease_hash_check check (
    lease_token_hash is null or lease_token_hash ~ '^[0-9a-f]{64}$'
  ),
  constraint research_pre_research_stage_execution_input_hash_check check (
    input_sha256 is null or input_sha256 ~ '^[0-9a-f]{64}$'
  ),
  constraint research_pre_research_stage_execution_error_detail_check check (
    last_error_detail is null or length(last_error_detail) <= 2000
  )
);

create index if not exists research_pre_research_stage_execution_ready_idx
  on public.research_pre_research_stage_execution(status, retry_after, updated_at);
create index if not exists research_pre_research_stage_execution_run_idx
  on public.research_pre_research_stage_execution(run_id, stage);

alter table public.research_pre_research_stage_execution enable row level security;
revoke all on public.research_pre_research_stage_execution from public, anon, authenticated;
grant select, insert, update, delete on public.research_pre_research_stage_execution to postgres, service_role;

create or replace function research_private.ensure_pre_research_stage_rows(p_run_id uuid)
returns void
language sql
security definer
set search_path = research_private, public, extensions
as $$
  insert into public.research_pre_research_stage_execution(run_id, stage, output_artifact_kinds)
  values
    (p_run_id, 'transcript_taxonomy', array['run_manifest','transcript_analysis','taxonomy_classification']),
    (p_run_id, 'web_context', array['web_context']),
    (p_run_id, 'organization_research', array['organization_research']),
    (p_run_id, 'source_verification', array['source_verification']),
    (p_run_id, 'curriculum', array['curriculum_signals']),
    (p_run_id, 'initial_summary', array['initial_summary']),
    (p_run_id, 'technology_library_summary', array['technology_library_summary']),
    (p_run_id, 'organization_profile', array['organization_profile']),
    (p_run_id, 'ingestion_intent', array['ingestion_intent'])
  on conflict (run_id, stage) do nothing;
$$;

create or replace function research_private.reconcile_pre_research_stage_rows(p_run_id uuid)
returns void
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
begin
  perform research_private.ensure_pre_research_stage_rows(p_run_id);
  with completed as (
    select e.stage_execution_id,
           jsonb_object_agg(r.artifact_kind, r.content_sha256) as hashes
      from public.research_pre_research_stage_execution e
      join public.research_pre_research_artifact r
        on r.run_id = e.run_id
       and r.artifact_kind = any(e.output_artifact_kinds)
     where e.run_id = p_run_id
     group by e.stage_execution_id
    having count(*) = max(cardinality(e.output_artifact_kinds))
  )
  update public.research_pre_research_stage_execution e
     set status = 'completed',
         completed_artifact_sha256s = completed.hashes,
         lease_owner = null,
         lease_token_hash = null,
         lease_expires_at = null,
         retry_after = null,
         last_error_code = null,
         last_error_detail = null,
         completed_at = coalesce(e.completed_at, timezone('utc', now())),
         updated_at = timezone('utc', now())
    from completed
   where e.stage_execution_id = completed.stage_execution_id;
end;
$$;

create or replace function research_private.claim_pre_research_stage(
  p_worker_id text,
  p_lease_seconds integer default 360,
  p_run_id uuid default null
)
returns table (
  stage_execution_id uuid,
  run_id uuid,
  stage text,
  attempt_count integer,
  lease_token text,
  lease_expires_at timestamptz,
  output_artifact_kinds text[]
)
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_run_id uuid := p_run_id;
  v_stage public.research_pre_research_stage_execution%rowtype;
  v_token text;
begin
  if nullif(btrim(p_worker_id), '') is null then
    raise exception 'STAGE_WORKER_REQUIRED';
  end if;
  if p_lease_seconds < 30 or p_lease_seconds > 1800 then
    raise exception 'STAGE_LEASE_SECONDS_OUT_OF_RANGE';
  end if;
  if v_run_id is null then
    select r.run_id into v_run_id
      from public.research_pre_research_run r
     where r.packet_schema_version = '2.0.0'
       and r.status::text = any(array['queued','claimed','analyzing','research_complete','synthesizing','intent_ready'])
     order by coalesce(r.updated_at, r.created_at), r.created_at, r.run_id
     for update skip locked
     limit 1;
  else
    perform 1 from public.research_pre_research_run r where r.run_id = v_run_id for update;
  end if;
  if v_run_id is null then return; end if;

  perform research_private.reconcile_pre_research_stage_rows(v_run_id);
  update public.research_pre_research_stage_execution e
     set status = case
           when e.status = 'leased' and e.lease_expires_at <= timezone('utc', now()) then 'pending'
           when e.status = 'retry_wait' and coalesce(e.retry_after, '-infinity') <= timezone('utc', now()) then 'pending'
           else e.status end,
         lease_owner = case when e.status = 'leased' and e.lease_expires_at <= timezone('utc', now()) then null else e.lease_owner end,
         lease_token_hash = case when e.status = 'leased' and e.lease_expires_at <= timezone('utc', now()) then null else e.lease_token_hash end,
         lease_expires_at = case when e.status = 'leased' and e.lease_expires_at <= timezone('utc', now()) then null else e.lease_expires_at end,
         updated_at = timezone('utc', now())
   where e.run_id = v_run_id
     and ((e.status = 'leased' and e.lease_expires_at <= timezone('utc', now()))
       or (e.status = 'retry_wait' and coalesce(e.retry_after, '-infinity') <= timezone('utc', now())));

  select e.* into v_stage
    from public.research_pre_research_stage_execution e
   where e.run_id = v_run_id
     and e.status = 'pending'
   order by array_position(array[
     'transcript_taxonomy','web_context','organization_research','source_verification','curriculum',
     'initial_summary','technology_library_summary','organization_profile','ingestion_intent'
   ], e.stage)
   for update skip locked
   limit 1;
  if v_stage.stage_execution_id is null then return; end if;

  v_token := encode(gen_random_bytes(32), 'hex');
  update public.research_pre_research_stage_execution e
     set status = 'leased',
         attempt_count = e.attempt_count + 1,
         lease_owner = p_worker_id,
         lease_token_hash = encode(digest(v_token, 'sha256'), 'hex'),
         lease_expires_at = timezone('utc', now()) + make_interval(secs => p_lease_seconds),
         retry_after = null,
         started_at = coalesce(e.started_at, timezone('utc', now())),
         updated_at = timezone('utc', now())
   where e.stage_execution_id = v_stage.stage_execution_id
   returning e.stage_execution_id, e.run_id, e.stage, e.attempt_count,
             v_token, e.lease_expires_at, e.output_artifact_kinds
        into stage_execution_id, run_id, stage, attempt_count,
             lease_token, lease_expires_at, output_artifact_kinds;

  if stage = 'initial_summary' then
    update public.research_pre_research_run set status = 'synthesizing', updated_at = timezone('utc', now())
     where research_pre_research_run.run_id = v_run_id and status = 'research_complete';
  elsif stage <> 'ingestion_intent' then
    update public.research_pre_research_run set status = 'analyzing', updated_at = timezone('utc', now())
     where research_pre_research_run.run_id = v_run_id and status::text = any(array['queued','claimed']);
  end if;
  return next;
end;
$$;

create or replace function research_private.checkpoint_pre_research_stage_input(
  p_run_id uuid,
  p_stage text,
  p_worker_id text,
  p_lease_token text,
  p_bucket text,
  p_manifest_path text,
  p_input_sha256 text,
  p_prompt_bundle_version text
)
returns public.research_pre_research_stage_execution
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare v_row public.research_pre_research_stage_execution%rowtype;
begin
  select * into v_row from public.research_pre_research_stage_execution
   where run_id = p_run_id and stage = p_stage for update;
  if v_row.status <> 'leased' or v_row.lease_owner <> p_worker_id
     or v_row.lease_token_hash <> encode(digest(p_lease_token, 'sha256'), 'hex')
     or v_row.lease_expires_at <= timezone('utc', now()) then
    raise exception 'STAGE_LEASE_INVALID';
  end if;
  if v_row.input_sha256 is not null and
     (v_row.input_sha256 <> p_input_sha256 or v_row.prompt_bundle_version <> p_prompt_bundle_version) then
    raise exception 'STAGE_INPUT_CONFLICT';
  end if;
  update public.research_pre_research_stage_execution
     set input_manifest_bucket = p_bucket, input_manifest_path = p_manifest_path,
         input_sha256 = p_input_sha256, prompt_bundle_version = p_prompt_bundle_version,
         updated_at = timezone('utc', now())
   where stage_execution_id = v_row.stage_execution_id returning * into v_row;
  return v_row;
end;
$$;

create or replace function research_private.complete_pre_research_stage(
  p_run_id uuid,
  p_stage text,
  p_worker_id text,
  p_lease_token text,
  p_artifact_sha256s jsonb,
  p_usage_summary jsonb default '{}'::jsonb,
  p_next_status text default null
)
returns public.research_pre_research_stage_execution
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_row public.research_pre_research_stage_execution%rowtype;
  v_actual jsonb;
begin
  select * into v_row from public.research_pre_research_stage_execution
   where run_id = p_run_id and stage = p_stage for update;
  select jsonb_object_agg(a.artifact_kind, a.content_sha256) into v_actual
    from public.research_pre_research_artifact a
   where a.run_id = p_run_id and a.artifact_kind = any(v_row.output_artifact_kinds);
  if coalesce(v_actual, '{}'::jsonb) <> coalesce(p_artifact_sha256s, '{}'::jsonb)
     or (select count(*) from jsonb_object_keys(coalesce(v_actual, '{}'::jsonb)))
          <> cardinality(v_row.output_artifact_kinds) then
    raise exception 'STAGE_ARTIFACT_HASH_MISMATCH';
  end if;
  if v_row.status = 'completed' then return v_row; end if;
  if v_row.status <> 'leased' or v_row.lease_owner <> p_worker_id
     or v_row.lease_token_hash <> encode(digest(p_lease_token, 'sha256'), 'hex') then
    raise exception 'STAGE_LEASE_INVALID';
  end if;
  update public.research_pre_research_stage_execution
     set status = 'completed', completed_artifact_sha256s = v_actual,
         usage_summary = coalesce(p_usage_summary, '{}'::jsonb), lease_owner = null,
         lease_token_hash = null, lease_expires_at = null, retry_after = null,
         last_error_code = null, last_error_detail = null,
         completed_at = timezone('utc', now()), updated_at = timezone('utc', now())
   where stage_execution_id = v_row.stage_execution_id returning * into v_row;

  if p_stage = 'curriculum' then
    update public.research_pre_research_run set status = 'research_complete', research_completed_at = timezone('utc', now()), updated_at = timezone('utc', now())
     where research_pre_research_run.run_id = p_run_id and status::text = any(array['claimed','analyzing']);
  elsif p_stage = 'ingestion_intent' then
    if p_next_status not in ('intent_ready','review_required') then raise exception 'STAGE_NEXT_STATUS_INVALID'; end if;
    update public.research_pre_research_run set status = p_next_status::public.research_pre_research_run_status,
      updated_at = timezone('utc', now()) where research_pre_research_run.run_id = p_run_id;
    perform research_private.project_pre_research_video_state(
      p_video_id := (select video_id from public.research_pre_research_run where run_id = p_run_id),
      p_latest_run_id := p_run_id,
      p_pipeline_status := p_next_status
    );
  end if;
  return v_row;
end;
$$;

create or replace function research_private.park_pre_research_stage(
  p_run_id uuid,
  p_stage text,
  p_worker_id text,
  p_lease_token text,
  p_retryable boolean,
  p_retry_after timestamptz,
  p_error_code text,
  p_error_detail text
)
returns public.research_pre_research_stage_execution
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare v_row public.research_pre_research_stage_execution%rowtype;
begin
  select * into v_row from public.research_pre_research_stage_execution
   where run_id = p_run_id and stage = p_stage for update;
  if v_row.status <> 'leased' or v_row.lease_owner <> p_worker_id
     or v_row.lease_token_hash <> encode(digest(p_lease_token, 'sha256'), 'hex') then
    raise exception 'STAGE_LEASE_INVALID';
  end if;
  update public.research_pre_research_stage_execution
     set status = case when p_retryable then 'retry_wait' else 'dead_letter' end,
         retry_after = case when p_retryable then p_retry_after else null end,
         lease_owner = null, lease_token_hash = null, lease_expires_at = null,
         last_error_code = left(coalesce(p_error_code, 'UNKNOWN'), 120),
         last_error_detail = left(coalesce(p_error_detail, ''), 2000),
         updated_at = timezone('utc', now())
   where stage_execution_id = v_row.stage_execution_id returning * into v_row;
  return v_row;
end;
$$;

revoke all on function research_private.ensure_pre_research_stage_rows(uuid) from public, anon, authenticated;
revoke all on function research_private.reconcile_pre_research_stage_rows(uuid) from public, anon, authenticated;
revoke all on function research_private.claim_pre_research_stage(text, integer, uuid) from public, anon, authenticated;
revoke all on function research_private.checkpoint_pre_research_stage_input(uuid, text, text, text, text, text, text, text) from public, anon, authenticated;
revoke all on function research_private.complete_pre_research_stage(uuid, text, text, text, jsonb, jsonb, text) from public, anon, authenticated;
revoke all on function research_private.park_pre_research_stage(uuid, text, text, text, boolean, timestamptz, text, text) from public, anon, authenticated;

grant execute on function research_private.ensure_pre_research_stage_rows(uuid) to postgres, service_role;
grant execute on function research_private.reconcile_pre_research_stage_rows(uuid) to postgres, service_role;
grant execute on function research_private.claim_pre_research_stage(text, integer, uuid) to postgres, service_role;
grant execute on function research_private.checkpoint_pre_research_stage_input(uuid, text, text, text, text, text, text, text) to postgres, service_role;
grant execute on function research_private.complete_pre_research_stage(uuid, text, text, text, jsonb, jsonb, text) to postgres, service_role;
grant execute on function research_private.park_pre_research_stage(uuid, text, text, text, boolean, timestamptz, text, text) to postgres, service_role;
