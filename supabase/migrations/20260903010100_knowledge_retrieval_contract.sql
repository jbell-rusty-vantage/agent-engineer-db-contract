-- Knowledge preparation service: stores, chunks, projections, fixed-dimension
-- embeddings, guarded publications, retrieval policies and evaluation records.
begin;

alter table retrieval.vector_space_version add column tenant_id uuid;
update retrieval.vector_space_version v set tenant_id = s.tenant_id
from retrieval.vector_space s where s.id = v.vector_space_id;
alter table retrieval.vector_space_version alter column tenant_id set not null;
alter table retrieval.vector_space_version alter column tenant_id set default util.default_tenant_id();
alter table retrieval.vector_space_version add constraint vector_space_version_tenant_id_uq unique (tenant_id, id);
alter table retrieval.vector_space add constraint vector_space_tenant_id_uq unique (tenant_id, id);
alter table retrieval.vector_space_version add constraint vector_space_version_tenant_space_fk
  foreign key (tenant_id, vector_space_id) references retrieval.vector_space(tenant_id, id) on delete restrict;
alter table retrieval.vector_item add constraint vector_item_tenant_id_uq unique (tenant_id, id);

alter table retrieval.projection_procedure
  add column prompt_schema jsonb not null default '{}'::jsonb,
  add column tokenizer text,
  add column projection_policy jsonb not null default '{}'::jsonb,
  add column implementation_sha256 text,
  add column container_sha256 text;

alter table retrieval.vector_space_version
  add column precision text not null default 'halfvec' check (precision in ('halfvec','vector')),
  add column distance_operator text not null default 'cosine' check (distance_operator in ('cosine','inner_product','l2')),
  add column normalization text not null default 'none',
  add column index_configuration jsonb not null default '{}'::jsonb,
  add column provider_routing_policy jsonb not null default '{}'::jsonb,
  add column publication_lifecycle text not null default 'draft' check (publication_lifecycle in
    ('draft','evaluated','approved','publishing','published','superseded','withdrawn')),
  add column publication_decision_id uuid;

create table retrieval.vector_store (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(),
  owner_identity text not null, store_class text not null check (store_class in ('official','exploratory','user_managed')),
  slug text not null, name text not null, purpose text not null, visibility text not null,
  lifecycle text not null default 'active' check (lifecycle in ('active','suspended','superseded','deleted')),
  quota_profile jsonb not null default '{}'::jsonb, retention_policy jsonb not null default '{}'::jsonb,
  deletion_policy jsonb not null default '{}'::jsonb, created_by_attempt_id uuid, supersedes_id uuid,
  created_at timestamptz not null default now(), unique (tenant_id,id), unique(tenant_id,slug),
  foreign key (tenant_id,created_by_attempt_id) references orchestration.attempt(tenant_id,id) on delete restrict,
  foreign key (tenant_id,supersedes_id) references retrieval.vector_store(tenant_id,id) on delete restrict,
  check (supersedes_id is null or supersedes_id <> id)
);

create table retrieval.vector_store_document (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(),
  vector_store_id uuid not null, document_id uuid not null, document_version_id uuid,
  representation_id uuid, admission_state text not null default 'requested', requested_profile jsonb not null default '{}'::jsonb,
  lifecycle text not null default 'active', tombstone_receipt_id uuid, supersedes_id uuid, created_at timestamptz not null default now(),
  unique(tenant_id,id), foreign key(tenant_id,vector_store_id) references retrieval.vector_store(tenant_id,id) on delete restrict,
  foreign key(tenant_id,document_id) references content.document(tenant_id,id) on delete restrict,
  foreign key(tenant_id,document_version_id) references content.document_version(tenant_id,id) on delete restrict,
  foreign key(tenant_id,representation_id) references content.document_representation(tenant_id,id) on delete restrict,
  foreign key(tenant_id,supersedes_id) references retrieval.vector_store_document(tenant_id,id) on delete restrict,
  check(supersedes_id is null or supersedes_id <> id)
);

