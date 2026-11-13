-- Build 08 knowledge loop 5 (candidate H): D-61 self-checked claims leave the score; D-69 no watch suggestion below 5 checked claims;
-- D-62 verdict-aware ranking as a reported evidence channel; released passages become T1; probe revalidation on release (D-76) and
-- releases that need review; the triage of claim candidates. Promoted 2026-11-13 from the lab drafts 20261113160000, 20261113160200,
-- 20261113160300 (kept in supabase/drafts/). Lab-proven on disposable-aieng-build04; cycle record: Build 08 §24.
begin;

-- ---- from draft 20261113160000_build08_loop5_followups.sql
-- Build 08 loop 5 (candidate H): loop-4 follow-ups. Draft for the disposable lab (disposable-aieng-build04).
-- D-61 self-checked claims leave the score; D-69 no watch suggestion below 5 checked claims; D-62 verdict-aware ranking as a
-- separate, reported channel; released passages are ours (T1); probe revalidation on release and releases that need review;
-- the triage of community claim candidates. D-64 (release data) is a pipeline repair, not DDL.

-- ------------------------------------------------------------------------------------------- 1. assessment rules (D-61, D-69)
alter table evidence.source_assessment add column if not exists self_checked integer not null default 0 check (self_checked >= 0);
comment on column evidence.source_assessment.self_checked is
  'Loop 5 (D-61): checked claims that the subject stated and our own probes checked. Shown, never counted in confirmed / qualified / refuted or in authority_score: a check by the party that made the claim is not independent evidence of that party''s reliability.';

create or replace function evidence.claim_is_self_stated(p_claim uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from evidence.claim c where c.id = p_claim and c.structured ->> 'source_role' = 'own_experiment')
      or exists (select 1 from evidence.attribution a
                  where a.claim_id = p_claim and a.entity_id is not null
                    and exists (select 1 from evidence.source_assessment s where s.subject_entity_id = a.entity_id and s.method in ('prior','reviewed') and s.source_role_code = 'own_experiment'))
$$;
comment on function evidence.claim_is_self_stated(uuid) is 'Loop 5: a claim stated by this system (structured.source_role own_experiment, or attributed to an entity whose prior role is own_experiment). Our probes checking it is self-verification (D-61).';

create or replace function evidence.derive_source_assessment(p_subject uuid, p_topic uuid DEFAULT NULL::uuid, p_assessed_by text DEFAULT 'agent:derive_source_assessment'::text, p_note text DEFAULT NULL::text)
 RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $function$
declare
  v_kind text; v_prior numeric; v_role text; v_prev uuid; v_base evidence.source_assessment; v_obs integer; v_conf integer; v_qual integer; v_ref integer; v_open integer; v_self integer;
  v_lead numeric; v_noise numeric; v_score numeric; v_level text; v_id uuid; v_checked integer; c_min constant integer := 5;
