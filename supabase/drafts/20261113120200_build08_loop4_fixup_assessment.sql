-- Build 08 loop 4 fixup 2 (lab only): evidence.derive_source_assessment
-- D-58: the base (role, conflict of interest, method disclosure) comes from the latest prior or reviewed row of the subject on the topic, else on all topics;
--       a per-topic row no longer falls back to the kind default (docs.langchain.com scored 90 overall and 68 on LangChain).
-- D-59: not_supported / unverifiable / insufficient_evidence are observed, not checked: "not reproduced" is not a refutation (P9).
begin;
create or replace function evidence.derive_source_assessment(p_subject uuid, p_topic uuid default null, p_assessed_by text default 'agent:derive_source_assessment', p_note text default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_kind text; v_prior numeric; v_role text; v_prev uuid; v_base evidence.source_assessment; v_obs integer; v_conf integer; v_qual integer; v_ref integer; v_open integer; v_lead numeric; v_noise numeric; v_score numeric; v_level text; v_id uuid;
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
    select distinct on (v.claim_id) v.claim_id, v.verdict::text as verdict from verification.probe_verdict v join stated using (claim_id)
     where v.review_state <> 'human_rejected' order by v.claim_id, v.decided_at desc
  ), leads as (
    select (c.structured->>'first_party_at')::date - (c.structured->>'stated_at')::date as lead
      from evidence.claim c join latest l on l.claim_id = c.id
     where l.verdict in ('directly_supported','supported_with_qualification','partially_supported','derived_verified') and c.structured ? 'first_party_at' and c.structured ? 'stated_at'
  )
  select (select count(*) from stated),
         (select count(*) from latest where verdict in ('directly_supported','derived_verified')),
         (select count(*) from latest where verdict in ('supported_with_qualification','partially_supported')),
         (select count(*) from latest where verdict in ('contradicted','derived_failed')),
         (select count(*) from latest where verdict not in ('directly_supported','derived_verified','supported_with_qualification','partially_supported','contradicted','derived_failed')),
         (select percentile_cont(0.5) within group (order by lead) from leads)
    into v_obs, v_conf, v_qual, v_ref, v_open, v_lead;
  select round(sum(sw.items_seen)::numeric / nullif(sum(sw.items_selected), 0), 2) into v_noise
    from acquisition.attention_sweep sw join acquisition.attention_policy p on p.id = sw.policy_id where p_subject = any(p.channel_entity_ids);
  v_score := round((4 * coalesce(v_prior, 10) + 100 * (v_conf + 0.5 * v_qual)) / (4 + v_conf + v_qual + v_ref), 2);
  v_level := case when v_score >= 70 and coalesce(v_noise, 1) <= 10 then 'W3' when v_score >= 50 and coalesce(v_noise, 1) <= 40 then 'W2' when v_score >= 30 then 'W1' else 'W0' end;
  insert into evidence.source_assessment(subject_entity_id, topic_entity_id, method, source_role_code, conflict_of_interest, method_disclosure, claims_observed, claims_checked, confirmed, qualified, refuted,
                                         median_lead_days, noise_ratio, authority_score, recommended_watch_level, rationale, inputs, assessed_by, supersedes_id)
  values (p_subject, p_topic, 'derived', v_role, coalesce(v_base.conflict_of_interest, 'unknown'), coalesce(v_base.method_disclosure, 'not_applicable'), v_obs, v_conf + v_qual + v_ref, v_conf, v_qual, v_ref,
          v_lead, v_noise, v_score, v_level,
          coalesce(p_note, format('derived from %s stated claims (%s checked: %s confirmed, %s qualified, %s refuted; %s judged but not checkable or not reproduced) over a %s prior of %s', v_obs, v_conf + v_qual + v_ref, v_conf, v_qual, v_ref, v_open, v_role, coalesce(v_prior, 10))),
          jsonb_build_object('prior', v_prior, 'base_assessment', v_base.id, 'open_verdicts', v_open, 'formula', '(4*prior + 100*(confirmed + 0.5*qualified)) / (4 + checked)'), p_assessed_by, v_prev)
  returning id into v_id;
  return v_id;
end $$;
comment on function evidence.derive_source_assessment is 'Loop 4: appends a derived assessment of a source on a topic from the latest probe verdicts on the claims it stated (evidence.attribution by actor, channel or publisher). The base (role, conflict of interest, method disclosure) is the latest prior or reviewed row on the topic, else on all topics. Supported and contradicted verdicts are checked; not reproduced, unverifiable and insufficient evidence are observed only (D-59).';
commit;
