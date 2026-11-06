-- Permit faithful source-only evidence to be materialized without inventing a
-- canonical knowledge record. The representation is the member target; an
-- optional document node narrows it to a source section.
begin;

alter table content.document_node
  add constraint document_node_tenant_representation_id_uq
  unique (tenant_id, representation_id, id);

alter table retrieval.packet_member
  drop constraint packet_member_exactly_one,
  drop column member_kind,
  add column source_representation_id uuid,
  add column source_document_node_id uuid,
  add column member_kind text generated always as (
    case
      when claim_id                    is not null then 'claim'
      when technical_problem_id        is not null then 'technical_problem'
      when solution_pattern_id         is not null then 'solution_pattern'
      when advanced_usage_pattern_id   is not null then 'advanced_usage_pattern'
      when implementation_example_id   is not null then 'implementation_example'
      when failure_mode_id             is not null then 'failure_mode'
      when benchmark_result_id         is not null then 'benchmark_result'
      when compatibility_constraint_id is not null then 'compatibility_constraint'
      when operational_practice_id     is not null then 'operational_practice'
      when security_consideration_id   is not null then 'security_consideration'
      when source_representation_id    is not null then 'source_representation'
    end
  ) stored,
  add constraint packet_member_exactly_one check (
    num_nonnulls(
      claim_id, technical_problem_id, solution_pattern_id,
      advanced_usage_pattern_id, implementation_example_id, failure_mode_id,
      benchmark_result_id, compatibility_constraint_id, operational_practice_id,
      security_consideration_id, source_representation_id
    ) = 1
  ),
  add constraint packet_member_source_node_requires_representation_ck check (
    source_document_node_id is null or source_representation_id is not null
  ),
  add constraint packet_member_source_representation_fk
    foreign key (tenant_id, source_representation_id)
    references content.document_representation(tenant_id, id) on delete restrict,
  add constraint packet_member_source_document_node_fk
    foreign key (tenant_id, source_representation_id, source_document_node_id)
    references content.document_node(tenant_id, representation_id, id) on delete restrict;

create index packet_member_source_representation_idx
  on retrieval.packet_member(tenant_id, source_representation_id)
  where source_representation_id is not null;

create index packet_member_source_document_node_idx
  on retrieval.packet_member(tenant_id, source_document_node_id)
  where source_document_node_id is not null;

create or replace function retrieval.enforce_evidence_gate() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_status               text;
  v_rank                 integer;
  v_kind                 text;
  v_id                   uuid;
  v_representation_class text;
  v_acceptance_state     text;
  v_source_native_byte_identical boolean;
  c_floor constant integer := 20; -- source_inspection
begin
  if new.claim_id is not null then
    select c.status::text into v_status
      from evidence.claim c
     where c.id = new.claim_id;
    if v_status is distinct from 'verified' then
      raise exception 'evidence gate: claim % is %, not verified',
        new.claim_id, coalesce(v_status, 'missing')
        using errcode = 'restrict_violation';
    end if;
    return new;
  end if;

  if new.source_representation_id is not null then
    select r.representation_class, r.acceptance_state, r.source_native_byte_identical
      into v_representation_class, v_acceptance_state, v_source_native_byte_identical
      from content.document_representation r
     where r.tenant_id = new.tenant_id
       and r.id = new.source_representation_id;

    if v_acceptance_state is distinct from 'accepted' then
      raise exception 'evidence gate: source representation % is %, not accepted',
        new.source_representation_id, coalesce(v_acceptance_state, 'missing')
        using errcode = 'restrict_violation';
    end if;

    if v_representation_class not in ('source_native', 'faithful_normalization') then
      raise exception 'evidence gate: representation class % is not source-faithful',
        v_representation_class
        using errcode = 'restrict_violation';
    end if;
    if v_representation_class = 'source_native'
       and v_source_native_byte_identical is distinct from true then
      raise exception 'evidence gate: source-native representation % is not byte-identical',
        new.source_representation_id
        using errcode = 'restrict_violation';
    end if;
    return new;
  end if;

  -- Derive this directly: generated columns are not populated in BEFORE triggers.
  select k, i into v_kind, v_id from (values
    ('technical_problem',        new.technical_problem_id),
    ('solution_pattern',         new.solution_pattern_id),
    ('advanced_usage_pattern',   new.advanced_usage_pattern_id),
    ('implementation_example',   new.implementation_example_id),
    ('failure_mode',             new.failure_mode_id),
    ('benchmark_result',         new.benchmark_result_id),
    ('compatibility_constraint', new.compatibility_constraint_id),
    ('operational_practice',     new.operational_practice_id),
    ('security_consideration',   new.security_consideration_id)
  ) as t(k, i) where i is not null limit 1;

  if v_kind is null then
    raise exception 'evidence gate: packet member has no resolvable subject'
      using errcode = 'restrict_violation';
  end if;

  execute format(
    'select al.rank from knowledge.%I r join knowledge.assurance_level al on al.code = r.assurance_level where r.id = $1',
    v_kind)
    into v_rank
    using v_id;

  if v_rank is null or v_rank < c_floor then
    raise exception 'evidence gate: % record % is below the assurance floor (rank %, floor %)',
      v_kind, v_id, coalesce(v_rank, -1), c_floor
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

comment on column retrieval.packet_member.source_representation_id is
  'Tenant-scoped authoritative source-only member target. The evidence gate accepts faithful_normalization or byte-identical source_native representations in the accepted state.';
comment on column retrieval.packet_member.source_document_node_id is
  'Optional section identity; the composite FK requires this node to belong to source_representation_id.';

commit;