begin
  select kind into v_kind from catalog.entity where id = p_subject;
  select id into v_prev from evidence.source_assessment where subject_entity_id = p_subject and topic_entity_id is not distinct from p_topic order by as_of desc, created_at desc limit 1;
  select * into v_base from evidence.source_assessment where subject_entity_id = p_subject and method in ('prior','reviewed') and (topic_entity_id is not distinct from p_topic or topic_entity_id is null)
   order by (topic_entity_id is not distinct from p_topic) desc, as_of desc, created_at desc limit 1;
  v_role := coalesce(v_base.source_role_code, case v_kind when 'community_actor' then 'community' when 'source_channel' then 'community' else 'unknown' end);
  select authority_rank into v_prior from content.source_role where code = v_role;
  with stated as (
    select distinct a.claim_id from evidence.attribution a left join evidence.source s on s.id = a.source_id
     where a.claim_id is not null and (a.entity_id = p_subject or s.channel_entity_id = p_subject or s.publisher_entity_id = p_subject)
       and (p_topic is null or exists (select 1 from evidence.claim_subject cs where cs.claim_id = a.claim_id and cs.entity_id = p_topic))
  ), latest as (
    select distinct on (v.claim_id) v.claim_id, v.verdict::text as verdict, evidence.claim_is_self_stated(v.claim_id) as self_
      from verification.probe_verdict v join stated using (claim_id)
     where v.review_state <> 'human_rejected' order by v.claim_id, v.decided_at desc
  ), checked as (
    select * from latest where verdict in ('directly_supported','derived_verified','supported_with_qualification','partially_supported','contradicted','derived_failed')
  ), leads as (
    select (c.structured->>'first_party_at')::date - (c.structured->>'stated_at')::date as lead
      from evidence.claim c join latest l on l.claim_id = c.id
     where not l.self_ and l.verdict in ('directly_supported','supported_with_qualification','partially_supported','derived_verified') and c.structured ? 'first_party_at' and c.structured ? 'stated_at'
  )
  select (select count(*) from stated),
         (select count(*) from checked where not self_ and verdict in ('directly_supported','derived_verified')),
         (select count(*) from checked where not self_ and verdict in ('supported_with_qualification','partially_supported')),
         (select count(*) from checked where not self_ and verdict in ('contradicted','derived_failed')),
         (select count(*) from latest where verdict not in ('directly_supported','derived_verified','supported_with_qualification','partially_supported','contradicted','derived_failed')),
         (select count(*) from checked where self_),
         (select percentile_cont(0.5) within group (order by lead) from leads)
    into v_obs, v_conf, v_qual, v_ref, v_open, v_self, v_lead;
  v_checked := v_conf + v_qual + v_ref;
  select round(sum(sw.items_seen)::numeric / nullif(sum(sw.items_selected), 0), 2) into v_noise
    from acquisition.attention_sweep sw join acquisition.attention_policy p on p.id = sw.policy_id where p_subject = any(p.channel_entity_ids);
  v_score := round((4 * coalesce(v_prior, 10) + 100 * (v_conf + 0.5 * v_qual)) / (4 + v_checked), 2);
  v_level := case when v_checked < c_min then null
                  when v_score >= 70 and coalesce(v_noise, 1) <= 10 then 'W3' when v_score >= 50 and coalesce(v_noise, 1) <= 40 then 'W2' when v_score >= 30 then 'W1' else 'W0' end;
  insert into evidence.source_assessment(subject_entity_id, topic_entity_id, method, source_role_code, conflict_of_interest, method_disclosure, claims_observed, claims_checked, confirmed, qualified, refuted,
                                         median_lead_days, noise_ratio, authority_score, recommended_watch_level, rationale, inputs, assessed_by, supersedes_id, self_checked)
  values (p_subject, p_topic, 'derived', v_role, coalesce(v_base.conflict_of_interest, 'unknown'), coalesce(v_base.method_disclosure, 'not_applicable'), v_obs, v_checked, v_conf, v_qual, v_ref,
          v_lead, v_noise, v_score, v_level,
          coalesce(p_note, format('derived from %s stated claims (%s independently checked: %s confirmed, %s qualified, %s refuted; %s self-checked, not scored; %s judged but not checkable or not reproduced) over a %s prior of %s%s',
                                  v_obs, v_checked, v_conf, v_qual, v_ref, v_self, v_open, v_role, coalesce(v_prior, 10),
                                  case when v_checked < c_min then format('; no watch suggestion: %s checked claims, the minimum is %s (D-69)', v_checked, c_min) else '' end)),
          jsonb_build_object('prior', v_prior, 'base_assessment', v_base.id, 'open_verdicts', v_open, 'self_checked', v_self, 'min_checked_for_suggestion', c_min,
                             'formula', '(4*prior + 100*(confirmed + 0.5*qualified)) / (4 + checked); self-checked claims excluded (D-61)'), p_assessed_by, v_prev, v_self)
  returning id into v_id;
  return v_id;
end $function$;
comment on function evidence.derive_source_assessment(uuid, uuid, text, text) is
  'Append a derived assessment for a source (subject) on a topic: the role prior moved by independently checked claims (self-checked ones counted in self_checked, not scored, D-61); a watch level is suggested only from 5 checked claims (D-69).';

