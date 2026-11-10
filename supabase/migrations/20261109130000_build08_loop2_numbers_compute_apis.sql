-- Build 08 knowledge loop 2 (RV07 benchmarks/conditions/cohorts, RV05 compute/offerings/sandboxes, RV04 symbols/APIs/advisories/registry,
-- paper levels P0-P2, unit links), promoted 2026-11-10 from the lab drafts 20261109130000..20261109130500 (the six draft files stay in
-- supabase/drafts/ as the sources). Lab-proven on disposable-aieng-build04; cycle record: Build 08 §19 in the AI Engineer review workspace.
begin;
-- ---- from draft 20261109130000_build08_loop2_numbers_compute_apis.sql
-- Build 08 knowledge loop 2 draft (lab disposable-aieng-build04 only; approved by John 2026-11-09 from
-- reviews/BUILD-08-LOOP-2-SELECTION.md §5). RV07 benchmarks/conditions/cohorts, RV05 compute/offerings/sandboxes,
-- RV04 repository symbols / OpenAPI units / advisories / registry listings / protocol versions, paper levels P0–P2 as
-- document attributes, the one new table content.unit_link (R4), and the two §14.7 grammar fixes that need DDL.
-- Domains land as vocabulary rows (entity kinds, stream kinds, unit kinds, document types, mappings) and api views.


-- ====================================================================================================== RV07
update taxonomy.entity_kind set description = 'A benchmark (task set + metric) that scores models, agents or systems; versions/editions are benchmark_version children',
  attributes_schema = '{"type":"object","properties":{"organizer":{"type":"string"},"canonical_url":{"type":"string"},"metric":{"type":"string"},"scoring":{"type":"string"},"higher_is_better":{"type":"boolean"},"domain":{"type":"string"},"agentic":{"type":"boolean"},"task_count":{"type":"integer"},"score_type":{"type":"string","enum":["accuracy","pass_at_k","elo_preference","throughput","cost","composite_index","latency","other"]},"description":{"type":"string"}},"additionalProperties":true}'::jsonb
  where code = 'benchmark';
insert into taxonomy.entity_kind(code, label, canonical_schema, canonical_table, description, attributes_schema, parent_kind, lens, is_work) values
  ('benchmark_version', 'Benchmark Version', 'catalog', 'entity', 'One edition/cohort of a benchmark (SWE-bench Verified, Terminal-Bench 4.1, ARC-AGI-2, OSWorld v2.1); scores reference the version, never the bare benchmark',
   '{"type":"object","required":["version_label"],"properties":{"version_label":{"type":"string"},"released_on":{"type":"string"},"task_count":{"type":"integer"},"changes":{"type":"string"},"canonical_url":{"type":"string"},"status":{"type":"string","enum":["current","archived","superseded","unknown"]}},"additionalProperties":true}'::jsonb, 'benchmark', 'corpus', false)
  on conflict (code) do nothing;
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['benchmark_version']) x), to_kinds = array(select distinct x from unnest(to_kinds || array['benchmark']) x) where code = 'version_of';
update taxonomy.relationship_kind set to_kinds = array(select distinct x from unnest(to_kinds || array['benchmark_version']) x) where code in ('about');
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['benchmark_version']) x) where code in ('instance_of_concept');
-- conditioned scores: who measured and under which harness are scope-key components (scope key = benchmark_version|harness|setting|reported_by)
update temporal.stream_kind set subject_kinds = array(select distinct x from unnest(subject_kinds || array['compute_device','compute_offering']) x),
  ref_entity_kinds = array['benchmark','benchmark_version'], unit_values = array(select distinct x from unnest(unit_values || array['tokens_per_second','samples_per_second','ms']) x),
  payload_schema = '{"type":"object","properties":{"harness":{"type":"string"},"harness_version":{"type":"string"},"setting":{"type":"string"},"tools":{"type":"string"},"pass_k":{"type":"integer"},"attempts":{"type":"integer"},"context_tokens":{"type":"integer"},"reasoning_effort":{"type":"string"},"cost_usd":{"type":"number"},"run_date":{"type":"string"},"n_tasks":{"type":"integer"},"ci_low":{"type":"number"},"ci_high":{"type":"number"},"reported_by":{"type":"string","enum":["organizer","self_reported","third_party","own"]},"source_kind":{"type":"string","enum":["first_party","third_party","own"]},"comparison":{"type":"string"},"benchmark_version":{"type":"string"},"scenario":{"type":"string"},"step_budget":{"type":"integer"},"tool_mode":{"type":"string"},"source_note":{"type":"string"}},"additionalProperties":true}'::jsonb,
  description = 'A benchmark result: subject (model version, product version, library release or compute system), ref benchmark_version (or benchmark), amount+unit, and the conditions that make it comparable; scope_key = benchmark_version|harness|setting|reported_by so organizer-run, self-reported and third-party numbers coexist'
  where code = 'benchmark_score';
-- leaderboards: publisher, benchmark version, source; edition = one dated capture (cohort = member ids); entries carry conditions
alter table ranking.leaderboard add column if not exists publisher_entity_id uuid references catalog.entity(id), add column if not exists benchmark_version_id uuid references catalog.entity(id),
  add column if not exists source_url text, add column if not exists methodology jsonb not null default '{}'::jsonb;
alter table ranking.leaderboard_edition add column if not exists capture_id uuid references evidence.source_capture(id), add column if not exists observed_at timestamptz, add column if not exists board_date date;
alter table ranking.leaderboard_entry add column if not exists conditions jsonb not null default '{}'::jsonb, add column if not exists subject_label text, add column if not exists node_id uuid references content.document_node(id);
comment on column ranking.leaderboard_edition.board_date is 'The date the publisher shows on the board (world time), if any; observed_at is when we captured it (knowledge time).';
comment on column ranking.leaderboard_entry.conditions is 'harness, reported_by, effort, tool_mode, step_budget ... as the board states them; the same conditions are on the benchmark_score segment payload.';

insert into content.document_type(code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time, status, axis_note) values
  ('leaderboard_page', 'research', 'A published leaderboard or benchmark results table (HTML, JSON, CSV) from an organizer or an aggregator', true, 'structural_heading', array['measurement','entity'], array['benchmark_intelligence'], array['abstract','technical'], null, true, 'active', 'primary when organizer-run; aggregator boards are T3 with per-row source labels'),
  ('api_surface', 'code', 'Derived document: the public API surface of one repository release (symbols parsed from the tag tarball); the tree itself is never a document (R1/R3)', true, 'structural_heading', array['entity'], array['tool_capabilities'], array['technical'], null, true, 'active', 'derived from a first-party tarball; attributes record repository, release_tag, tag_filter, parser and scope'),
  ('openapi_spec', 'vendor', 'A machine-readable API description (OpenAPI 3 YAML/JSON) published by the provider', true, 'structural_heading', array['entity'], array['tool_capabilities'], array['technical'], null, true, 'active', 'endpoints, parameters and schema components become typed units; diffs across captures are what the provider added')
  on conflict (code) do nothing;

