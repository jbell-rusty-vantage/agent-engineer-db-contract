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