create or replace view api.source_registry as
 SELECT e.id AS source_entity_id, e.kind AS source_kind, e.display_name AS source, (e.attributes ->> 'platform'::text) AS platform,
    COALESCE((e.attributes ->> 'url'::text), (e.attributes ->> 'profile_url'::text)) AS url, t.id AS topic_entity_id, t.display_name AS topic,
    a.as_of, a.method, a.source_role_code, a.conflict_of_interest, a.method_disclosure, a.claims_observed, a.claims_checked, a.confirmed, a.qualified, a.refuted,
    a.median_lead_days, a.noise_ratio, a.authority_score, a.recommended_watch_level,
    ( SELECT p.watch_level FROM acquisition.attention_policy p WHERE ((e.id = ANY (p.channel_entity_ids)) AND (p.state <> 'retired'::text)) ORDER BY p.watch_level DESC LIMIT 1) AS current_watch_level,
    ( SELECT count(*) AS count FROM evidence.source s WHERE (s.channel_entity_id = e.id)) AS urls,
    a.rationale, a.id AS assessment_id, a.self_checked
   FROM ((( SELECT DISTINCT ON (sa.subject_entity_id, sa.topic_entity_id) sa.* FROM evidence.source_assessment sa
          ORDER BY sa.subject_entity_id, sa.topic_entity_id, sa.as_of DESC, sa.created_at DESC) a
     JOIN catalog.entity e ON ((e.id = a.subject_entity_id)))
     LEFT JOIN catalog.entity t ON ((t.id = a.topic_entity_id)));
comment on view api.source_registry is 'Latest assessment per source and topic: role prior, conflict of interest, method disclosure, track record from independently checked claims, self_checked (shown, not scored, D-61), lead days, noise, derived score and a watch suggestion only from 5 checked claims (D-69).';

-- ------------------------------------------------------------------------------------------- 2. verdict-aware ranking (D-62)
create or replace function retrieval.evidence_signal(p_claim uuid, p_document uuid, p_unit_kind text) returns jsonb
language sql stable security definer set search_path = '' as $$
  with claims as (
    select p_claim as claim_id where p_claim is not null
    union
    select pc.claim_id from verification.probe_run pr join content.document_version_source_capture vc on vc.source_capture_id = pr.output_capture_id
      join content.document_version v on v.id = vc.document_version_id join verification.probe_claim pc on pc.probe_id = pr.probe_id
     where p_claim is null and p_unit_kind = 'probe_observation' and v.document_id = p_document
  ), judged as (
    select c.id, c.status::text as status,
           (select v.verdict::text from verification.probe_verdict v where v.claim_id = c.id and v.review_state <> 'human_rejected'
             and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id) order by v.decided_at desc limit 1) as verdict
      from evidence.claim c join claims cl on cl.claim_id = c.id
  ), scored as (
    select id, status, verdict,
           case when status in ('disputed','rejected') or verdict in ('contradicted','derived_failed') then -1.0
                when status = 'verified' or verdict in ('directly_supported','derived_verified') then 1.0
                when verdict in ('supported_with_qualification','partially_supported') then 0.5 else 0.0 end as signal
      from judged
  )
  select case when count(*) = 0 then null else jsonb_build_object(
           'signal', round(avg(signal)::numeric, 3), 'claims', count(*),
           'verdict', (select verdict from scored order by abs(signal) desc, verdict nulls last limit 1),
           'status', (select status from scored order by abs(signal) desc limit 1)) end
    from scored
$$;
comment on function retrieval.evidence_signal(uuid, uuid, text) is
  'Loop 5 (D-62): the evidence behind a search candidate: its claim''s current probe verdict and status, or for a probe observation the verdicts of the claims its probe judged. +1 supported or verified, +0.5 qualified, -1 contradicted or disputed, 0 otherwise (averaged). Not a relevance score; search reports it as its own channel.';

drop function if exists api.search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer);
CREATE OR REPLACE FUNCTION api.search_unified(p_query text, p_query_embedding halfvec DEFAULT NULL::halfvec, p_lenses text[] DEFAULT ARRAY['corpus'::text, 'ours'::text], p_tiers smallint[] DEFAULT NULL::smallint[], p_space_slugs text[] DEFAULT NULL::text[], p_document_types text[] DEFAULT NULL::text[], p_unit_kinds text[] DEFAULT NULL::text[], p_entity_ids uuid[] DEFAULT NULL::uuid[], p_as_of timestamp with time zone DEFAULT NULL::timestamp with time zone, p_workspace_ids uuid[] DEFAULT NULL::uuid[], p_source_roles text[] DEFAULT NULL::text[], p_content_kinds text[] DEFAULT NULL::text[], p_limit integer DEFAULT 20, p_candidate_limit integer DEFAULT 100, p_rrf_k integer DEFAULT 60, p_evidence_weight double precision DEFAULT 0.15)
 RETURNS TABLE(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid, target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamp with time zone, valid_during tstzrange, space_slug text, fused_score double precision, channel_scores jsonb)
 LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery('english', p_query);