insert into content.unit_kind(code, description, is_universal, applicable_document_types, parent_kinds, attributes_schema, logical_key_attributes, selector_kind, retrieval_role, entity_roles) values
  ('leaderboard_row', 'One ranked row of a leaderboard: subject, score, conditions as the board states them', false, array['leaderboard_page'], array['table','section','document_root'],
   '{"type":"object","required":["subject_name","score"],"properties":{"rank":{"type":"integer"},"subject_name":{"type":"string"},"score":{"type":"number"},"unit":{"type":"string"},"benchmark":{"type":"string"},"benchmark_version":{"type":"string"},"harness":{"type":"string"},"harness_version":{"type":"string"},"reported_by":{"type":"string"},"run_date":{"type":"string"},"release_date":{"type":"string"},"cost_usd":{"type":"number"},"n_tasks":{"type":"integer"},"ci_low":{"type":"number"},"ci_high":{"type":"number"},"pass_k":{"type":"integer"},"effort":{"type":"string"},"tool_mode":{"type":"string"},"step_budget":{"type":"integer"},"organization":{"type":"string"},"source_label":{"type":"string"},"source_url":{"type":"string"},"votes":{"type":"integer"},"scenario":{"type":"string"},"accelerator":{"type":"string"},"accelerators_per_node":{"type":"integer"},"system_name":{"type":"string"},"model":{"type":"string"},"notes":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['benchmark','subject_name','harness'], 'table', 'embed', array['subject','benchmark','leaderboard','harness','publisher','system']),
  ('metric_definition', 'What a metric or benchmark measures, how it is scored and which direction is better', false, array['leaderboard_page','arxiv_paper','framework_docs_page','official_docs_page','tech_report'], array['section','document_root'],
   '{"type":"object","required":["name"],"properties":{"name":{"type":"string"},"formula":{"type":"string"},"scale":{"type":"string"},"higher_is_better":{"type":"boolean"},"description":{"type":"string"},"version":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['name'], 'text_quote', 'embed', array['benchmark']),
  ('api_symbol', 'One public symbol of a library release: qualified name, kind, signature, module (R3); logical key = qualified name so unit_change across releases is the breaking-change evidence', false, array['api_surface'], array['document_root','section'],
   '{"type":"object","required":["qualified_name","kind"],"properties":{"qualified_name":{"type":"string"},"kind":{"type":"string","enum":["function","class","method","constant","type","module","variable"]},"signature":{"type":"string"},"module":{"type":"string"},"is_public":{"type":"boolean"},"deprecated":{"type":"boolean"},"docstring_head":{"type":"string"},"path":{"type":"string"},"lineno":{"type":"integer"},"exported_by":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['qualified_name'], 'repository', 'embed', array['release','software','documents']),
  ('endpoint', 'One API operation (method + path) of a provider API', false, array['openapi_spec','api_reference'], array['document_root','section'],
   '{"type":"object","required":["method","path"],"properties":{"method":{"type":"string"},"path":{"type":"string"},"operation_id":{"type":"string"},"summary":{"type":"string"},"tags":{"type":"array","items":{"type":"string"}},"deprecated":{"type":"boolean"},"parameter_count":{"type":"integer"},"has_request_body":{"type":"boolean"},"family":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['method','path'], 'json_pointer', 'embed', array['api','product_version','provider']),
  ('parameter', 'One parameter or request-body field of an endpoint', false, array['openapi_spec','api_reference'], array['endpoint'],
   '{"type":"object","required":["endpoint_key","name","location"],"properties":{"endpoint_key":{"type":"string"},"name":{"type":"string"},"location":{"type":"string","enum":["path","query","header","cookie","body"]},"schema_type":{"type":"string"},"required":{"type":"boolean"},"description":{"type":"string"},"deprecated":{"type":"boolean"}},"additionalProperties":true}'::jsonb,
   array['endpoint_key','location','name'], 'json_pointer', 'filter', array['api']),
  ('schema_component', 'One named schema (component) of an API description or protocol schema', false, array['openapi_spec','api_reference'], array['document_root','section'],
   '{"type":"object","required":["name"],"properties":{"name":{"type":"string"},"type":{"type":"string"},"required":{"type":"array","items":{"type":"string"}},"property_count":{"type":"integer"},"description":{"type":"string"},"protocol_version":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['name'], 'json_pointer', 'filter', array['api','protocol_version']),
  ('advisory', 'One security advisory record (GHSA/CVE) with the affected package, range and fix', false, array['security_advisory_page'], array['document_root','section'],
   '{"type":"object","required":["ghsa_id"],"properties":{"ghsa_id":{"type":"string"},"cve_id":{"type":"string"},"severity":{"type":"string"},"package":{"type":"string"},"ecosystem":{"type":"string"},"affected_range":{"type":"string"},"fixed_version":{"type":"string"},"published_at":{"type":"string"},"updated_at":{"type":"string"},"summary":{"type":"string"},"url":{"type":"string"},"cwe":{"type":"array","items":{"type":"string"}}},"additionalProperties":true}'::jsonb,
   array['ghsa_id','package'], 'json_pointer', 'embed', array['advisory','software','package']),
  ('registry_listing', 'One listing of a server/package in a registry (MCP registry server-version entry)', false, array['registry_listing_page'], array['document_root','section'],
   '{"type":"object","required":["registry","name"],"properties":{"registry":{"type":"string"},"name":{"type":"string"},"namespace":{"type":"string"},"publisher":{"type":"string"},"version":{"type":"string"},"transports":{"type":"array","items":{"type":"string"}},"package_identifiers":{"type":"array","items":{"type":"string"}},"first_party_inferred":{"type":"boolean"},"registry_status":{"type":"string"},"repository_url":{"type":"string"},"website_url":{"type":"string"},"published_at":{"type":"string"},"updated_at":{"type":"string"},"description":{"type":"string"},"is_latest":{"type":"boolean"}},"additionalProperties":true}'::jsonb,
   array['registry','name'], 'json_pointer', 'embed', array['server','registry','publisher']),
  ('paper_section', 'A section of a paper or technical report (P1 keeps abstract and conclusion; P2 keeps all)', false, array['arxiv_paper','tech_report','conference_paper','journal_article'], array['document_root','section'],
   '{"type":"object","properties":{"heading":{"type":"string"},"level":{"type":"integer"},"path":{"type":"string"},"section_role":{"type":"string","enum":["abstract","introduction","method","results","discussion","limitations","conclusion","references","appendix","other"]}},"additionalProperties":true}'::jsonb,
   array['path'], 'text_quote', 'embed', array['paper']),
  ('reference', 'One bibliographic reference of a paper or post (becomes a cites relationship when the target resolves)', false, array['arxiv_paper','tech_report','conference_paper','journal_article','official_blog_post','aie_talk'], array['document_root','section','list'],
   '{"type":"object","required":["ref_key"],"properties":{"ref_key":{"type":"string"},"title":{"type":"string"},"arxiv_id":{"type":"string"},"doi":{"type":"string"},"url":{"type":"string"},"ordinal":{"type":"integer"}},"additionalProperties":true}'::jsonb,
   array['ref_key'], 'text_quote', 'filter', array['paper','cited'])
  on conflict (code, version) do nothing;
-- existing kinds widened for loop 2
update content.unit_kind set applicable_document_types = array(select distinct x from unnest(applicable_document_types || array['arxiv_paper','tech_report','leaderboard_page','official_blog_post']) x),
  attributes_schema = '{"type":"object","required":["benchmark","score"],"properties":{"unit":{"type":"string"},"model":{"type":"string"},"score":{"type":"number"},"setting":{"type":"string"},"benchmark":{"type":"string"},"benchmark_version":{"type":"string"},"harness":{"type":"string"},"reported_by":{"type":"string"},"effort":{"type":"string"},"comparison_model":{"type":"string"},"source_note":{"type":"string"},"n_trials":{"type":"integer"},"ci":{"type":"string"},"table_heading":{"type":"string"}},"additionalProperties":true}'::jsonb,
  logical_key_attributes = array['benchmark','setting','model','reported_by'], entity_roles = array['model','benchmark','harness','publisher'] where code = 'eval_row' and version = 1;
update content.unit_kind set entity_roles = array['model','device','offering'], description = 'A specification field of a model page or hardware spec page (context window, cutoff, modalities, memory, bandwidth, TDP)' where code = 'spec_field' and version = 1;
update content.unit_kind set attributes_schema = '{"type":"object","required":["offering","meter","amount","currency","unit"],"properties":{"tier":{"type":"string"},"unit":{"type":"string"},"meter":{"type":"string"},"amount":{"type":"number"},"region":{"type":"string"},"currency":{"type":"string"},"offering":{"type":"string"},"condition":{"type":"string"},"commitment":{"type":"string"},"per":{"type":"string"},"gpu_count":{"type":"integer"},"section":{"type":"string"},"effective_from":{"type":"string"}},"additionalProperties":true}'::jsonb,
  logical_key_attributes = array['offering','meter','tier','region','commitment'], description = 'One priced meter for an offering (model tokens, GPU-hours, sandbox vCPU-seconds); the section label is read before slot assignment (§14.7 grammar fix b)' where code = 'price_row' and version = 1;
update content.unit_kind set parent_kinds = array(select distinct x from unnest(parent_kinds || array['slide']) x), description = 'A resource link listed on a talk page or inside a slide (repository, paper, docs); slide links are cites candidates' where code = 'talk_resource' and version = 1;
update content.unit_kind set applicable_document_types = array(select distinct x from unnest(applicable_document_types || array['product_page','official_blog_post','api_reference']) x) where code = 'section' and version = 1 and not is_universal;
update content.unit_kind set entity_roles = array(select distinct x from unnest(entity_roles || array['symbol_doc']) x) where code = 'docs_section' and version = 1;

insert into content.unit_assertion_mapping(unit_kind, document_type_code, source_role_code, target_kind, stream_kind, relationship_kind, event_kind, subject_template, value_template, qualifier_template, time_template, deterministic, risk_floor, description) values
  ('leaderboard_row', 'leaderboard_page', 'event_organizer', 'stream', 'benchmark_score', null, null, '{"entity":"$role.subject","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark_version|$attr.harness|$attr.effort|organizer","payload":{"harness":"$attr.harness","reported_by":"organizer","run_date":"$attr.run_date","cost_usd":"$attr.cost_usd"}}', '{"temporal_basis":"observation_bounded","valid_from":"$attr.run_date|$capture.captured_at"}', true, 'L0', 'An organizer-run leaderboard row is an organizer-measured score under the stated harness and conditions'),
  ('leaderboard_row', 'leaderboard_page', 'third_party_editorial', 'stream', 'benchmark_score', null, null, '{"entity":"$role.subject","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark_version|$attr.harness|$attr.effort|$attr.reported_by","payload":{"harness":"$attr.harness","reported_by":"$attr.reported_by","source_label":"$attr.source_label"}}', '{"temporal_basis":"observation_bounded","valid_from":"$attr.run_date|$capture.captured_at"}', true, 'L1', 'An aggregator row keeps the aggregator''s own source label (internal run vs external) as reported_by'),
  ('eval_row', 'official_blog_post', 'first_party', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark_version|$attr.harness|$attr.setting|self_reported","payload":{"setting":"$attr.setting","harness":"$attr.harness","reported_by":"self_reported","source_kind":"first_party","source_note":"$attr.source_note"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L0', 'A vendor announcement table row is a self-reported score; footnotes naming another party''s number become reported_by third_party'),
  ('eval_row', 'system_card', 'first_party', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark_version|$attr.harness|$attr.setting|self_reported","payload":{"setting":"$attr.setting","reported_by":"self_reported","source_kind":"first_party"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L0', 'A first-party model/system card evaluation row (P2 by default) is a self-reported score'),
  ('eval_row', 'arxiv_paper', 'academic', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark_version|$attr.harness|$attr.setting|self_reported","payload":{"setting":"$attr.setting","reported_by":"self_reported","source_kind":"first_party","n_tasks":"$attr.n_trials"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L1', 'A paper''s result row is the authors'' own measurement (P1 digest key_result or P2 eval_row)'),
  ('spec_field', 'product_page', 'first_party', 'entity_attribute', null, null, null, '{"entity":"$role.device"}', '{"attribute":"$attr.field","value":"$attr.value","unit":"$attr.unit"}', '{}', '{}', true, 'L0', 'A hardware spec-sheet field sets a compute_device attribute with a claim locator (specs are attributes, not time series)'),
  ('advisory', 'security_advisory_page', 'registry', 'relationship', null, 'affected_by_advisory', null, '{"from":"$role.software","to":"$role.advisory"}', '{"properties":{"affected_range":"$attr.affected_range","fixed_version":"$attr.fixed_version","severity":"$attr.severity","cve_id":"$attr.cve_id"}}', '{}', '{"valid_from":"$attr.published_at"}', true, 'L0', 'A GHSA record links the affected package to the advisory with the vulnerable range and first patched version'),
  ('advisory', 'security_advisory_page', 'registry', 'event', null, null, 'advisory_published', '{"entity":"$role.advisory"}', '{"payload":{"ghsa_id":"$attr.ghsa_id","cve_id":"$attr.cve_id","severity":"$attr.severity","package":"$attr.package"}}', '{}', '{"occurred_at":"$attr.published_at","mode":"actual"}', true, 'L0', 'The advisory publication date is an event'),
  ('registry_listing', 'registry_listing_page', 'registry', 'relationship', null, 'listed_in', null, '{"from":"$role.server","to":"$role.registry"}', '{"properties":{"version":"$attr.version","transports":"$attr.transports","first_party_inferred":"$attr.first_party_inferred"}}', '{}', '{"valid_from":"$attr.published_at"}', true, 'L0', 'A registry entry lists the server in the registry'),
  ('registry_listing', 'registry_listing_page', 'registry', 'stream', 'registry_listing_status', null, null, '{"relationship":"listed_in($role.server,$role.registry)"}', '{"status":"$attr.registry_status"}', '{}', '{"temporal_basis":"observation_bounded","valid_from":"$attr.updated_at|$capture.captured_at"}', true, 'L0', 'The registry''s own status (active/deprecated/deleted) is a stream on the listing relationship'),
  ('talk_resource', 'aie_talk', 'event_organizer', 'relationship', null, 'cites', null, '{"from":"$document.work_entity","to":"$role.references"}', '{}', '{}', '{}', true, 'L0', 'A paper link on a talk page or slide: the talk cites the paper (first-party when speaker-authored)'),
  ('reference', 'arxiv_paper', 'academic', 'relationship', null, 'cites', null, '{"from":"$document.work_entity","to":"$role.cited"}', '{}', '{}', '{}', true, 'L0', 'A resolved bibliographic reference is a cites relationship between papers')
  on conflict do nothing;

-- ====================================================================================================== RV05
update taxonomy.entity_kind set description = 'An accelerator or system (GPU, TPU, NPU, CPU or a multi-GPU system such as GB200 NVL72); specs are attributes with claim locators',
  attributes_schema = '{"type":"object","properties":{"vendor":{"type":"string"},"device_class":{"type":"string","enum":["gpu","tpu","npu","cpu","system","other"]},"memory_gb":{"type":"number"},"memory_bandwidth_tbps":{"type":"number"},"bf16_tflops":{"type":"number"},"fp8_tflops":{"type":"number"},"fp4_pflops":{"type":"number"},"sparse_figures":{"type":"boolean"},"tdp_w":{"type":"number"},"interconnect":{"type":"string"},"interconnect_gbps":{"type":"number"},"form_factor":{"type":"string"},"announced_on":{"type":"string"},"available_on":{"type":"string"},"released_on":{"type":"string"},"spec_url":{"type":"string"},"gpus_per_system":{"type":"integer"},"description":{"type":"string"}},"additionalProperties":true}'::jsonb
  where code = 'compute_device';
update taxonomy.entity_kind set description = 'A sellable compute offering: an instance type, a serverless GPU, a sandbox product, a managed cluster or an inference endpoint (offering_class), priced through offering_price',
  attributes_schema = '{"type":"object","required":["offering_class"],"properties":{"offering_class":{"type":"string","enum":["instance_type","serverless_gpu","sandbox","managed_cluster","inference_endpoint","tpu_slice","other"]},"provider_slug":{"type":"string"},"sku":{"type":"string"},"gpu_count":{"type":"integer"},"gpu_device_slug":{"type":"string"},"vcpu":{"type":"number"},"memory_gb":{"type":"number"},"storage_gb":{"type":"number"},"regions":{"type":"array","items":{"type":"string"}},"pricing_url":{"type":"string"},"billing_granularity":{"type":"string"},"description":{"type":"string"}},"additionalProperties":true}'::jsonb
  where code = 'compute_offering';
-- one home for prices: offering_price already accepts compute_offering subjects; the duplicate kind goes
delete from temporal.stream_kind where code = 'compute_offering_price' and not exists (select 1 from temporal.stream s where s.kind = 'compute_offering_price');
update temporal.stream_kind set unit_values = array(select distinct x from unnest(unit_values || array['USD_per_GPU_hour','USD_per_node_hour','USD_per_chip_hour','USD_per_vcpu_second','USD_per_GiB_second','USD_per_GB_hour','USD_per_vcpu_hour','USD_per_sandbox_hour','USD_per_1M_creations','USD_per_GB_month']) x),
  payload_schema = '{"type":"object","required":["meter"],"properties":{"tier":{"type":"string"},"meter":{"type":"string"},"region":{"type":"string"},"condition":{"type":"string"},"context_band":{"type":"string"},"commitment":{"type":"string","enum":["on_demand","spot","preemptible","reserved_1y","reserved_3y","reserved","flex_start","calendar","unknown"]},"interruptible":{"type":"boolean"},"per":{"type":"string","enum":["gpu","node","instance","sandbox","chip","vcpu","gib","unit"]},"gpu_count":{"type":"integer"},"source_role":{"type":"string"},"effective_from":{"type":"string"},"section":{"type":"string"}},"additionalProperties":true}'::jsonb,
  description = 'Price of one meter of an offering (input_tokens, output_tokens, gpu_hour, vcpu_second, gib_second ...); scope_key = meter|tier|region|commitment; amount+currency+unit normalized; observation_bounded from the capture unless the page states an effective date'
  where code = 'offering_price';
insert into temporal.stream_kind(code, subject_mode, subject_kinds, status_values, requires_amount, unit_values, requires_ref_entity, ref_entity_kinds, payload_schema, description) values
  ('offering_limit', 'entity', array['model_offering','compute_offering'], null, true, array['context_tokens','max_output_tokens','rpm','tpm','batch_size','seconds','minutes','hours','count','GiB','vcpu','GB'], false, null,
   '{"type":"object","required":["limit_name"],"properties":{"limit_name":{"type":"string"},"plan":{"type":"string"},"condition":{"type":"string"}},"additionalProperties":true}'::jsonb, 'A stated limit of an offering (max session duration, concurrency, memory, rate limits); scope_key = limit_name|plan')
  on conflict (code) do nothing;
delete from temporal.stream_kind where code = 'model_offering_limit' and not exists (select 1 from temporal.stream s where s.kind = 'model_offering_limit');
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['compute_offering']) x) where code = 'runs_on';

-- ====================================================================================================== RV04
create table if not exists content.unit_link (
  tenant_id uuid not null default util.default_tenant_id(),
  from_node_id uuid not null references content.document_node(id) on delete cascade,
  to_node_id uuid not null references content.document_node(id) on delete cascade,
  kind text not null check (kind in ('documents','cites','supersedes','implements','mentions','same_symbol')),
  method text not null default 'rule',
  confidence numeric(5,4) not null default 1.0,
  created_at timestamptz not null default now(),
  primary key (from_node_id, to_node_id, kind)
);
create index if not exists unit_link_to_ix on content.unit_link(to_node_id, kind);
comment on table content.unit_link is 'R4: typed edge between two units (a docs section documents an api_symbol; a slide cites a paper reference; a symbol unit in release B is the same symbol as in release A). Symbols are units, not entities, so unit_entity_role cannot carry this.';
alter table content.unit_link enable row level security;
create policy unit_link_tenant on content.unit_link using (tenant_id = util.current_tenant_id());
grant select on content.unit_link to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner;

update taxonomy.entity_kind set attributes_schema = '{"type":"object","required":["version_label"],"properties":{"license":{"type":"string"},"breaking":{"type":"boolean"},"highlights":{"type":"array","items":{"type":"string"}},"release_url":{"type":"string"},"released_on":{"type":"string"},"version_label":{"type":"string"},"tag":{"type":"string"},"prerelease":{"type":"boolean"},"source_tarball_sha256":{"type":"string"},"symbol_count":{"type":"integer"},"public_symbol_count":{"type":"integer"},"over_cap":{"type":"boolean"},"parser":{"type":"string"},"parser_scope":{"type":"string"}},"additionalProperties":true}'::jsonb where code = 'library_release';
update taxonomy.entity_kind set description = 'A published security advisory (GHSA/CVE) affecting software; the record itself, not the vulnerability concept',
  attributes_schema = '{"type":"object","properties":{"ghsa_id":{"type":"string"},"cve_id":{"type":"string"},"severity":{"type":"string"},"summary":{"type":"string"},"url":{"type":"string"},"published_at":{"type":"string"},"updated_at":{"type":"string"},"ecosystem":{"type":"string"},"package":{"type":"string"},"affected_range":{"type":"string"},"fixed_version":{"type":"string"},"cwe":{"type":"array","items":{"type":"string"}}},"additionalProperties":true}'::jsonb where code = 'security_advisory';
update taxonomy.entity_kind set description = 'One revision of a protocol (MCP 2026-07-28); status current/final/draft from the versioning page',
  attributes_schema = '{"type":"object","required":["version_label"],"properties":{"version_label":{"type":"string"},"released_on":{"type":"string"},"changelog_url":{"type":"string"},"schema_url":{"type":"string"},"status":{"type":"string","enum":["current","final","draft","deprecated","unknown"]},"deprecates":{"type":"array","items":{"type":"string"}},"highlights":{"type":"array","items":{"type":"string"}}},"additionalProperties":true}'::jsonb where code = 'ai_protocol_version';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","properties":{"auth":{"type":"string"},"tools":{"type":"array","items":{"type":"string"}},"hosting":{"enum":["local","remote","both","unknown"],"type":"string"},"transport":{"type":"array","items":{"type":"string"}},"description":{"type":"string"},"is_official":{"type":"boolean"},"registry_name":{"type":"string"},"namespace":{"type":"string"},"first_party_inferred":{"type":"boolean"},"registry_status":{"type":"string"},"repository_url":{"type":"string"},"website_url":{"type":"string"},"latest_version":{"type":"string"},"package_identifiers":{"type":"array","items":{"type":"string"}}},"additionalProperties":true}'::jsonb where code = 'mcp_server';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","properties":{"registry_kind":{"type":"string"},"api_url":{"type":"string"},"website_url":{"type":"string"},"description":{"type":"string"}},"additionalProperties":true}'::jsonb where code = 'registry';
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['talk','story','media_work']) x), to_kinds = array(select distinct x from unnest(to_kinds || array['paper']) x) where code = 'cites';
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['library_release']) x) where code = 'implements_protocol';
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['library_release','repository']) x) where code = 'affected_by_advisory';

