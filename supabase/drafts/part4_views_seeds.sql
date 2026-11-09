-- Build 08 R2 draft. Part 4: vocabulary seeds (one home for numbers, new verbs, assertion mappings), L1 catalog views, L2 time/change queries.

-- ---------------------------------------------------------------------------------------------- 20. vocabulary: numbers are fact streams
delete from temporal.stream_kind where code = 'model_offering_price';
insert into temporal.stream_kind(code, subject_mode, subject_kinds, status_values, requires_amount, unit_values, requires_ref_entity, ref_entity_kinds, payload_schema, description) values
  ('offering_price', 'entity', '{model_offering,compute_offering}', null, true, '{USD_per_1M_tokens,USD_per_1K_tokens,USD_per_request,USD_per_minute,USD_per_image,USD_per_hour,USD_per_GB,USD_per_month}', false, null,
   '{"type":"object","required":["meter"],"properties":{"meter":{"type":"string"},"tier":{"type":"string"},"region":{"type":"string"},"condition":{"type":"string"},"context_band":{"type":"string"}}}',
   'Price of one meter of an offering (input_tokens, output_tokens, cached_input_tokens, batch_input_tokens ...); scope_key = meter|tier|region; amount+currency+unit normalized; observation_bounded from the capture'),
  ('model_context_window', 'entity', '{ai_model_version}', null, true, '{tokens}', false, null, '{"type":"object"}', 'Maximum context window in tokens'),
  ('model_max_output_tokens', 'entity', '{ai_model_version}', null, true, '{tokens}', false, null, '{"type":"object"}', 'Maximum output tokens'),
  ('model_capability', 'entity', '{ai_model_version}', '{supported,unsupported,preview,unknown}', false, null, false, null, '{"type":"object","properties":{"detail":{"type":"string"}}}', 'Capability status per scope_key: tool_use, structured_output, reasoning, vision, audio, open_weights, prompt_caching, batch, fine_tuning'),
  ('model_knowledge_cutoff', 'entity', '{ai_model_version}', null, false, null, false, null, '{"type":"object","required":["cutoff_on"],"properties":{"cutoff_on":{"type":"string"}}}', 'Training data cutoff as stated by the developer'),
  ('model_availability', 'entity', '{ai_model_version,model_offering}', '{announced,preview,generally_available,deprecated,retired}', false, null, false, null, '{"type":"object"}', 'Lifecycle availability of a model version or offering'),
  ('benchmark_score', 'entity', '{ai_model_version,product_version,library_release}', null, true, '{percent,score,elo,pass_at_1,seconds,usd,count}', true, '{benchmark}', '{"type":"object","properties":{"setting":{"type":"string"},"source_kind":{"type":"string","enum":["first_party","third_party","own"]},"harness":{"type":"string"},"comparison":{"type":"string"}}}', 'A benchmark result: subject version, ref benchmark, amount+unit, setting and who measured it (first-party self-report vs third party)'),
  ('repository_stars', 'entity', '{repository}', null, true, '{count}', false, null, '{"type":"object"}', 'GitHub stars at observation'),
  ('repository_forks', 'entity', '{repository}', null, true, '{count}', false, null, '{"type":"object"}', 'Forks at observation'),
  ('repository_open_issues', 'entity', '{repository}', null, true, '{count}', false, null, '{"type":"object"}', 'Open issues at observation'),
  ('package_downloads', 'entity', '{library}', null, true, '{per_week,per_month,total}', false, null, '{"type":"object","properties":{"registry":{"type":"string"}}}', 'Package downloads for a window'),
  ('media_views', 'entity', '{media_work,talk}', null, true, '{count}', false, null, '{"type":"object","properties":{"platform":{"type":"string"}}}', 'Recording views at observation'),
  ('paper_citations', 'entity', '{paper}', null, true, '{count}', false, null, '{"type":"object","properties":{"source":{"type":"string"}}}', 'Citation count at observation'),
  ('organization_headcount', 'entity', '{organization}', null, true, '{count}', false, null, '{"type":"object","properties":{"source":{"type":"string"}}}', 'Headcount at observation')
on conflict (code) do nothing;
update temporal.stream_kind set subject_kinds = '{library,repository,mcp_server,agent_skill,product,ai_model_version}', description = 'License of a software thing or open-weights model (payload spdx), as stated by the publisher' where code = 'library_license';

insert into taxonomy.relationship_kind(code, from_kinds, to_kinds, temporal, "symmetric", inverse_label, description, property_schema) values
  ('has_code', '{talk,paper,media_work,story,case_study}', '{repository}', false, false, 'code_for', 'A work points at the repository that holds its code', '{"type":"object"}'),
  ('compatible_with', '{library_release,product_version,ai_model_version,mcp_server}', '{library_release,product_version,ai_model_version,ai_protocol_version}', false, false, 'compatible_with', 'A stated compatibility between versions (constraint in properties)', '{"type":"object","properties":{"constraint":{"type":"string"},"stated_by":{"type":"string"}}}'),
  ('integrates_with', '{library,product,mcp_server,agent_skill}', '{library,product,mcp_server,ai_model,ai_protocol}', true, false, 'integrated_by', 'A documented integration between software things', '{"type":"object","properties":{"kind":{"type":"string"}}}'),
  ('published_in', '{paper}', '{industry_event,media_channel,organization}', false, false, 'published', 'Venue of a paper', '{"type":"object"}')
on conflict (code) do nothing;
update taxonomy.relationship_kind set from_kinds = '{story,case_study,talk,paper,media_work}' where code = 'about';
update taxonomy.relationship_kind set to_kinds = array_cat(to_kinds, '{talk,paper}') where code = 'has_code' and not ('talk' = any(to_kinds));