begin
  if coalesce(length(btrim(p_query)),0) < 1 or length(p_query) > 4096 then raise exception 'query text length must be between 1 and 4096' using errcode='invalid_parameter_value'; end if;
  if p_limit not between 1 and 200 or p_candidate_limit not between p_limit and 2000 then raise exception 'result/candidate bounds are invalid' using errcode='invalid_parameter_value'; end if;
  if p_evidence_weight is null or p_evidence_weight not between 0 and 1 then raise exception 'evidence weight must be between 0 and 1' using errcode='invalid_parameter_value'; end if;
  perform set_config('hnsw.iterative_scan','relaxed_order',true);
  return query
  with eligible as materialized (
    select vi.*, s.slug as space_slug_
    from retrieval.vector_item vi join retrieval.vector_space_version v on v.id = vi.space_version_id join retrieval.vector_space s on s.id = v.vector_space_id
    where vi.tenant_id = t and vi.lifecycle = 'active'
      and vi.lens = any(p_lenses)
      and (vi.lens <> 'private' or (p_workspace_ids is not null and vi.workspace_id = any(p_workspace_ids)))
      and (p_tiers is null or vi.source_tier = any(p_tiers))
      and (p_space_slugs is null or s.slug = any(p_space_slugs))
      and (p_document_types is null or vi.document_type_code = any(p_document_types))
      and (p_unit_kinds is null or vi.unit_kind = any(p_unit_kinds))
      and (p_content_kinds is null or vi.content_kind = any(p_content_kinds))
      and (p_source_roles is null or vi.source_role_code = any(p_source_roles))
      and (p_entity_ids is null or vi.entity_id = any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)
      and (p_as_of is null or vi.valid_during is null or vi.valid_during @> p_as_of)
  ), fts as (
    select e.id, ts_rank_cd(e.search_tsv_en, q)::double precision raw, row_number() over (order by ts_rank_cd(e.search_tsv_en, q) desc, e.id)::bigint rk
    from eligible e where e.search_tsv_en @@ q limit p_candidate_limit
  ), trigram as (
    select e.id, extensions.similarity(e.search_text, p_query)::double precision raw, row_number() over (order by extensions.similarity(e.search_text, p_query) desc, e.id)::bigint rk
    from eligible e where length(p_query) >= 3 and extensions.similarity(e.search_text, p_query) > 0.3 limit p_candidate_limit
  ), ann as (
    select e.id, (1 - (emb.embedding operator(extensions.<=>) p_query_embedding))::double precision raw, row_number() over (order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id)::bigint rk
    from eligible e join retrieval.vector_item_embedding_1536 emb on emb.vector_item_id = e.id and emb.vector_space_key = e.space_slug_
    where p_query_embedding is not null
    order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id limit p_candidate_limit
  ), channels as (
    select id, 'fts' ch, raw, rk from fts union all select id, 'trigram', raw, rk from trigram union all select id, 'ann', raw, rk from ann
  ), fused as (
    select id, sum(1.0/(p_rrf_k + rk))::double precision score, jsonb_object_agg(ch, jsonb_build_object('score', raw, 'rank', rk) order by ch) details from channels group by id
  ), judged as (
    select f.id, f.score, f.details, e2.source_tier tier_,
           case when p_evidence_weight > 0 then retrieval.evidence_signal(pt.claim_id, e2.document_id, e2.unit_kind) end ev
      from fused f join eligible e2 on e2.id = f.id left join retrieval.projection_target pt on pt.id = e2.projection_target_id
  ), ranked as (
    select j.*, j.score * (1 + coalesce(0.1 * (3 - j.tier_), 0)) * (1 + p_evidence_weight * coalesce((j.ev ->> 'signal')::double precision, 0)) final_
      from judged j
  )
  select e.id, e.lens, e.source_tier, e.content_kind, e.document_type_code, e.unit_kind, e.entity_id, e.document_id, e.document_version_id,
         pt.target_kind, coalesce(pt.entity_id, pt.record_id, pt.chunk_id, pt.claim_id, pt.summary_id, pt.document_node_id, pt.digest_item_id, pt.digest_id, pt.authored_revision_id, pt.passage_id),
         e.workspace_id, left(e.search_text, 320), e.start_ms, e.end_ms, e.observed_at, e.valid_during, e.space_slug_, r.final_,
         case when r.ev is null then r.details else r.details || jsonb_build_object('evidence', r.ev || jsonb_build_object('weight', p_evidence_weight,
              'factor', round((1 + p_evidence_weight * coalesce((r.ev ->> 'signal')::double precision, 0))::numeric, 4))) end
  from ranked r join eligible e on e.id = r.id left join retrieval.projection_target pt on pt.id = e.projection_target_id
  order by r.final_ desc, e.id limit p_limit;