-- §14.7 grammar fix (a): representation-format-only differences are recorded, not counted as content changes
alter table content.unit_change drop constraint if exists unit_change_change_kind_check;
alter table content.unit_change add constraint unit_change_change_kind_check check (change_kind in ('added','removed','attribute_changed','text_changed','moved','format_only'));
comment on column content.unit_change.change_kind is 'added | removed | attribute_changed | text_changed | moved | format_only (same logical key, same normalized content, different representation format: excluded from changes_since by default).';

-- ====================================================================================================== api surface
drop view if exists api.benchmark_scores;
create view api.benchmark_scores as
 select s.id as segment_id, st.subject_entity_id as subject_id, sub.display_name as subject, sub.kind as subject_kind,
    s.ref_entity_id as benchmark_version_id, b.display_name as benchmark_version, coalesce(bb.id, case when b.kind = 'benchmark' then b.id end) as benchmark_id, coalesce(bb.display_name, case when b.kind = 'benchmark' then b.display_name end) as benchmark,
    s.amount as score, s.unit, s.payload->>'harness' as harness, s.payload->>'setting' as setting, s.payload->>'reported_by' as reported_by, s.payload->>'source_kind' as source_kind,
    (s.payload->>'cost_usd')::numeric as cost_usd, s.payload->>'run_date' as run_date, (s.payload->>'n_tasks')::integer as n_tasks, s.payload->>'reasoning_effort' as reasoning_effort, s.payload as conditions,
    lower(s.valid_during) as valid_from, s.k_from as learned_k, s.created_at as observed_at, s.primary_claim_id as claim_id, s.belief, st.scope_key
   from temporal.segment s join temporal.stream st on st.id = s.stream_id join catalog.entity sub on sub.id = st.subject_entity_id
   left join catalog.entity b on b.id = s.ref_entity_id
   left join catalog.relationship vr on vr.from_entity_id = b.id and vr.kind = 'version_of' and vr.k_to is null
   left join catalog.entity bb on bb.id = vr.to_entity_id and bb.kind = 'benchmark'
  where s.tenant_id = util.current_tenant_id() and st.kind = 'benchmark_score' and s.k_to is null;
