-- Build 08 knowledge loop 6 (candidate F): Knowledge Services admission of probe verdicts, the first verified claims. D-55 kept: verified
-- only under a receipt bound to an admitted knowledge_verification exact-use decision, admitted in the same transaction. D-72: an admitted
-- receipt may target an existing claim (action verified) so the claim keeps its identity; D-73: the exact-use checker R2 dropped is restored;
-- D-74: the native write binds the exact payload text to the decision's bound effect; D-75: the claim_verification intent type.
-- Promoted 2026-11-13 from the lab drafts 20261113150000, 20261113150100, 20261113160100 (kept in supabase/drafts/). Lab-proven on
-- disposable-aieng-build04; cycle record: Build 08 §25 in the AI Engineer review workspace.
begin;

-- ---- from draft 20261113150000_build08_loop6_ks_admission.sql
-- Build 08 loop 6 (candidate F): Knowledge Services admission of probe verdicts; the first `verified` claims.
-- Draft for the disposable lab (disposable-aieng-build04). D-55 is kept: `verified` is reachable only under an operation receipt
-- bound to an admitted exact-use decision of the knowledge_verification component, admitted in the same transaction.
-- What changes is how the receipt binds the claim (D-72): an admitted receipt may TARGET an existing claim (action `verified`)
-- instead of having created it, so a claim keeps its identity, subjects, attributions, verdicts and bindings when it is verified.

-- 1. A receipt target may record that the receipt verified a claim.
alter table orchestration.operation_receipt_target drop constraint operation_receipt_target_action_check;
alter table orchestration.operation_receipt_target add constraint operation_receipt_target_action_check
  check (action = any (array['created','reused','superseded','staged','verified']));
comment on column orchestration.operation_receipt_target.action is
  'created, reused, superseded, staged; verified (loop 6): the receipt, bound to an admitted knowledge_verification use decision, moved the target claim to status verified.';

-- 2. The gate: verified needs an admitted creating receipt (unchanged) OR a same-transaction admitted receipt that targets the claim.
create or replace function evidence.enforce_verified_claim_gate() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.status <> 'verified' or (tg_op = 'UPDATE' and old.status = 'verified') then return new; end if;
  if new.created_by_receipt_id is not null and exists (
    select 1 from orchestration.operation_receipt r
     where r.id = new.created_by_receipt_id and r.requires_admission and r.use_decision_id is not null and r.bound_effect_digest is not null
  ) then return new; end if;
  if tg_op = 'UPDATE' and exists (
    select 1 from orchestration.operation_receipt_target t
      join orchestration.operation_receipt r on r.id = t.receipt_id
      join verification.use_admission a on a.use_decision_id = r.use_decision_id and a.bound_effect_digest = r.bound_effect_digest
     where t.claim_id = new.id and t.action = 'verified' and t.target_schema = 'evidence' and t.target_table = 'claim'
       and r.requires_admission and a.tenant_id = new.tenant_id and a.xact_id = pg_current_xact_id()::text::bigint
  ) then return new; end if;
  raise exception 'VERIFIED_CLAIM_REQUIRES_ADMITTED_USE'
    using errcode = 'check_violation',
          hint = 'a verified claim needs an operation receipt bound to an admitted knowledge_verification use decision: either the creating receipt, or a receipt targeting the claim with action verified, admitted (verification.assert_admitted_use) in the same transaction';
end $$;
revoke all on function evidence.enforce_verified_claim_gate() from public, anon, authenticated;
comment on function evidence.enforce_verified_claim_gate() is
  'Status verified requires a receipt bound to an admitted exact-use decision of the knowledge_verification component: the creating receipt (requires_admission, use_decision_id, bound_effect_digest), or (loop 6, D-72) a receipt that targets the claim with action verified and whose use was admitted in the same transaction. The decision itself is issued only by the component from a sealed verification run.';

