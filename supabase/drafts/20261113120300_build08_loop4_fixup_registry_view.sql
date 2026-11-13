-- Build 08 loop 4 fixup 3 (lab only): api.source_registry shows the latest assessment per (source, topic)
-- D-60: "not superseded" showed two rows when a prior was added after a derived row; the latest row per (subject, topic) is the current one.
begin;
create or replace view api.source_registry as
  select e.id as source_entity_id, e.kind as source_kind, e.display_name as source, e.attributes->>'platform' as platform, coalesce(e.attributes->>'url', e.attributes->>'profile_url') as url,
         t.id as topic_entity_id, t.display_name as topic, a.as_of, a.method, a.source_role_code, a.conflict_of_interest, a.method_disclosure,
         a.claims_observed, a.claims_checked, a.confirmed, a.qualified, a.refuted, a.median_lead_days, a.noise_ratio, a.authority_score, a.recommended_watch_level,
         (select p.watch_level from acquisition.attention_policy p where e.id = any(p.channel_entity_ids) and p.state <> 'retired' order by p.watch_level desc limit 1) as current_watch_level,
         (select count(*) from evidence.source s where s.channel_entity_id = e.id) as urls, a.rationale, a.id as assessment_id
    from (select distinct on (subject_entity_id, topic_entity_id) * from evidence.source_assessment order by subject_entity_id, topic_entity_id, as_of desc, created_at desc) a
    join catalog.entity e on e.id = a.subject_entity_id left join catalog.entity t on t.id = a.topic_entity_id;
comment on view api.source_registry is 'The current (latest) assessment of each registered source (channel, actor, organization) per topic, with its components and the watch level its policies give it. Order by authority_score for a ranking; never read authority_score without claims_checked.';
grant select on api.source_registry to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