create table retrieval.vector_store_space (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(),
  vector_store_id uuid not null, vector_space_id uuid not null, active_space_version_id uuid,
  authority_class text not null check (authority_class in ('official','exploratory','user_managed')), created_at timestamptz not null default now(), unique(tenant_id,id),
  unique(tenant_id,vector_store_id,vector_space_id),
  foreign key(tenant_id,vector_store_id) references retrieval.vector_store(tenant_id,id) on delete restrict,
  foreign key(tenant_id,vector_space_id) references retrieval.vector_space(tenant_id,id) on delete restrict,
  foreign key(tenant_id,active_space_version_id) references retrieval.vector_space_version(tenant_id,id) on delete restrict
);

create function retrieval.validate_vector_store_space_authority() returns trigger language plpgsql set search_path='' as $$
declare parent_class text; begin
 select store_class into parent_class from retrieval.vector_store where tenant_id=new.tenant_id and id=new.vector_store_id;
 if parent_class is null or parent_class<>new.authority_class then
  raise exception 'vector store space authority must match its parent store class' using errcode='check_violation';
 end if;
 return new;
end $$;
create trigger vector_store_space_authority before insert or update of tenant_id,vector_store_id,authority_class
 on retrieval.vector_store_space for each row execute function retrieval.validate_vector_store_space_authority();

create table retrieval.chunking_procedure_version (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(),
  slug text not null, version text not null, capability_version_id uuid references orchestration.capability_version(id) on delete restrict,
  supported_content_classes jsonb not null, tokenizer text not null, schema_contract jsonb not null,
  code_sha256 text not null check(code_sha256 ~ '^[0-9a-f]{64}$'), container_sha256 text,
  defaults jsonb not null default '{}'::jsonb, limits jsonb not null default '{}'::jsonb,
  status text not null check(status in ('candidate','admitted','retired')), created_at timestamptz not null default now(),
  unique(tenant_id,id), unique(tenant_id,slug,version)
);

create table retrieval.chunk_set (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), representation_id uuid not null,
  procedure_version_id uuid not null, frozen_config jsonb not null, tokenizer text not null,
  input_manifest_sha256 text not null check(input_manifest_sha256 ~ '^[0-9a-f]{64}$'),
  output_manifest_sha256 text check(output_manifest_sha256 is null or output_manifest_sha256 ~ '^[0-9a-f]{64}$'),
  chunk_set_sha256 text not null check(chunk_set_sha256 ~ '^[0-9a-f]{64}$'), status text not null default 'queued',
  qa_evaluation_id uuid, promotion_decision_id uuid, supersedes_id uuid, created_at timestamptz not null default now(),
  unique(tenant_id,id), unique(tenant_id,chunk_set_sha256),
  foreign key(tenant_id,representation_id) references content.document_representation(tenant_id,id) on delete restrict,
  foreign key(tenant_id,procedure_version_id) references retrieval.chunking_procedure_version(tenant_id,id) on delete restrict,
  foreign key(tenant_id,supersedes_id) references retrieval.chunk_set(tenant_id,id) on delete restrict,
  check(supersedes_id is null or supersedes_id <> id)
);

create table retrieval.retrieval_chunk (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), chunk_set_id uuid not null,
  ordinal integer not null check(ordinal>=0), parent_chunk_id uuid, source_text text not null, contextual_prefix text not null default '',
  embedding_text text not null, source_text_sha256 text not null check(source_text_sha256 ~ '^[0-9a-f]{64}$'),
  contextual_prefix_sha256 text not null check(contextual_prefix_sha256 ~ '^[0-9a-f]{64}$'),
  embedding_text_sha256 text not null check(embedding_text_sha256 ~ '^[0-9a-f]{64}$'),
  source_token_count integer not null check(source_token_count>=0), embedding_token_count integer not null check(embedding_token_count>=0),
  retrieval_role text not null, language text, promotion_state text not null default 'candidate', lifecycle text not null default 'active',
  created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,chunk_set_id,ordinal),
  foreign key(tenant_id,chunk_set_id) references retrieval.chunk_set(tenant_id,id) on delete restrict,
  foreign key(tenant_id,parent_chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
  check(parent_chunk_id is null or parent_chunk_id<>id)
);