create or replace function retrieval.history_claim_authorized(p_claim uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from evidence.claim c
      join orchestration.operation_receipt r on r.id = c.created_by_receipt_id
     where c.tenant_id = util.current_tenant_id() and c.id = p_claim and c.status::text in ('verified', 'superseded')
       and r.requires_admission and r.use_decision_id is not null
       and exists (select 1 from verification.use_admission a where a.tenant_id = c.tenant_id and a.use_decision_id = r.use_decision_id and a.bound_effect_digest = r.bound_effect_digest))
  or exists (
    select 1 from evidence.claim c
      join orchestration.operation_receipt_target t on t.claim_id = c.id and t.action = 'verified'
      join orchestration.operation_receipt r on r.id = t.receipt_id
     where c.tenant_id = util.current_tenant_id() and c.id = p_claim and c.status::text in ('verified', 'superseded')
       and r.requires_admission
       and exists (select 1 from verification.use_admission a where a.tenant_id = c.tenant_id and a.use_decision_id = r.use_decision_id and a.bound_effect_digest = r.bound_effect_digest))
$$;
comment on function retrieval.history_claim_authorized(uuid) is
  'A historical claim is authorized for retrieval when it is verified (or superseded after verification) under a receipt bound to a knowledge_verification use decision with a recorded verification.use_admission: the creating receipt, or a receipt that verified it (loop 6). Admission is separate from belief.';

-- 3. The native write a Knowledge Services admission performs, inside the caller's transaction.
create or replace function verification.record_admitted_claim_verification(
  p_claim uuid, p_use_decision_id text, p_bound_effect_digest text, p_processed_epoch bigint, p_normalized_values_digest text,
  p_origin_digest text, p_effect jsonb, p_executor text)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_tenant uuid := util.current_tenant_id(); c evidence.claim; v_intent uuid; v_receipt uuid; v_payload_digest text;
begin
  select * into c from evidence.claim where id = p_claim and tenant_id = v_tenant for update;
  if c.id is null then raise exception 'CLAIM_NOT_FOUND' using errcode = 'no_data_found'; end if;
  if c.status::text = 'verified' then
    return (select t.receipt_id from orchestration.operation_receipt_target t where t.claim_id = p_claim and t.action = 'verified' order by t.receipt_id desc limit 1);
  end if;
  if c.status::text not in ('proposed') then
    raise exception 'CLAIM_NOT_VERIFIABLE' using errcode = 'check_violation', detail = format('claim %s has status %s; only proposed claims are verified', p_claim, c.status);
  end if;
  if p_effect ->> 'claim_id' is distinct from p_claim::text or p_effect ->> 'statement_sha256' is distinct from encode(extensions.digest(convert_to(c.statement, 'utf8'), 'sha256'), 'hex') then
    raise exception 'EFFECT_DOES_NOT_MATCH_CLAIM' using errcode = 'check_violation', detail = 'the bound native payload names another claim or another statement';
  end if;
  -- the component rule (exact decision, effect, epoch, normalized values) runs inside assert_admitted_use's guard trigger
  perform verification.assert_admitted_use(v_tenant, p_use_decision_id, p_bound_effect_digest, p_processed_epoch, p_normalized_values_digest);
  insert into orchestration.operation_intent(tenant_id, intent_type, payload, idempotency_key, approval_state, origin_digest, origin_kind)
  values (v_tenant, 'claim_verification', p_effect, 'claim-verify:' || p_claim || ':' || p_use_decision_id, 'approved', p_origin_digest, 'standalone')
  returning id into v_intent;
  insert into orchestration.operation_receipt(intent_id, executor_version, outcome, changes_summary, affected_refs, requires_admission, use_decision_id, bound_effect_digest, origin_digest)
  values (v_intent, p_executor, 'applied', jsonb_build_object('claim_status', jsonb_build_array(c.status::text, 'verified')),
          jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'claim', 'id', p_claim)), true, p_use_decision_id, p_bound_effect_digest, p_origin_digest)
  returning id into v_receipt;
  insert into orchestration.operation_receipt_target(tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action, claim_id)
  values (v_tenant, v_receipt, 0, 'evidence', 'claim', p_claim::text, 'subject', 'verified', p_claim);
  update evidence.claim set status = 'verified' where id = p_claim;
  return v_receipt;
