-- Knowledge model v2: retrieval. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';

create table retrieval.projection_target (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  target_kind text not null check (target_kind in ('entity','record','chunk','claim','summary')),
  entity_id uuid references corpus.entity(id), record_id uuid references knowledge.record(id),
  chunk_id uuid references retrieval.retrieval_chunk(id), claim_id uuid references evidence.claim(id),
  summary_id uuid references content.document_summary(id),
  admitted_at timestamptz not null default now(), retired_at timestamptz,
  check (num_nonnulls(entity_id, record_id, chunk_id, claim_id, summary_id) = 1),
  unique (tenant_id, id),
  unique nulls not distinct (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id));
alter table retrieval.projection_target add check((target_kind='entity' and entity_id is not null) or(target_kind='record' and record_id is not null) or(target_kind='chunk' and chunk_id is not null) or(target_kind='claim' and claim_id is not null) or(target_kind='summary' and summary_id is not null));
alter table retrieval.vector_item add column projection_target_id uuid references retrieval.projection_target(id),add column entity_id uuid,add column entity_kind text,add column secondary_entity_ids uuid[] not null default '{}',add column document_type_code text references content.document_type(code),add column content_kind text not null default 'chunk' check(content_kind in ('chunk','summary','claim','record','profile','timeline','measurement')),add column valid_during tstzrange,add column knowledge_seq bigint,add column assurance_rank smallint,add column start_ms integer,add column end_ms integer,add foreign key(tenant_id,entity_id,entity_kind) references corpus.entity(tenant_id,id,kind);
create index vector_item_entity_idx on retrieval.vector_item(tenant_id,entity_id) where lifecycle='active';
create index vector_item_secondary_gin on retrieval.vector_item using gin(secondary_entity_ids) where lifecycle='active';
create index vector_item_valid_gist on retrieval.vector_item using gist(valid_during) where lifecycle='active';
create index vector_item_type_kind_idx on retrieval.vector_item(tenant_id,document_type_code,content_kind) where lifecycle='active';
alter table retrieval.chunking_procedure_version add column strategy text check(strategy in ('structural_heading','semantic_boundary','transcript_window','code_symbol','table_row')),add column target_tokens integer,add column overlap_tokens integer,add column respect_boundaries boolean not null default true;
create table retrieval.chunk_entity_mention(tenant_id uuid not null default util.current_tenant_id(),chunk_id uuid not null references retrieval.retrieval_chunk(id),entity_id uuid not null references corpus.entity(id),verb text not null check(verb in ('mentions','is_about','defines','compares','demonstrates','quotes','cites','deprecates','recommends')),confidence numeric check(confidence between 0 and 1),method text not null,primary key(tenant_id,chunk_id,entity_id,verb));
create table retrieval.chunk_claim_link(tenant_id uuid not null default util.current_tenant_id(),chunk_id uuid not null references retrieval.retrieval_chunk(id),claim_id uuid not null references evidence.claim(id),verb text not null check(verb in ('supports','challenges','context','asserts','mentions','quotes','explains','qualifies')),primary key(tenant_id,chunk_id,claim_id,verb));
create table retrieval.chunk_relationship_evidence(tenant_id uuid not null default util.current_tenant_id(),chunk_id uuid not null references retrieval.retrieval_chunk(id),relationship_id uuid not null references corpus.relationship(id),verb text not null check(verb in ('supports','challenges','context','dates')),primary key(tenant_id,chunk_id,relationship_id,verb));
insert into retrieval.vector_space(slug,purpose,class) values ('engineering_claims','engineering claims','canonical'),('tool_capabilities','tool capabilities','canonical'),('implementation_examples','implementation examples','canonical'),('paper_case_study_knowledge','paper case study knowledge','canonical'),('entity_profiles','entity profiles','canonical'),('model_capabilities','model capabilities','canonical'),('benchmark_intelligence','benchmark intelligence','canonical'),('entity_timeline','entity timeline','canonical'),('market_intelligence','market intelligence','canonical'),('document_summaries','document summaries','canonical'),('source_native_sections','source native sections','exploratory') on conflict(tenant_id,slug) do nothing;


alter table retrieval.vector_item_embedding_1536 detach partition retrieval.vector_item_embedding_1536_default;
create table retrieval.vector_item_embedding_1536_engineering_claims partition of retrieval.vector_item_embedding_1536 for values in ('engineering_claims');
create index embedding_engineering_claims_hnsw on retrieval.vector_item_embedding_1536_engineering_claims using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_tool_capabilities partition of retrieval.vector_item_embedding_1536 for values in ('tool_capabilities');
create index embedding_tool_capabilities_hnsw on retrieval.vector_item_embedding_1536_tool_capabilities using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_implementation_examples partition of retrieval.vector_item_embedding_1536 for values in ('implementation_examples');
create index embedding_implementation_examples_hnsw on retrieval.vector_item_embedding_1536_implementation_examples using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_paper_case_study_knowledge partition of retrieval.vector_item_embedding_1536 for values in ('paper_case_study_knowledge');
create index embedding_paper_case_study_knowledge_hnsw on retrieval.vector_item_embedding_1536_paper_case_study_knowledge using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_entity_profiles partition of retrieval.vector_item_embedding_1536 for values in ('entity_profiles');
create index embedding_entity_profiles_hnsw on retrieval.vector_item_embedding_1536_entity_profiles using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_model_capabilities partition of retrieval.vector_item_embedding_1536 for values in ('model_capabilities');
create index embedding_model_capabilities_hnsw on retrieval.vector_item_embedding_1536_model_capabilities using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_benchmark_intelligence partition of retrieval.vector_item_embedding_1536 for values in ('benchmark_intelligence');
create index embedding_benchmark_intelligence_hnsw on retrieval.vector_item_embedding_1536_benchmark_intelligence using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_entity_timeline partition of retrieval.vector_item_embedding_1536 for values in ('entity_timeline');
create index embedding_entity_timeline_hnsw on retrieval.vector_item_embedding_1536_entity_timeline using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_market_intelligence partition of retrieval.vector_item_embedding_1536 for values in ('market_intelligence');
create index embedding_market_intelligence_hnsw on retrieval.vector_item_embedding_1536_market_intelligence using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_document_summaries partition of retrieval.vector_item_embedding_1536 for values in ('document_summaries');
create index embedding_document_summaries_hnsw on retrieval.vector_item_embedding_1536_document_summaries using hnsw(embedding extensions.halfvec_cosine_ops);
create table retrieval.vector_item_embedding_1536_source_native_sections partition of retrieval.vector_item_embedding_1536 for values in ('source_native_sections');
create index embedding_source_native_sections_hnsw on retrieval.vector_item_embedding_1536_source_native_sections using hnsw(embedding extensions.halfvec_cosine_ops);
insert into retrieval.vector_item_embedding_1536(tenant_id,vector_space_key,vector_space_version_id,vector_item_id,embedding,embedding_sha256,created_at) select tenant_id,vector_space_key,vector_space_version_id,vector_item_id,embedding,embedding_sha256,created_at from retrieval.vector_item_embedding_1536_default;
drop table retrieval.vector_item_embedding_1536_default;

commit;