create table retrieval.chunk_span (
  tenant_id uuid not null default util.default_tenant_id(), chunk_id uuid not null, ordinal integer not null check(ordinal>=0),
  document_node_id uuid not null, start_offset integer, end_offset integer, locator_id uuid references evidence.locator(id) on delete restrict,
  selected_text_sha256 text not null check(selected_text_sha256 ~ '^[0-9a-f]{64}$'), created_at timestamptz not null default now(),
  primary key(tenant_id,chunk_id,ordinal), foreign key(tenant_id,chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
  foreign key(tenant_id,document_node_id) references content.document_node(tenant_id,id) on delete restrict,
  check(start_offset is null or start_offset>=0), check(end_offset is null or (start_offset is not null and end_offset>=start_offset))
);

create table retrieval.chunk_edge (
  tenant_id uuid not null default util.default_tenant_id(), from_chunk_id uuid not null, to_chunk_id uuid not null,
  relation_kind text not null check(relation_kind in ('parent_of','overlaps','continues','elaborates','summarizes','same_table','same_code_symbol','cross_references','supersedes')),
  metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(),
  primary key(tenant_id,from_chunk_id,to_chunk_id,relation_kind),
  foreign key(tenant_id,from_chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
  foreign key(tenant_id,to_chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
  check(from_chunk_id<>to_chunk_id)
);

create table retrieval.projection_target (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(),
  target_kind text not null, schema_version integer not null, canonical_table regclass not null, canonical_record_id uuid not null,
  eligibility_validator regprocedure not null, admitted_at timestamptz not null default now(), retired_at timestamptz,
  unique(tenant_id,id), unique(tenant_id,target_kind,canonical_record_id)
);

create table retrieval.search_projection (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), projection_target_id uuid not null,
  projection_procedure_id uuid not null references retrieval.projection_procedure(id) on delete restrict, purpose text not null,
  source_text text not null, contextual_prefix text not null default '', embedding_text text not null,
  source_text_sha256 text not null check(source_text_sha256 ~ '^[0-9a-f]{64}$'),
  contextual_prefix_sha256 text not null check(contextual_prefix_sha256 ~ '^[0-9a-f]{64}$'),
  embedding_text_sha256 text not null check(embedding_text_sha256 ~ '^[0-9a-f]{64}$'), support_manifest jsonb not null default '[]'::jsonb,
  language text, content_kind text not null, visibility text not null, classification text not null, effective_during tstzrange,
  promotion_state text not null default 'candidate', generator_identity text, prompt_schema_version text,
  representation_decision_id uuid, content_promotion_decision_id uuid, created_at timestamptz not null default now(),
  unique(tenant_id,id), unique(tenant_id,projection_target_id,projection_procedure_id,purpose,embedding_text_sha256),
  foreign key(tenant_id,projection_target_id) references retrieval.projection_target(tenant_id,id) on delete restrict,
  foreign key(tenant_id,representation_decision_id) references content.representation_decision(tenant_id,id) on delete restrict
);

create table retrieval.embedding_run (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), vector_space_version_id uuid not null,
 operation_id uuid, adapter_version text not null, gateway_model_slug text not null, provider_route_policy jsonb not null,
 expected_dimensions integer not null, input_manifest_sha256 text not null check(input_manifest_sha256 ~ '^[0-9a-f]{64}$'),
 output_manifest_sha256 text, idempotency_key text not null, status text not null default 'queued', request_id text,
 observed_provider_route text, usage jsonb not null default '{}'::jsonb, latency_ms bigint, retry_history jsonb not null default '[]'::jsonb,
 cost_usd numeric(14,6), receipt jsonb, failure_class text, created_at timestamptz not null default now(), completed_at timestamptz,
 unique(tenant_id,id), unique(tenant_id,idempotency_key), foreign key(tenant_id,vector_space_version_id) references retrieval.vector_space_version(tenant_id,id) on delete restrict
);

create table retrieval.embedding_item (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), embedding_run_id uuid not null,
 search_projection_id uuid not null, input_sha256 text not null check(input_sha256 ~ '^[0-9a-f]{64}$'), output_sha256 text not null check(output_sha256 ~ '^[0-9a-f]{64}$'),
 dimensions integer not null, cache_key text not null, status text not null, provider_metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,embedding_run_id,search_projection_id),
 foreign key(tenant_id,embedding_run_id) references retrieval.embedding_run(tenant_id,id) on delete restrict,
 foreign key(tenant_id,search_projection_id) references retrieval.search_projection(tenant_id,id) on delete restrict
);

