-- Complete the normalized chunk-link, candidate-source and evaluation surfaces
-- while retaining legacy columns for a compatibility window.
begin;

create table retrieval.chunk_entity_mention (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), chunk_id uuid not null,
 entity_target_id uuid not null, mention_role text not null, method text not null, confidence numeric(5,4) check(confidence between 0 and 1),
 verification_state text not null default 'pending', document_node_id uuid, start_offset integer, end_offset integer,
 created_at timestamptz not null default now(), foreign key(tenant_id,chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
 foreign key(tenant_id,entity_target_id) references retrieval.projection_target(tenant_id,id) on delete restrict,
 foreign key(tenant_id,document_node_id) references content.document_node(tenant_id,id) on delete restrict
);
create table retrieval.chunk_claim_link (
 tenant_id uuid not null default util.default_tenant_id(), chunk_id uuid not null, claim_id uuid not null,
 semantic_role text not null check(semantic_role in ('states','supports','challenges','qualifies','summarizes','cites')),
 created_at timestamptz not null default now(), primary key(tenant_id,chunk_id,claim_id,semantic_role),
 foreign key(tenant_id,chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
 foreign key(tenant_id,claim_id) references evidence.claim(tenant_id,id) on delete restrict
);
create table retrieval.chunk_concept_link (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), chunk_id uuid not null,
 concept_target_id uuid not null, role text not null, method text not null, confidence numeric(5,4) check(confidence between 0 and 1),
 verification_state text not null default 'pending', created_at timestamptz not null default now(),
 foreign key(tenant_id,chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
 foreign key(tenant_id,concept_target_id) references retrieval.projection_target(tenant_id,id) on delete restrict
);
create table retrieval.chunk_citation_link (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), chunk_id uuid not null,
 citation_document_id uuid, citation_source_id uuid, citation_marker text not null, resolution_state text not null,
 created_at timestamptz not null default now(), foreign key(tenant_id,chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
 foreign key(tenant_id,citation_document_id) references content.document(tenant_id,id) on delete restrict,
 foreign key(tenant_id,citation_source_id) references evidence.source(tenant_id,id) on delete restrict,
 check(num_nonnulls(citation_document_id,citation_source_id)>=1)
);
create table retrieval.chunk_relationship_evidence (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), chunk_id uuid not null,
 relationship_target_id uuid not null, evidence_role text not null, support_strength numeric(5,4) check(support_strength between 0 and 1),
 verification_decision_id uuid, created_at timestamptz not null default now(),
 foreign key(tenant_id,chunk_id) references retrieval.retrieval_chunk(tenant_id,id) on delete restrict,
 foreign key(tenant_id,relationship_target_id) references retrieval.projection_target(tenant_id,id) on delete restrict
);

alter table retrieval.retrieval_plan add constraint retrieval_plan_tenant_id_uq unique(tenant_id,id);
alter table retrieval.retrieval_run add column tenant_id uuid;
update retrieval.retrieval_run r set tenant_id=p.tenant_id from retrieval.retrieval_plan p where p.id=r.plan_id;
alter table retrieval.retrieval_run alter column tenant_id set not null;
alter table retrieval.retrieval_run alter column tenant_id set default util.default_tenant_id();
alter table retrieval.retrieval_run add constraint retrieval_run_tenant_id_uq unique(tenant_id,id);
alter table retrieval.retrieval_run add constraint retrieval_run_tenant_plan_fk foreign key(tenant_id,plan_id) references retrieval.retrieval_plan(tenant_id,id) on delete restrict;
alter table retrieval.retrieval_candidate add column tenant_id uuid;
update retrieval.retrieval_candidate c set tenant_id=r.tenant_id from retrieval.retrieval_run r where r.id=c.run_id;
alter table retrieval.retrieval_candidate alter column tenant_id set not null;
alter table retrieval.retrieval_candidate alter column tenant_id set default util.default_tenant_id();
alter table retrieval.retrieval_candidate add constraint retrieval_candidate_tenant_id_uq unique(tenant_id,id);
alter table retrieval.retrieval_candidate add constraint retrieval_candidate_tenant_run_fk foreign key(tenant_id,run_id) references retrieval.retrieval_run(tenant_id,id) on delete restrict;
alter table retrieval.evidence_packet add constraint evidence_packet_tenant_id_uq unique(tenant_id,id);
alter table retrieval.evidence_packet add constraint evidence_packet_tenant_run_fk foreign key(tenant_id,run_id) references retrieval.retrieval_run(tenant_id,id) on delete restrict;
alter table retrieval.packet_member add column tenant_id uuid;
update retrieval.packet_member m set tenant_id=p.tenant_id from retrieval.evidence_packet p where p.id=m.packet_id;
alter table retrieval.packet_member alter column tenant_id set not null;
alter table retrieval.packet_member alter column tenant_id set default util.default_tenant_id();
alter table retrieval.packet_member add constraint packet_member_tenant_packet_fk foreign key(tenant_id,packet_id) references retrieval.evidence_packet(tenant_id,id) on delete restrict;
create trigger packet_member_immutable before update or delete on retrieval.packet_member for each row execute function util.reject_mutation();