end $function$;
comment on function api.search_unified is
  'One search stack: RRF over FTS + trigram + ANN within lens/tier/space/facet filters, a small source-tier boost, and (loop 5, D-62) an evidence factor 1 + weight x signal from retrieval.evidence_signal, reported as channel_scores.evidence (signal, verdict, status, weight, factor). Weight 0 reproduces the loop-4 order. Rank, authority and verdict stay separate fields.';
grant execute on function api.search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer, double precision)
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
revoke all on function retrieval.evidence_signal(uuid, uuid, text) from public, anon;

-- ------------------------------------------------------------------------------------------- 3. released passages are ours (T1)
-- retrieval.vector_item is immutable: a tier change is a successor item (same text, projection and embedding, tier 1) that supersedes the draft item.
create or replace function retrieval.promote_revision_passages(p_revision uuid) returns integer
language plpgsql security definer set search_path = '' as $$
declare r_ retrieval.vector_item; n uuid; c integer := 0;
begin
  for r_ in select vi.* from retrieval.vector_item vi join retrieval.projection_target pt on pt.id = vi.projection_target_id join library.passage pa on pa.id = pt.passage_id
            where pa.revision_id = p_revision and vi.lifecycle = 'active' and vi.source_tier is distinct from 1 loop
    insert into retrieval.vector_item(tenant_id,space_version_id,source_version_hash,content_sha256,chunk_index,backend_location,generation_run_id,receipt_id,verification_state,search_projection_id,embedding_item_id,language,visibility,classification,lifecycle,authority_level,freshness_at,search_text,retrieval_chunk_id,projection_target_id,entity_id,entity_kind,secondary_entity_ids,document_type_code,content_kind,valid_during,knowledge_seq,assurance_rank,start_ms,end_ms,lens,source_tier,workspace_id,unit_kind,document_id,document_version_id,source_role_code,observed_at)
    select o.tenant_id,o.space_version_id,o.source_version_hash,o.content_sha256,o.chunk_index,o.backend_location,o.generation_run_id,o.receipt_id,o.verification_state,o.search_projection_id,o.embedding_item_id,o.language,o.visibility,o.classification,o.lifecycle,o.authority_level,o.freshness_at,o.search_text,o.retrieval_chunk_id,o.projection_target_id,o.entity_id,o.entity_kind,o.secondary_entity_ids,o.document_type_code,o.content_kind,o.valid_during,o.knowledge_seq,o.assurance_rank,o.start_ms,o.end_ms,o.lens,1::smallint,o.workspace_id,o.unit_kind,o.document_id,o.document_version_id,o.source_role_code,o.observed_at from (select r_.*) o returning id into n;
    insert into retrieval.vector_item_embedding_1536(tenant_id, vector_space_key, vector_space_version_id, vector_item_id, embedding, embedding_sha256)
    select e.tenant_id, e.vector_space_key, e.vector_space_version_id, n, e.embedding, e.embedding_sha256 from retrieval.vector_item_embedding_1536 e where e.vector_item_id = r_.id;
    update retrieval.vector_item set superseded_by_id = n where id = r_.id;
    update retrieval.vector_item set lifecycle = 'superseded' where id = r_.id;
    c := c + 1;
  end loop;
  return c;
end $$;
comment on function retrieval.promote_revision_passages(uuid) is 'Loop 5: the active search items of a released revision''s passages get a successor at tier T1 (our content), same text, projection and embedding; the draft item is superseded. A workspace draft has no tier.';
create or replace function retrieval.promote_release_passages(p_release uuid) returns integer
language sql security definer set search_path = '' as $$
  select coalesce(sum(retrieval.promote_revision_passages(ri.revision_id)), 0)::integer from authoring.release_item ri
   where ri.release_id = p_release and ri.revision_id is not null and ri.disposition in ('include','snapshot')