comment on view api.benchmark_scores is 'L1: current conditioned benchmark scores: subject, benchmark version and parent benchmark, harness, who measured (reported_by), cost, run date, with the claim locator id.';

create or replace view api.benchmarks as
 select b.id as benchmark_id, b.display_name as benchmark, b.slug, b.attributes->>'organizer' as organizer, b.attributes->>'metric' as metric, b.attributes->>'score_type' as score_type, b.attributes->>'domain' as domain, (b.attributes->>'agentic')::boolean as agentic, b.attributes->>'canonical_url' as canonical_url,
    coalesce((select array_agg(v.display_name order by v.display_name) from catalog.relationship r join catalog.entity v on v.id = r.from_entity_id where r.to_entity_id = b.id and r.kind = 'version_of' and r.k_to is null and v.kind = 'benchmark_version'), '{}'::text[]) as versions,
    (select count(*) from api.benchmark_scores sc where sc.benchmark_id = b.id) as score_count,
    (select array_agg(distinct sc.reported_by) from api.benchmark_scores sc where sc.benchmark_id = b.id) as reported_by_kinds
   from catalog.entity b where b.tenant_id = util.current_tenant_id() and b.kind = 'benchmark' and b.lifecycle = 'active';
comment on view api.benchmarks is 'L1: benchmarks with their versions, organizer, metric/score type and how many conditioned scores we hold from which reporters.';