-- ---------------------------------------------------------------------------------------------- 21. assertion mappings (act 3 as data)
alter table content.unit_assertion_mapping drop constraint unit_assertion_mapping_target_kind_check;
alter table content.unit_assertion_mapping add constraint unit_assertion_mapping_target_kind_check check (target_kind in ('stream','relationship','event','entity_attribute','claim_candidate','guidance_item'));
alter table content.unit_assertion_mapping drop constraint mapping_target_consistent;
alter table content.unit_assertion_mapping add constraint mapping_target_consistent check ((target_kind = 'stream' and stream_kind is not null) or (target_kind = 'relationship' and relationship_kind is not null) or (target_kind = 'event' and event_kind is not null) or target_kind in ('entity_attribute','claim_candidate','guidance_item'));
insert into content.unit_assertion_mapping(unit_kind, document_type_code, source_role_code, target_kind, stream_kind, relationship_kind, event_kind, subject_template, value_template, qualifier_template, time_template, deterministic, risk_floor, description) values
  ('price_row', 'pricing_page', 'first_party', 'stream', 'offering_price', null, null, '{"entity":"$role.offering"}', '{"amount":"$attr.amount","currency":"$attr.currency","unit":"$attr.unit"}', '{"scope_key":"$attr.meter|$attr.tier|$attr.region","payload":{"meter":"$attr.meter","tier":"$attr.tier","region":"$attr.region","condition":"$attr.condition"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'A vendor price row establishes the vendor''s own price as of the capture (cheap path: act 1 + deterministic act 3 + first-party authority)'),
  ('release_entry', 'changelog', 'first_party', 'event', null, null, 'release_published', '{"entity":"$role.release"}', '{"payload":{"version":"$attr.version","breaking":"$attr.breaking","title":"$attr.title","url":"$attr.url"}}', '{}', '{"occurred_at":"$attr.released_on","mode":"actual"}', true, 'L0', 'A first-party changelog entry establishes the release and its date'),
  ('release_entry', 'github_release', 'first_party', 'event', null, null, 'release_published', '{"entity":"$role.release"}', '{"payload":{"version":"$attr.version","breaking":"$attr.breaking","title":"$attr.title","url":"$attr.url"}}', '{}', '{"occurred_at":"$attr.released_on","mode":"actual"}', true, 'L0', 'A GitHub release entry establishes the release and its date'),
  ('release_entry', 'release_notes', 'first_party', 'event', null, null, 'release_published', '{"entity":"$role.release"}', '{"payload":{"version":"$attr.version","breaking":"$attr.breaking","title":"$attr.title","url":"$attr.url"}}', '{}', '{"occurred_at":"$attr.released_on","mode":"actual"}', true, 'L0', 'Release notes establish the release and its date'),
  ('eval_row', 'model_card', 'first_party', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark|$attr.setting","payload":{"setting":"$attr.setting","source_kind":"first_party"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L0', 'A first-party evaluation row is a self-reported score, kept with source_kind first_party'),
  ('eval_row', 'product_page', 'first_party', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark|$attr.setting","payload":{"setting":"$attr.setting","source_kind":"first_party"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L0', 'A model page evaluation row is a self-reported score'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_context_window', null, null, '{"entity":"$role.model"}', '{"amount":"$attr.value","unit":"tokens"}', '{"when":{"field":"context_window"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Context window from a model page spec field'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_max_output_tokens', null, null, '{"entity":"$role.model"}', '{"amount":"$attr.value","unit":"tokens"}', '{"when":{"field":"max_output_tokens"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Max output tokens from a model page spec field'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_knowledge_cutoff', null, null, '{"entity":"$role.model"}', '{"payload":{"cutoff_on":"$attr.value"}}', '{"when":{"field":"knowledge_cutoff"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Knowledge cutoff from a model page spec field'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_capability', null, null, '{"entity":"$role.model"}', '{"status":"$attr.value"}', '{"when":{"field_in":["tool_use","structured_output","reasoning","vision","audio","open_weights","prompt_caching","batch","fine_tuning"]},"scope_key":"$attr.field"}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Capability status from a model page spec field'),
  ('talk_header', 'aie_talk', 'event_organizer', 'relationship', null, 'presented_by', null, '{"from":"$role.talk","to":"$role.speaker"}', '{}', '{}', '{}', true, 'L0', 'The organizer''s session record establishes who presented the talk'),
  ('talk_header', 'aie_talk', 'event_organizer', 'relationship', null, 'presented_at', null, '{"from":"$role.talk","to":"$role.event"}', '{}', '{}', '{}', true, 'L0', 'The organizer''s session record establishes the event'),
  ('talk_resource', 'aie_talk', 'event_organizer', 'relationship', null, 'has_code', null, '{"from":"$role.talk","to":"$role.repository"}', '{}', '{"when":{"resource_kind":"repository"}}', '{}', true, 'L0', 'A repository listed under a talk''s Resources is the talk''s code'),
  ('transcript_segment', 'aie_talk', 'event_organizer', 'claim_candidate', null, null, null, '{"speaker":"$talk.speakers","timecode":"$attr.t0_ms"}', '{}', '{}', '{}', false, 'L1', 'What a speaker says at a timecode is a claim candidate attributed to the talk (no speaker labels in panel transcripts), never a fact until verified'),
  ('talk_writeup', 'aie_talk', 'event_organizer', 'claim_candidate', null, null, null, '{"speaker":"$talk.speakers"}', '{}', '{}', '{}', false, 'L1', 'A talk write-up heading such as "X teaches the model Y" is a claim candidate with speaker role'),
  ('post_paragraph', null, 'third_party_editorial', 'claim_candidate', null, null, null, '{"mentions":"$role.mentions"}', '{}', '{}', '{"learned_at":"$version.published_at"}', false, 'L1', 'A third-party restatement sets learned-at, never valid-from; conflicts with first-party values are kept as disputed'),
  ('code_example', 'framework_docs_page', 'first_party', 'guidance_item', null, null, null, '{"entity":"$role.software"}', '{"kind":"implementation_example"}', '{}', '{}', true, 'L0', 'A docs code example becomes an implementation_example guidance item bound to the software version'),
  ('docs_section', 'framework_docs_page', 'first_party', 'claim_candidate', null, null, null, '{"entity":"$role.software"}', '{}', '{"when":{"has_version_note":true}}', '{}', false, 'L1', 'A version note in docs is a candidate compatibility/breaking statement');

-- ---------------------------------------------------------------------------------------------- 22. L2 helpers: current fact slots
create or replace function api.fact_amount(p_entity uuid, p_kind text, p_scope_key text default null, p_at timestamptz default now()) returns numeric
language sql stable security definer set search_path = '' as $$
  select s.amount from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_entity and st.kind = p_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted'
  order by s.created_at desc limit 1
$$;
create or replace function api.fact_status(p_entity uuid, p_kind text, p_scope_key text default null, p_at timestamptz default now()) returns text
language sql stable security definer set search_path = '' as $$
  select s.status from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_entity and st.kind = p_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted'
  order by s.created_at desc limit 1
$$;
create or replace function api.fact_payload(p_entity uuid, p_kind text, p_scope_key text default null, p_at timestamptz default now()) returns jsonb
language sql stable security definer set search_path = '' as $$
  select s.payload from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_entity and st.kind = p_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted'
  order by s.created_at desc limit 1
$$;
create or replace function api.price_per_1m(p_offering uuid, p_meter text, p_at timestamptz default now()) returns numeric
language sql stable security definer set search_path = '' as $$
  select case s.unit when 'USD_per_1M_tokens' then s.amount when 'USD_per_1K_tokens' then s.amount * 1000 end
  from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_offering and st.kind = 'offering_price' and s.payload->>'meter' = p_meter and coalesce(s.payload->>'tier','standard') in ('standard','default')
    and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted' and s.currency = 'USD'
  order by s.created_at desc limit 1
$$;
create or replace function api.related(p_entity uuid, p_kind text, p_direction text default 'outgoing', p_at timestamptz default now()) returns setof uuid
language sql stable security definer set search_path = '' as $$
  select case when p_direction = 'outgoing' then r.to_entity_id else r.from_entity_id end
  from catalog.relationship r join taxonomy.relationship_kind rk on rk.code = r.kind
  where r.kind = p_kind and r.k_to is null and ((p_direction = 'outgoing' and r.from_entity_id = p_entity) or (p_direction = 'incoming' and r.to_entity_id = p_entity))
    and (not rk.temporal or exists (select 1 from temporal.stream st join temporal.segment s on s.stream_id = st.id where st.subject_relationship_id = r.id and st.kind = 'relationship_active' and s.status = 'active' and s.k_to is null and s.valid_during @> p_at))
$$;
create or replace function api.names(p_ids uuid[]) returns text[] language sql stable security definer set search_path = '' as $$
  select coalesce(array_agg(e.display_name order by e.display_name), '{}') from catalog.entity e where e.id = any(p_ids)
$$;
grant execute on function api.fact_amount(uuid,text,text,timestamptz), api.fact_status(uuid,text,text,timestamptz), api.fact_payload(uuid,text,text,timestamptz), api.price_per_1m(uuid,text,timestamptz), api.related(uuid,text,text,timestamptz), api.names(uuid[]) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---------------------------------------------------------------------------------------------- 23. L1 catalog views (derived from entities, attributes and current facts; never stored twice)
create or replace function api.models_at(p_at timestamptz default now()) returns table(
  model_version_id uuid, model text, slug text, version_label text, provider_model_id text, model_family_id uuid, model_family text, developer_id uuid, developer text,
  released_on date, context_tokens numeric, max_output_tokens numeric, modalities text[], tool_use text, structured_output text, reasoning text, vision text, open_weights boolean,
  knowledge_cutoff text, availability text, min_input_usd_per_1m numeric, min_output_usd_per_1m numeric, offering_count bigint, observed_at timestamptz, as_of_knowledge_seq bigint)
language sql stable security definer set search_path = '' as $$
  with head as (select coalesce(max(h.knowledge_seq), 0) k from temporal.knowledge_head h where h.tenant_id = util.current_tenant_id())
  select v.id, v.display_name, v.slug, v.attributes->>'version_label', v.attributes->>'provider_model_id',
    fam.id, fam.display_name, dev.id, dev.display_name,
    (select lower(o.occurred_during)::date from temporal.event e join temporal.event_occurrence o on o.event_id = e.id where e.subject_entity_id = v.id and e.kind = 'model_version_released' and o.k_to is null order by lower(o.occurred_during) limit 1),
    api.fact_amount(v.id, 'model_context_window', null, p_at), api.fact_amount(v.id, 'model_max_output_tokens', null, p_at),
    coalesce((select array_agg(x) from jsonb_array_elements_text(coalesce(v.attributes->'modalities', '[]'::jsonb)) x), '{}'),
    api.fact_status(v.id, 'model_capability', 'tool_use', p_at), api.fact_status(v.id, 'model_capability', 'structured_output', p_at), api.fact_status(v.id, 'model_capability', 'reasoning', p_at), api.fact_status(v.id, 'model_capability', 'vision', p_at),
    coalesce((v.attributes->>'open_weights')::boolean, api.fact_status(v.id, 'model_capability', 'open_weights', p_at) = 'supported', false),
    api.fact_payload(v.id, 'model_knowledge_cutoff', null, p_at)->>'cutoff_on', api.fact_status(v.id, 'model_availability', null, p_at),
    (select min(api.price_per_1m(o.id, 'input_tokens', p_at)) from catalog.entity o where o.id in (select api.related(v.id, 'offered_as', 'outgoing', p_at))),
    (select min(api.price_per_1m(o.id, 'output_tokens', p_at)) from catalog.entity o where o.id in (select api.related(v.id, 'offered_as', 'outgoing', p_at))),
    (select count(*) from api.related(v.id, 'offered_as', 'outgoing', p_at)),
    (select max(s.created_at) from temporal.segment s join temporal.stream st on st.id = s.stream_id where st.subject_entity_id = v.id),
    head.k
  from catalog.entity v cross join head
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(v.id, 'version_of', 'outgoing', p_at)) limit 1) fam on true
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(fam.id, 'develops', 'incoming', p_at)) limit 1) dev on true
  where v.tenant_id = util.current_tenant_id() and v.kind = 'ai_model_version' and v.lifecycle = 'active'
