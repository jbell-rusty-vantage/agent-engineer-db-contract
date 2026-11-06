-- 0010b | Fix: the evidence gate read a generated column in a BEFORE trigger.
--
-- packet_member.member_kind is GENERATED ALWAYS ... STORED. Generated columns are
-- not computed until after BEFORE-row triggers run, so NEW.member_kind was always
-- NULL inside the gate. The dynamic lookup therefore never found an assurance
-- rank, and every knowledge-record member was rejected -- including records well
-- above the floor.
--
-- Symptom was masked: the "below the floor" case still raised, so the gate looked
-- like it worked. It was rejecting for the wrong reason.
--
-- Fix: derive the kind and id from the NEW columns directly, and never read a
-- generated column from a BEFORE trigger.

begin;

create or replace function retrieval.enforce_evidence_gate() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_status text;
  v_rank   integer;
  v_kind   text;
  v_id     uuid;
  c_floor  constant integer := 20;   -- source_inspection
begin
  if new.claim_id is not null then
    select c.status::text into v_status from evidence.claim c where c.id = new.claim_id;
    if v_status is distinct from 'verified' then
      raise exception 'evidence gate: claim % is %, not verified',
        new.claim_id, coalesce(v_status,'missing')
        using errcode = 'restrict_violation';
    end if;
    return new;
  end if;

  -- Derived here, not read from the generated column, which is not yet populated.
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
    'select al.rank from knowledge.%I r
       join knowledge.assurance_level al on al.code = r.assurance_level
      where r.id = $1', v_kind)
    into v_rank using v_id;

  if v_rank is null or v_rank < c_floor then
    raise exception 'evidence gate: % record % is below the assurance floor (rank %, floor %)',
      v_kind, v_id, coalesce(v_rank, -1), c_floor
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

commit;
