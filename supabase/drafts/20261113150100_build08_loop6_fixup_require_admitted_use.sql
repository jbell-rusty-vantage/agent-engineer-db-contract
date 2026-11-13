-- Build 08 loop 6 fixup 1 (D-73): restore the exact-use checker the admission guard calls.
-- R2 (20261108120000) moved research.use_admission, assert_admitted_use, guard_use_admission and require_receipt_admission into
-- `verification` and rewrote their bodies, but research.require_admitted_use was dropped with `drop schema research cascade`;
-- verification.guard_use_admission still called it, so every admission since R2 failed with `schema "research" does not exist`.
-- Same body as 20261024010200, in its new schema.
create or replace function verification.require_admitted_use(
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
  select a.outcome, a.reason, a.authoritative_epoch into r
    from knowledge_verification.admit_exact_use(p_tenant, p_use_decision_id, p_bound_effect_digest, p_processed_epoch, now(),
                                                p_normalized_values_digest) a;
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
comment on function verification.require_admitted_use(uuid, text, text, bigint, text) is
  'Internal checker shared by assert_admitted_use and the use_admission insert trigger: knowledge_verification.admit_exact_use (normalized values digest forwarded) outcome -> typed errors KSA01..KSA04.';

create or replace function verification.guard_use_admission() returns trigger
language plpgsql set search_path = '' as $$
declare c record;
begin
  if new.tenant_id is distinct from util.current_tenant_id() then
    raise exception 'TENANT_MISMATCH' using errcode = 'insufficient_privilege';
  end if;
  select * into c from verification.require_admitted_use(new.tenant_id, new.use_decision_id, new.bound_effect_digest, new.processed_epoch,
                                                       new.normalized_values_digest);
  new.xact_id := pg_current_xact_id()::text::bigint;
  new.authoritative_epoch := c.authoritative_epoch;
  new.effect_key := c.effect_key;
  new.admitted_at := now();
  return new;
end $$;

revoke all on function verification.require_admitted_use(uuid, text, text, bigint, text) from public, anon, authenticated;
grant execute on function verification.require_admitted_use(uuid, text, text, bigint, text) to executor_service;
