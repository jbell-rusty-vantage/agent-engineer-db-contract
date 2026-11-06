-- Never lease a later pre-research stage while any predecessor is unfinished.
-- This protects recovery after a worker loses its connection while parking or
-- completing the currently leased stage.

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
  v_stage_order text[] := array[
    'transcript_taxonomy','web_context','organization_research','source_verification','curriculum',
    'initial_summary','technology_library_summary','organization_profile','ingestion_intent'
  ];
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
     and not exists (
       select 1
         from public.research_pre_research_stage_execution predecessor
        where predecessor.run_id = e.run_id
          and array_position(v_stage_order, predecessor.stage) < array_position(v_stage_order, e.stage)
          and predecessor.status <> 'completed'
     )
   order by array_position(v_stage_order, e.stage)
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

revoke all on function research_private.claim_pre_research_stage(text, integer, uuid) from public, anon, authenticated;
grant execute on function research_private.claim_pre_research_stage(text, integer, uuid) to postgres, service_role;