create or replace function api.leaderboard_diff(p_slug text, p_edition_a integer default null, p_edition_b integer default null) returns table(
  change text, subject_label text, entity_id uuid, rank_a integer, rank_b integer, score_a numeric, score_b numeric, conditions jsonb, edition_a integer, edition_b integer, observed_a timestamptz, observed_b timestamptz, board_date_a date, board_date_b date)
language sql stable security definer set search_path = '' as $$
  with l as (select id from ranking.leaderboard where tenant_id = util.current_tenant_id() and slug = p_slug),
  eds as (select ed.* from ranking.leaderboard_edition ed join l on ed.leaderboard_id = l.id),
  ea as (select * from eds where edition_no = coalesce(p_edition_a, (select max(edition_no) from eds where edition_no < coalesce(p_edition_b, (select max(edition_no) from eds))))),
  eb as (select * from eds where edition_no = coalesce(p_edition_b, (select max(edition_no) from eds))),
  a as (select e.* from ranking.leaderboard_entry e join ea on e.edition_id = ea.id),
  b as (select e.* from ranking.leaderboard_entry e join eb on e.edition_id = eb.id)
  select case when a.entity_id is null then 'entered' when b.entity_id is null then 'left' when a.rank <> b.rank then 'moved' when a.score is distinct from b.score then 'score_changed' else 'unchanged' end,
         coalesce(b.subject_label, a.subject_label), coalesce(b.entity_id, a.entity_id), a.rank, b.rank, a.score, b.score, coalesce(b.conditions, a.conditions),
         (select edition_no from ea), (select edition_no from eb), (select observed_at from ea), (select observed_at from eb), (select board_date from ea), (select board_date from eb)
  from a full outer join b on a.entity_id = b.entity_id and coalesce(a.conditions->>'harness','') = coalesce(b.conditions->>'harness','')
  order by coalesce(b.rank, a.rank)
$$;
comment on function api.leaderboard_diff is 'L2: what changed on a leaderboard between two editions (captures): entered, left, moved, score_changed, unchanged; both clocks (board_date vs observed_at).';

create or replace view api.compute_devices as
 select d.id as device_id, d.display_name as device, d.slug, d.attributes->>'vendor' as vendor, d.attributes->>'device_class' as device_class, (d.attributes->>'memory_gb')::numeric as memory_gb, (d.attributes->>'memory_bandwidth_tbps')::numeric as memory_bandwidth_tbps,
    (d.attributes->>'bf16_tflops')::numeric as bf16_tflops, (d.attributes->>'fp8_tflops')::numeric as fp8_tflops, (d.attributes->>'fp4_pflops')::numeric as fp4_pflops, (d.attributes->>'sparse_figures')::boolean as sparse_figures, (d.attributes->>'tdp_w')::numeric as tdp_w,
    d.attributes->>'interconnect' as interconnect, d.attributes->>'form_factor' as form_factor, d.attributes->>'released_on' as released_on, d.attributes->>'spec_url' as spec_url,
    api.names((select array_agg(x.x) from api.related(d.id, 'manufactures', 'incoming') x(x))) as manufacturers,
    (select count(*) from catalog.relationship r where r.to_entity_id = d.id and r.kind = 'runs_on' and r.k_to is null) as offering_count
   from catalog.entity d where d.tenant_id = util.current_tenant_id() and d.kind = 'compute_device' and d.lifecycle = 'active';
comment on view api.compute_devices is 'L1: accelerators and systems with first-party spec attributes (sparse figures flagged) and how many offerings run on them.';

create or replace view api.compute_offerings as
 select o.id as offering_id, o.display_name as offering, o.slug, o.attributes->>'offering_class' as offering_class, o.attributes->>'provider_slug' as provider_slug,
    api.names((select array_agg(x.x) from api.related(o.id, 'provides_compute', 'incoming') x(x))) as providers,
    api.names((select array_agg(x.x) from api.related(o.id, 'runs_on', 'outgoing') x(x))) as devices,
    (o.attributes->>'gpu_count')::integer as gpu_count, (o.attributes->>'vcpu')::numeric as vcpu, (o.attributes->>'memory_gb')::numeric as memory_gb, o.attributes->>'pricing_url' as pricing_url,
    p.meter, p.commitment, p.region, p.amount, p.currency, p.unit, p.per, p.usd_per_gpu_hour, p.valid_from, p.learned_k, p.claim_id
   from catalog.entity o
   left join lateral (
     select s.payload->>'meter' as meter, coalesce(s.payload->>'commitment','unknown') as commitment, s.payload->>'region' as region, s.amount, s.currency, s.unit, s.payload->>'per' as per,
            case when s.unit = 'USD_per_GPU_hour' then s.amount when s.unit in ('USD_per_node_hour','USD_per_hour') and coalesce((s.payload->>'gpu_count')::numeric, (o.attributes->>'gpu_count')::numeric) > 0 then s.amount / coalesce((s.payload->>'gpu_count')::numeric, (o.attributes->>'gpu_count')::numeric) when s.unit = 'USD_per_chip_hour' then s.amount end as usd_per_gpu_hour,
            lower(s.valid_during) as valid_from, s.k_from as learned_k, s.primary_claim_id as claim_id
     from temporal.segment s join temporal.stream st on st.id = s.stream_id where st.subject_entity_id = o.id and st.kind = 'offering_price' and s.k_to is null and (upper_inf(s.valid_during) or upper(s.valid_during) > now())
   ) p on true
  where o.tenant_id = util.current_tenant_id() and o.kind = 'compute_offering' and o.lifecycle = 'active';
comment on view api.compute_offerings is 'L1: compute offerings (instance types, serverless GPUs, sandboxes, TPU slices) with every current price row (meter × commitment × region) normalised to USD per GPU-hour where a GPU count is known.';

