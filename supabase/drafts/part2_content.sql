-- Build 08 R2 draft. Part 2: honest acquisition, document axes, open-world kinds, census, unit grammar, typed units, diffs, bridge, digests.

-- ---------------------------------------------------------------------------------------------- 7. acquisition: the fetch ledger (F-25 honest capture provenance)
create schema if not exists acquisition;
comment on schema acquisition is 'How bytes were obtained: every product/harness/mission fetch is a ledger row before it becomes an evidence.source_capture. Search/provider attempts stay in evidence until the KS executor moves (deferred).';
create table acquisition.fetch (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  origin_kind text not null check (origin_kind in ('native_harness','mission_invocation','product_user','scheduled_refresh','manual_upload')),
  origin_label text not null,
  actor_principal_id uuid,
  mc_mission_id text,
  mc_run_id text,
  tool text not null check (tool in ('http','firecrawl','browser','api','repository','upload','youtube_transcript','other')),
  tool_version text,
  request_url text not null,
  final_url text,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  http_status integer,
  outcome text not null check (outcome in ('captured','unchanged','failed','blocked','skipped')),
  content_sha256 text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  media_type text,
  size_bytes bigint check (size_bytes is null or size_bytes >= 0),
  credits_used numeric,
  cost_usd numeric,
  failure_class text,
  prior_capture_id uuid references evidence.source_capture(id),
  notes jsonb not null default '{}'::jsonb
);
comment on table acquisition.fetch is 'One attempt to obtain bytes from a URL: who (origin), with what tool, outcome, hash, spend. unchanged = same bytes as prior_capture_id (no new document version).';
create index fetch_url_idx on acquisition.fetch (tenant_id, request_url, requested_at desc);
alter table evidence.source_capture add column acquisition_fetch_id uuid references acquisition.fetch(id);
alter table evidence.source_capture drop constraint source_capture_exactly_one_producer_ck;
alter table evidence.source_capture add constraint source_capture_exactly_one_producer_ck check (num_nonnulls(produced_by_attempt_id, knowledge_operation_id, acquisition_fetch_id) = 1);
comment on column evidence.source_capture.acquisition_fetch_id is 'Producer when the bytes came from a product/harness fetch (acquisition.fetch) rather than a mission attempt or a KS operation.';
insert into evidence.capture_method(code, description) values ('native_harness_http', 'Fetched by a coding-harness agent over plain HTTPS; provenance in acquisition.fetch') on conflict do nothing;

-- ---------------------------------------------------------------------------------------------- 8. document axes: format x kind x source role
create table content.format (
  code text primary key,
  description text not null,
  default_locator_kinds text[] not null default '{}'
);
comment on table content.format is 'Media/format axis of a captured version: decides the parser and the locator kinds (page+bbox, timecode, table cell, JSON pointer, line range).';
insert into content.format(code, description, default_locator_kinds) values
  ('html', 'HTML page', '{text_quote,html,table}'),
  ('markdown', 'Markdown text (including rendered .md of a talk page)', '{text_quote,character_position}'),
  ('pdf', 'PDF document', '{pdf_text,bounding_box,table}'),
  ('json', 'Machine-structured JSON or API record', '{json_pointer,api_record}'),
  ('timed_text', 'Timestamped transcript/captions', '{media_timecode,text_quote}'),
  ('code', 'Source code or notebook', '{repository,character_position}'),
  ('tabular', 'CSV/Parquet/spreadsheet', '{table,dataset}'),
  ('slides', 'Slide deck', '{bounding_box,pdf_text}'),
  ('video', 'Video file or page', '{media_timecode,media_region}'),
  ('audio', 'Audio', '{media_timecode}'),
  ('image', 'Image/diagram/screenshot', '{bounding_box,media_region}'),
  ('text', 'Plain text', '{text_quote,character_position}'),
  ('archive', 'Archive/bundle', '{repository}'),
  ('unknown', 'Not yet determined', '{}');