$$;
create or replace view api.models as select * from api.models_at(now());
comment on view api.models is 'L1: one row per model version with developer, release date, context, modalities, capability statuses, knowledge cutoff, availability and the minimum current price per 1M tokens across offerings. Filter/compare/rank here; no embeddings.';

create or replace function api.model_offerings_at(p_at timestamptz default now()) returns table(
  offering_id uuid, offering text, offering_key text, model_version_id uuid, model text, provider_id uuid, provider text, region text, tier text,
  input_usd_per_1m numeric, output_usd_per_1m numeric, cached_input_usd_per_1m numeric, batch_input_usd_per_1m numeric, availability text, pricing_url text,
  price_valid_from timestamptz, price_observed_at timestamptz, price_claim_id uuid, price_locator_id uuid, as_of_knowledge_seq bigint)
language sql stable security definer set search_path = '' as $$
  with head as (select coalesce(max(h.knowledge_seq), 0) k from temporal.knowledge_head h where h.tenant_id = util.current_tenant_id())
  select o.id, o.display_name, o.attributes->>'offering_key', mv.id, mv.display_name, pr.id, pr.display_name, o.attributes->>'region', o.attributes->>'tier',
    api.price_per_1m(o.id, 'input_tokens', p_at), api.price_per_1m(o.id, 'output_tokens', p_at), api.price_per_1m(o.id, 'cached_input_tokens', p_at), api.price_per_1m(o.id, 'batch_input_tokens', p_at),
    api.fact_status(o.id, 'model_availability', null, p_at), o.attributes->>'pricing_url',
    ip.valid_from, ip.created_at, ip.primary_claim_id, (select ss.locator_id from evidence.segment_support ss where ss.segment_id = ip.id and ss.role = 'supports' limit 1), head.k
  from catalog.entity o cross join head
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(o.id, 'offered_as', 'incoming', p_at)) limit 1) mv on true
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(o.id, 'offered_by', 'outgoing', p_at)) limit 1) pr on true
  left join lateral (select s.id, lower(s.valid_during) valid_from, s.created_at, s.primary_claim_id from temporal.segment s join temporal.stream st on st.id = s.stream_id
                     where st.subject_entity_id = o.id and st.kind = 'offering_price' and s.payload->>'meter' = 'input_tokens' and s.k_to is null and s.valid_during @> p_at order by s.created_at desc limit 1) ip on true
  where o.tenant_id = util.current_tenant_id() and o.kind = 'model_offering' and o.lifecycle = 'active'