create or replace function api.cheapest_compute(p_device text, p_commitment text default 'on_demand', p_at timestamptz default now()) returns table(
  offering text, provider text, offering_class text, region text, commitment text, amount numeric, unit text, usd_per_gpu_hour numeric, gpu_count integer, valid_from timestamptz, learned_k bigint, claim_id uuid, locator_count bigint)
language sql stable security definer set search_path = '' as $$
  select o.display_name, api.names((select array_agg(x.x) from api.related(o.id, 'provides_compute', 'incoming') x(x))), o.attributes->>'offering_class', s.payload->>'region', coalesce(s.payload->>'commitment','unknown'), s.amount, s.unit,
         case when s.unit = 'USD_per_GPU_hour' then s.amount when s.unit in ('USD_per_node_hour','USD_per_hour') and coalesce((s.payload->>'gpu_count')::numeric, (o.attributes->>'gpu_count')::numeric) > 0 then s.amount / coalesce((s.payload->>'gpu_count')::numeric, (o.attributes->>'gpu_count')::numeric) when s.unit = 'USD_per_chip_hour' then s.amount end,
         coalesce((s.payload->>'gpu_count')::integer, (o.attributes->>'gpu_count')::integer), lower(s.valid_during), s.k_from, s.primary_claim_id,
         (select count(*) from evidence.segment_support ss where ss.segment_id = s.id)
  from catalog.entity o join catalog.relationship r on r.from_entity_id = o.id and r.kind = 'runs_on' and r.k_to is null join catalog.entity d on d.id = r.to_entity_id
  join temporal.stream st on st.subject_entity_id = o.id and st.kind = 'offering_price' join temporal.segment s on s.stream_id = st.id
  where o.tenant_id = util.current_tenant_id() and o.kind = 'compute_offering' and (d.slug = p_device or lower(d.display_name) = lower(p_device))
    and s.valid_during @> p_at and (s.k_to is null or s.k_to > (select coalesce(max(knowledge_seq), 0) from temporal.knowledge_batch where recorded_at <= p_at)) and s.k_from <= (select coalesce(max(knowledge_seq), 0) from temporal.knowledge_batch where recorded_at <= p_at)
    and coalesce(s.payload->>'commitment','unknown') = p_commitment and s.payload->>'meter' in ('gpu_hour','instance_hour','node_hour','chip_hour')
  order by 8 nulls last, 6
$$;
comment on function api.cheapest_compute is 'L1→L2: current (or as-of) prices of offerings that run on a device, cheapest per GPU-hour first, with the claim id behind each price; commitment on_demand | spot | preemptible | reserved_*.';

create or replace view api.api_symbols as
 select n.id as node_id, d.id as document_id, d.attributes->>'repository' as repository, d.attributes->>'release_tag' as release_tag, d.attributes->>'package' as package,
    n.attributes->>'qualified_name' as qualified_name, n.attributes->>'kind' as symbol_kind, n.attributes->>'signature' as signature, n.attributes->>'module' as module, (n.attributes->>'is_public')::boolean as is_public, (n.attributes->>'deprecated')::boolean as deprecated,
    n.attributes->>'docstring_head' as docstring_head, n.attributes->>'path' as path, (n.attributes->>'lineno')::integer as lineno,
    (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'release' limit 1) as release_id,
    (select count(*) from content.unit_link l where l.to_node_id = n.id and l.kind = 'documents') as docs_links
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and d.document_type_code = 'api_surface' and n.unit_kind = 'api_symbol';
comment on view api.api_symbols is 'L1: public symbols per repository release (R3), with how many docs sections document each symbol (R4).';

create or replace function api.symbol_changes(p_repository text, p_from_tag text, p_to_tag text) returns table(
  change text, qualified_name text, symbol_kind text, signature_from text, signature_to text, module text, from_node_id uuid, to_node_id uuid)
language sql stable security definer set search_path = '' as $$
  with a as (select * from api.api_symbols where repository = p_repository and release_tag = p_from_tag), b as (select * from api.api_symbols where repository = p_repository and release_tag = p_to_tag)
  select case when a.node_id is null then 'added' when b.node_id is null then 'removed' when a.signature is distinct from b.signature then 'signature_changed' when coalesce(a.deprecated,false) <> coalesce(b.deprecated,false) then 'deprecation_changed' else 'unchanged' end,
         coalesce(b.qualified_name, a.qualified_name), coalesce(b.symbol_kind, a.symbol_kind), a.signature, b.signature, coalesce(b.module, a.module), a.node_id, b.node_id
  from a full outer join b on a.qualified_name = b.qualified_name
  where a.node_id is null or b.node_id is null or a.signature is distinct from b.signature or coalesce(a.deprecated,false) <> coalesce(b.deprecated,false)
  order by 1, 2
$$;
comment on function api.symbol_changes is 'L2: public symbols added, removed, re-signed or (un)deprecated between two releases of a repository: the breaking-change evidence behind modules_affected_by_release.';

create or replace view api.endpoints as
 select n.id as node_id, d.id as document_id, d.canonical_title as api_document, v.version_label, v.published_at, n.attributes->>'method' as method, n.attributes->>'path' as path, n.attributes->>'operation_id' as operation_id, n.attributes->>'summary' as summary,
    n.attributes->'tags' as tags, (n.attributes->>'deprecated')::boolean as deprecated, (n.attributes->>'parameter_count')::integer as parameter_count, n.attributes->>'family' as family, n.logical_key,
    (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'api' limit 1) as api_entity_id
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and d.document_type_code in ('openapi_spec','api_reference') and n.unit_kind = 'endpoint';
comment on view api.endpoints is 'L1: API operations per captured specification version; diff two versions by logical key (method|path) through content.unit_change or api.changes_since.';

create or replace view api.advisories as
 select a.id as advisory_id, a.display_name as advisory, a.attributes->>'ghsa_id' as ghsa_id, a.attributes->>'cve_id' as cve_id, a.attributes->>'severity' as severity, a.attributes->>'summary' as summary, a.attributes->>'url' as url, a.attributes->>'published_at' as published_at,
    r.from_entity_id as software_id, s.display_name as software, s.kind as software_kind, r.properties->>'affected_range' as affected_range, r.properties->>'fixed_version' as fixed_version, r.primary_claim_id as claim_id, r.k_from as learned_k
   from catalog.entity a left join catalog.relationship r on r.to_entity_id = a.id and r.kind = 'affected_by_advisory' and r.k_to is null left join catalog.entity s on s.id = r.from_entity_id
  where a.tenant_id = util.current_tenant_id() and a.kind = 'security_advisory' and a.lifecycle = 'active';
comment on view api.advisories is 'L1: security advisories with the affected software, vulnerable range and first patched version (GHSA records; OSV used only to resolve aliases).';

create or replace function api.advisories_for(p_software text, p_version text default null) returns table(
  ghsa_id text, cve_id text, severity text, summary text, affected_range text, fixed_version text, affects_version boolean, published_at text, url text, claim_id uuid)
language sql stable security definer set search_path = '' as $$
  with v as (select string_to_array(regexp_replace(coalesce(p_version,''), '[^0-9.].*$', ''), '.')::int[] parts)
  select a.ghsa_id, a.cve_id, a.severity, a.summary, a.affected_range, a.fixed_version,
    case when p_version is null then null else (
      -- PEP 440-ish: every comparator in the GHSA range ("<= 1.0.9", ">= 1.2.3, < 1.2.14") must hold for the version
      select bool_and(
        case split_part(trim(c), ' ', 1)
          when '<' then (select parts from v) < string_to_array(regexp_replace(split_part(trim(c), ' ', 2), '[^0-9.].*$', ''), '.')::int[]
          when '<=' then (select parts from v) <= string_to_array(regexp_replace(split_part(trim(c), ' ', 2), '[^0-9.].*$', ''), '.')::int[]
          when '>' then (select parts from v) > string_to_array(regexp_replace(split_part(trim(c), ' ', 2), '[^0-9.].*$', ''), '.')::int[]
          when '>=' then (select parts from v) >= string_to_array(regexp_replace(split_part(trim(c), ' ', 2), '[^0-9.].*$', ''), '.')::int[]
          when '=' then (select parts from v) = string_to_array(regexp_replace(split_part(trim(c), ' ', 2), '[^0-9.].*$', ''), '.')::int[]
          else true end)
      from unnest(string_to_array(a.affected_range, ',')) c) end,
    a.published_at, a.url, a.claim_id
  from api.advisories a
  where a.software_id is not null and (a.software = p_software or exists (select 1 from catalog.entity e where e.id = a.software_id and (e.slug = p_software or lower(e.display_name) = lower(p_software))))
  order by a.published_at desc
