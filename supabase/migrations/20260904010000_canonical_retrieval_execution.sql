begin;

alter table retrieval.retrieval_run
  add column operation_id uuid,
  add column request_sha256 text;

alter table retrieval.retrieval_run
  add constraint retrieval_run_operation_fk
    foreign key (tenant_id, operation_id)
    references knowledge_service.operation(tenant_id, id) on delete restrict,
  add constraint retrieval_run_request_sha256_ck
    check (request_sha256 is null or request_sha256 ~ '^[0-9a-f]{64}$');

create unique index retrieval_run_operation_uq
  on retrieval.retrieval_run(tenant_id, operation_id)
  where operation_id is not null;

create trigger retrieval_plan_immutable
  before update or delete on retrieval.retrieval_plan
  for each row execute function util.reject_mutation();

create trigger retrieval_run_immutable
  before update or delete on retrieval.retrieval_run
  for each row execute function util.reject_mutation();

create trigger retrieval_candidate_immutable
  before update or delete on retrieval.retrieval_candidate
  for each row execute function util.reject_mutation();

comment on column retrieval.retrieval_run.operation_id is
  'Durable API operation that authorized and executed this immutable retrieval run.';
comment on column retrieval.retrieval_run.request_sha256 is
  'Canonical digest of the validated retrieval request used for idempotent replay.';

commit;
