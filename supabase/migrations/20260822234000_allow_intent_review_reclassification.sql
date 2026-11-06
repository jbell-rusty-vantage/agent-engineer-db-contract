create or replace function research_private.complete_synthesis_phase(
  p_run_id uuid,
  p_eve_session_id text,
  p_next_status public.research_pre_research_run_status
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_run public.research_pre_research_run%rowtype;
  v_hash text;
begin
  if p_next_status not in ('intent_ready', 'review_required') then
    raise exception 'ILLEGAL_SYNTHESIS_NEXT_STATUS: %', p_next_status;
  end if;

  select * into v_run
  from public.research_pre_research_run
  where run_id = p_run_id
  for update;

  if not found then raise exception 'RUN_NOT_FOUND: %', p_run_id; end if;
  if v_run.synthesis_session_id is null then raise exception 'SESSION_BINDING_PENDING: %', p_run_id; end if;
  if v_run.synthesis_session_id is distinct from p_eve_session_id then
    raise exception 'SESSION_MISMATCH: %', p_run_id;
  end if;

  -- The normal transition completes synthesis. The second transition is a
  -- defensive reclassification when the executor discovers a deterministic
  -- review blocker after a run was already labelled intent_ready.
  if v_run.status = 'synthesizing' then
    update public.research_pre_research_session
    set status = 'completed', completed_at = timezone('utc', now())
    where run_id = p_run_id
      and phase = 'synthesis'
      and eve_session_id = p_eve_session_id
      and status = 'started';
  elsif not (v_run.status = 'intent_ready' and p_next_status = 'review_required') then
    raise exception 'ILLEGAL_PHASE_TRANSITION: % %', p_run_id, v_run.status;
  end if;

  v_hash := research_private.current_transcript_hash(v_run.video_id);
  if v_hash is distinct from v_run.transcript_sha256 then
    raise exception 'TRANSCRIPT_HASH_MISMATCH: %', p_run_id;
  end if;

  update public.research_pre_research_run
  set status = p_next_status
  where run_id = p_run_id
  returning * into v_run;

  perform research_private.project_pre_research_video_state(
    v_run.video_id,
    v_run.run_id,
    p_next_status::text
  );
  return jsonb_build_object('ok', true, 'run', to_jsonb(v_run));
end;
$$;
