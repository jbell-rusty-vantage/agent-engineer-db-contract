-- Build 08 knowledge loop 4 (source intelligence: a registry of channels and handle-level actors with per-topic assessments derived from
-- probe verdicts; attention allocation: policies, sweeps and the due-list a Mission Control watch mission calls; experiments: probes,
-- runs captured as evidence, verdicts; design interviews as product conversations; the library dossier; candidate B: D-47, D-50,
-- one producer in the digests space, benchmark_run removed), promoted 2026-11-13 from the lab drafts 20261113120000..20261113120400
-- (the five draft files stay in supabase/drafts/ as the sources). Lab-proven on disposable-aieng-build04; cycle record: Build 08 §22
-- in the AI Engineer review workspace.
begin;

-- ---- from draft 20261113120000_build08_loop4_source_intelligence_experiments.sql
-- Build 08 knowledge loop 4 draft (lab disposable-aieng-build04 only; approved and pre-approved by John 2026-11-12/13,
-- selection in reviews/BUILD-08-LOOP-4-SELECTION.md §7). Source intelligence (registry + per-topic assessments derived from
-- verification outcomes), attention allocation (policies, sweeps, the due-list a Mission Control watch mission calls),
-- experiments (probes, runs as captured evidence, verdicts), design interviews as product conversations, the library dossier,
-- and candidate B (D-47, D-50, digest producers in the digests space, benchmark_run removal).

-- ====================================================================================================== registry (RV09, RV06)
insert into taxonomy.entity_kind(code, label, canonical_schema, canonical_table, description, attributes_schema, parent_kind, lens, is_work) values
  ('source_channel', 'Source channel', 'catalog', 'entity',
   'A place statements are published: an issue tracker of one repository, a forum, a Q&A tag, an aggregator, a blog or newsletter, a docs site, a social platform. Each evidence.source URL points to its channel; assessments and attention policies are about channels',
   '{"type":"object","required":["platform"],"properties":{"platform":{"type":"string"},"channel_kind":{"type":"string","enum":["issue_tracker","forum","qa_site","aggregator","blog","newsletter","docs_site","social","video_channel","event_site","registry"]},"url":{"type":"string"},"repository":{"type":"string"},"access":{"type":"object"},"terms_url":{"type":"string"},"content_license":{"type":"string"},"note":{"type":"string"}},"additionalProperties":true}'::jsonb, null, 'corpus', false),
  ('community_actor', 'Community actor', 'catalog', 'entity',
   'A handle that published statements on a channel, kept as published (platform + handle) with the platform''s own role label. No enrichment: no inferred real name, employer or contact; linked to a person only when the platform states it (same_actor_as)',
   '{"type":"object","required":["platform","handle"],"properties":{"platform":{"type":"string"},"handle":{"type":"string"},"profile_url":{"type":"string"},"platform_roles":{"type":"array","items":{"type":"string"}},"first_seen_at":{"type":"string"}},"additionalProperties":false}'::jsonb, null, 'corpus', false)
on conflict (code) do nothing;

insert into taxonomy.relationship_kind(code, from_kinds, to_kinds, temporal, "symmetric", inverse_label, description, property_schema) values
  ('operates_channel', array['organization','person'], array['source_channel'], false, false, 'operated_by', 'The organization or person that runs the channel (a vendor runs its issue tracker and docs site)', '{"type":"object"}'::jsonb),
  ('active_on', array['community_actor','person'], array['source_channel'], false, false, 'has_participant', 'The actor published at least one captured statement on the channel', '{"type":"object","properties":{"posts":{"type":"integer"},"platform_role":{"type":"string"}}}'::jsonb),
  ('same_actor_as', array['community_actor'], array['person'], false, false, 'has_handle', 'Only when the platform itself states the link (e.g. a GitHub MEMBER of the vendor org who is a catalogued maintainer); never inferred', '{"type":"object","properties":{"stated_by":{"type":"string"}}}'::jsonb)
on conflict (code) do nothing;

alter table evidence.source add column if not exists channel_entity_id uuid references catalog.entity(id);
create index if not exists source_channel_ix on evidence.source(channel_entity_id) where channel_entity_id is not null;
comment on column evidence.source.channel_entity_id is 'Loop 4: the source_channel this URL belongs to (issue tracker, forum, aggregator, blog, docs site).';

insert into content.source_role(code, description, authority_rank, default_source_tier) values
  ('own_experiment', 'Executed by this system in a recorded environment (a probe run); the run output is the evidence', 85, 1)
on conflict (code) do nothing;

