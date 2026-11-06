-- Bind every canonical evidence-packet subject to the packet tenant.
begin;

alter table knowledge.technical_problem add constraint technical_problem_tenant_id_uq unique(tenant_id,id);
alter table knowledge.solution_pattern add constraint solution_pattern_tenant_id_uq unique(tenant_id,id);
alter table knowledge.advanced_usage_pattern add constraint advanced_usage_pattern_tenant_id_uq unique(tenant_id,id);
alter table knowledge.implementation_example add constraint implementation_example_tenant_id_uq unique(tenant_id,id);
alter table knowledge.failure_mode add constraint failure_mode_tenant_id_uq unique(tenant_id,id);
alter table knowledge.benchmark_result add constraint benchmark_result_tenant_id_uq unique(tenant_id,id);
alter table knowledge.compatibility_constraint add constraint compatibility_constraint_tenant_id_uq unique(tenant_id,id);
alter table knowledge.operational_practice add constraint operational_practice_tenant_id_uq unique(tenant_id,id);
alter table knowledge.security_consideration add constraint security_consideration_tenant_id_uq unique(tenant_id,id);

alter table retrieval.packet_member
  drop constraint packet_member_claim_id_fkey,
  drop constraint packet_member_technical_problem_id_fkey,
  drop constraint packet_member_solution_pattern_id_fkey,
  drop constraint packet_member_advanced_usage_pattern_id_fkey,
  drop constraint packet_member_implementation_example_id_fkey,
  drop constraint packet_member_failure_mode_id_fkey,
  drop constraint packet_member_benchmark_result_id_fkey,
  drop constraint packet_member_compatibility_constraint_id_fkey,
  drop constraint packet_member_operational_practice_id_fkey,
  drop constraint packet_member_security_consideration_id_fkey,
  add constraint packet_member_claim_tenant_fk foreign key(tenant_id,claim_id) references evidence.claim(tenant_id,id) on delete restrict,
  add constraint packet_member_technical_problem_tenant_fk foreign key(tenant_id,technical_problem_id) references knowledge.technical_problem(tenant_id,id) on delete restrict,
  add constraint packet_member_solution_pattern_tenant_fk foreign key(tenant_id,solution_pattern_id) references knowledge.solution_pattern(tenant_id,id) on delete restrict,
  add constraint packet_member_advanced_usage_pattern_tenant_fk foreign key(tenant_id,advanced_usage_pattern_id) references knowledge.advanced_usage_pattern(tenant_id,id) on delete restrict,
  add constraint packet_member_implementation_example_tenant_fk foreign key(tenant_id,implementation_example_id) references knowledge.implementation_example(tenant_id,id) on delete restrict,
  add constraint packet_member_failure_mode_tenant_fk foreign key(tenant_id,failure_mode_id) references knowledge.failure_mode(tenant_id,id) on delete restrict,
  add constraint packet_member_benchmark_result_tenant_fk foreign key(tenant_id,benchmark_result_id) references knowledge.benchmark_result(tenant_id,id) on delete restrict,
  add constraint packet_member_compatibility_constraint_tenant_fk foreign key(tenant_id,compatibility_constraint_id) references knowledge.compatibility_constraint(tenant_id,id) on delete restrict,
  add constraint packet_member_operational_practice_tenant_fk foreign key(tenant_id,operational_practice_id) references knowledge.operational_practice(tenant_id,id) on delete restrict,
  add constraint packet_member_security_consideration_tenant_fk foreign key(tenant_id,security_consideration_id) references knowledge.security_consideration(tenant_id,id) on delete restrict;

create or replace function retrieval.enforce_evidence_gate() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_status text; v_rank integer; v_kind text; v_id uuid;
  v_representation_class text; v_acceptance_state text; v_source_native_byte_identical boolean;
  c_floor constant integer := 20;
begin
  if new.claim_id is not null then
    select c.status::text into v_status from evidence.claim c where c.tenant_id=new.tenant_id and c.id=new.claim_id;
    if v_status is distinct from 'verified' then raise exception 'evidence gate: claim % is %, not verified',new.claim_id,coalesce(v_status,'missing') using errcode='restrict_violation'; end if;
    return new;
  end if;
  if new.source_representation_id is not null then
    select r.representation_class,r.acceptance_state,r.source_native_byte_identical into v_representation_class,v_acceptance_state,v_source_native_byte_identical
      from content.document_representation r where r.tenant_id=new.tenant_id and r.id=new.source_representation_id;
    if v_acceptance_state is distinct from 'accepted' then raise exception 'evidence gate: source representation % is %, not accepted',new.source_representation_id,coalesce(v_acceptance_state,'missing') using errcode='restrict_violation'; end if;
    if v_representation_class not in ('source_native','faithful_normalization') then raise exception 'evidence gate: representation class % is not source-faithful',v_representation_class using errcode='restrict_violation'; end if;
    if v_representation_class='source_native' and v_source_native_byte_identical is distinct from true then raise exception 'evidence gate: source-native representation % is not byte-identical',new.source_representation_id using errcode='restrict_violation'; end if;
    return new;
  end if;
  select k,i into v_kind,v_id from (values
    ('technical_problem',new.technical_problem_id),('solution_pattern',new.solution_pattern_id),('advanced_usage_pattern',new.advanced_usage_pattern_id),
    ('implementation_example',new.implementation_example_id),('failure_mode',new.failure_mode_id),('benchmark_result',new.benchmark_result_id),
    ('compatibility_constraint',new.compatibility_constraint_id),('operational_practice',new.operational_practice_id),('security_consideration',new.security_consideration_id)
  ) as t(k,i) where i is not null limit 1;
  if v_kind is null then raise exception 'evidence gate: packet member has no resolvable subject' using errcode='restrict_violation'; end if;
  execute format('select al.rank from knowledge.%I r join knowledge.assurance_level al on al.code=r.assurance_level where r.tenant_id=$1 and r.id=$2',v_kind)
    into v_rank using new.tenant_id,v_id;
  if v_rank is null or v_rank<c_floor then raise exception 'evidence gate: % record % is below the assurance floor (rank %, floor %)',v_kind,v_id,coalesce(v_rank,-1),c_floor using errcode='restrict_violation'; end if;
  return new;
end;
$$;

commit;