$$;
create or replace view api.model_offerings as select * from api.model_offerings_at(now());
comment on view api.model_offerings is 'L1: one row per offering (model as sold by a provider) with normalized USD per 1M tokens for input/output/cached/batch, availability and the exact claim + locator behind the input price.';

create or replace view api.organizations as
  select e.id as organization_id, e.display_name as organization, e.slug, e.attributes->>'org_kind' org_kind, e.attributes->>'website_url' website_url, e.attributes->>'country_code' country_code, e.attributes->>'founded_on' founded_on, e.summary,
    (select count(*) from api.related(e.id, 'develops', 'outgoing')) developed_count,
    (select count(*) from api.related(e.id, 'offered_by', 'incoming')) offering_count,
    (select count(*) from api.related(e.id, 'employed_by', 'incoming')) people_count,
    api.fact_amount(e.id, 'organization_headcount') headcount
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind = 'organization' and e.lifecycle = 'active';
comment on view api.organizations is 'L1: organizations with kind, site, country, founding date and counts of what they develop, sell and employ.';

create or replace view api.people as
  select e.id as person_id, e.display_name as person, e.slug, e.attributes->>'title' title, e.attributes->>'profile_url' profile_url,
    api.names((select array_agg(x) from api.related(e.id, 'employed_by', 'outgoing') x)) affiliations,
    (select count(*) from api.related(e.id, 'presented_by', 'incoming')) talk_count,
    (select count(*) from api.related(e.id, 'authored_by', 'incoming')) work_count
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind = 'person' and e.lifecycle = 'active';
comment on view api.people is 'L1: people with current affiliations (employed_by, as of now) and how many talks/works they presented or authored.';

