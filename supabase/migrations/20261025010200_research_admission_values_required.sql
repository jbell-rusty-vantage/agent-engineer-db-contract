-- 20261025010200_research_admission_values_required
-- Sprint V (knowledge_verification 2.4.0, component migration 0007, review finding F2): admit_exact_use now raises
-- NORMALIZED_VALUES_REQUIRED (SQLSTATE 22004) when the decision binds a normalized-values digest and the writer presents
-- none, instead of skipping the comparison. The native AIDB guard maps that refusal to a typed K01 error so the KS
-- executor's classifier never sees a raw 22004: UNRESOLVED_EFFECT (KSA04), the class 20261024010100 already uses for
-- missing inputs. Signatures, grants, the trigger and assert_admitted_use are unchanged (create or replace).
begin;
set local lock_timeout = '15s';

do $$
begin
  if to_regprocedure('knowledge_verification.consume_credential(uuid,text,text,text,timestamptz)') is null then
    raise exception 'KNOWLEDGE_VERIFICATION_COMPONENT_2_4_REQUIRED'
      using hint = 'install @aiengineer/knowledge-db-contract 2.4.0 (knowledge-db install --application ai-engineer) before this migration';
  end if;
end $$;

create or replace function research.require_admitted_use(
  p_tenant uuid, p_use_decision_id text, p_bound_effect_digest text, p_processed_epoch bigint, p_normalized_values_digest text default null
) returns table (authoritative_epoch bigint, effect_key text)
language plpgsql volatile set search_path = '' as $$
declare r record; v_effect_key text;
begin
  if p_tenant is null or coalesce(btrim(p_use_decision_id), '') = '' or p_bound_effect_digest is null or p_processed_epoch is null then
    raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
      detail = 'tenant, use decision id, bound effect digest and processed epoch are all required';
  end if;
  if p_normalized_values_digest is not null and p_normalized_values_digest !~ '^sha256:[0-9a-f]{64}$' then
    raise exception 'EFFECT_CONFLICT' using errcode = 'KSA03', detail = 'malformed normalized values digest';
  end if;
  perform knowledge_verification.assert_tenant(p_tenant);
  begin
    select a.outcome, a.reason, a.authoritative_epoch into r
      from knowledge_verification.admit_exact_use(p_tenant, p_use_decision_id, p_bound_effect_digest, p_processed_epoch, now(),
                                                  p_normalized_values_digest) a;
  exception when null_value_not_allowed then
    if sqlerrm <> 'NORMALIZED_VALUES_REQUIRED' then raise; end if;
    raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
      detail = format('use decision %s binds normalized values; the native writer must present their digest (NORMALIZED_VALUES_REQUIRED)', p_use_decision_id);
  end;
  if r.outcome is distinct from 'admitted' then
    if r.reason in ('STALE_DECISION', 'REVOCATION_EPOCH_STALE', 'INVALIDATION_CLOSURE_INCOMPLETE', 'DECISION_EXPIRED', 'DECISION_INVALIDATED') then
      raise exception 'STALE_DECISION' using errcode = 'KSA01',
        detail = format('admit_exact_use %s/%s; authoritative epoch %s, processed %s', r.outcome, r.reason, r.authoritative_epoch, p_processed_epoch);
    elsif r.reason in ('EFFECT_DIGEST_MISMATCH', 'NORMALIZED_VALUES_MISMATCH') then
      raise exception 'EFFECT_CONFLICT' using errcode = 'KSA03',
        detail = format('admit_exact_use %s: the decision admits a different bound effect or normalized values digest', r.reason);
    elsif r.reason = 'DECISION_NOT_FOUND' then
      raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
        detail = format('no use decision %s in this tenant', p_use_decision_id);
    else
      raise exception 'REVIEW_REQUIRED' using errcode = 'KSA02',
        detail = format('admit_exact_use %s/%s', coalesce(r.outcome, '<none>'), coalesce(r.reason, '<none>'));
    end if;
  end if;
  select e.effect_key into v_effect_key from knowledge_verification.effect e
   where e.tenant_id = p_tenant and e.bound_effect_digest = p_bound_effect_digest
   order by e.created_at, e.effect_key limit 1;
  if v_effect_key is null then
    raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
      detail = 'the admitted bound effect digest has no knowledge_verification.effect row; bind_effect first';
  end if;
  return query select r.authoritative_epoch, v_effect_key;
end $$;
comment on function research.require_admitted_use(uuid, text, text, bigint, text) is
  'Internal checker shared by assert_admitted_use and the use_admission insert trigger: knowledge_verification.admit_exact_use (2.4.0; the normalized values digest is required when the decision binds one) outcome -> typed errors KSA01..KSA04; NORMALIZED_VALUES_REQUIRED -> UNRESOLVED_EFFECT (KSA04).';

commit;