end $$;
revoke all on function verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, jsonb, text) from public, anon, authenticated;
grant execute on function verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, jsonb, text) to verifier_agent, executor_service, control_plane;
-- the Knowledge Services writer performs the native write in its admission transaction (the AIDB binding accepts it as the executor)
do $$ begin if exists (select 1 from pg_roles where rolname = 'knowledge_verification_writer') then
  execute 'grant execute on function verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, jsonb, text) to knowledge_verification_writer';
  execute 'grant usage on schema verification to knowledge_verification_writer';
end if; end $$;
comment on function verification.record_admitted_claim_verification is
  'Loop 6: the AI Engineer native write of a Knowledge Services claim-verification admission. In the caller''s transaction: assert the admitted exact use (component rule + AIDB guard), write the intent and the admission-bound receipt, target the claim with action verified, set status verified. The bound payload must name this claim and the sha256 of its statement. Idempotent for an already verified claim.';

-- 4. Reader: verified claims with the decision, the receipt and the probe evidence behind them.
create or replace view api.verified_claims as
  select c.id as claim_id, c.statement, c.claim_type, r.id as receipt_id, r.use_decision_id, r.bound_effect_digest, r.applied_at as verified_at,
         r.executor_version, i.payload as effect,
         (select jsonb_agg(jsonb_build_object('probe', p.slug, 'verdict', v.verdict, 'review_state', v.review_state) order by p.slug)
            from verification.probe_verdict v join verification.probe p on p.id = v.probe_id
           where v.claim_id = c.id and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)) as verdicts
    from evidence.claim c
    join orchestration.operation_receipt_target t on t.claim_id = c.id and t.action = 'verified'
    join orchestration.operation_receipt r on r.id = t.receipt_id
    join orchestration.operation_intent i on i.id = r.intent_id
   where c.tenant_id = util.current_tenant_id() and c.status::text = 'verified';
comment on view api.verified_claims is 'Loop 6: claims that reached verified through a Knowledge Services admission, with the use decision, the admission-bound receipt, the bound native payload and the current probe verdicts.';
grant select on api.verified_claims to app_reader, pipeline_agent, verifier_agent, control_plane, product_api_owner, authenticated, service_role;

-- ---- from draft 20261113150100_build08_loop6_fixup_require_admitted_use.sql
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

-- ---- from draft 20261113160100_build08_loop6_fixup_bind_payload.sql
-- Build 08 loop 6 fixup 2 (D-74, D-75), found by the Knowledge Services harness's negative controls on 2026-11-13.
-- D-74: verification.record_admitted_claim_verification checked that the payload names the claim, but not that the payload is the
--       one the decision admitted: claim A's decision with a payload rewritten to name claim B verified B. The native write now takes
--       the exact payload text, and its sha256 must equal the semantic payload digest of the bound effect the component recorded
--       (knowledge_verification.effect, keyed by the bound effect digest). The already-verified path no longer returns early for
--       another decision.
-- D-75: the intent type `claim_verification` was missing from orchestration.intent_type (the harness's first attempt failed on it;
--       the row was added by hand on the lab and is now part of the migration). The grant to knowledge_verification_writer is dropped:
--       the native write runs as executor_service, the AIDB ingestion executor.

insert into orchestration.intent_type(code, description, schema_version)
values ('claim_verification', 'Verify an existing claim under a Knowledge Services admitted exact-use decision (verification.record_admitted_claim_verification)', 1)
on conflict (code) do update set description = excluded.description;

drop function if exists verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, jsonb, text);
create or replace function verification.record_admitted_claim_verification(
  p_claim uuid, p_use_decision_id text, p_bound_effect_digest text, p_processed_epoch bigint, p_normalized_values_digest text,
  p_origin_digest text, p_effect_text text, p_executor text)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_tenant uuid := util.current_tenant_id(); c evidence.claim; v_intent uuid; v_receipt uuid; v_effect jsonb; v_payload_digest text; v_existing record;