$$;
comment on function retrieval.promote_release_passages(uuid) is 'Loop 5: promote the passages of every revision a release includes to T1.';
create or replace function retrieval.on_release_item_promote() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.revision_id is not null and new.disposition in ('include','snapshot') then perform retrieval.promote_revision_passages(new.revision_id); end if;
  return null;
end $$;
drop trigger if exists release_item_promote_passages on authoring.release_item;
create trigger release_item_promote_passages after insert on authoring.release_item for each row execute function retrieval.on_release_item_promote();
do $$ declare r record; begin for r in select id from authoring.release loop perform retrieval.promote_release_passages(r.id); end loop; end $$;

-- ------------------------------------------------------------------------------------------- 4. revalidation on release
create or replace function api.probe_revalidation_due(p_as_of timestamptz default now())
returns table(probe_id uuid, probe text, cell_label text, last_run_at timestamptz, library text, resolved_version text, newest_version text, newest_released_at timestamptz, reason text)
language sql stable security definer set search_path = '' as $$
  with latest_cell as (
    select distinct on (pr.probe_id, pr.cell_label) pr.probe_id, pr.cell_label, pr.started_at, pr.resolved
      from verification.probe_run pr join verification.probe p on p.id = pr.probe_id
     where p.state = 'active' and pr.started_at <= p_as_of and (pr.cell ->> 'exclude_newer') is null and pr.cell_label like '%latest%'
     order by pr.probe_id, pr.cell_label, pr.started_at desc
  ), subj as (
    select lc.*, l.id lib_id, l.slug lib_slug, l.display_name lib_name
      from latest_cell lc join verification.probe p on p.id = lc.probe_id join catalog.entity l on l.id = any(p.subject_entity_ids) and l.kind = 'library'
  ), newest as (
    select distinct on (r.software_id) r.software_id, r.version_label, r.released_at
      from api.software_releases r where r.released_at <= p_as_of and r.version_label ~ '^\d+\.\d+(\.\d+)?$'
     order by r.software_id, r.released_at desc, r.version_label desc
  )
  select s.probe_id, p.slug, s.cell_label, s.started_at, s.lib_slug, s.resolved ->> s.lib_slug, n.version_label, n.released_at,
         format('%s %s released %s, after the last %s run (%s resolved %s)', s.lib_name, n.version_label, n.released_at::date, s.cell_label, s.started_at::date, coalesce(s.resolved ->> s.lib_slug, 'nothing'))
    from subj s join verification.probe p on p.id = s.probe_id join newest n on n.software_id = s.lib_id
   where n.released_at > s.started_at and (s.resolved ->> s.lib_slug) is distinct from n.version_label
   order by p.slug, s.lib_slug
$$;
comment on function api.probe_revalidation_due(timestamptz) is 'Loop 5: probes whose latest (unpinned) cell last resolved an older version of a subject library than its newest catalogued release, released after that run: the probe-revalidation policy reruns them.';

create or replace function api.releases_needing_review() returns table(release_id uuid, release_no integer, root_work_id uuid, released_at timestamptz, claim_id uuid, statement text, verdict_at_release text, verdict_now text, status_now text, decided_at timestamptz)
language sql stable security definer set search_path = '' as $$
  with bound as (
    select r.id rid, r.release_no, r.root_work_id, r.created_at rat, ri.claim_id from authoring.release r join authoring.release_item ri on ri.release_id = r.id
     where r.tenant_id = util.current_tenant_id() and ri.claim_id is not null
    union
    select r.id, r.release_no, r.root_work_id, r.created_at, b.claim_id from authoring.release r join authoring.revision_binding b on b.revision_id = r.root_revision_id
     where r.tenant_id = util.current_tenant_id() and b.claim_id is not null
  )
  select b.rid, b.release_no, b.root_work_id, b.rat, b.claim_id, c.statement, at_rel.verdict, now_.verdict, c.status::text, now_.decided_at
    from bound b join evidence.claim c on c.id = b.claim_id
    left join lateral (select v.verdict::text verdict from verification.probe_verdict v where v.claim_id = b.claim_id and v.decided_at <= b.rat and v.review_state <> 'human_rejected' order by v.decided_at desc limit 1) at_rel on true
    left join lateral (select v.verdict::text verdict, v.decided_at from verification.probe_verdict v where v.claim_id = b.claim_id and v.review_state <> 'human_rejected' order by v.decided_at desc limit 1) now_ on true
   where now_.decided_at > b.rat and now_.verdict is distinct from at_rel.verdict
   order by b.rat, c.statement