create or replace view api.software as
  select e.id as software_id, e.kind, e.display_name as software, e.slug, e.attributes->>'ecosystem' ecosystem, e.attributes->>'package_name' package_name, e.attributes->>'category' category,
    e.attributes->>'docs_url' docs_url, coalesce(e.attributes->>'repository_url', (select 'https://'||(x.attributes->>'host')||'/'||(x.attributes->>'owner')||'/'||(x.attributes->>'name') from catalog.entity x where x.id in (select api.related(e.id, 'backed_by_repository', 'outgoing')) limit 1)) repository_url,
    api.names((select array_agg(x) from api.related(e.id, 'develops', 'incoming') x)) developers,
    api.names((select array_agg(x) from api.related(e.id, 'maintains', 'incoming') x)) maintainers,
    lr.version_label latest_release, lr.released_on latest_release_on,
    coalesce(api.fact_payload(e.id, 'library_license')->>'spdx', e.attributes->>'license') license,
    api.fact_amount(coalesce((select api.related(e.id, 'backed_by_repository', 'outgoing') limit 1), e.id), 'repository_stars') stars,
    api.fact_amount(e.id, 'package_downloads') downloads,
    e.attributes->>'hosting' mcp_hosting, e.attributes->>'auth' mcp_auth, (e.attributes->>'is_official')::boolean mcp_is_official,
    api.names((select array_agg(x) from api.related(e.id, 'implements_protocol', 'outgoing') x)) protocols,
    api.names((select array_agg(x) from api.related(e.id, 'instance_of_concept', 'outgoing') x)) concepts,
    e.summary
  from catalog.entity e
  left join lateral (select r.attributes->>'version_label' version_label, (r.attributes->>'released_on')::date released_on from catalog.entity r
                     where r.kind = 'library_release' and r.id in (select api.related(e.id, 'version_of', 'incoming')) order by (r.attributes->>'released_on') desc nulls last limit 1) lr on true
  where e.tenant_id = util.current_tenant_id() and e.kind in ('library','repository','mcp_server','agent_skill','product','ai_protocol') and e.lifecycle = 'active';
comment on view api.software is 'L1: libraries, repositories, MCP servers, agent skills, products and protocols in one table with ecosystem, docs/repo links, developers, latest release, license, stars/downloads, MCP hosting/auth/official flags, protocols and concepts.';
create or replace view api.libraries as select * from api.software where kind = 'library';
create or replace view api.repositories as select * from api.software where kind = 'repository';
create or replace view api.mcp_servers as select * from api.software where kind = 'mcp_server';
create or replace view api.agent_skills as select * from api.software where kind = 'agent_skill';

create or replace view api.software_releases as
  select r.id as release_id, r.display_name as release, s.id as software_id, s.display_name as software, s.kind software_kind, r.attributes->>'version_label' version_label,
    coalesce((select lower(o.occurred_during) from temporal.event e join temporal.event_occurrence o on o.event_id = e.id where e.subject_entity_id = r.id and e.kind = 'release_published' and o.k_to is null order by lower(o.occurred_during) limit 1), (r.attributes->>'released_on')::timestamptz) released_at,
    coalesce((r.attributes->>'breaking')::boolean, false) breaking, coalesce((select array_agg(x) from jsonb_array_elements_text(coalesce(r.attributes->'highlights', '[]'::jsonb)) x), '{}') highlights,
    r.attributes->>'release_url' release_url,
    (select o.k_from from temporal.event e join temporal.event_occurrence o on o.event_id = e.id where e.subject_entity_id = r.id and e.kind = 'release_published' and o.k_to is null limit 1) learned_k,
    r.created_at observed_at
  from catalog.entity r join catalog.relationship rel on rel.from_entity_id = r.id and rel.kind = 'version_of' and rel.k_to is null join catalog.entity s on s.id = rel.to_entity_id
  where r.tenant_id = util.current_tenant_id() and r.kind = 'library_release' and r.lifecycle = 'active';
comment on view api.software_releases is 'L1/L2: every known release of a software thing with its date, breaking flag, highlights and the knowledge sequence it was learned at. Order by released_at for history.';

create or replace view api.talks as
  select w.id as talk_id, w.title, e.slug, w.attributes->>'talk_kind' talk_kind, w.attributes->>'track' track, w.attributes->>'level' level,
    ev.display_name event, ev.id event_id, (ev.attributes->>'starts_on') event_starts_on,
    api.names((select array_agg(x) from api.related(w.id, 'presented_by', 'outgoing') x)) speakers,
    (select array_agg(distinct org.display_name) from api.related(w.id, 'presented_by', 'outgoing') sp join catalog.relationship r on r.from_entity_id = sp and r.kind = 'employed_by' and r.k_to is null join catalog.entity org on org.id = r.to_entity_id) speaker_affiliations,
    api.names((select array_agg(x) from api.related(w.id, 'about', 'outgoing') x)) topics,
    api.names((select array_agg(x) from api.related(w.id, 'has_code', 'outgoing') x)) repositories,
    w.published_at recorded_at, w.duration_ms, w.canonical_url, w.attributes->>'video_url' video_url, w.attributes->>'slides_url' slides_url, w.attributes->>'session_id' session_id,
    (select count(*) from content.document d where d.work_entity_id = w.id) document_count,
    e.summary
  from catalog.work w join catalog.entity e on e.id = w.id
  left join lateral (select x.* from catalog.entity x where x.id in (select api.related(w.id, 'presented_at', 'outgoing')) limit 1) ev on true
  where w.tenant_id = util.current_tenant_id() and w.kind = 'talk' and e.lifecycle = 'active';