begin
  select * into c from evidence.claim where id = p_claim and tenant_id = v_tenant for update;
  if c.id is null then raise exception 'CLAIM_NOT_FOUND' using errcode = 'no_data_found'; end if;
  -- the payload must be the exact bytes the decision's bound effect was computed over
  v_payload_digest := 'sha256:' || encode(extensions.digest(convert_to(p_effect_text, 'utf8'), 'sha256'), 'hex');
  if not exists (select 1 from knowledge_verification.effect e where e.tenant_id = v_tenant and e.bound_effect_digest = p_bound_effect_digest and e.semantic_payload_digest = v_payload_digest) then
    raise exception 'EFFECT_PAYLOAD_NOT_BOUND' using errcode = 'check_violation',
      detail = 'the presented payload is not the payload whose bound effect digest the decision admits (sha256 of the payload text differs from knowledge_verification.effect.semantic_payload_digest)';
  end if;
  v_effect := p_effect_text::jsonb;
  if v_effect ->> 'claim_id' is distinct from p_claim::text or v_effect ->> 'statement_sha256' is distinct from encode(extensions.digest(convert_to(c.statement, 'utf8'), 'sha256'), 'hex') then
    raise exception 'EFFECT_DOES_NOT_MATCH_CLAIM' using errcode = 'check_violation', detail = 'the bound native payload names another claim or another statement';
  end if;
  if c.status::text = 'verified' then
    select r.id, r.use_decision_id into v_existing from orchestration.operation_receipt_target t join orchestration.operation_receipt r on r.id = t.receipt_id
     where t.claim_id = p_claim and t.action = 'verified' order by r.applied_at desc limit 1;
    if v_existing.use_decision_id is distinct from p_use_decision_id then
      raise exception 'CLAIM_ALREADY_VERIFIED' using errcode = 'check_violation', detail = format('claim %s was verified under decision %s', p_claim, v_existing.use_decision_id);
    end if;
    return v_existing.id;
  end if;
  if c.status::text not in ('proposed') then
    raise exception 'CLAIM_NOT_VERIFIABLE' using errcode = 'check_violation', detail = format('claim %s has status %s; only proposed claims are verified', p_claim, c.status);
  end if;
  perform verification.assert_admitted_use(v_tenant, p_use_decision_id, p_bound_effect_digest, p_processed_epoch, p_normalized_values_digest);
  insert into orchestration.operation_intent(tenant_id, intent_type, payload, idempotency_key, approval_state, origin_digest, origin_kind)
  values (v_tenant, 'claim_verification', v_effect, 'claim-verify:' || p_claim || ':' || p_use_decision_id, 'approved', p_origin_digest, 'standalone')
  returning id into v_intent;
  insert into orchestration.operation_receipt(intent_id, executor_version, outcome, changes_summary, affected_refs, requires_admission, use_decision_id, bound_effect_digest, origin_digest)
  values (v_intent, p_executor, 'applied', jsonb_build_object('claim_status', jsonb_build_array(c.status::text, 'verified'), 'payload_sha256', v_payload_digest),
          jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'claim', 'id', p_claim)), true, p_use_decision_id, p_bound_effect_digest, p_origin_digest)
  returning id into v_receipt;
  insert into orchestration.operation_receipt_target(tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action, claim_id)
  values (v_tenant, v_receipt, 0, 'evidence', 'claim', p_claim::text, 'subject', 'verified', p_claim);
  update evidence.claim set status = 'verified' where id = p_claim;
  return v_receipt;
end $$;
revoke all on function verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, text, text) from public, anon, authenticated;
grant execute on function verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, text, text) to executor_service, verifier_agent, control_plane;
comment on function verification.record_admitted_claim_verification(uuid, text, text, bigint, text, text, text, text) is
  'Loop 6: the AI Engineer native write of a Knowledge Services claim-verification admission, inside the caller''s transaction. The payload text must hash to the semantic payload digest of the decision''s bound effect (D-74) and name this claim and the sha256 of its statement; then: assert the admitted exact use (component rule + AIDB guard), write the intent and the admission-bound receipt, target the claim with action verified, set status verified. Re-presenting the same decision for an already verified claim returns its receipt; another decision is refused.';

commit;