alter table retrieval.vector_item add column search_projection_id uuid, add column embedding_item_id uuid,
 add column language text, add column visibility text, add column classification text, add column lifecycle text not null default 'active',
 add column authority_level text, add column freshness_at timestamptz, add column search_text text;
alter table retrieval.vector_item add column search_tsv tsvector generated always as (to_tsvector('simple',coalesce(search_text,''))) stored;
alter table retrieval.vector_item add constraint vector_item_projection_fk foreign key(tenant_id,search_projection_id) references retrieval.search_projection(tenant_id,id) on delete restrict;
alter table retrieval.vector_item add constraint vector_item_tenant_space_version_fk foreign key(tenant_id,space_version_id) references retrieval.vector_space_version(tenant_id,id) on delete restrict;
create index vector_item_search_tsv_idx on retrieval.vector_item using gin(search_tsv);

create table retrieval.vector_item_embedding_1536 (
 tenant_id uuid not null, vector_space_key text not null, vector_space_version_id uuid not null, vector_item_id uuid not null,
 embedding extensions.halfvec(1536) not null, embedding_sha256 text not null check(embedding_sha256 ~ '^[0-9a-f]{64}$'),
 created_at timestamptz not null default now(), primary key(vector_space_key,vector_item_id),
 foreign key(tenant_id,vector_item_id) references retrieval.vector_item(tenant_id,id) on delete restrict,
 foreign key(tenant_id,vector_space_version_id) references retrieval.vector_space_version(tenant_id,id) on delete restrict
) partition by list(vector_space_key);
create table retrieval.vector_item_embedding_1536_default partition of retrieval.vector_item_embedding_1536 default;
create index vector_item_embedding_1536_hnsw on retrieval.vector_item_embedding_1536_default using hnsw(embedding extensions.halfvec_cosine_ops);

create table retrieval.content_promotion_proposal (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), proposal_sha256 text not null check(proposal_sha256 ~ '^[0-9a-f]{64}$'),
 source_manifest jsonb not null, chunk_manifest jsonb not null, projection_manifest jsonb not null, target_domains text[] not null,
 expected_value text not null, risks text[] not null default '{}', exclusions text[] not null default '{}', procedures jsonb not null, reason text not null,
 proposed_by text not null, created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,proposal_sha256)
);
create table retrieval.content_promotion_decision (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), proposal_id uuid not null,
 guarded_sha256 text not null check(guarded_sha256 ~ '^[0-9a-f]{64}$'), decision text not null check(decision in ('accept','reject','defer','request_changes')),
 gates jsonb not null, reviewer_identity text not null, policy_version text not null, rationale text not null, expires_at timestamptz,
 created_at timestamptz not null default now(), unique(tenant_id,id),
 foreign key(tenant_id,proposal_id) references retrieval.content_promotion_proposal(tenant_id,id) on delete restrict
);
alter table retrieval.search_projection add constraint search_projection_promotion_decision_fk
 foreign key(tenant_id,content_promotion_decision_id) references retrieval.content_promotion_decision(tenant_id,id) on delete restrict;