comment on view api.talks is 'L1: conference talks with event, track, speakers and their affiliations, topics (about), linked repositories (has_code), recording and slides links.';

create or replace view api.events as
  select e.id as event_id, e.display_name as event, e.slug, e.attributes->>'edition_label' edition_label, e.attributes->>'starts_on' starts_on, e.attributes->>'ends_on' ends_on, e.attributes->>'city' city, e.attributes->>'country' country, e.attributes->>'website_url' website_url,
    api.names((select array_agg(x) from api.related(e.id, 'edition_of', 'outgoing') x)) series,
    api.names((select array_agg(x) from api.related(e.id, 'organized_by', 'outgoing') x)) organizers,
    (select count(*) from api.related(e.id, 'presented_at', 'incoming')) talk_count,
    coalesce((select array_agg(x) from jsonb_array_elements_text(coalesce(e.attributes->'tracks', '[]'::jsonb)) x), '{}') tracks
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind = 'industry_event' and e.lifecycle = 'active';
comment on view api.events is 'L1: industry events (conference editions) with dates, place, series, organizers, tracks and talk counts.';

create or replace view api.concepts as
  select e.id as concept_id, e.kind, e.display_name as concept, e.slug, e.attributes->>'component' component, e.attributes->>'level' level, coalesce(e.attributes->>'description', e.summary) description,
    (select count(*) from api.related(e.id, 'about', 'incoming')) works_about,
    (select count(*) from api.related(e.id, 'instance_of_concept', 'incoming')) instances,
    (select count(*) from api.related(e.id, 'implements_technique', 'incoming')) implementations,
    (select count(*) from guidance.item_subject s where s.entity_id = e.id) guidance_items,
    (select count(distinct b.revision_id) from authoring.revision_binding b where b.entity_id = e.id and b.relation = 'covers') modules_covering
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind in ('concept','technique') and e.lifecycle = 'active';
comment on view api.concepts is 'L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...) with how many works discuss them, software implements them, guidance items explain them and our modules cover them.';

create or replace view api.papers as
  select w.id as paper_id, w.title, w.attributes->>'arxiv_id' arxiv_id, w.attributes->>'doi' doi, w.published_at published_at, w.canonical_url,
    api.names((select array_agg(x) from api.related(w.id, 'authored_by', 'outgoing') x)) authors,
    api.names((select array_agg(x) from api.related(w.id, 'published_by', 'outgoing') x)) publishers,
    api.names((select array_agg(x) from api.related(w.id, 'has_code', 'outgoing') x)) repositories,
    api.names((select array_agg(x) from api.related(w.id, 'introduces_technique', 'outgoing') x)) techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind = 'about' and t.kind = 'talk' and r.k_to is null) talks_about,
    api.fact_amount(w.id, 'paper_citations') citations, w.abstract
  from catalog.work w join catalog.entity e on e.id = w.id where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with identifiers, authors, code repositories, techniques introduced and the talks that discuss them.';

create or replace view api.benchmark_scores as
  select s.id as segment_id, st.subject_entity_id as subject_id, sub.display_name as subject, sub.kind subject_kind, s.ref_entity_id as benchmark_id, b.display_name as benchmark,
    s.amount as score, s.unit, s.payload->>'setting' setting, s.payload->>'source_kind' source_kind, lower(s.valid_during) valid_from, s.k_from learned_k, s.created_at observed_at, s.primary_claim_id claim_id, s.belief
  from temporal.segment s join temporal.stream st on st.id = s.stream_id join catalog.entity sub on sub.id = st.subject_entity_id left join catalog.entity b on b.id = s.ref_entity_id
  where s.tenant_id = util.current_tenant_id() and st.kind = 'benchmark_score' and s.k_to is null;
comment on view api.benchmark_scores is 'L1: benchmark results as facts (one home for numbers): subject version, benchmark, score/unit, setting, who measured it, when it holds and when we learned it.';

create or replace view api.works_authored as
  select w.id as work_id, w.kind, w.slug, r.title, r.id as head_revision_id, r.revision_no, w.workspace_id, ws.kind workspace_kind,
    exists (select 1 from authoring.release_item i where i.revision_id = r.id and i.disposition in ('include','snapshot')) released,
    api.names((select array_agg(b.entity_id) from authoring.revision_binding b where b.revision_id = r.id and b.relation = 'covers' and b.entity_id is not null)) covers_concepts,
    api.names((select array_agg(x) from (select b.entity_id x from authoring.revision_binding b where b.revision_id = r.id and b.relation = 'uses' and b.entity_id is not null union select q.entity_id from authoring.runtime_requirement q where q.revision_id = r.id and q.entity_id is not null) u)) uses_software,
    (select array_agg(q.name||' '||coalesce(q.version_spec,'')) from authoring.runtime_requirement q where q.revision_id = r.id) runtime_requirements,
    r.knowledge_seq, r.created_at, 1::smallint source_tier
  from authoring.work w join authoring.work_revision r on r.id = w.head_revision_id join authoring.workspace ws on ws.id = w.workspace_id
  where w.tenant_id = util.default_tenant_id() and w.kind in ('course','track','module','lesson','activity','report','project_template','challenge','component','experience');
comment on view api.works_authored is 'L1 (ours, tier 1): our courses, modules, lessons, activities, reports and templates at their head revision, whether released, which concepts they cover and which software/versions they use.';