$$;
comment on function api.advisories_for is 'L2: advisories affecting a software thing, and whether a given version falls in each vulnerable range (numeric component comparison, not string compare: 1.2.3 < 1.2.14).';

create or replace view api.registry_listings as
 select r.id as relationship_id, s.id as server_id, s.display_name as server, s.attributes->>'namespace' as namespace, (s.attributes->>'first_party_inferred')::boolean as first_party_inferred, s.attributes->'transport' as transports, s.attributes->>'latest_version' as latest_version,
    s.attributes->>'repository_url' as repository_url, s.attributes->>'registry_status' as registry_status, g.display_name as registry, r.properties, r.k_from as learned_k,
    (select seg.status from temporal.stream st join temporal.segment seg on seg.stream_id = st.id where st.subject_relationship_id = r.id and st.kind = 'registry_listing_status' and seg.k_to is null order by lower(seg.valid_during) desc limit 1) as current_status
   from catalog.relationship r join catalog.entity s on s.id = r.from_entity_id join catalog.entity g on g.id = r.to_entity_id
  where r.tenant_id = util.current_tenant_id() and r.kind = 'listed_in' and r.k_to is null and g.kind = 'registry';
comment on view api.registry_listings is 'L1: servers listed in a registry with transports, namespace-inferred first-party flag and the registry''s own status stream (official = registry validation, not vendor status).';

create or replace view api.protocol_versions as
 select v.id as version_id, v.display_name as version, p.display_name as protocol, v.attributes->>'version_label' as version_label, v.attributes->>'released_on' as released_on, v.attributes->>'status' as status, v.attributes->>'changelog_url' as changelog_url, v.attributes->>'schema_url' as schema_url, v.attributes->'deprecates' as deprecates, v.attributes->'highlights' as highlights,
    api.names((select array_agg(x.x) from api.related(v.id, 'implements_protocol', 'incoming') x(x))) as implemented_by
   from catalog.entity v join catalog.relationship r on r.from_entity_id = v.id and r.kind = 'version_of' and r.k_to is null join catalog.entity p on p.id = r.to_entity_id and p.kind = 'ai_protocol'
  where v.tenant_id = util.current_tenant_id() and v.kind = 'ai_protocol_version' and v.lifecycle = 'active';
comment on view api.protocol_versions is 'L1: protocol revisions (MCP) with status, changelog, highlights and the software releases that implement them.';

-- papers: ingestion level as data
drop view if exists api.papers;
create view api.papers as
 select w.id as paper_id, w.title, w.attributes->>'arxiv_id' as arxiv_id, w.attributes->>'doi' as doi, w.published_at, w.canonical_url,
    api.names((select array_agg(x.x) from api.related(w.id, 'authored_by', 'outgoing') x(x))) as authors,
    api.names((select array_agg(x.x) from api.related(w.id, 'published_by', 'outgoing') x(x))) as publishers,
    api.names((select array_agg(x.x) from api.related(w.id, 'has_code', 'outgoing') x(x))) as repositories,
    api.names((select array_agg(x.x) from api.related(w.id, 'introduces_technique', 'outgoing') x(x))) as techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind in ('about','cites') and t.kind = 'talk' and r.k_to is null) as talks_about,
    api.fact_amount(w.id, 'paper_citations') as citations, w.abstract,
    coalesce((select d.attributes->>'ingestion_level' from content.document d where d.work_entity_id = w.id order by d.created_at desc limit 1), 'P0') as ingestion_level,
    (select d.attributes->'promotion' from content.document d where d.work_entity_id = w.id order by d.created_at desc limit 1) as promotion,
    (select d.id from content.document d where d.work_entity_id = w.id order by d.created_at desc limit 1) as document_id,
    w.attributes->>'publication_form' as publication_form
   from catalog.work w join catalog.entity e on e.id = w.id
  where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with authors, code, citing talks and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision.';

-- changes_since: exclude format-only unit changes by default
create or replace function api.changes_since(p_since timestamptz, p_stream_kinds text[] default null, p_entity_kinds text[] default null, p_document_types text[] default null) returns table(
  change_source text, change_kind text, learned_at timestamptz, knowledge_seq bigint, world_from timestamptz, subject_entity_id uuid, subject text, stream_kind text, scope_key text, old_value jsonb, new_value jsonb, document_id uuid, document_title text, logical_key text, unit_kind text, changed_attributes jsonb, claim_id uuid)
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
  where uc.tenant_id = t.id and uc.detected_at > p_since and uc.change_kind <> 'format_only' and (p_document_types is null or d.document_type_code = any(p_document_types))
  order by 3 desc
$$;
comment on function api.changes_since is 'L2 both clocks: facts opened/replaced, events and unit changes learned after p_since; format-only unit changes (same content, different representation format) are excluded (§14.7 fix a).';

grant select on api.benchmark_scores, api.benchmarks, api.compute_devices, api.compute_offerings, api.api_symbols, api.endpoints, api.advisories, api.registry_listings, api.protocol_versions, api.papers
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
grant execute on function api.leaderboard_diff(text, integer, integer), api.cheapest_compute(text, text, timestamptz), api.symbol_changes(text, text, text), api.advisories_for(text, text), api.changes_since(timestamptz, text[], text[], text[])
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
grant select on ranking.leaderboard, ranking.leaderboard_edition, ranking.leaderboard_entry to app_reader, product_api_owner;

-- ---- from draft 20261109130100_build08_loop2_fixups.sql
-- Build 08 loop 2 draft, fixup 1 (in-loop deltas found while the first grammars ran, 2026-11-09):
-- D-17 price rows on compute pages name the device they price (role vocabulary); D-18 per-GB meters (data transfer, drive reads);
-- D-19 content.document is append-only, so a paper's document is linked to its work through content.document_about_entity (role 'work'),
--      and api.papers reads the ingestion level from there; D-20 the aggregator label for who measured.

update content.unit_kind set entity_roles = array['offering','provider','device'] where code = 'price_row' and version = 1;
update content.unit_kind set entity_roles = array['subject','benchmark','leaderboard','harness','publisher','system','device'] where code = 'leaderboard_row' and version = 1;
update temporal.stream_kind set unit_values = array(select distinct x from unnest(unit_values || array['USD_per_GB','USD_per_1K_images']) x) where code = 'offering_price';

drop view if exists api.papers;
create view api.papers as
 with doc as (
   select a.entity_id, d.id as document_id, d.attributes, d.document_type_code, row_number() over (partition by a.entity_id order by d.created_at desc) rn
   from content.document_about_entity a join content.document d on d.id = a.document_id where a.role = 'work'
 )
 select w.id as paper_id, w.title, w.attributes->>'arxiv_id' as arxiv_id, w.attributes->>'doi' as doi, w.published_at, w.canonical_url,
    api.names((select array_agg(x.x) from api.related(w.id, 'authored_by', 'outgoing') x(x))) as authors,
    api.names((select array_agg(x.x) from api.related(w.id, 'published_by', 'outgoing') x(x))) as publishers,
    api.names((select array_agg(x.x) from api.related(w.id, 'has_code', 'outgoing') x(x))) as repositories,
    api.names((select array_agg(x.x) from api.related(w.id, 'introduces_technique', 'outgoing') x(x))) as techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind in ('about','cites') and t.kind = 'talk' and r.k_to is null) as talks_about,
    (select count(*) from catalog.relationship r where r.to_entity_id = w.id and r.kind = 'cites' and r.k_to is null) as cited_by_count,
    api.fact_amount(w.id, 'paper_citations') as citations, w.abstract,
    coalesce(doc.attributes->>'ingestion_level', w.attributes->>'ingestion_level', 'P0') as ingestion_level,
    coalesce(doc.attributes->'promotion', w.attributes->'promotion') as promotion,
    doc.document_id, doc.document_type_code, w.attributes->>'publication_form' as publication_form
   from catalog.work w join catalog.entity e on e.id = w.id left join doc on doc.entity_id = w.id and doc.rn = 1
  where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with authors, code, citing talks/papers and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision (document linked through document_about_entity role work).';