create table retrieval.space_publication (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), vector_store_space_id uuid not null,
 vector_space_version_id uuid not null, vector_item_manifest_sha256 text not null check(vector_item_manifest_sha256 ~ '^[0-9a-f]{64}$'),
 embedding_manifest_sha256 text not null check(embedding_manifest_sha256 ~ '^[0-9a-f]{64}$'), index_manifest_sha256 text not null check(index_manifest_sha256 ~ '^[0-9a-f]{64}$'),
 evaluation_result_id uuid, publication_decision_id uuid not null, predecessor_id uuid, status text not null default 'draft' check(status in ('draft','evaluated','approved','publishing','published','superseded','withdrawn')),
 expected_item_count bigint not null check(expected_item_count>=0), published_at timestamptz, created_at timestamptz not null default now(),
 unique(tenant_id,id), foreign key(tenant_id,vector_store_space_id) references retrieval.vector_store_space(tenant_id,id) on delete restrict,
 foreign key(tenant_id,vector_space_version_id) references retrieval.vector_space_version(tenant_id,id) on delete restrict,
 foreign key(tenant_id,publication_decision_id) references retrieval.content_promotion_decision(tenant_id,id) on delete restrict,
 foreign key(tenant_id,predecessor_id) references retrieval.space_publication(tenant_id,id) on delete restrict,
 check(predecessor_id is null or predecessor_id<>id), check((status='published')=(published_at is not null))
);

create table retrieval.retrieval_policy (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), slug text not null, purpose text not null,
 lifecycle text not null default 'active', created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,slug)
);
create table retrieval.retrieval_policy_version (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), retrieval_policy_id uuid not null,
 version integer not null, policy jsonb not null, policy_schema jsonb not null, policy_sha256 text not null check(policy_sha256 ~ '^[0-9a-f]{64}$'),
 status text not null default 'candidate', created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,retrieval_policy_id,version),
 foreign key(tenant_id,retrieval_policy_id) references retrieval.retrieval_policy(tenant_id,id) on delete restrict
);