grant select on api.models, api.model_offerings, api.organizations, api.people, api.software, api.libraries, api.repositories, api.mcp_servers, api.agent_skills, api.software_releases, api.talks, api.events, api.concepts, api.papers, api.benchmark_scores, api.works_authored, api.guidance_items
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
grant execute on function api.models_at(timestamptz), api.model_offerings_at(timestamptz) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---------------------------------------------------------------------------------------------- 24. L2 named queries: both clocks, history, flywheel, locators, talk passages
create or replace function api.changes_since(p_since timestamptz, p_stream_kinds text[] default null, p_entity_kinds text[] default null, p_document_types text[] default null) returns table(
  change_source text, change_kind text, learned_at timestamptz, knowledge_seq bigint, world_from timestamptz, subject_entity_id uuid, subject text, stream_kind text, scope_key text,
  old_value jsonb, new_value jsonb, document_id uuid, document_title text, logical_key text, unit_kind text, changed_attributes jsonb, claim_id uuid)
language sql stable security definer set search_path = '' as $$
  with t as (select util.current_tenant_id() id)
  select 'fact', case when s.replaces_segment_id is null then 'opened' else 'replaced' end, kb.recorded_at, s.k_from, lower(s.valid_during), st.subject_entity_id, e.display_name, st.kind, st.scope_key,
    (select jsonb_build_object('amount', o.amount, 'currency', o.currency, 'unit', o.unit, 'status', o.status, 'payload', o.payload) from temporal.segment o where o.id = s.replaces_segment_id),
    jsonb_build_object('amount', s.amount, 'currency', s.currency, 'unit', s.unit, 'status', s.status, 'payload', s.payload), null::uuid, null::text, null::text, null::text, null::jsonb, s.primary_claim_id
  from temporal.segment s join temporal.stream st on st.id = s.stream_id join temporal.knowledge_batch kb on kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from
  left join catalog.entity e on e.id = st.subject_entity_id, t
  where s.tenant_id = t.id and kb.recorded_at > p_since and (p_stream_kinds is null or st.kind = any(p_stream_kinds)) and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'event', ev.kind, kb.recorded_at, o.k_from, lower(o.occurred_during), ev.subject_entity_id, e.display_name, null::text, null::text, null::jsonb, o.payload, null::uuid, null::text, null::text, null::text, null::jsonb, o.primary_claim_id
  from temporal.event_occurrence o join temporal.event ev on ev.id = o.event_id join temporal.knowledge_batch kb on kb.tenant_id = o.tenant_id and kb.knowledge_seq = o.k_from
  left join catalog.entity e on e.id = ev.subject_entity_id, t
  where o.tenant_id = t.id and kb.recorded_at > p_since and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'unit', uc.change_kind, uc.detected_at, null::bigint, dv.published_at, d.work_entity_id, e.display_name, null::text, null::text,
    (select to_jsonb(n.attributes) from content.document_node n where n.id = uc.from_node_id), (select to_jsonb(n.attributes) from content.document_node n where n.id = uc.to_node_id),
    d.id, d.canonical_title, uc.logical_key, uc.unit_kind, uc.changed_attributes, null::uuid
  from content.unit_change uc join content.document d on d.id = uc.document_id join content.document_version dv on dv.id = uc.to_version_id left join catalog.entity e on e.id = d.work_entity_id, t
  where uc.tenant_id = t.id and uc.detected_at > p_since and (p_document_types is null or d.document_type_code = any(p_document_types))
  order by 3 desc
$$;
comment on function api.changes_since is 'L2 both clocks: what changed since a date, as facts opened/replaced (with the old value), events, and unit-level diffs of refreshed documents; learned_at is when we recorded it, world_from is when it holds in the world.';

create or replace function api.price_history(p_offering uuid, p_meter text default 'input_tokens') returns table(
  segment_id uuid, meter text, tier text, region text, amount numeric, currency text, unit text, valid_during tstzrange, belief text, temporal_basis text, k_from bigint, k_to bigint, learned_at timestamptz, retracted_at timestamptz, claim_id uuid, replaces_segment_id uuid)
language sql stable security definer set search_path = '' as $$
  select s.id, s.payload->>'meter', s.payload->>'tier', s.payload->>'region', s.amount, s.currency::text, s.unit, s.valid_during, s.belief, s.temporal_basis, s.k_from, s.k_to,
    (select kb.recorded_at from temporal.knowledge_batch kb where kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from),
    (select kb.recorded_at from temporal.knowledge_batch kb where kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_to), s.primary_claim_id, s.replaces_segment_id
  from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where s.tenant_id = util.current_tenant_id() and st.subject_entity_id = p_offering and st.kind = 'offering_price' and (p_meter is null or s.payload->>'meter' = p_meter)
  order by lower(s.valid_during), s.k_from
$$;
comment on function api.price_history is 'L2: every price segment of an offering and meter with both clocks (valid_during; k_from/k_to with learned_at), including superseded beliefs.';

create or replace function api.fact_locators(p_entity uuid, p_stream_kind text, p_scope_key text default null) returns table(
  segment_id uuid, scope_key text, amount numeric, currency text, unit text, status text, payload jsonb, valid_during tstzrange, claim_id uuid, claim_statement text, locator_id uuid, selector_kind text, selector jsonb, normalized_value text,
  capture_id uuid, captured_at timestamptz, request_url text, source_url text, document_node_id uuid, unit_kind text, logical_key text)
