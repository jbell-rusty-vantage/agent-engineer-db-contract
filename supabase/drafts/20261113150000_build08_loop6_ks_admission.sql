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
