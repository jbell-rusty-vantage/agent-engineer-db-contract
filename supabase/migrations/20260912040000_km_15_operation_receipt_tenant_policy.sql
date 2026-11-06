-- km_15: orchestration.operation_receipt has no tenant_id column, so 20260903010200 gave it the
-- blanket deny-all policy. Receipt writers (executor_service, control_plane) therefore could not
-- record the receipt that temporal.commit_batch requires, and no bounded role could read receipts.
-- Derive tenancy from the owning intent instead.
begin;
set local lock_timeout = '15s';

drop policy if exists bounded_role_access on orchestration.operation_receipt;
create policy intent_tenant_access on orchestration.operation_receipt
  for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (
    exists (
      select 1 from orchestration.operation_intent i
      where i.id = operation_receipt.intent_id and i.tenant_id = util.current_tenant_id()
    )
  )
  with check (
    exists (
      select 1 from orchestration.operation_intent i
      where i.id = operation_receipt.intent_id and i.tenant_id = util.current_tenant_id()
    )
  );

commit;