create table retrieval.retrieval_candidate_source (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), retrieval_candidate_id uuid not null,
 channel text not null check(channel in ('vector','lexical','exact','graph','rerank')), search_projection_id uuid, vector_item_id uuid,
 source_rank integer not null check(source_rank>0), score numeric not null, explanation jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(),
 foreign key(tenant_id,retrieval_candidate_id) references retrieval.retrieval_candidate(tenant_id,id) on delete restrict,
 foreign key(tenant_id,search_projection_id) references retrieval.search_projection(tenant_id,id) on delete restrict,
 foreign key(tenant_id,vector_item_id) references retrieval.vector_item(tenant_id,id) on delete restrict,
 check(num_nonnulls(search_projection_id,vector_item_id)>=1)
);

alter table evaluation.eval_case add column tenant_id uuid;
update evaluation.eval_case c set tenant_id=d.tenant_id from evaluation.eval_dataset d where d.id=c.dataset_id;
alter table evaluation.eval_case alter column tenant_id set not null;
alter table evaluation.eval_case alter column tenant_id set default util.default_tenant_id();
alter table evaluation.eval_case add constraint eval_case_tenant_id_uq unique(tenant_id,id);
alter table evaluation.eval_case add constraint eval_case_tenant_dataset_fk foreign key(tenant_id,dataset_id) references evaluation.eval_dataset(tenant_id,id) on delete restrict;
create table evaluation.eval_case_provenance (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), eval_case_id uuid not null,
 artifact_id uuid, source_capture_id uuid, provenance jsonb not null, created_at timestamptz not null default now(),
 foreign key(tenant_id,eval_case_id) references evaluation.eval_case(tenant_id,id) on delete restrict,
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,source_capture_id) references evidence.source_capture(tenant_id,id) on delete restrict
);
create table evaluation.eval_case_relevance (
 tenant_id uuid not null default util.default_tenant_id(), eval_case_id uuid not null, projection_target_id uuid not null,
 relevance_grade integer not null check(relevance_grade between 0 and 4), rationale text, created_at timestamptz not null default now(),
 primary key(tenant_id,eval_case_id,projection_target_id), foreign key(tenant_id,eval_case_id) references evaluation.eval_case(tenant_id,id) on delete restrict,
 foreign key(tenant_id,projection_target_id) references retrieval.projection_target(tenant_id,id) on delete restrict
);
create table evaluation.eval_case_expected_filter (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), eval_case_id uuid not null,
 filter_kind text not null, expected_filter jsonb not null, hard_constraint boolean not null default true, created_at timestamptz not null default now(),
 foreign key(tenant_id,eval_case_id) references evaluation.eval_case(tenant_id,id) on delete restrict
);
create table evaluation.judge_output (
 id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.default_tenant_id(), eval_run_case_output_id uuid not null,
 grader_version_id uuid not null references evaluation.grader_version(id) on delete restrict, prompt_sha256 text not null check(prompt_sha256 ~ '^[0-9a-f]{64}$'),
 model_identity text not null, schema_version text not null, calibration_identity text, output jsonb not null,
 output_sha256 text not null check(output_sha256 ~ '^[0-9a-f]{64}$'), created_at timestamptz not null default now(),
 foreign key(tenant_id,eval_run_case_output_id) references evaluation.eval_run_case_output(tenant_id,id) on delete restrict
);

do $$ declare r record; begin
 for r in select n.nspname s,c.relname t from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where n.nspname in ('retrieval','evaluation') and c.relname in
  ('chunk_entity_mention','chunk_claim_link','chunk_concept_link','chunk_citation_link','chunk_relationship_evidence','retrieval_candidate_source','eval_case_provenance','eval_case_relevance','eval_case_expected_filter','judge_output')
 loop
  execute format('alter table %I.%I enable row level security',r.s,r.t);
  execute format('create policy bounded_role_access on %I.%I for all to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id())',r.s,r.t);
  execute format('create trigger %I_immutable before update or delete on %I.%I for each row execute function util.reject_mutation()',r.t,r.s,r.t);
 end loop;
end $$;

grant select,insert on retrieval.chunk_entity_mention,retrieval.chunk_claim_link,retrieval.chunk_concept_link,
 retrieval.chunk_citation_link,retrieval.chunk_relationship_evidence,retrieval.retrieval_candidate_source to executor_service;
grant select on evaluation.eval_case_provenance,evaluation.eval_case_relevance,evaluation.eval_case_expected_filter,evaluation.judge_output to executor_service;
grant select,insert on evaluation.eval_case_provenance,evaluation.eval_case_relevance,evaluation.eval_case_expected_filter,evaluation.judge_output to control_plane;
commit;