grant select on api.papers to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---- from draft 20261109130200_build08_loop2_fixups2.sql
-- Build 08 loop 2 draft, fixup 2 (2026-11-09): D-19 corrected — content.document_about_entity.role is constrained to
-- primary | secondary | mention, so a paper's document links to its work with role 'primary'; api.papers reads it that way.
-- D-21: benchmark_score may take a paper as its subject when a paper reports aggregate results of its own system
-- (UndoBench's 83.54 % nominal / 46.72 % recovery are the paper's numbers, not a catalogued model's).

drop view if exists api.papers;
create view api.papers as
 with doc as (
   select a.entity_id, d.id as document_id, d.attributes, d.document_type_code, row_number() over (partition by a.entity_id order by d.created_at desc) rn
   from content.document_about_entity a join content.document d on d.id = a.document_id
   where a.role = 'primary' and d.document_type_code in ('arxiv_paper','conference_paper','journal_article','tech_report','model_card','system_card','dataset_card','research_report')
 )
 select w.id as paper_id, w.title, w.attributes->>'arxiv_id' as arxiv_id, w.attributes->>'doi' as doi, w.published_at, w.canonical_url,
    api.names((select array_agg(x.x) from api.related(w.id, 'authored_by', 'outgoing') x(x))) as authors,
    api.names((select array_agg(x.x) from api.related(w.id, 'published_by', 'outgoing') x(x))) as publishers,
    api.names((select array_agg(x.x) from api.related(w.id, 'has_code', 'outgoing') x(x))) as repositories,
    api.names((select array_agg(x.x) from api.related(w.id, 'introduces_technique', 'outgoing') x(x))) as techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind in ('about','cites') and t.kind = 'talk' and r.k_to is null) as talks_about,
    (select count(*) from catalog.relationship r where r.to_entity_id = w.id and r.kind = 'cites' and r.k_to is null) as cited_by_count,
    (select count(*) from catalog.relationship r where r.from_entity_id = w.id and r.kind = 'cites' and r.k_to is null) as cites_count,
    api.fact_amount(w.id, 'paper_citations') as citations, w.abstract,
    coalesce(doc.attributes->>'ingestion_level', w.attributes->>'ingestion_level', 'P0') as ingestion_level,
    coalesce(doc.attributes->'promotion', w.attributes->'promotion') as promotion,
    doc.document_id, doc.document_type_code, w.attributes->>'publication_form' as publication_form
   from catalog.work w join catalog.entity e on e.id = w.id left join doc on doc.entity_id = w.id and doc.rn = 1
  where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision (document linked through document_about_entity role primary).';
grant select on api.papers to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
update temporal.stream_kind set subject_kinds = array(select distinct x from unnest(subject_kinds || array['paper']) x) where code = 'benchmark_score';

-- ---- from draft 20261109130300_build08_loop2_fixups3.sql
-- Build 08 loop 2 draft, fixup 3 (2026-11-09): D-35 the version_of pair check names its pairs explicitly; the new
-- benchmark_version -> benchmark pair joins the list (the pair list is the data-level rule behind taxonomy.relationship_kind.version_of).

create or replace function catalog.check_relationship_kinds() returns trigger language plpgsql set search_path = '' as $$
declare f text; t text; r taxonomy.relationship_kind;
begin
 select kind into strict f from catalog.entity where tenant_id=new.tenant_id and id=new.from_entity_id;
 select kind into strict t from catalog.entity where tenant_id=new.tenant_id and id=new.to_entity_id;
 select * into strict r from taxonomy.relationship_kind where code=new.kind;
 if not(f=any(r.from_kinds)) or not(t=any(r.to_kinds)) then raise exception 'invalid relationship endpoint kinds' using errcode='23514'; end if;
 if new.kind='version_of' and (f,t) not in (('product_version','product'),('ai_model_version','ai_model'),('library_release','library'),('ai_protocol_version','ai_protocol'),('benchmark_version','benchmark')) then raise exception 'invalid version pair' using errcode='23514'; end if;
 return new;
end $$;
comment on function catalog.check_relationship_kinds is 'Relationship endpoints must match the kind vocabulary; version_of pairs are enumerated: product_version→product, ai_model_version→ai_model, library_release→library, ai_protocol_version→ai_protocol, benchmark_version→benchmark (loop 2).';

-- ---- from draft 20261109130400_build08_loop2_fixups4.sql
-- Build 08 loop 2 draft, fixup 4 (2026-11-09): D-36 the structured paper digest of §15.3 P1 needs item kinds beyond loop 1's seven
-- (problem, method, key_result, artifact, practitioner_change); the check constraint is the item-kind vocabulary.

alter table content.digest_item drop constraint if exists digest_item_item_kind_check;
alter table content.digest_item add constraint digest_item_item_kind_check check (item_kind in ('key_point','entity_role','assertion_ref','change','open_question','limitation','research_direction','problem','method','key_result','artifact','practitioner_change'));
comment on column content.digest_item.item_kind is 'key_point | entity_role | assertion_ref | change | open_question | limitation | research_direction | problem | method | key_result | artifact | practitioner_change (the last five are the P1 structured paper digest of Build 08 §15.3).';

-- ---- from draft 20261109130500_build08_loop2_fixups5.sql
-- Build 08 loop 2 draft, fixup 5 (2026-11-10): D-39 a qualified symbol name can appear more than once in one release (typing overloads,
-- property getter/setter pairs), so api.symbol_changes compares one aggregated signature set per name instead of cross-joining duplicates.

create or replace function api.symbol_changes(p_repository text, p_from_tag text, p_to_tag text) returns table(
  change text, qualified_name text, symbol_kind text, signature_from text, signature_to text, module text, from_node_id uuid, to_node_id uuid)
language sql stable security definer set search_path = '' as $$
  with a as (select qualified_name, min(symbol_kind) symbol_kind, string_agg(distinct coalesce(signature, ''), ' || ' order by coalesce(signature, '')) signature, bool_or(coalesce(deprecated, false)) deprecated, min(module) module, min(node_id::text)::uuid node_id
             from api.api_symbols where repository = p_repository and release_tag = p_from_tag group by qualified_name),
       b as (select qualified_name, min(symbol_kind) symbol_kind, string_agg(distinct coalesce(signature, ''), ' || ' order by coalesce(signature, '')) signature, bool_or(coalesce(deprecated, false)) deprecated, min(module) module, min(node_id::text)::uuid node_id
             from api.api_symbols where repository = p_repository and release_tag = p_to_tag group by qualified_name)
  select case when a.node_id is null then 'added' when b.node_id is null then 'removed' when a.signature <> b.signature then 'signature_changed' when a.deprecated <> b.deprecated then 'deprecation_changed' else 'unchanged' end,
         coalesce(b.qualified_name, a.qualified_name), coalesce(b.symbol_kind, a.symbol_kind), a.signature, b.signature, coalesce(b.module, a.module), a.node_id, b.node_id
  from a full outer join b on a.qualified_name = b.qualified_name
  where a.node_id is null or b.node_id is null or a.signature <> b.signature or a.deprecated <> b.deprecated
  order by 1, 2
$$;
comment on function api.symbol_changes is 'L2: public symbols added, removed, re-signed or (un)deprecated between two releases of a repository; overloaded names are compared as one signature set (D-39).';
grant execute on function api.symbol_changes(text, text, text) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

commit;