create table if not exists evidence.source_assessment (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  subject_entity_id uuid not null references catalog.entity(id),
  topic_entity_id uuid references catalog.entity(id),
  as_of timestamptz not null default now(),
  method text not null check (method in ('prior','derived','reviewed')),
  source_role_code text references content.source_role(code),
  conflict_of_interest text not null default 'unknown' check (conflict_of_interest in ('none','vendor_self','vendor_adjacent','competitor','unknown')),
  method_disclosure text not null default 'not_applicable' check (method_disclosure in ('none','partial','full','not_applicable')),
  claims_observed integer not null default 0, claims_checked integer not null default 0,
  confirmed integer not null default 0, qualified integer not null default 0, refuted integer not null default 0,
  median_lead_days numeric(8,2), noise_ratio numeric(10,2),
  authority_score numeric(5,2) check (authority_score between 0 and 100),
  recommended_watch_level text check (recommended_watch_level in ('W0','W1','W2','W3')),
  rationale text not null,
  inputs jsonb not null default '{}'::jsonb,
  assessed_by text not null,
  receipt_id uuid,
  supersedes_id uuid references evidence.source_assessment(id),
  created_at timestamptz not null default now(),
  check (claims_checked = confirmed + qualified + refuted), check (claims_checked <= claims_observed)
);
create index if not exists source_assessment_subject_ix on evidence.source_assessment(subject_entity_id, topic_entity_id, as_of desc);
comment on table evidence.source_assessment is 'Loop 4: what we know about a source (channel, actor, organization, person) on a topic at a time. Components, never a bare score: role prior, conflict of interest, method disclosure, track record from verdicts, lead time against first-party docs, sweep noise. Append-only; a new row supersedes. authority_score is derived: (4·prior + 100·(confirmed + 0.5·qualified)) / (4 + checked).';
alter table evidence.source_assessment enable row level security;
create policy source_assessment_tenant on evidence.source_assessment using (tenant_id = util.current_tenant_id());
grant select on evidence.source_assessment to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner;
grant insert on evidence.source_assessment to pipeline_agent, verifier_agent, control_plane;

-- ====================================================================================================== attention (RV09, RV22)
create table if not exists acquisition.attention_policy (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  slug text not null,
  title text not null,
  scope_kind text not null check (scope_kind in ('channel','entity','query','probe_set')),
  channel_entity_ids uuid[] not null default '{}',
  subject_entity_ids uuid[] not null default '{}',
  watch_level text not null check (watch_level in ('W0','W1','W2','W3')),
  cadence text check (cadence ~ '^P(T?[0-9]+[YMWDHS])+$'),
  depth jsonb not null default '{}'::jsonb,
  selection jsonb not null default '{}'::jsonb,
  triggers jsonb not null default '[]'::jsonb check (jsonb_typeof(triggers) = 'array'),
  budget_usd_per_run numeric(10,4) not null default 0 check (budget_usd_per_run >= 0),
  budget_credits_per_run integer not null default 0 check (budget_credits_per_run >= 0),
  budget_total_usd numeric(10,4),
  stop_condition jsonb not null default '{}'::jsonb,
  inquiry_watch_id uuid references inquiry.watch(id),
  mission_id uuid references orchestration.mission(id),
  designed_in_thread_id uuid references conversation.thread(id),
  state text not null default 'active' check (state in ('active','paused','retired')),
  rationale text not null,
  decided_by text not null,
  supersedes_id uuid references acquisition.attention_policy(id),
  created_at timestamptz not null default now(),
  unique (tenant_id, slug),
  check (watch_level = 'W0' or cadence is not null or jsonb_array_length(triggers) > 0)
);
comment on table acquisition.attention_policy is 'Loop 4: what we watch, how often (cadence, triggers), how deep (depth, selection) and on what budget. W0 ignore (registered, never swept; reason in rationale), W1 reference, W2 sampled, W3 release-coupled. A Mission Control watch mission (mission_id) executes it; a product watch (inquiry_watch_id) may have asked for it; a design interview (designed_in_thread_id) may have produced it.';
alter table acquisition.attention_policy enable row level security;
create policy attention_policy_tenant on acquisition.attention_policy using (tenant_id = util.current_tenant_id());

create table if not exists acquisition.attention_sweep (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  policy_id uuid not null references acquisition.attention_policy(id),
  trigger_kind text not null check (trigger_kind in ('schedule','event','manual','backfill')),
  trigger_ref jsonb not null default '{}'::jsonb,
  mission_id uuid references orchestration.mission(id),
  origin_kind text not null check (origin_kind in ('standalone','mission')),
  window_from timestamptz, window_to timestamptz,
  started_at timestamptz not null default now(), ended_at timestamptz,
  items_seen integer not null default 0, items_selected integer not null default 0, items_captured integer not null default 0,
  rejected jsonb not null default '{}'::jsonb,
  spend_usd numeric(10,4) not null default 0, credits integer not null default 0,
  outcome text check (outcome in ('completed','partial','failed','budget_stopped')),
  receipt_id uuid,
  note text,
  check ((origin_kind = 'mission') = (mission_id is not null)),
  check (items_selected <= items_seen)
);
create index if not exists attention_sweep_policy_ix on acquisition.attention_sweep(policy_id, started_at desc);
comment on table acquisition.attention_sweep is 'Loop 4: one execution of an attention policy: trigger, window, items seen / selected / captured, rejections by reason, spend. Every fetch it makes carries sweep_id. origin_kind=mission only when a Mission Control mission ran it.';
alter table acquisition.attention_sweep enable row level security;
create policy attention_sweep_tenant on acquisition.attention_sweep using (tenant_id = util.current_tenant_id());
alter table acquisition.fetch add column if not exists sweep_id uuid references acquisition.attention_sweep(id);
grant select on acquisition.attention_policy, acquisition.attention_sweep to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner;
grant insert, update on acquisition.attention_policy, acquisition.attention_sweep to pipeline_agent, control_plane;

-- ====================================================================================================== experiments (RV10, RV13)
insert into evidence.capture_method(code, description) values
  ('probe_execution', 'Output of a probe run executed by this system in a recorded environment (lockfile, interpreter, platform)')