-- Evaluation extensions are normalized additions; existing datasets/cases/runs remain canonical.
alter table evaluation.eval_dataset add constraint eval_dataset_tenant_id_uq unique(tenant_id,id);
alter table evaluation.eval_run add constraint eval_run_tenant_id_uq unique(tenant_id,id);
create table evaluation.eval_dataset_version (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), dataset_id uuid not null,
 version integer not null, manifest_sha256 text not null check(manifest_sha256 ~ '^[0-9a-f]{64}$'), manifest jsonb not null,
 created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,dataset_id,version),
 foreign key(tenant_id,dataset_id) references evaluation.eval_dataset(tenant_id,id) on delete restrict
);
create table evaluation.experiment (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), name text not null, hypothesis text not null,
 dataset_version_id uuid not null, created_at timestamptz not null default now(), unique(tenant_id,id),
 foreign key(tenant_id,dataset_version_id) references evaluation.eval_dataset_version(tenant_id,id) on delete restrict
);
create table evaluation.experiment_arm (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), experiment_id uuid not null,
 name text not null, configuration jsonb not null, is_control boolean not null default false, created_at timestamptz not null default now(),
 unique(tenant_id,id), unique(tenant_id,experiment_id,name), foreign key(tenant_id,experiment_id) references evaluation.experiment(tenant_id,id) on delete restrict
);
create table evaluation.eval_run_case_output (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), eval_run_id uuid not null,
 eval_case_id uuid not null references evaluation.eval_case(id) on delete restrict, plan jsonb, candidates jsonb, packets jsonb, answer jsonb,
 output_sha256 text not null check(output_sha256 ~ '^[0-9a-f]{64}$'), created_at timestamptz not null default now(), unique(tenant_id,id),
 unique(tenant_id,eval_run_id,eval_case_id), foreign key(tenant_id,eval_run_id) references evaluation.eval_run(tenant_id,id) on delete restrict
);
create table evaluation.metric_definition (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), slug text not null, version integer not null,
 metric_kind text not null, definition jsonb not null, created_at timestamptz not null default now(), unique(tenant_id,id), unique(tenant_id,slug,version)
);
create table evaluation.metric_observation (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), metric_definition_id uuid not null,
 eval_run_id uuid not null, eval_case_id uuid references evaluation.eval_case(id) on delete restrict, value numeric, details jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(), foreign key(tenant_id,metric_definition_id) references evaluation.metric_definition(tenant_id,id) on delete restrict,
 foreign key(tenant_id,eval_run_id) references evaluation.eval_run(tenant_id,id) on delete restrict
);
create table evaluation.promotion_gate_version (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), slug text not null, version integer not null,
 definition jsonb not null, definition_sha256 text not null check(definition_sha256 ~ '^[0-9a-f]{64}$'), created_at timestamptz not null default now(),
 unique(tenant_id,id), unique(tenant_id,slug,version)
);
create table evaluation.promotion_gate_result (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), gate_version_id uuid not null,
 eval_run_id uuid not null, passed boolean not null, false_acceptance_count integer not null default 0, observations jsonb not null,
 result_sha256 text not null check(result_sha256 ~ '^[0-9a-f]{64}$'), created_at timestamptz not null default now(), unique(tenant_id,id),
 foreign key(tenant_id,gate_version_id) references evaluation.promotion_gate_version(tenant_id,id) on delete restrict,
 foreign key(tenant_id,eval_run_id) references evaluation.eval_run(tenant_id,id) on delete restrict
);
create table evaluation.regression_baseline (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), name text not null,
 gate_result_id uuid not null, vector_space_version_id uuid, baseline_sha256 text not null check(baseline_sha256 ~ '^[0-9a-f]{64}$'),
 created_at timestamptz not null default now(), unique(tenant_id,id), foreign key(tenant_id,gate_result_id) references evaluation.promotion_gate_result(tenant_id,id) on delete restrict,
 foreign key(tenant_id,vector_space_version_id) references retrieval.vector_space_version(tenant_id,id) on delete restrict
);

create index chunk_set_representation_idx on retrieval.chunk_set(tenant_id,representation_id,created_at desc);
create index retrieval_chunk_set_idx on retrieval.retrieval_chunk(tenant_id,chunk_set_id,ordinal);
create index search_projection_target_idx on retrieval.search_projection(tenant_id,projection_target_id,purpose);
create index embedding_item_cache_idx on retrieval.embedding_item(tenant_id,input_sha256,dimensions) where status='succeeded';
create index publication_current_idx on retrieval.space_publication(tenant_id,vector_store_space_id) where status='published';

do $$ declare r record; begin
 for r in select n.nspname s,c.relname t from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where n.nspname in ('retrieval','evaluation') and c.relname in
  ('vector_store','vector_store_document','vector_store_space','chunking_procedure_version','chunk_set','retrieval_chunk','chunk_span','chunk_edge','projection_target','search_projection','embedding_run','embedding_item','content_promotion_proposal','content_promotion_decision','space_publication','retrieval_policy','retrieval_policy_version','eval_dataset_version','experiment','experiment_arm','eval_run_case_output','metric_definition','metric_observation','promotion_gate_version','promotion_gate_result','regression_baseline')
 loop execute format('create trigger %I_immutable before update or delete on %I.%I for each row execute function util.reject_mutation()',r.t,r.s,r.t); end loop;
end $$;

comment on table retrieval.vector_item_embedding_1536 is 'Canonical fixed-dimension pgvector storage; legacy vector_item.embedding is compatibility-only.';
commit;
