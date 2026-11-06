-- 20261024010200_research_admission_normalized_values
-- Sprint V (SV-08 follow-up for knowledge_verification 2.2.0, migration 0005): the AIDB native guard forwards the
-- normalized-values digest to the component's exact-use rule and maps its new reason.
--
-- Component 2.2.0 `admit_exact_use(p_tenant, p_id, p_digest, p_epoch, p_now default now(), p_normalized_values_digest
-- default null)` rejects NORMALIZED_VALUES_MISMATCH when a presented digest differs from the decision's. The native
-- ingestion transaction writes domain values, so it presents their digest here; null keeps the 2.1.0 call shape (the
-- component then skips the comparison).
--
-- Signature change (callers): research.assert_admitted_use(uuid, text, text, bigint)
--                          -> research.assert_admitted_use(uuid, text, text, bigint, text default null).
-- A 4-argument call still resolves; a catalog probe for the old 4-argument regprocedure does not (KS
-- exact-use-admission.ts must probe the 5-argument signature). Both forms cannot coexist: a 4-argument call would be
-- ambiguous. Mapping change: NORMALIZED_VALUES_MISMATCH -> EFFECT_CONFLICT (KSA03); everything else as 20261024010100.
begin;
set local lock_timeout = '15s';

do $$
begin
  if to_regprocedure('knowledge_verification.admit_exact_use(uuid,text,text,bigint,timestamptz,text)') is null then
    raise exception 'KNOWLEDGE_VERIFICATION_COMPONENT_2_2_REQUIRED'
      using hint = 'install @aiengineer/knowledge-db-contract 2.2.0 (knowledge-db install --application ai-engineer) before this migration';
  end if;
end $$;

-- The admission record keeps the digest the native transaction presented (null = not presented).
alter table research.use_admission
  add column normalized_values_digest text,
  add constraint use_admission_normalized_values_digest check (normalized_values_digest is null or normalized_values_digest ~ '^sha256:[0-9a-f]{64}$');
-- One admission row per (decision, effect digest, transaction, authoritative epoch, presented normalized digest): a
-- re-check that presents the digest records it instead of collapsing into an earlier digest-less row.
alter table research.use_admission
  drop constraint use_admission_pkey,
  add constraint use_admission_key unique nulls not distinct
    (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest);
comment on column research.use_admission.normalized_values_digest is
  'K01 canonical digest of the normalized values the native transaction presented to admit_exact_use; null when the caller presented none (the component then skipped the comparison).';

drop function research.assert_admitted_use(uuid, text, text, bigint);
drop function research.require_admitted_use(uuid, text, text, bigint);

create function research.require_admitted_use(
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
comment on function research.require_admitted_use(uuid, text, text, bigint, text) is
  'Internal checker shared by assert_admitted_use and the use_admission insert trigger: knowledge_verification.admit_exact_use (2.2.0, normalized values digest forwarded) outcome -> typed errors KSA01..KSA04.';

create or replace function research.guard_use_admission() returns trigger
language plpgsql set search_path = '' as $$
declare c record;
begin
  if new.tenant_id is distinct from util.current_tenant_id() then
    raise exception 'TENANT_MISMATCH' using errcode = 'insufficient_privilege';
  end if;
  select * into c from research.require_admitted_use(new.tenant_id, new.use_decision_id, new.bound_effect_digest, new.processed_epoch,
                                                       new.normalized_values_digest);
  new.xact_id := pg_current_xact_id()::text::bigint;
  new.authoritative_epoch := c.authoritative_epoch;
  new.effect_key := c.effect_key;
  new.admitted_at := now();
  return new;
end $$;

create function research.assert_admitted_use(
  p_tenant uuid, p_use_decision_id text, p_bound_effect_digest text, p_processed_epoch bigint, p_normalized_values_digest text default null
) returns research.use_admission
language plpgsql volatile set search_path = '' as $$
declare row_ research.use_admission;
begin
  insert into research.use_admission (tenant_id, use_decision_id, bound_effect_digest, xact_id, processed_epoch, authoritative_epoch, effect_key,
                                      normalized_values_digest)
  values (p_tenant, p_use_decision_id, p_bound_effect_digest, 0, p_processed_epoch, 0, '', p_normalized_values_digest)
  on conflict (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest) do nothing
  returning * into row_;
  if row_ is null then
    -- Repeated in the same transaction at the same authoritative epoch: the trigger re-checked the authority (with this
    -- call's normalized digest) before the conflict was detected; return the row already recorded for that epoch.
    select * into row_ from research.use_admission a
     where a.tenant_id = p_tenant and a.use_decision_id = p_use_decision_id and a.bound_effect_digest = p_bound_effect_digest
       and a.xact_id = pg_current_xact_id()::text::bigint
       and a.normalized_values_digest is not distinct from p_normalized_values_digest
     order by a.authoritative_epoch desc limit 1;
  end if;
  return row_;
end $$;
comment on function research.assert_admitted_use(uuid, text, text, bigint, text) is
  'Native exact-use guard (design section 7): call inside the ingestion transaction before canonical writes, presenting the normalized values digest of the values being written. Calls knowledge_verification.admit_exact_use under its epoch lock (held to commit) and records research.use_admission for this transaction; raises STALE_DECISION (KSA01), REVIEW_REQUIRED (KSA02), EFFECT_CONFLICT (KSA03, incl. normalized values mismatch) or UNRESOLVED_EFFECT (KSA04).';

revoke all on function research.require_admitted_use(uuid, text, text, bigint, text),
  research.assert_admitted_use(uuid, text, text, bigint, text) from public, anon, authenticated;
grant execute on function research.require_admitted_use(uuid, text, text, bigint, text),
  research.assert_admitted_use(uuid, text, text, bigint, text) to executor_service;

commit;