on conflict (code) do nothing;
insert into evidence.claim_type(code, description) values
  ('assertion', 'A plain statement by a speaker or author that something is the case (D-47), before it is typed as attribute, capability, compatibility or event')
on conflict (code) do nothing;

create table if not exists verification.probe (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  slug text not null,
  title text not null,
  hypothesis text not null,
  kind text not null check (kind in ('executed','static_docs','resolution','registry_check','live_model')),
  subject_entity_ids uuid[] not null default '{}',
  script_path text,
  script_sha256 text check (script_sha256 is null or script_sha256 ~ '^[0-9a-f]{64}$'),
  environment jsonb not null default '{}'::jsonb,
  matrix jsonb not null default '[]'::jsonb check (jsonb_typeof(matrix) = 'array'),
  model_policy text not null default 'none' check (model_policy in ('none','fake','live')),
  budget_usd numeric(10,4) not null default 0,
  designed_in_thread_id uuid references conversation.thread(id),
  designed_by text not null,
  state text not null default 'active' check (state in ('draft','active','retired')),
  created_at timestamptz not null default now(),
  unique (tenant_id, slug)
);
comment on table verification.probe is 'Loop 4: an experiment that tests stated claims against a matrix of environments. Cells are dates (uv --exclude-newer) or explicit pins; the script is versioned by path and sha256. A design interview may have produced it.';
create table if not exists verification.probe_claim (
  tenant_id uuid not null default util.default_tenant_id(),
  probe_id uuid not null references verification.probe(id) on delete cascade,
  claim_id uuid not null references evidence.claim(id),
  expectation jsonb not null default '{}'::jsonb,
  primary key (probe_id, claim_id)
);
create table if not exists verification.probe_run (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  probe_id uuid not null references verification.probe(id),
  cell_label text not null,
  cell jsonb not null default '{}'::jsonb,
  resolved jsonb not null default '{}'::jsonb,
  lock_sha256 text,
  python_version text, platform text,
  started_at timestamptz not null, ended_at timestamptz,
  exit_code integer,
  outcome text not null check (outcome in ('pass','fail','error','skipped')),
  observations jsonb not null default '{}'::jsonb,
  output_capture_id uuid references evidence.source_capture(id),
  output_locator_id uuid references evidence.locator(id),
  tokens_in integer, tokens_out integer, cost_usd numeric(10,6), latency_ms integer,
  sweep_id uuid references acquisition.attention_sweep(id),
  mission_id uuid references orchestration.mission(id),
  origin_kind text not null default 'standalone' check (origin_kind in ('standalone','mission')),
  receipt_id uuid,
  created_at timestamptz not null default now()
);
create index if not exists probe_run_probe_ix on verification.probe_run(probe_id, cell_label, started_at desc);
comment on table verification.probe_run is 'Loop 4: one execution of a probe in one cell. outcome pass/fail is about the probe''s own checks, not about the claim; observations hold what was seen (warnings, exception types and messages, keys, counts). The output JSON is captured like any other source (capture method probe_execution) so verdicts cite a locator.';
create table if not exists verification.probe_verdict (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  claim_id uuid not null references evidence.claim(id),
  probe_id uuid not null references verification.probe(id),
  verdict evidence.support_verdict not null,
  cells jsonb not null default '{}'::jsonb,
  rationale text not null,
  decided_by text not null,
  review_state text not null default 'agent_proposed' check (review_state in ('agent_proposed','human_confirmed','human_rejected')),
  decided_at timestamptz not null default now(),
  supersedes_id uuid references verification.probe_verdict(id)
);
create index if not exists probe_verdict_claim_ix on verification.probe_verdict(claim_id, decided_at desc);
comment on table verification.probe_verdict is 'Loop 4: what a probe''s runs say about one claim. agent_proposed by default; a human confirmation is a separate state. An executed deterministic probe may move the claim to verified (supported) or disputed (contradicted); live arms and community claims never verify alone.';
do $$ declare t text; begin
  foreach t in array array['probe','probe_claim','probe_run','probe_verdict'] loop
    execute format('alter table verification.%I enable row level security', t);
    execute format('create policy %I on verification.%I using (tenant_id = util.current_tenant_id())', t || '_tenant', t);
    execute format('grant select on verification.%I to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner', t);
    execute format('grant insert, update on verification.%I to pipeline_agent, verifier_agent, control_plane', t);
  end loop; end $$;
grant usage on schema verification to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner;

-- document kinds and unit kinds for threads, articles and probe reports
alter table content.document_type drop constraint document_type_family_check;
alter table content.document_type add constraint document_type_family_check check (family in ('regulatory_filing','research','vendor','code','media_transcript','editorial','market','registry','system_generated','event_media','own','community','unknown'));
insert into content.document_type(code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time, status, axis_note) values
  ('issue_thread', 'community', 'A repository issue or pull request with its comments, captured from the platform API; one thread_post unit per post', false, 'section', '{claim,entity}', '{units}', '{key_claims}', null, true, 'active', 'community statements: claim candidates only; the channel is the repository issue tracker'),
  ('forum_thread', 'community', 'A forum, Q&A or aggregator thread (Discourse topic, Stack Overflow question, Hacker News item) with its posts', false, 'section', '{claim,entity}', '{units}', '{key_claims}', null, true, 'active', 'community statements: claim candidates only'),
  ('comparison_article', 'editorial', 'A third-party article that compares or evaluates products, ideally with a disclosed method (tests, dates, models)', false, 'section', '{claim,entity}', '{units}', '{key_claims}', null, true, 'active', 'method disclosure and conflict of interest are assessed on its channel'),
  ('probe_report', 'own', 'The outputs of one probe across its matrix: one probe_observation unit per cell and run', true, 'section', '{claim}', '{units}', '{key_claims}', null, true, 'active', 'our own experiment (source role own_experiment)')