$$;
comment on function api.releases_needing_review() is 'Loop 5: releases whose bound claims have a current probe verdict, decided after the release, that differs from the verdict current when the release was frozen; a human confirmation of the same verdict does not trigger.';

-- ------------------------------------------------------------------------------------------- 5. triage of claim candidates
create table if not exists verification.claim_triage (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  claim_id uuid not null references evidence.claim(id),
  disposition text not null check (disposition in ('probe','docs_check','registry_check','not_checkable','duplicate','out_of_scope')),
  checkability text not null check (checkability in ('deterministic_local','needs_live_model','needs_external_service','historical_only','not_applicable')),
  priority numeric(6,2),
  components jsonb not null default '{}'::jsonb,
  duplicate_of_claim_id uuid references evidence.claim(id),
  probe_id uuid references verification.probe(id),
  rationale text not null,
  decided_by text not null,
  review_state text not null default 'agent_proposed' check (review_state in ('agent_proposed','human_confirmed','human_rejected')),
  decided_at timestamptz not null default now(),
  supersedes_id uuid references verification.claim_triage(id)
);
create index if not exists claim_triage_claim_ix on verification.claim_triage(claim_id, decided_at desc);
comment on table verification.claim_triage is 'Loop 5: what to do with a claim candidate before anyone checks it: probe it, check the docs or the registry, or not checkable (advice, experience, opinion), duplicate, out of scope; with checkability, priority components, rationale and the probe it became. Append-only; a later row supersedes.';
alter table verification.claim_triage enable row level security;
create policy claim_triage_tenant on verification.claim_triage using (tenant_id = util.current_tenant_id());
grant select on verification.claim_triage to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner;
grant insert on verification.claim_triage to pipeline_agent, verifier_agent, control_plane;

create or replace view api.claim_triage as
  select t.claim_id, c.statement, c.claim_type::text claim_type, c.status::text status, t.disposition, t.checkability, t.priority, t.components, t.rationale,
         p.slug probe, t.duplicate_of_claim_id, t.decided_by, t.review_state, t.decided_at,
         (select v.verdict::text from verification.probe_verdict v where v.claim_id = t.claim_id order by v.decided_at desc limit 1) verdict
    from verification.claim_triage t join evidence.claim c on c.id = t.claim_id left join verification.probe p on p.id = t.probe_id
   where t.tenant_id = util.current_tenant_id() and not exists (select 1 from verification.claim_triage w where w.supersedes_id = t.id);
comment on view api.claim_triage is 'Loop 5: the current triage of each claim candidate, with the probe it became and its verdict if probed.';
grant select on api.claim_triage to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner, authenticated, service_role;
grant execute on function api.probe_revalidation_due(timestamptz), api.releases_needing_review() to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner, authenticated, service_role;

-- ---- from draft 20261113160200_build08_loop5_fixup_revalidation_due.sql
-- Build 08 loop 5 fixup 1 (D-76): api.probe_revalidation_due compared the newest release's date with the run's start time. A cell
-- environment is built once and reused, so a run made after a release can still resolve the older version (P19 ran at 14:50 on
-- 2026-11-13 with deepagents 0.7.37, eighteen minutes after 0.7.38 was published). Due now means: the newest catalogued release of a
-- subject library is a different version from the one the latest cell resolved, and it was released after that resolved version
-- (or after the run, when the resolved version is not in the catalog).
create or replace function api.probe_revalidation_due(p_as_of timestamptz default now())
returns table(probe_id uuid, probe text, cell_label text, last_run_at timestamptz, library text, resolved_version text, newest_version text, newest_released_at timestamptz, reason text)
language sql stable security definer set search_path = '' as $$
  with latest_cell as (
    select distinct on (pr.probe_id, pr.cell_label) pr.probe_id, pr.cell_label, pr.started_at, pr.resolved
      from verification.probe_run pr join verification.probe p on p.id = pr.probe_id
     where p.state = 'active' and pr.started_at <= p_as_of and (pr.cell ->> 'exclude_newer') is null and pr.cell_label like '%latest%'
     order by pr.probe_id, pr.cell_label, pr.started_at desc
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

-- ---- from draft 20261113160300_build08_loop5_fixup_latest_cell.sql
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

commit;