language sql stable security definer set search_path = '' as $$
  select s.id, st.scope_key, s.amount, s.currency::text, s.unit, s.status, s.payload, s.valid_during, c.id, c.statement, l.id, l.selector_kind, l.selector, l.normalized_value,
    cap.id, cap.captured_at, cap.request_url, src.canonical_url, xr.document_node_id, n.unit_kind, n.logical_key
  from temporal.segment s join temporal.stream st on st.id = s.stream_id
  left join evidence.claim c on c.id = s.primary_claim_id
  left join evidence.segment_support ss on ss.segment_id = s.id and ss.role = 'supports'
  left join evidence.locator l on l.id = ss.locator_id
  left join evidence.source_capture cap on cap.id = l.capture_id
  left join evidence.source src on src.id = cap.source_id
  left join evidence.extraction_record xr on xr.claim_id = c.id
  left join content.document_node n on n.id = xr.document_node_id
  where s.tenant_id = util.current_tenant_id() and st.subject_entity_id = p_entity and st.kind = p_stream_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null
  order by lower(s.valid_during) desc
$$;
comment on function api.fact_locators is 'L1->evidence: a current fact with its claim, exact locator (selector + normalized value), the capture (URL, time) and the typed unit it was read from.';

create or replace function api.modules_affected_by_release(p_release uuid) returns table(
  work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamptz, software text, release text, released_at timestamptz, breaking boolean, binding text, version_spec text)
language sql stable security definer set search_path = '' as $$
  with rel as (select r.* from api.software_releases r where r.release_id = p_release)
  select w.id, w.kind, w.slug, rv.id, rv.title, rv.created_at, rel.software, rel.release, rel.released_at, rel.breaking, b.binding, b.version_spec
  from rel join (
    select x.revision_id, 'binding:'||x.relation binding, null::text version_spec, x.entity_id from authoring.revision_binding x where x.entity_id is not null
    union all select q.revision_id, 'runtime_requirement', q.version_spec, q.entity_id from authoring.runtime_requirement q where q.entity_id is not null
  ) b on b.entity_id = rel.software_id
  join authoring.work_revision rv on rv.id = b.revision_id join authoring.work w on w.id = rv.work_id and w.head_revision_id = rv.id
  where rel.released_at is null or rv.created_at < rel.released_at
  order by rel.released_at desc, w.slug
$$;
comment on function api.modules_affected_by_release is 'L2 flywheel: our head revisions (modules, activities, courses) that bind or require the software a release belongs to and were authored before that release; breaking tells which need review first.';

create or replace function api.talk_segments(p_talk uuid, p_from_ms integer default null, p_to_ms integer default null, p_query text default null) returns table(
  node_id uuid, unit_kind text, start_ms integer, end_ms integer, slide_n integer, text text, document_id uuid, representation_id uuid, logical_key text)
language sql stable security definer set search_path = '' as $$
  select n.id, n.unit_kind, n.start_ms, n.end_ms, (n.attributes->>'slide_n')::integer, n.inline_text, d.id, n.representation_id, n.logical_key
  from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and d.work_entity_id = p_talk and n.unit_kind in ('transcript_segment','slide','talk_writeup')
    and (p_from_ms is null or coalesce(n.end_ms, n.start_ms) >= p_from_ms) and (p_to_ms is null or n.start_ms <= p_to_ms)
    and (p_query is null or to_tsvector('english', coalesce(n.inline_text,'')) @@ websearch_to_tsquery('english', p_query))
  order by n.start_ms nulls last, n.ordinal
$$;
comment on function api.talk_segments is 'L3 exact: the transcript segments and slides of a talk inside a timecode window, optionally filtered by text; the speaker is the talk''s presenter unless the segment carries a speaker attribute (ai.engineer transcripts have none).';

create or replace function api.document_units(p_document uuid, p_unit_kinds text[] default null) returns table(
  node_id uuid, version_label text, unit_kind text, logical_key text, attributes jsonb, inline_text text, page_number integer, start_ms integer, end_ms integer, stable_local_key text)
language sql stable security definer set search_path = '' as $$
  select n.id, v.version_label, n.unit_kind, n.logical_key, n.attributes, n.inline_text, n.page_number, n.start_ms, n.end_ms, n.stable_local_key
  from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and d.id = p_document and (p_unit_kinds is null or n.unit_kind = any(p_unit_kinds))
  order by v.created_at desc, n.ordinal
$$;
comment on function api.document_units is 'Typed units of a document across its versions (newest first): the structural view a question drills into after the L1 row.';

create or replace function api.document_digest(p_document uuid) returns table(digest_id uuid, version_label text, scope text, producer_kind text, ordinal integer, item_kind text, text text, payload jsonb, entity text, node_ids uuid[], claim_id uuid, confidence numeric)
language sql stable security definer set search_path = '' as $$
  select g.id, v.version_label, g.scope, g.producer_kind, i.ordinal, i.item_kind, i.text, i.payload, e.display_name, i.node_ids, i.claim_id, i.confidence
  from content.document_digest g join content.document_version v on v.id = g.document_version_id join content.digest_item i on i.digest_id = g.id left join catalog.entity e on e.id = i.entity_id
  where g.tenant_id = util.current_tenant_id() and v.document_id = p_document and g.lifecycle = 'active' order by v.created_at desc, i.ordinal
$$;
comment on function api.document_digest is 'The structured digest of a document''s newest version: key points, entity roles, assertion references, changes, open questions and research directions, each anchored to units.';

grant execute on function api.changes_since(timestamptz, text[], text[], text[]), api.price_history(uuid, text), api.fact_locators(uuid, text, text), api.modules_affected_by_release(uuid), api.talk_segments(uuid, integer, integer, text), api.document_units(uuid, text[]), api.document_digest(uuid)
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
