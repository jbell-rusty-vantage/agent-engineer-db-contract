-- Build 08 loop 4 fixup 4 (lab only): api.community_claims
-- D-63: a reader had no path to "claims stated on a channel" (evidence.claim and evidence.attribution are not readable by app_reader); Q5 failed with permission denied.
begin;
create or replace view api.community_claims as
  select c.id as claim_id, c.statement, c.claim_type, (c.status)::text as status, c.structured->>'quote' as quote, c.structured->>'stated_at' as stated_at,
         ch.slug as channel_slug, ch.display_name as channel, x.display_name as stated_by, x.kind as stated_by_kind, so.canonical_url as thread_url, d.canonical_title as thread, d.attributes->>'thread_state' as thread_state,
         (select array_agg(e.slug) from evidence.claim_subject cs join catalog.entity e on e.id = cs.entity_id where cs.claim_id = c.id) as subjects,
         c.structured->>'producer' as extracted_by,
         (select v.verdict::text from verification.probe_verdict v where v.claim_id = c.id order by v.decided_at desc limit 1) as verdict
    from evidence.claim c
    join evidence.attribution a on a.claim_id = c.id and a.role = 'stated_by'
    join evidence.source so on so.id = a.source_id
    join catalog.entity ch on ch.id = so.channel_entity_id
    left join catalog.entity x on x.id = a.entity_id
    left join content.document d on d.canonical_source_id = so.id
   where c.structured->>'path' in ('community_thread','comparison_article');
comment on view api.community_claims is 'Claims stated on a community or editorial channel (issue trackers, forums, aggregators, comparison articles): quote, who stated it (handle as published), thread and its state, subjects, whether a model extracted it, and the latest probe verdict if any. Candidates, never facts.';
grant select on api.community_claims to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