create table content.source_role (
  code text primary key,
  description text not null,
  authority_rank smallint not null,
  default_source_tier smallint not null check (default_source_tier between 0 and 4)
);
comment on table content.source_role is 'Who speaks: first party about itself, filer, academic, registry, third-party editorial, community, our own content, system. Feeds attribution/authority and the source tier.';
insert into content.source_role(code, description, authority_rank, default_source_tier) values
  ('first_party', 'The vendor/author about its own product, model, price or release', 90, 2),
  ('filer', 'A regulated filer about itself (SEC, patent office)', 90, 2),
  ('academic', 'Peer-reviewed or preprint research', 80, 2),
  ('event_organizer', 'Conference organizer publishing session metadata and talk pages', 75, 2),
  ('registry', 'Registry/aggregator records (package index, model hub, MCP registry, leaderboard)', 70, 2),
  ('third_party_editorial', 'Press, analysts, newsletters, blogs restating facts', 50, 3),
  ('community', 'Forums, social posts, Q&A, chat exports', 40, 3),
  ('own', 'Our courses, guides, reports and dataset cards', 60, 1),
  ('system', 'Generated by this system (digests, profiles, timelines)', 30, 1),
  ('unknown', 'Not yet classified', 10, 3);

alter table content.document_type
  add column status text not null default 'active' check (status in ('candidate','active','retired')),
  add column axis_note text,
  add column promoted_from_census boolean not null default false;
comment on column content.document_type.status is 'Open-world kinds: candidate (seen in census, grammar not settled), active, retired. unclassified is always valid.';
alter table content.document_type drop constraint document_type_family_check;
alter table content.document_type add constraint document_type_family_check check (family in ('regulatory_filing','research','vendor','code','media_transcript','editorial','market','registry','system_generated','event_media','own','unknown'));
insert into content.document_type(code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time, status) values
  ('unclassified', 'unknown', 'Kind not assigned yet; universal units and census only; promotion candidate', false, 'section', '{}', '{units}', '{abstract}', null, false, 'active'),
  ('aie_talk', 'event_media', 'An ai.engineer talk page: write-up, resources, slides with timecodes and a timestamped transcript without speaker labels, plus its sessions.json record', true, 'transcript_window', '{claim,entity,relationship}', '{units,digests}', '{abstract,key_claims,timeline}', 'talk', true, 'active'),
  ('framework_docs_page', 'vendor', 'A framework/library documentation page (concepts, API usage, examples, version notes)', true, 'section', '{claim,entity}', '{units}', '{technical}', null, false, 'active'),
  ('github_release', 'code', 'A GitHub release entry (tag, date, notes, breaking changes)', true, 'section', '{claim,entity,relationship}', '{units}', '{key_claims}', null, true, 'active'),
  ('course_module', 'own', 'Our own course module/lesson/guide revision (authoring.work_revision) projected as tier-1 content', true, 'section', '{entity}', '{own_content}', '{abstract}', null, false, 'active'),
  ('guide', 'own', 'Our own setup/development guide', true, 'section', '{entity}', '{own_content}', '{abstract}', null, false, 'active')
on conflict (code) do nothing;
update content.document_type set description = 'Vendor pricing page: plan sections and price rows per offering/meter/tier/region; first-party about itself' where code = 'pricing_page';

alter table content.document_version add column format_code text references content.format(code);
comment on column content.document_version.format_code is 'Format axis of this captured version (content.format).';
alter table content.document
  add column source_role_code text references content.source_role(code),
  add column source_role_method text check (source_role_method in ('rule','model','person','default')),
  add column attributes jsonb not null default '{}'::jsonb;
comment on column content.document.source_role_code is 'Source-role axis: who speaks (content.source_role); set by rule (URL/publisher), model or person.';

