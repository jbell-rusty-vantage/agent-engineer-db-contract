-- Allow claiming a specific video_id. The 4-arg form is replaced by a
-- 5-arg form with p_video_id defaulting to null (next eligible video).

drop function if exists research_private.claim_pre_research_video(integer, text, text, text);

create or replace function research_private.claim_pre_research_video(
  p_lease_seconds integer default 1800,
  p_taxonomy_version text default '1.0.0',
  p_prompt_bundle_version text default 'pre-research-1.0.0',
  p_model_id text default 'zai/glm-5.2',
  p_video_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public
as $$
declare
  v_video public.research_starter_videos%rowtype;
  v_hash text;
  v_run public.research_pre_research_run%rowtype;
  v_taxonomy_id uuid;
  v_lease_token uuid;
begin
  if p_lease_seconds < 60 or p_lease_seconds > 21600 then
    raise exception 'INVALID_LEASE_SECONDS: %', p_lease_seconds;
  end if;

  update public.research_pre_research_run
  set
    status = 'failed',
    error_code = 'LEASE_EXPIRED',
    error_detail = 'Lease expired before the run completed',
    completed_at = timezone('utc', now())
  where status in ('claimed', 'analyzing')
    and lease_expires_at is not null
    and lease_expires_at < timezone('utc', now());

  select taxonomy_version_id
  into v_taxonomy_id
  from public.research_taxonomy_version
  where version = p_taxonomy_version
    and status = 'active'
  limit 1;

  if v_taxonomy_id is null then
    raise exception 'ACTIVE_TAXONOMY_NOT_FOUND: %', p_taxonomy_version;
  end if;

  if p_video_id is not null then
    select v.*
    into v_video
    from public.research_starter_videos v
    where v.video_id = p_video_id
    for update of v skip locked;

    if not found then
      return jsonb_build_object('claimed', false, 'reason', 'VIDEO_NOT_FOUND', 'video_id', p_video_id);
    end if;

    if v_video.transcript_status is distinct from 'stored'
      or v_video.transcript_text is null
      or length(btrim(v_video.transcript_text)) = 0 then
      return jsonb_build_object(
        'claimed', false,
        'reason', 'VIDEO_TRANSCRIPT_NOT_STORED',
        'video_id', p_video_id,
        'transcript_status', v_video.transcript_status
      );
    end if;

    v_hash := encode(digest(v_video.transcript_text, 'sha256'), 'hex');

    if exists (
      select 1
      from public.research_pre_research_run r
      where r.video_id = v_video.video_id
        and r.transcript_sha256 = v_hash
        and r.status in (
          'queued', 'claimed', 'analyzing', 'intent_ready', 'applying', 'applied'
        )
    ) then
      return jsonb_build_object(
        'claimed', false,
        'reason', 'VIDEO_ALREADY_CLAIMED_OR_APPLIED',
        'video_id', p_video_id
      );
    end if;
  else
    select v.*
    into v_video
    from public.research_starter_videos v
    where v.transcript_status = 'stored'
      and v.transcript_text is not null
      and length(btrim(v.transcript_text)) > 0
      and not exists (
        select 1
        from public.research_pre_research_run r
        where r.video_id = v.video_id
          and r.transcript_sha256 = encode(digest(v.transcript_text, 'sha256'), 'hex')
          and r.status in (
            'queued', 'claimed', 'analyzing', 'intent_ready', 'applying', 'applied'
          )
      )
    order by v.published_at asc nulls last, v.video_id
    for update of v skip locked
    limit 1;

    if not found then
      return jsonb_build_object('claimed', false, 'reason', 'NO_ELIGIBLE_VIDEO');
    end if;

    v_hash := encode(digest(v_video.transcript_text, 'sha256'), 'hex');
  end if;

  v_lease_token := gen_random_uuid();

  insert into public.research_pre_research_run (
    video_id,
    taxonomy_version_id,
    status,
    attempt,
    lease_token,
    lease_expires_at,
    transcript_sha256,
    prompt_bundle_version,
    model_id,
    started_at
  )
  values (
    v_video.video_id,
    v_taxonomy_id,
    'claimed',
    coalesce((
      select max(r.attempt)
      from public.research_pre_research_run r
      where r.video_id = v_video.video_id
    ), 0) + 1,
    v_lease_token,
    timezone('utc', now()) + make_interval(secs => p_lease_seconds),
    v_hash,
    p_prompt_bundle_version,
    p_model_id,
    timezone('utc', now())
  )
  returning * into v_run;

  return jsonb_build_object(
    'claimed', true,
    'run', to_jsonb(v_run),
    'video', jsonb_build_object(
      'video_id', v_video.video_id,
      'title', v_video.title,
      'description', v_video.description,
      'published_at', v_video.published_at,
      'channel_id', v_video.channel_id,
      'channel_handle', v_video.channel_handle,
      'channel_title', v_video.channel_title,
      'duration', v_video.duration,
      'duration_seconds', v_video.duration_seconds,
      'url', v_video.url,
      'thumbnail_url', v_video.thumbnail_url,
      'transcript_status', v_video.transcript_status,
      'transcript_bucket', v_video.transcript_bucket,
      'transcript_path', v_video.transcript_path,
      'transcript_language', v_video.transcript_language,
      'transcript_char_count', v_video.transcript_char_count,
      'transcript_sha256', v_hash
    )
  );
end;
$$;

revoke all on function research_private.claim_pre_research_video(integer, text, text, text, text)
  from public, anon, authenticated;
grant execute on function research_private.claim_pre_research_video(integer, text, text, text, text)
  to postgres, service_role;