on conflict (code) do nothing;
update content.document_type set family = 'community', axis_note = 'community statements: claim candidates only (loop 4 moved it from editorial)' where code = 'forum_thread';
insert into content.unit_kind(code, description, is_universal, applicable_document_types, parent_kinds, attributes_schema, logical_key_attributes, selector_kind, retrieval_role, entity_roles) values
  ('thread_post', 'One post of an issue, forum or aggregator thread: author handle as published, platform role, time, reactions; the opening post has is_op', false, array['issue_thread','forum_thread'], array['document_root','section'],
   '{"type":"object","required":["post_id","author"],"properties":{"post_id":{"type":"string"},"author":{"type":"string"},"platform_role":{"type":"string"},"created_at":{"type":"string"},"reactions":{"type":"integer"},"is_op":{"type":"boolean"},"accepted":{"type":"boolean"},"url":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['post_id'], 'text_quote', 'embed', array['author']),
  ('probe_observation', 'What one probe run observed in one cell (versions, warnings, exceptions, keys, counts) rendered as text plus the structured observation', false, array['probe_report'], array['document_root','section'],
   '{"type":"object","required":["probe","cell"],"properties":{"probe":{"type":"string"},"cell":{"type":"string"},"outcome":{"type":"string"},"run_id":{"type":"string"},"resolved":{"type":"object"},"observation":{"type":"object"}},"additionalProperties":true}'::jsonb,
   array['probe','cell','run_id'], 'json_pointer', 'embed', array['subject'])
on conflict (code, version) do nothing;

-- ====================================================================================================== interviews (human participation)
alter table conversation.thread drop constraint if exists thread_purpose_check;
alter table conversation.thread drop constraint if exists thread_mode_check;
do $$ declare c record; begin
  for c in select conname from pg_constraint where conrelid = 'conversation.thread'::regclass and contype = 'c' and (pg_get_constraintdef(oid) like '%purpose%' or pg_get_constraintdef(oid) like '%mode = ANY%') loop
    execute format('alter table conversation.thread drop constraint %I', c.conname);
  end loop; end $$;
alter table conversation.thread add constraint thread_purpose_check check (purpose in ('tutor','build','research','authoring','project','general','defense','interview'));
alter table conversation.thread add constraint thread_mode_check check (mode in ('coach','build_with_me','elicit'));
comment on column conversation.thread.purpose is 'tutor | build | research | authoring | project | general | defense | interview (loop 4: a design interview between a person and an agent that produces probes, attention policies and claims, with knowledge-base retrieval snapshots on the agent turns).';

-- ====================================================================================================== candidate B
-- D-50: the talks_about page points to the transcript-window task
comment on function api.talks_about is 'Two levels in one call: level document/summary = the talk is about the entity in a stated role (document_about_entity, digest items of kind entity_role); level passage = the entity is mentioned in that transcript segment (unit_entity_role), with timecode and deep link. For the transcript around a known timecode use api.talk_segments(talk, from_ms, to_ms) instead (D-50).';

-- digests space: one producer per space (model-written digest items lead; deterministic loop-1/2 items stay in knowledge_text)
create or replace function retrieval.retire_deterministic_digest_items() returns integer language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
  update retrieval.vector_item vi set lifecycle = 'retired'
    from retrieval.projection_target pt, retrieval.vector_space_version sv, retrieval.vector_space vs, content.document_digest g
   where vi.projection_target_id = pt.id and vi.space_version_id = sv.id and sv.vector_space_id = vs.id and vs.slug = 'digests'
     and vi.lifecycle = 'active' and pt.target_kind in ('digest','digest_item')
     and g.id = coalesce(pt.digest_id, (select di.digest_id from content.digest_item di where di.id = pt.digest_item_id))
     and g.producer_kind = 'deterministic';
  get diagnostics n = row_count;
  return n;
end $$;
comment on function retrieval.retire_deterministic_digest_items is 'Loop 4 (candidate B): retires deterministic digest items from the digests space so that space holds model-written digests only; the items stay searchable in knowledge_text.';
grant execute on function retrieval.retire_deterministic_digest_items() to pipeline_agent, control_plane, service_role;

-- benchmark_run: no question needed a run entity (loops 2 and 3); 0 rows
update taxonomy.relationship_kind set from_kinds = array_remove(from_kinds, 'benchmark_run'), to_kinds = array_remove(to_kinds, 'benchmark_run') where code in ('instance_of_concept','about');
delete from taxonomy.relationship_kind where code in ('evaluated_on','benchmark_subject','benchmark_executed_by') and not exists (select 1 from catalog.relationship r where r.kind in ('evaluated_on','benchmark_subject','benchmark_executed_by'));
delete from taxonomy.entity_kind where code = 'benchmark_run' and not exists (select 1 from catalog.entity e where e.kind = 'benchmark_run');

-- ====================================================================================================== derivation
create or replace function evidence.derive_source_assessment(p_subject uuid, p_topic uuid default null, p_assessed_by text default 'agent:derive_source_assessment', p_note text default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_kind text; v_prior numeric; v_role text; v_prev evidence.source_assessment; v_obs integer; v_conf integer; v_qual integer; v_ref integer; v_lead numeric; v_noise numeric; v_score numeric; v_level text; v_id uuid;
begin
  select kind into v_kind from catalog.entity where id = p_subject;
  select * into v_prev from evidence.source_assessment where subject_entity_id = p_subject and topic_entity_id is not distinct from p_topic order by as_of desc, created_at desc limit 1;
  v_role := coalesce(v_prev.source_role_code, case v_kind when 'community_actor' then 'community' when 'source_channel' then 'community' else 'unknown' end);
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
         (select count(*) from latest where verdict in ('contradicted','not_supported','derived_failed')),
         (select percentile_cont(0.5) within group (order by lead) from leads)
    into v_obs, v_conf, v_qual, v_ref, v_lead;
  select round(sum(sw.items_seen)::numeric / nullif(sum(sw.items_selected), 0), 2) into v_noise
    from acquisition.attention_sweep sw join acquisition.attention_policy p on p.id = sw.policy_id where p_subject = any(p.channel_entity_ids);
  v_score := round((4 * coalesce(v_prior, 10) + 100 * (v_conf + 0.5 * v_qual)) / (4 + v_conf + v_qual + v_ref), 2);
  v_level := case when v_score >= 70 and coalesce(v_noise, 1) <= 10 then 'W3' when v_score >= 50 and coalesce(v_noise, 1) <= 40 then 'W2' when v_score >= 30 then 'W1' else 'W0' end;
  insert into evidence.source_assessment(subject_entity_id, topic_entity_id, method, source_role_code, conflict_of_interest, method_disclosure, claims_observed, claims_checked, confirmed, qualified, refuted,
                                         median_lead_days, noise_ratio, authority_score, recommended_watch_level, rationale, inputs, assessed_by, supersedes_id)
  values (p_subject, p_topic, 'derived', v_role, coalesce(v_prev.conflict_of_interest, 'unknown'), coalesce(v_prev.method_disclosure, 'not_applicable'), v_obs, v_conf + v_qual + v_ref, v_conf, v_qual, v_ref,
          v_lead, v_noise, v_score, v_level,
          coalesce(p_note, format('derived from %s stated claims (%s checked: %s confirmed, %s qualified, %s refuted) over a %s prior of %s', v_obs, v_conf + v_qual + v_ref, v_conf, v_qual, v_ref, v_role, coalesce(v_prior, 10))),
          jsonb_build_object('prior', v_prior, 'formula', '(4*prior + 100*(confirmed + 0.5*qualified)) / (4 + checked)', 'previous', v_prev.id), p_assessed_by, v_prev.id)
  returning id into v_id;
  return v_id;
end $$;
comment on function evidence.derive_source_assessment is 'Loop 4: appends a derived assessment of a source on a topic from the latest probe verdicts on the claims it stated (evidence.attribution by actor, channel or publisher), the lead time of supported claims against first-party dates, and the noise of the channel''s sweeps. Conflict of interest and method disclosure carry over from the previous (prior or reviewed) row.';
grant execute on function evidence.derive_source_assessment(uuid, uuid, text, text) to pipeline_agent, verifier_agent, control_plane, service_role;

-- ====================================================================================================== api views and functions
create or replace view api.source_registry as
  select e.id as source_entity_id, e.kind as source_kind, e.display_name as source, e.attributes->>'platform' as platform, coalesce(e.attributes->>'url', e.attributes->>'profile_url') as url,
         t.id as topic_entity_id, t.display_name as topic, a.as_of, a.method, a.source_role_code, a.conflict_of_interest, a.method_disclosure,
         a.claims_observed, a.claims_checked, a.confirmed, a.qualified, a.refuted, a.median_lead_days, a.noise_ratio, a.authority_score, a.recommended_watch_level,
         (select p.watch_level from acquisition.attention_policy p where e.id = any(p.channel_entity_ids) and p.state <> 'retired' order by p.watch_level desc limit 1) as current_watch_level,
         (select count(*) from evidence.source s where s.channel_entity_id = e.id) as urls, a.rationale, a.id as assessment_id
    from evidence.source_assessment a join catalog.entity e on e.id = a.subject_entity_id left join catalog.entity t on t.id = a.topic_entity_id
   where not exists (select 1 from evidence.source_assessment b where b.supersedes_id = a.id);
comment on view api.source_registry is 'The current assessment of each registered source (channel, actor, organization) per topic, with its components and the watch level its policies give it. Order by authority_score for a ranking; never read authority_score without claims_checked.';

create or replace view api.claim_verdicts as
  select c.id as claim_id, c.statement, c.claim_type, (c.status)::text as status, c.structured->>'stated_at' as stated_at, c.structured->>'quote' as quote,
         (select string_agg(distinct x.display_name, '; ') from evidence.attribution a join catalog.entity x on x.id = a.entity_id where a.claim_id = c.id) as stated_by,
         (select string_agg(distinct ch.display_name, '; ') from evidence.attribution a join evidence.source s on s.id = a.source_id join catalog.entity ch on ch.id = s.channel_entity_id where a.claim_id = c.id) as channel,
         v.verdict::text as verdict, p.slug as probe, v.review_state, v.decided_by, v.decided_at, v.cells, v.rationale
    from evidence.claim c join lateral (select * from verification.probe_verdict v where v.claim_id = c.id order by v.decided_at desc limit 1) v on true
    join verification.probe p on p.id = v.probe_id;
comment on view api.claim_verdicts is 'Claims that a probe has judged, with who stated them, on which channel, the latest verdict, its review state and the per-cell summary.';

create or replace view api.probes as
  select p.id as probe_id, p.slug, p.title, p.kind, p.hypothesis, p.model_policy, p.matrix, p.script_path, p.designed_by, p.designed_in_thread_id,
         (select array_agg(e.slug) from catalog.entity e where e.id = any(p.subject_entity_ids)) as subjects,
         (select count(*) from verification.probe_claim pc where pc.probe_id = p.id) as claims,
         (select count(*) from verification.probe_run r where r.probe_id = p.id) as runs,
         (select max(r.started_at) from verification.probe_run r where r.probe_id = p.id) as last_run_at,
         (select jsonb_agg(jsonb_build_object('claim', c.statement, 'verdict', v.verdict, 'review_state', v.review_state))
            from verification.probe_verdict v join evidence.claim c on c.id = v.claim_id where v.probe_id = p.id and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)) as verdicts
    from verification.probe p;

create or replace function api.probe_matrix(p_probe text)
returns table(cell_label text, cell jsonb, outcome text, resolved jsonb, observations jsonb, started_at timestamptz, run_id uuid, locator_id uuid)
language sql stable security definer set search_path = '' as $$
  select distinct on (r.cell_label) r.cell_label, r.cell, r.outcome, r.resolved, r.observations, r.started_at, r.id, r.output_locator_id
    from verification.probe_run r join verification.probe p on p.id = r.probe_id
   where p.slug = p_probe or p.id::text = p_probe
   order by r.cell_label, r.started_at desc
$$;
comment on function api.probe_matrix is 'The latest run of a probe in each cell: outcome, the resolved package versions and what was observed. Cells are dates (what a tutorial-follower got that day) or explicit pins.';

create or replace view api.attention_policies as
  select p.id as policy_id, p.slug, p.title, p.scope_kind, p.watch_level, p.cadence, p.depth, p.selection, p.triggers, p.budget_usd_per_run, p.budget_credits_per_run, p.state, p.rationale, p.decided_by,
         (select array_agg(e.display_name) from catalog.entity e where e.id = any(p.channel_entity_ids)) as channels,
         (select array_agg(e.slug) from catalog.entity e where e.id = any(p.subject_entity_ids)) as subjects,
         m.slug as mission, p.designed_in_thread_id,
         s.started_at as last_sweep_at, s.outcome as last_outcome, s.items_seen as last_seen, s.items_selected as last_selected,
         (select count(*) from acquisition.attention_sweep x where x.policy_id = p.id) as sweeps,
         (select sum(x.spend_usd) from acquisition.attention_sweep x where x.policy_id = p.id) as spend_usd
    from acquisition.attention_policy p left join orchestration.mission m on m.id = p.mission_id
    left join lateral (select * from acquisition.attention_sweep x where x.policy_id = p.id order by x.started_at desc limit 1) s on true
   where not exists (select 1 from acquisition.attention_policy q where q.supersedes_id = p.id);

create or replace function api.attention_due(p_as_of timestamptz default now())
returns table(policy_id uuid, slug text, watch_level text, reason text, trigger_ref jsonb, last_sweep_at timestamptz, budget_usd_per_run numeric, mission text)
language sql stable security definer set search_path = '' as $$
  with pol as (
    select p.*, (select max(s.started_at) from acquisition.attention_sweep s where s.policy_id = p.id and s.started_at <= p_as_of) as last_at
      from acquisition.attention_policy p
     where p.state = 'active' and p.watch_level <> 'W0' and not exists (select 1 from acquisition.attention_policy q where q.supersedes_id = p.id)
  ), ev as (
    select pol.id as policy_id, e.id as event_id, e.kind, lower(o.occurred_during) as at, coalesce(lib.slug, x.slug) as subject
      from pol cross join lateral jsonb_array_elements(pol.triggers) t
      join temporal.event e on e.kind = t->>'on'
      join temporal.event_occurrence o on o.event_id = e.id and o.k_to is null
      join catalog.entity x on x.id = e.subject_entity_id
      left join catalog.relationship r on r.from_entity_id = x.id and r.kind = 'version_of' and r.k_to is null
      left join catalog.entity lib on lib.id = r.to_entity_id
     where (x.id = any(pol.subject_entity_ids) or lib.id = any(pol.subject_entity_ids))
       and lower(o.occurred_during) <= p_as_of
       and lower(o.occurred_during) > coalesce(pol.last_at, p_as_of - make_interval(days => coalesce((t->>'window_days')::int, 14)))
       and lower(o.occurred_during) > p_as_of - make_interval(days => coalesce((t->>'window_days')::int, 14))
  )
  select p.id, p.slug, p.watch_level, 'event: ' || string_agg(distinct ev.kind || ' ' || ev.subject, ', '), jsonb_agg(distinct jsonb_build_object('event_id', ev.event_id, 'kind', ev.kind, 'subject', ev.subject, 'at', ev.at)), p.last_at, p.budget_usd_per_run,
         (select m.slug from orchestration.mission m where m.id = p.mission_id)
    from pol p join ev on ev.policy_id = p.id group by p.id, p.slug, p.watch_level, p.last_at, p.budget_usd_per_run, p.mission_id
  union all
  select p.id, p.slug, p.watch_level, case when p.last_at is null then 'never swept' else 'cadence ' || p.cadence end, '{}'::jsonb, p.last_at, p.budget_usd_per_run,
         (select m.slug from orchestration.mission m where m.id = p.mission_id)
    from pol p where p.cadence is not null and (p.last_at is null or p.last_at + p.cadence::interval <= p_as_of)
     and not exists (select 1 from ev where ev.policy_id = p.id)
$$;
comment on function api.attention_due is 'The contract a Mission Control watch mission calls: which attention policies are due at a time, because a trigger event (e.g. release_published of a subject library, or of a release of it) happened since the last sweep inside the trigger window, or because the cadence elapsed. W0 and paused policies are never due.';

create or replace function api.interview_outputs(p_thread uuid)
returns table(output_kind text, output_id uuid, slug text, title text, state text, runs bigint, last_run_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select 'probe', p.id, p.slug, p.title, p.state, (select count(*) from verification.probe_run r where r.probe_id = p.id), (select max(r.started_at) from verification.probe_run r where r.probe_id = p.id)
    from verification.probe p where p.designed_in_thread_id = p_thread
  union all
  select 'attention_policy', a.id, a.slug, a.title, a.state, (select count(*) from acquisition.attention_sweep s where s.policy_id = a.id), (select max(s.started_at) from acquisition.attention_sweep s where s.policy_id = a.id)
    from acquisition.attention_policy a where a.designed_in_thread_id = p_thread
$$;
comment on function api.interview_outputs is 'What a design interview (conversation.thread purpose interview) produced: probes and attention policies, and whether each has run.';

create or replace function api.library_dossier(p_library text)
returns jsonb language sql stable security definer set search_path = '' as $$
  with lib as (select id, slug, display_name, attributes from catalog.entity where kind = 'library' and (slug = p_library or id::text = p_library) limit 1),
  rel as (select r2.slug, r2.attributes->>'version_label' as version, r2.attributes->>'released_on' as released_on, coalesce((r2.attributes->>'prerelease')::boolean, false) as prerelease
            from lib join catalog.relationship r on r.to_entity_id = lib.id and r.kind = 'version_of' and r.k_to is null join catalog.entity r2 on r2.id = r.from_entity_id),
  cl as (select distinct c.id from lib join evidence.claim_subject cs on cs.entity_id = lib.id join evidence.claim c on c.id = cs.claim_id)
  select jsonb_build_object(
    'library', (select jsonb_build_object('slug', slug, 'name', display_name, 'attributes', attributes) from lib),
    'releases', (select jsonb_build_object('count', count(*), 'first', min(released_on), 'latest', (select jsonb_build_object('version', version, 'released_on', released_on) from rel where not prerelease order by released_on desc nulls last, version desc limit 1),
                                           'recent', (select jsonb_agg(x) from (select version, released_on from rel order by released_on desc nulls last limit 8) x)) from rel),
    'claims', (select jsonb_build_object('total', count(*), 'proposed', count(*) filter (where c.status = 'proposed'), 'verified', count(*) filter (where c.status = 'verified'), 'disputed', count(*) filter (where c.status = 'disputed'))
                 from cl join evidence.claim c on c.id = cl.id),
    'open_community_claims', (select jsonb_agg(x) from (select c.statement, c.structured->>'url' as url, c.structured->>'stated_at' as stated_at, c.structured->>'thread_state' as thread_state
                                                          from cl join evidence.claim c on c.id = cl.id where c.status = 'proposed' and c.structured->>'path' = 'community_thread' order by c.structured->>'stated_at' desc nulls last limit 12) x),
    'probes', (select jsonb_agg(jsonb_build_object('probe', p.slug, 'title', p.title, 'kind', p.kind, 'cells', (select jsonb_object_agg(m.cell_label, m.outcome) from api.probe_matrix(p.slug) m), 'verdicts', p.verdicts))
                 from api.probes p, lib where lib.slug = any(p.subjects)),
    'sources', (select jsonb_agg(x) from (select s.source, s.source_kind, s.authority_score, s.claims_checked, s.confirmed, s.refuted, s.recommended_watch_level from api.source_registry s, lib
                                            where s.topic_entity_id = lib.id order by s.authority_score desc nulls last limit 12) x),
    'as_of', now())
$$;
comment on function api.library_dossier is 'One call for the report a module embeds: releases (count, latest, recent), claims by status, open community claims, probes with their per-cell outcomes and verdicts, and the ranked sources on this library.';

create or replace view api.source_track_record as
  select a.entity_id as source_entity_id, x.display_name as source, x.kind as source_kind, c.id as claim_id, c.statement, (c.status)::text as status,
         c.structured->>'stated_at' as stated_at, c.structured->>'first_party_at' as first_party_at, v.verdict::text as verdict, p.slug as probe
    from evidence.attribution a join catalog.entity x on x.id = a.entity_id join evidence.claim c on c.id = a.claim_id
    left join lateral (select * from verification.probe_verdict v where v.claim_id = c.id order by v.decided_at desc limit 1) v on true
    left join verification.probe p on p.id = v.probe_id;
comment on view api.source_track_record is 'Every claim a source stated, with its latest verdict: the rows behind an assessment''s counts.';

grant select on api.source_registry, api.claim_verdicts, api.probes, api.attention_policies, api.source_track_record to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
grant execute on function api.probe_matrix(text), api.attention_due(timestamptz), api.interview_outputs(uuid), api.library_dossier(text) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---- from draft 20261113120100_build08_loop4_fixup_attention_due.sql
-- Build 08 loop 4 fixup 1 (lab only): api.attention_due
-- D-56: a trigger with "only": "major" fires only for x.0.0 releases (it fired for every patch release).
-- D-57: a backfill sweep does not satisfy an event trigger (it does not apply the trigger window's selection rules); cadence still counts every sweep.

create or replace function api.attention_due(p_as_of timestamptz default now())
returns table(policy_id uuid, slug text, watch_level text, reason text, trigger_ref jsonb, last_sweep_at timestamptz, budget_usd_per_run numeric, mission text)
language sql stable security definer set search_path = '' as $$
  with pol as (
    select p.*,
           (select max(s.started_at) from acquisition.attention_sweep s where s.policy_id = p.id and s.started_at <= p_as_of) as last_at,
           (select max(s.started_at) from acquisition.attention_sweep s where s.policy_id = p.id and s.started_at <= p_as_of and s.trigger_kind <> 'backfill') as last_event_at
      from acquisition.attention_policy p
     where p.state = 'active' and p.watch_level <> 'W0' and not exists (select 1 from acquisition.attention_policy q where q.supersedes_id = p.id)
  ), ev as (
    select pol.id as policy_id, e.id as event_id, e.kind, lower(o.occurred_during) as at, coalesce(lib.slug, x.slug) as subject, x.attributes->>'version_label' as version
      from pol cross join lateral jsonb_array_elements(pol.triggers) t
      join temporal.event e on e.kind = t->>'on'
      join temporal.event_occurrence o on o.event_id = e.id and o.k_to is null
      join catalog.entity x on x.id = e.subject_entity_id
      left join catalog.relationship r on r.from_entity_id = x.id and r.kind = 'version_of' and r.k_to is null
      left join catalog.entity lib on lib.id = r.to_entity_id
     where (x.id = any(pol.subject_entity_ids) or lib.id = any(pol.subject_entity_ids))
       and (t->>'only' is distinct from 'major' or coalesce(x.attributes->>'version_label', '') ~ '^[0-9]+\.0\.0$')
       and lower(o.occurred_during) <= p_as_of
       and lower(o.occurred_during) > coalesce(pol.last_event_at, '-infinity'::timestamptz)
       and lower(o.occurred_during) > p_as_of - make_interval(days => coalesce((t->>'window_days')::int, 14))
  )
  select p.id, p.slug, p.watch_level, 'event: ' || string_agg(distinct ev.kind || ' ' || ev.subject || coalesce(' ' || ev.version, ''), ', '),
         jsonb_agg(distinct jsonb_build_object('event_id', ev.event_id, 'kind', ev.kind, 'subject', ev.subject, 'version', ev.version, 'at', ev.at)), p.last_at, p.budget_usd_per_run,
         (select m.slug from orchestration.mission m where m.id = p.mission_id)
    from pol p join ev on ev.policy_id = p.id group by p.id, p.slug, p.watch_level, p.last_at, p.budget_usd_per_run, p.mission_id
  union all
  select p.id, p.slug, p.watch_level, case when p.last_at is null then 'never swept' else 'cadence ' || p.cadence end, '{}'::jsonb, p.last_at, p.budget_usd_per_run,
         (select m.slug from orchestration.mission m where m.id = p.mission_id)
    from pol p where p.cadence is not null and (p.last_at is null or p.last_at + p.cadence::interval <= p_as_of)
     and not exists (select 1 from ev where ev.policy_id = p.id)
$$;
comment on function api.attention_due is 'The contract a Mission Control watch mission calls: which attention policies are due at a time, because a trigger event happened since the last non-backfill sweep inside the trigger window (a trigger with "only": "major" counts x.0.0 releases only), or because the cadence elapsed since any sweep. W0 and paused policies are never due.';

-- ---- from draft 20261113120200_build08_loop4_fixup_assessment.sql
-- Build 08 loop 4 fixup 2 (lab only): evidence.derive_source_assessment
-- D-58: the base (role, conflict of interest, method disclosure) comes from the latest prior or reviewed row of the subject on the topic, else on all topics;
--       a per-topic row no longer falls back to the kind default (docs.langchain.com scored 90 overall and 68 on LangChain).
-- D-59: not_supported / unverifiable / insufficient_evidence are observed, not checked: "not reproduced" is not a refutation (P9).

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

-- ---- from draft 20261113120300_build08_loop4_fixup_registry_view.sql
-- Build 08 loop 4 fixup 3 (lab only): api.source_registry shows the latest assessment per (source, topic)
-- D-60: "not superseded" showed two rows when a prior was added after a derived row; the latest row per (subject, topic) is the current one.

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

-- ---- from draft 20261113120400_build08_loop4_fixup_community_claims.sql
-- Build 08 loop 4 fixup 4 (lab only): api.community_claims
-- D-63: a reader had no path to "claims stated on a channel" (evidence.claim and evidence.attribution are not readable by app_reader); Q5 failed with permission denied.

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