create table content.document_kind_assignment (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  document_type_code text not null references content.document_type(code),
  method text not null check (method in ('rule','model','person','census')),
  confidence numeric check (confidence between 0 and 1),
  rationale text,
  assigned_at timestamptz not null default now(),
  superseded_by_id uuid references content.document_kind_assignment(id),
  foreign key (tenant_id, document_id) references content.document(tenant_id, id) on delete restrict
);
comment on table content.document_kind_assignment is 'Append-only kind assignments of a document (open world): the current one has superseded_by_id null; document.document_type_code is the initial assignment.';
create index document_kind_assignment_current_idx on content.document_kind_assignment (tenant_id, document_id) where superseded_by_id is null;
create or replace function content.current_kind(p_document uuid) returns text language sql stable set search_path = '' as $$
  select coalesce((select a.document_type_code from content.document_kind_assignment a where a.document_id = p_document and a.superseded_by_id is null order by a.assigned_at desc limit 1),
                  (select d.document_type_code from content.document d where d.id = p_document))
$$;

-- ---------------------------------------------------------------------------------------------- 9. structure census (cheap, deterministic, before any grammar)
create table content.structure_census (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  representation_id uuid not null,
  census_version text not null,
  format_code text not null references content.format(code),
  counts jsonb not null,
  signatures jsonb not null default '{}'::jsonb,
  language text,
  digest text not null check (digest ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  unique (tenant_id, representation_id, census_version),
  constraint structure_census_counts_shape check (extensions.jsonb_matches_schema('{"type":"object","properties":{"headings":{"type":"integer"},"heading_depth":{"type":"integer"},"paragraphs":{"type":"integer"},"tables":{"type":"integer"},"table_rows":{"type":"integer"},"lists":{"type":"integer"},"list_items":{"type":"integer"},"code_blocks":{"type":"integer"},"links":{"type":"integer"},"timecodes":{"type":"integer"},"speaker_labels":{"type":"integer"},"figures":{"type":"integer"},"machine_blocks":{"type":"integer"},"words":{"type":"integer"}},"additionalProperties":true}'::json, counts))
);
comment on table content.structure_census is 'What a captured representation structurally contains (headings, tables, lists, code, timecodes, speakers, figures, machine blocks) before a kind or grammar is assigned. Promotion candidates come from census statistics.';

-- ---------------------------------------------------------------------------------------------- 10. unit grammar as data and typed units
create table content.unit_kind (
  code text not null,
  version integer not null default 1 check (version >= 1),
  status text not null default 'active' check (status in ('candidate','active','retired')),
  description text not null,
  is_universal boolean not null default false,
  applicable_document_types text[],
  parent_kinds text[],
  attributes_schema jsonb not null default '{"type":"object"}'::jsonb,
  logical_key_attributes text[] not null default '{}',
  selector_kind text not null check (selector_kind in ('text_quote','character_position','multi_fragment_text','json_pointer','html','pdf_text','bounding_box','table','repository','dataset','api_record','media_timecode','media_region')),
  retrieval_role text not null default 'embed' check (retrieval_role in ('embed','filter','structure_only')),
  entity_roles text[] not null default '{}',
  primary key (code, version)
);
comment on table content.unit_kind is 'Grammar as data: the typed units a document kind decomposes into, with a JSON Schema for attributes, the attributes forming the logical key (stable across captures), the locator kind and the retrieval role. Universal units apply to every kind.';
insert into content.unit_kind(code, description, is_universal, applicable_document_types, parent_kinds, attributes_schema, logical_key_attributes, selector_kind, retrieval_role, entity_roles) values
  ('document_root', 'Root of a representation tree', true, null, null, '{"type":"object"}', '{}', 'character_position', 'structure_only', '{}'),
  ('section', 'Heading-delimited section', true, null, '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"level":{"type":"integer"},"path":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{}'),
  ('paragraph', 'Prose paragraph', true, null, '{section,document_root,list_item}', '{"type":"object","properties":{"ordinal_in_section":{"type":"integer"}}}', '{}', 'text_quote', 'embed', '{mentions}'),
  ('list', 'Ordered or unordered list', true, null, '{section,document_root}', '{"type":"object","properties":{"ordered":{"type":"boolean"},"items":{"type":"integer"}}}', '{}', 'text_quote', 'structure_only', '{}'),
  ('list_item', 'List item', true, null, '{list}', '{"type":"object","properties":{"ordinal":{"type":"integer"}}}', '{}', 'text_quote', 'embed', '{mentions}'),
  ('table', 'Table with header signature', true, null, '{section,document_root}', '{"type":"object","properties":{"caption":{"type":"string"},"header":{"type":"array","items":{"type":"string"}},"rows":{"type":"integer"}}}', '{header}', 'table', 'structure_only', '{}'),
  ('table_row', 'Table row keyed by its first cell', true, null, '{table}', '{"type":"object","properties":{"row_key":{"type":"string"},"cells":{"type":"array","items":{"type":"string"}}}}', '{row_key}', 'table', 'embed', '{subject}'),
  ('code_block', 'Code block with language', true, null, '{section,list_item,document_root}', '{"type":"object","properties":{"language":{"type":"string"},"lines":{"type":"integer"}}}', '{}', 'character_position', 'embed', '{demonstrates}'),
  ('figure', 'Figure/image with caption', true, null, '{section,document_root}', '{"type":"object","properties":{"caption":{"type":"string"},"src":{"type":"string"}}}', '{}', 'bounding_box', 'embed', '{}'),
  ('media_segment', 'Timed segment of a transcript', true, null, '{document_root,section}', '{"type":"object","required":["t0_ms"],"properties":{"t0_ms":{"type":"integer"},"t1_ms":{"type":"integer"},"speaker":{"type":"string"}}}', '{t0_ms}', 'media_timecode', 'embed', '{speaker,mentions}'),
  ('link', 'Hyperlink with anchor text', true, null, '{paragraph,list_item,section}', '{"type":"object","required":["href"],"properties":{"href":{"type":"string"},"text":{"type":"string"}}}', '{href}', 'text_quote', 'filter', '{references}'),
  ('metadata_field', 'Machine-readable field (frontmatter, JSON key, meta tag)', true, null, '{document_root}', '{"type":"object","required":["key"],"properties":{"key":{"type":"string"},"value":{}}}', '{key}', 'json_pointer', 'filter', '{}'),
  -- pricing_page grammar
  ('plan_section', 'A pricing plan/model family section', false, '{pricing_page}', '{document_root,section}', '{"type":"object","required":["plan"],"properties":{"plan":{"type":"string"},"tier":{"type":"string"}}}', '{plan}', 'text_quote', 'embed', '{offering}'),
  ('price_row', 'One priced meter for an offering', false, '{pricing_page}', '{plan_section,table}', '{"type":"object","required":["offering","meter","amount","currency","unit"],"properties":{"offering":{"type":"string"},"meter":{"type":"string"},"amount":{"type":"number"},"currency":{"type":"string"},"unit":{"type":"string"},"tier":{"type":"string"},"region":{"type":"string"},"condition":{"type":"string"}}}', '{offering,meter,tier,region}', 'table', 'embed', '{offering,provider}'),
  -- changelog / release grammar
  ('release_entry', 'One dated release/version entry', false, '{changelog,release_notes,github_release}', '{document_root,section}', '{"type":"object","required":["version"],"properties":{"version":{"type":"string"},"released_on":{"type":"string"},"title":{"type":"string"},"breaking":{"type":"boolean"},"url":{"type":"string"}}}', '{version}', 'text_quote', 'embed', '{software,release}'),
  ('change_item', 'One change line inside a release entry', false, '{changelog,release_notes,github_release}', '{release_entry,list}', '{"type":"object","required":["kind"],"properties":{"kind":{"type":"string","enum":["added","changed","deprecated","removed","fixed","security","breaking","docs","other"]},"component":{"type":"string"},"ordinal":{"type":"integer"}}}', '{ordinal}', 'text_quote', 'embed', '{software,component,mentions}'),
  -- model/system card grammar
  ('model_card_section', 'Named section of a model/system card or model page', false, '{model_card,system_card,product_page}', '{document_root,section}', '{"type":"object","required":["section_kind"],"properties":{"section_kind":{"type":"string","enum":["overview","capabilities","limitations","safety","evaluation","training","pricing","availability","specifications","other"]},"heading":{"type":"string"}}}', '{section_kind}', 'text_quote', 'embed', '{model}'),
  ('eval_row', 'One benchmark result row', false, '{model_card,system_card,product_page}', '{model_card_section,table}', '{"type":"object","required":["benchmark","score"],"properties":{"benchmark":{"type":"string"},"score":{"type":"number"},"unit":{"type":"string"},"setting":{"type":"string"},"model":{"type":"string"},"comparison_model":{"type":"string"}}}', '{benchmark,setting,model}', 'table', 'embed', '{model,benchmark}'),
  ('spec_field', 'A specification field of a model page (context window, cutoff, modalities, pricing)', false, '{model_card,system_card,product_page}', '{model_card_section,metadata_field,table}', '{"type":"object","required":["field","value"],"properties":{"field":{"type":"string"},"value":{},"unit":{"type":"string"}}}', '{field}', 'text_quote', 'embed', '{model}'),
  -- aie_talk grammar
  ('talk_header', 'Talk title, speakers, track and event fields from the page/sessions record', false, '{aie_talk}', '{document_root}', '{"type":"object","properties":{"title":{"type":"string"},"speakers":{"type":"array","items":{"type":"string"}},"track":{"type":"string"},"event":{"type":"string"},"session_id":{"type":"string"},"video_url":{"type":"string"}}}', '{session_id}', 'json_pointer', 'filter', '{speaker,event}'),
  ('talk_writeup', 'Organizer/AI write-up section of a talk page: claim candidates, never facts', false, '{aie_talk}', '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"path":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{mentions}'),
  ('talk_resource', 'A resource link listed on a talk page (repository, paper, docs)', false, '{aie_talk}', '{document_root,section,list}', '{"type":"object","required":["href"],"properties":{"href":{"type":"string"},"text":{"type":"string"},"resource_kind":{"type":"string","enum":["repository","paper","docs","website","video","slides","other"]}}}', '{href}', 'text_quote', 'filter', '{references}'),
  ('slide', 'A slide with its start timecode', false, '{aie_talk}', '{document_root,section}', '{"type":"object","required":["n","t0_ms"],"properties":{"n":{"type":"integer"},"title":{"type":"string"},"t0_ms":{"type":"integer"}}}', '{n}', 'media_timecode', 'embed', '{}'),
  ('transcript_segment', 'Timestamped transcript window (no speaker labels on ai.engineer pages)', false, '{aie_talk,video_transcript,podcast_transcript}', '{document_root,section}', '{"type":"object","required":["t0_ms"],"properties":{"t0_ms":{"type":"integer"},"t1_ms":{"type":"integer"},"speaker":{"type":"string"},"slide_n":{"type":"integer"}}}', '{t0_ms}', 'media_timecode', 'embed', '{speaker,mentions}'),
  -- framework docs grammar
  ('docs_section', 'Documentation section', false, '{framework_docs_page,official_docs_page,api_reference}', '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"path":{"type":"string"},"version_note":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{software,concept}'),
  ('code_example', 'Code example in docs with language and the API it demonstrates', false, '{framework_docs_page,official_docs_page,repository_readme}', '{docs_section,section}', '{"type":"object","properties":{"language":{"type":"string"},"demonstrates":{"type":"string"},"path":{"type":"string"}}}', '{path,language}', 'character_position', 'embed', '{software,demonstrates}'),
  -- repository readme
  ('readme_section', 'README section', false, '{repository_readme}', '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"path":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{software,concept}'),
  -- news/social
  ('post_paragraph', 'A paragraph of a post/article that may carry claims', false, '{news_article,social_post,thirdparty_blog_post,official_blog_post,analysis_post,newsletter_issue}', '{document_root,section}', '{"type":"object","properties":{"ordinal":{"type":"integer"},"byline":{"type":"string"},"published_at":{"type":"string"}}}', '{ordinal}', 'text_quote', 'embed', '{mentions,quotes}'),
  ('quote', 'A quotation attributed to a speaker', false, '{news_article,social_post,thirdparty_blog_post,official_blog_post,analysis_post,newsletter_issue,aie_talk}', '{post_paragraph,paragraph,transcript_segment}', '{"type":"object","properties":{"speaker":{"type":"string"},"ordinal":{"type":"integer"}}}', '{ordinal}', 'text_quote', 'embed', '{speaker}'),
  -- own content
  ('module_block', 'A block of our own module/lesson/guide revision', false, '{course_module,guide}', '{document_root,section}', '{"type":"object","required":["block_key"],"properties":{"block_key":{"type":"string"},"block_type":{"type":"string"}}}', '{block_key}', 'character_position', 'embed', '{covers,uses}');

alter table content.document_node rename column node_kind to unit_kind;
alter table content.document_node
  add column unit_kind_version integer not null default 1,
  add column attributes jsonb not null default '{}'::jsonb,
  add column logical_key text,
  add column grammar_version text;
alter table content.document_node add constraint document_node_unit_kind_fkey foreign key (unit_kind, unit_kind_version) references content.unit_kind(code, version);
create index document_node_logical_key_idx on content.document_node (tenant_id, logical_key) where logical_key is not null;
create index document_node_unit_kind_idx on content.document_node (tenant_id, unit_kind);
comment on table content.document_node is 'A typed unit of a representation: unit_kind (+version) from content.unit_kind, validated attributes, a logical_key stable across captures (grammar logical key), a stable_local_key within this representation, and typed position (offsets, page, bbox, timecodes).';
comment on column content.document_node.logical_key is 'Grammar logical key: unit_kind + the logical_key_attributes values, so the same unit can be matched across versions for diffs (price_row:gpt-6.1|input_tokens|standard|global).';
create or replace function content.validate_unit_attributes() returns trigger language plpgsql set search_path = '' as $$
declare sch jsonb;
begin
  select attributes_schema into sch from content.unit_kind where code = new.unit_kind and version = new.unit_kind_version;
  if sch is not null and sch <> '{"type":"object"}'::jsonb and not extensions.jsonb_matches_schema(sch::json, new.attributes) then
    raise exception 'unit attributes do not match the %/% schema', new.unit_kind, new.unit_kind_version using errcode = '23514';
  end if;
  return new;
end $$;
create trigger document_node_attributes_valid before insert on content.document_node for each row execute function content.validate_unit_attributes();
alter table content.document_representation add column grammar_version text;
comment on column content.document_representation.grammar_version is 'The grammar (unit_kind set + parser version) that produced this representation''s units; a later grammar never reinterprets old units silently.';

-- ---------------------------------------------------------------------------------------------- 11. refresh: unchanged checks and unit-level changes
create table content.refresh_check (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  prior_version_id uuid not null,
  fetch_id uuid references acquisition.fetch(id),
  checked_at timestamptz not null default now(),
  outcome text not null check (outcome in ('unchanged','changed','failed')),
  content_sha256 text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  new_version_id uuid,
  foreign key (tenant_id, document_id) references content.document(tenant_id, id),
  foreign key (tenant_id, prior_version_id) references content.document_version(tenant_id, id),
  foreign key (tenant_id, new_version_id) references content.document_version(tenant_id, id)
);
comment on table content.refresh_check is 'Each refresh of a document: unchanged (same bytes, no new version), changed (new version created) or failed. This is what a daily refresh writes even when nothing moved.';
create table content.unit_change (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  logical_key text not null,
  unit_kind text not null,
  from_version_id uuid,
  to_version_id uuid not null,
  from_node_id uuid,
  to_node_id uuid,
  change_kind text not null check (change_kind in ('added','removed','attribute_changed','text_changed','moved')),
  changed_attributes jsonb not null default '{}'::jsonb,
  detected_at timestamptz not null default now(),
  refresh_check_id uuid references content.refresh_check(id),
  update_proposal_state text not null default 'none' check (update_proposal_state in ('none','proposed','applied','rejected')),
  foreign key (tenant_id, document_id) references content.document(tenant_id, id),
  foreign key (tenant_id, to_version_id) references content.document_version(tenant_id, id),
  foreign key (tenant_id, from_node_id) references content.document_node(tenant_id, id),
  foreign key (tenant_id, to_node_id) references content.document_node(tenant_id, id)
);
comment on table content.unit_change is 'A unit-level diff between two versions of a document, matched by logical_key: added/removed/attribute_changed/text_changed/moved, with the changed attribute values. Drives update proposals for facts.';
create index unit_change_document_idx on content.unit_change (tenant_id, document_id, detected_at desc);
create index unit_change_detected_idx on content.unit_change (tenant_id, detected_at desc);

-- ---------------------------------------------------------------------------------------------- 12. bridge: unit -> assertion template (act 3 as data) and unit-entity roles
create table content.unit_assertion_mapping (
  id uuid primary key default util.uuidv7(),
  unit_kind text not null,
  unit_kind_version integer not null default 1,
  document_type_code text references content.document_type(code),
  source_role_code text references content.source_role(code),
  target_kind text not null check (target_kind in ('stream','relationship','event','entity_attribute')),
  stream_kind text references temporal.stream_kind(code),
  relationship_kind text references taxonomy.relationship_kind(code),
  event_kind text references temporal.event_kind(code),
  subject_template jsonb not null,
  value_template jsonb not null default '{}'::jsonb,
  qualifier_template jsonb not null default '{}'::jsonb,
  time_template jsonb not null default '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}'::jsonb,
  deterministic boolean not null default true,
  risk_floor text not null default 'L0' check (risk_floor in ('L0','L1','L2','L3')),
  status text not null default 'active' check (status in ('candidate','active','retired')),
  description text not null,
  foreign key (unit_kind, unit_kind_version) references content.unit_kind(code, version),
  constraint mapping_target_consistent check (
    (target_kind = 'stream' and stream_kind is not null) or (target_kind = 'relationship' and relationship_kind is not null)
    or (target_kind = 'event' and event_kind is not null) or (target_kind = 'entity_attribute'))
);
comment on table content.unit_assertion_mapping is 'Declarative act 3: how a unit kind''s attributes become an assertion (stream kind / relationship / event / attribute) with subject, value, qualifier and time templates; deterministic mappings on first-party structured units take the cheap path, others carry a risk floor for KS verification.';
alter table evidence.extraction_record
  add column document_node_id uuid,
  add column mapping_id uuid references content.unit_assertion_mapping(id);
alter table evidence.extraction_record add constraint extraction_record_node_fk foreign key (tenant_id, document_node_id) references content.document_node(tenant_id, id) deferrable initially deferred;
comment on column evidence.extraction_record.document_node_id is 'Act 2 anchor: the typed unit this faithful extraction reads (chunks are derived; units are stable).';
comment on column evidence.extraction_record.mapping_id is 'Act 3 template used to interpret this unit into a claim (content.unit_assertion_mapping).';

create table content.unit_entity_role (
  tenant_id uuid not null default util.default_tenant_id(),
  node_id uuid not null,
  entity_id uuid not null references catalog.entity(id),
  role text not null,
  method text not null check (method in ('rule','model','person','mapping')),
  confidence numeric check (confidence between 0 and 1),
  claim_id uuid references evidence.claim(id),
  created_at timestamptz not null default now(),
  primary key (node_id, entity_id, role),
  foreign key (tenant_id, node_id) references content.document_node(tenant_id, id) on delete restrict
);
comment on table content.unit_entity_role is 'Which entity a unit is about and in what role from the unit kind''s role vocabulary (offering, provider, model, speaker, software, release, mentions ...). Anchored on units, never chunks.';
create index unit_entity_role_entity_idx on content.unit_entity_role (tenant_id, entity_id, role);
create or replace function content.validate_unit_entity_role() returns trigger language plpgsql set search_path = '' as $$
declare roles text[];
begin
  select k.entity_roles into roles from content.document_node n join content.unit_kind k on k.code = n.unit_kind and k.version = n.unit_kind_version where n.id = new.node_id;
  if roles is not null and cardinality(roles) > 0 and not (new.role = any(roles)) then
    raise exception 'role % is not in the unit kind role vocabulary %', new.role, roles using errcode = '23514';
  end if;
  return new;
end $$;
create trigger unit_entity_role_valid before insert or update on content.unit_entity_role for each row execute function content.validate_unit_entity_role();

-- ---------------------------------------------------------------------------------------------- 13. digests: structured, anchored, never evidence
create table content.document_digest (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_version_id uuid not null,
  scope text not null check (scope in ('document','section','entity_view')),
  scope_node_id uuid,
  focus_entity_id uuid references catalog.entity(id),
  digest_schema_version text not null default 'aieng.digest.v1',
  producer_identity text not null,
  producer_kind text not null check (producer_kind in ('deterministic','model','person')),
  transformation_run_id uuid,
  lifecycle text not null default 'active' check (lifecycle in ('active','superseded','withdrawn')),
  created_at timestamptz not null default now(),
  foreign key (tenant_id, document_version_id) references content.document_version(tenant_id, id),
  foreign key (tenant_id, scope_node_id) references content.document_node(tenant_id, id),
  foreign key (tenant_id, transformation_run_id) references content.transformation_run(tenant_id, id),
  constraint digest_section_scope check (scope <> 'section' or scope_node_id is not null),
  constraint digest_entity_scope check (scope <> 'entity_view' or focus_entity_id is not null)
);
comment on table content.document_digest is 'A structured digest of a version (or section/entity view): items are records anchored to units; prose summaries in content.document_summary are renderings of a digest, never evidence.';
create table content.digest_item (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  digest_id uuid not null references content.document_digest(id) on delete restrict,
  ordinal integer not null check (ordinal >= 0),
  item_kind text not null check (item_kind in ('key_point','entity_role','assertion_ref','change','open_question','limitation','research_direction')),
  text text,
  payload jsonb not null default '{}'::jsonb,
  node_ids uuid[] not null default '{}',
  entity_id uuid references catalog.entity(id),
  claim_id uuid references evidence.claim(id),
  unit_change_id uuid references content.unit_change(id),
  confidence numeric check (confidence between 0 and 1),
  unique (digest_id, ordinal)
);
comment on table content.digest_item is 'One digest item: a key point, an entity role, a reference to an assertion/claim, a change, an open question, a limitation or a cautious research direction, each anchored to unit node ids.';
alter table content.document_summary add column digest_id uuid references content.document_digest(id);
comment on column content.document_summary.digest_id is 'The structured digest this prose summary renders; prose without a digest is not evidence.';

-- grants and RLS for the new content/acquisition tables follow the knowledge-side pattern
do $$
declare t text;
begin
  foreach t in array array['acquisition.fetch','content.document_kind_assignment','content.structure_census','content.refresh_check','content.unit_change','content.unit_entity_role','content.document_digest','content.digest_item'] loop
    execute format('alter table %s enable row level security', t);
    execute format('create policy bounded_role_access on %s for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id())', t);
    execute format('grant select on %s to pipeline_agent, verifier_agent, control_plane, app_reader, product_api_owner', t);
    execute format('grant select, insert, update on %s to executor_service', t);
  end loop;
  foreach t in array array['content.format','content.source_role','content.unit_kind','content.unit_assertion_mapping','guidance.item_kind','ranking.leaderboard_entry'] loop
    execute format('grant select on %s to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader, product_api_owner', t);
  end loop;
end $$;
grant usage on schema acquisition, verification, guidance, catalog to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader, product_api_owner;
grant usage on schema content to app_reader;
