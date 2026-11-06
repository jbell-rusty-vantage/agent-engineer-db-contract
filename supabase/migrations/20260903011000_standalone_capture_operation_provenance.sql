-- Source captures may be produced either by a Mission Control attempt or by a
-- standalone durable knowledge-service operation. Exactly one authority path
-- is required; the operation itself retains an optional link to an external
-- attempt when Mission Control owns execution.
begin;

alter table evidence.source_capture
  add column knowledge_operation_id uuid;

alter table evidence.source_capture
  alter column produced_by_attempt_id drop not null;

alter table evidence.source_capture
  add constraint source_capture_knowledge_operation_fk
  foreign key (tenant_id, knowledge_operation_id)
  references knowledge_service.operation(tenant_id, id) on delete restrict;

alter table evidence.source_capture
  add constraint source_capture_exactly_one_producer_ck
  check (num_nonnulls(produced_by_attempt_id, knowledge_operation_id) = 1);

create index source_capture_knowledge_operation_idx
  on evidence.source_capture(tenant_id, knowledge_operation_id)
  where knowledge_operation_id is not null;

comment on column evidence.source_capture.knowledge_operation_id is
  'Standalone knowledge-service producer. Mutually exclusive with produced_by_attempt_id; Mission Control operations retain attempt lineage through knowledge_service.operation.';

commit;
