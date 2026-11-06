-- Governed Gate 2-3 provenance and faithful chunk-backed vector materialization.
begin;

alter table knowledge_service.review_decision
  add column decision_operation_id uuid,
  add column legacy_provenance boolean not null default false,
  add constraint review_decision_operation_fk
    foreign key (tenant_id,decision_operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;
update knowledge_service.review_decision set legacy_provenance=true where decision_operation_id is null;
alter table knowledge_service.review_decision add constraint review_decision_provenance_required_ck
  check (legacy_provenance or decision_operation_id is not null);

alter table content.representation_decision
  add column knowledge_review_decision_id uuid,
  add column decision_operation_id uuid,
  add column legacy_provenance boolean not null default false,
  add constraint representation_decision_review_fk
    foreign key (tenant_id,knowledge_review_decision_id)
    references knowledge_service.review_decision(tenant_id,id) on delete restrict,
  add constraint representation_decision_operation_fk
    foreign key (tenant_id,decision_operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;
update content.representation_decision set legacy_provenance=true
  where knowledge_review_decision_id is null and decision_operation_id is null;
alter table content.representation_decision add constraint representation_decision_provenance_ck check (
  (legacy_provenance and num_nonnulls(knowledge_review_decision_id,decision_operation_id)=0)
  or (not legacy_provenance and num_nonnulls(knowledge_review_decision_id,decision_operation_id)=2)
);

alter table retrieval.content_promotion_proposal
  add column operation_id uuid,
  add column legacy_provenance boolean not null default false,
  add constraint content_promotion_proposal_operation_fk
    foreign key (tenant_id,operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;
update retrieval.content_promotion_proposal set legacy_provenance=true where operation_id is null;
alter table retrieval.content_promotion_proposal add constraint content_promotion_proposal_provenance_required_ck
  check (legacy_provenance or operation_id is not null);

alter table retrieval.content_promotion_decision
  add column knowledge_review_decision_id uuid,
  add column decision_operation_id uuid,
  add column legacy_provenance boolean not null default false,
  add constraint content_promotion_decision_review_fk
    foreign key (tenant_id,knowledge_review_decision_id)
    references knowledge_service.review_decision(tenant_id,id) on delete restrict,
  add constraint content_promotion_decision_operation_fk
    foreign key (tenant_id,decision_operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;
update retrieval.content_promotion_decision set legacy_provenance=true
  where knowledge_review_decision_id is null and decision_operation_id is null;
alter table retrieval.content_promotion_decision add constraint content_promotion_decision_provenance_ck check (
  (legacy_provenance and num_nonnulls(knowledge_review_decision_id,decision_operation_id)=0)
  or (not legacy_provenance and num_nonnulls(knowledge_review_decision_id,decision_operation_id)=2)
);

alter table retrieval.embedding_run
  add column promotion_decision_id uuid,
  add column legacy_provenance boolean not null default false,
  add constraint embedding_run_operation_fk
    foreign key (tenant_id,operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict,
  add constraint embedding_run_promotion_decision_fk
    foreign key (tenant_id,promotion_decision_id)
    references retrieval.content_promotion_decision(tenant_id,id) on delete restrict;
update retrieval.embedding_run set legacy_provenance=true where operation_id is null or promotion_decision_id is null;
alter table retrieval.embedding_run add constraint embedding_run_provenance_required_ck
  check (legacy_provenance or (operation_id is not null and promotion_decision_id is not null));

alter table retrieval.space_publication
  add column operation_id uuid,
  add column legacy_provenance boolean not null default false,
  add constraint space_publication_operation_fk
    foreign key (tenant_id,operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;
update retrieval.space_publication set legacy_provenance=true where operation_id is null;
alter table retrieval.space_publication add constraint space_publication_provenance_required_ck
  check (legacy_provenance or operation_id is not null);

create table retrieval.search_projection_chunk_support (
  tenant_id uuid not null default util.default_tenant_id(),
  search_projection_id uuid not null,
  ordinal integer not null check (ordinal >= 0),
  chunk_id uuid not null,
  support_kind text not null check (support_kind in ('faithful_source','atomic_support')),
  locator_id uuid references evidence.locator(id) on delete restrict,
  selected_text_sha256 text not null check (selected_text_sha256 ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (tenant_id,search_projection_id,ordinal),
  unique (tenant_id,search_projection_id,chunk_id,support_kind),
  foreign key (tenant_id,search_projection_id)
    references retrieval.search_projection(tenant_id,id) on delete restrict,
  foreign key (tenant_id,chunk_id)
    references retrieval.retrieval_chunk(tenant_id,id) on delete restrict
);

create table retrieval.authorized_publication_execution (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  operation_id uuid not null,
  switch_receipt_id uuid not null,
  action text not null check (action in ('publish','rollback')),
  guarded_sha256 text not null check (guarded_sha256 ~ '^[0-9a-f]{64}$'),
  publisher_identity text not null,
  created_at timestamptz not null default now(),
  unique (tenant_id,id),
  unique (tenant_id,operation_id,switch_receipt_id),
  foreign key (tenant_id,operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict,
  foreign key (tenant_id,switch_receipt_id)
    references retrieval.publication_switch_receipt(tenant_id,id) on delete restrict
);

alter table retrieval.vector_item_embedding_1536
  add column physical_embedding_sha256 text generated always as
    (encode(extensions.digest(embedding::text,'sha256'),'hex')) stored;

create trigger search_projection_chunk_support_immutable
  before update or delete on retrieval.search_projection_chunk_support
  for each row execute function util.reject_mutation();
create trigger authorized_publication_execution_immutable
  before update or delete on retrieval.authorized_publication_execution
  for each row execute function util.reject_mutation();

create function retrieval.reject_new_legacy_governance_provenance() returns trigger
language plpgsql set search_path='' as $$ begin
  if new.legacy_provenance then
    raise exception 'legacy provenance is migration-owned and cannot be asserted for a new row'
      using errcode='insufficient_privilege';
  end if;
  return new;
end $$;
create trigger review_decision_no_new_legacy before insert on knowledge_service.review_decision
  for each row execute function retrieval.reject_new_legacy_governance_provenance();
create trigger representation_decision_no_new_legacy before insert on content.representation_decision
  for each row execute function retrieval.reject_new_legacy_governance_provenance();
create trigger promotion_proposal_no_new_legacy before insert on retrieval.content_promotion_proposal
  for each row execute function retrieval.reject_new_legacy_governance_provenance();
create trigger promotion_decision_no_new_legacy before insert on retrieval.content_promotion_decision
  for each row execute function retrieval.reject_new_legacy_governance_provenance();
create trigger embedding_run_no_new_legacy before insert on retrieval.embedding_run
  for each row execute function retrieval.reject_new_legacy_governance_provenance();
create trigger space_publication_no_new_legacy before insert on retrieval.space_publication
  for each row execute function retrieval.reject_new_legacy_governance_provenance();

alter table retrieval.vector_item add column retrieval_chunk_id uuid;
alter table retrieval.vector_item drop constraint vector_item_exactly_one_source;
drop index retrieval.vector_item_space_idx;
drop index retrieval.vector_item_source_idx;
alter table retrieval.vector_item drop column source_kind;
alter table retrieval.vector_item add column source_kind text generated always as (
  case
    when claim_id is not null then 'claim'
    when technical_problem_id is not null then 'technical_problem'
    when solution_pattern_id is not null then 'solution_pattern'
    when advanced_usage_pattern_id is not null then 'advanced_usage_pattern'
    when implementation_example_id is not null then 'implementation_example'
    when failure_mode_id is not null then 'failure_mode'
    when benchmark_result_id is not null then 'benchmark_result'
    when compatibility_constraint_id is not null then 'compatibility_constraint'
    when operational_practice_id is not null then 'operational_practice'
    when security_consideration_id is not null then 'security_consideration'
    when report_version_id is not null then 'report_version'
    when video_id is not null then 'video'
    when talk_id is not null then 'talk'
    when retrieval_chunk_id is not null then 'retrieval_chunk'
  end
) stored;
alter table retrieval.vector_item add constraint vector_item_exactly_one_source check (
  num_nonnulls(claim_id,technical_problem_id,solution_pattern_id,advanced_usage_pattern_id,
    implementation_example_id,failure_mode_id,benchmark_result_id,compatibility_constraint_id,
    operational_practice_id,security_consideration_id,report_version_id,video_id,talk_id,
    retrieval_chunk_id) = 1
);
alter table retrieval.vector_item add constraint vector_item_retrieval_chunk_fk
  foreign key (tenant_id,retrieval_chunk_id)
  references retrieval.retrieval_chunk(tenant_id,id) on delete restrict;
alter table retrieval.vector_item add constraint vector_item_embedding_item_fk
  foreign key (tenant_id,embedding_item_id)
  references retrieval.embedding_item(tenant_id,id) on delete restrict;
create index vector_item_space_idx on retrieval.vector_item (space_version_id,source_kind);
create index vector_item_source_idx on retrieval.vector_item (source_kind);

create function retrieval.validate_chunk_projection_target(
  p_tenant_id uuid,
  p_chunk_id uuid
) returns boolean language sql stable set search_path='' as $$
  select exists(
    select 1 from retrieval.retrieval_chunk c
    join retrieval.chunk_set cs on cs.tenant_id=c.tenant_id and cs.id=c.chunk_set_id
    join content.document_representation r on r.tenant_id=cs.tenant_id and r.id=cs.representation_id
    join content.representation_decision d on d.tenant_id=r.tenant_id and d.representation_id=r.id
      and d.decision='accept' and (d.expires_at is null or d.expires_at>now())
    where c.tenant_id=p_tenant_id and c.id=p_chunk_id
      and c.lifecycle='active' and c.promotion_state='candidate'
  )
$$;

comment on table retrieval.search_projection_chunk_support is
  'Typed, immutable faithful/atomic support for a purpose-specific search projection.';
comment on column knowledge_service.review_decision.decision_operation_id is
  'Authenticated durable operation that carried the reviewer actor identity.';

alter table retrieval.search_projection_chunk_support enable row level security;
alter table retrieval.search_projection_chunk_support force row level security;
alter table retrieval.authorized_publication_execution enable row level security;
alter table retrieval.authorized_publication_execution force row level security;
create policy bounded_role_access on retrieval.search_projection_chunk_support
  for all to executor_service,control_plane using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
create policy bounded_role_access on retrieval.authorized_publication_execution
  for all to executor_service,control_plane using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
grant select,insert on retrieval.search_projection_chunk_support to executor_service,control_plane;
grant select,insert on retrieval.authorized_publication_execution to executor_service,control_plane;
revoke update,delete on retrieval.search_projection_chunk_support from executor_service,control_plane;
revoke update,delete on retrieval.authorized_publication_execution from executor_service,control_plane;

-- Rollback creates a new immutable publication.  The original six-argument RPC
-- predates durable operation provenance, so replace it with an operation-bound
-- form rather than allowing the generated publication to bypass the gate.
drop function retrieval.rollback_vector_space(uuid,uuid,text,text,text,text);
create function retrieval.rollback_vector_space(
  p_current_publication_id uuid,
  p_target_publication_id uuid,
  p_expected_guarded_sha256 text,
  p_reason text,
  p_actor_identity text,
  p_idempotency_key text,
  p_operation_id uuid
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_tenant uuid := util.current_tenant_id();
  v_current retrieval.space_publication%rowtype;
  v_target retrieval.space_publication%rowtype;
  v_new_publication_id uuid := util.uuidv7();
  v_receipt_id uuid;
begin
  if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
  if coalesce(btrim(p_reason),'') = '' or coalesce(btrim(p_actor_identity),'') = ''
     or coalesce(btrim(p_idempotency_key),'') = '' or p_operation_id is null then
    raise exception 'rollback reason, actor identity, idempotency key, and operation are required' using errcode='invalid_parameter_value';
  end if;
  if not exists(select 1 from knowledge_service.operation o where o.tenant_id=v_tenant and o.id=p_operation_id
      and o.operation_kind='publication_rollback' and o.status in ('running','succeeded')) then
    raise exception 'authorized rollback operation is required' using errcode='insufficient_privilege';
  end if;
  select id into v_receipt_id from retrieval.publication_switch_receipt
    where tenant_id=v_tenant and idempotency_key=p_idempotency_key;
  if v_receipt_id is not null then return v_receipt_id; end if;
  select * into v_current from retrieval.space_publication
    where tenant_id=v_tenant and id=p_current_publication_id and status='published' for update;
  select * into v_target from retrieval.space_publication
    where tenant_id=v_tenant and id=p_target_publication_id
      and vector_store_space_id=v_current.vector_store_space_id for update;
  if v_current.id is null or v_target.id is null or v_current.id=v_target.id then
    raise exception 'current and rollback target publications are invalid' using errcode='object_not_in_prerequisite_state';
  end if;
  if not exists(select 1 from retrieval.content_promotion_decision d
    where d.tenant_id=v_tenant and d.id=v_target.publication_decision_id
      and d.guarded_sha256=p_expected_guarded_sha256 and d.decision='accept') then
    raise exception 'rollback target guarded digest is invalid' using errcode='check_violation';
  end if;

  insert into retrieval.space_publication
    (id,tenant_id,vector_store_space_id,vector_space_version_id,vector_item_manifest_sha256,
     embedding_manifest_sha256,index_manifest_sha256,evaluation_result_id,publication_decision_id,
     predecessor_id,status,expected_item_count,operation_id)
  values (v_new_publication_id,v_tenant,v_target.vector_store_space_id,v_target.vector_space_version_id,
     v_target.vector_item_manifest_sha256,v_target.embedding_manifest_sha256,v_target.index_manifest_sha256,
     v_target.evaluation_result_id,v_target.publication_decision_id,v_current.id,'approved',v_target.expected_item_count,
     p_operation_id);
  update retrieval.space_publication set status='published',published_at=clock_timestamp()
    where tenant_id=v_tenant and id=v_new_publication_id;
  update retrieval.space_publication set status='superseded'
    where tenant_id=v_tenant and id=v_current.id;
  update retrieval.vector_store_space set active_space_version_id=v_target.vector_space_version_id
    where tenant_id=v_tenant and id=v_target.vector_store_space_id;
  update retrieval.vector_space_version set publication_lifecycle='superseded'
    where tenant_id=v_tenant and id=v_current.vector_space_version_id;
  update retrieval.vector_space_version set publication_lifecycle='published',publication_decision_id=v_target.publication_decision_id
    where tenant_id=v_tenant and id=v_target.vector_space_version_id;
  insert into retrieval.publication_switch_receipt
    (tenant_id,vector_store_space_id,from_publication_id,to_publication_id,action,reason,
     guarded_sha256,actor_identity,idempotency_key)
  values(v_tenant,v_target.vector_store_space_id,v_current.id,v_new_publication_id,'rollback',p_reason,
     p_expected_guarded_sha256,p_actor_identity,p_idempotency_key)
  returning id into v_receipt_id;
  return v_receipt_id;
end $$;
revoke all on function retrieval.rollback_vector_space(uuid,uuid,text,text,text,text,uuid) from public,anon,authenticated;
grant execute on function retrieval.rollback_vector_space(uuid,uuid,text,text,text,text,uuid) to executor_service,control_plane,service_role;

commit;
