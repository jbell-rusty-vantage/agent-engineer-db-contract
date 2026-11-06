begin;
set local lock_timeout = '15s';

create table evidence.source_provider_attempt (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.current_tenant_id(),
 source_query_id uuid not null references evidence.source_query(id) on delete restrict,
 provider_code text not null references evidence.search_provider(code),
 origin text not null check(origin in ('managed','imported')),
 idempotency_key text not null check(length(btrim(idempotency_key)) between 1 and 256),
 request_sha256 text not null check(request_sha256 ~ '^[0-9a-f]{64}$'),
 requested_urls jsonb not null default '[]'::jsonb check(jsonb_typeof(requested_urls)='array'),
 request_artifact_id uuid not null references orchestration.artifact(id),
 raw_output_artifact_id uuid references orchestration.artifact(id),
 external_receipt_artifact_id uuid references orchestration.artifact(id),
 provider_native_attempt_id text,
 attempt_ordinal integer not null default 0 check(attempt_ordinal>=0),
 state text not null check(state in ('started','succeeded','failed','uncertain','cancelled')),
 failure_code text check(failure_code is null or failure_code ~ '^[A-Z][A-Z0-9_]{2,127}$'),
 dispatch_owner text,
 dispatch_token uuid,
 dispatch_fencing_token bigint not null default 0 check(dispatch_fencing_token>=0),
 dispatch_claimed_at timestamptz,
 dispatch_expires_at timestamptz,
 started_at timestamptz not null default clock_timestamp(),
 completed_at timestamptz,
 completion_sha256 text check(completion_sha256 is null or completion_sha256 ~ '^[0-9a-f]{64}$'),
 unique(tenant_id,id),
 unique(tenant_id,idempotency_key),
 unique(tenant_id,source_query_id,attempt_ordinal),
 check(completed_at is null or completed_at>=started_at),
 check((state='started' and completed_at is null and completion_sha256 is null and raw_output_artifact_id is null and failure_code is null
      and ((dispatch_owner is null and dispatch_token is null and dispatch_claimed_at is null and dispatch_expires_at is null)
        or (dispatch_owner is not null and dispatch_token is not null and dispatch_claimed_at is not null and dispatch_expires_at is not null and dispatch_expires_at>dispatch_claimed_at)))
    or (state='succeeded' and completed_at is not null and completion_sha256 is not null and coalesce(raw_output_artifact_id,external_receipt_artifact_id) is not null and failure_code is null and dispatch_owner is null and dispatch_token is null and dispatch_claimed_at is null and dispatch_expires_at is null)
    or (state in ('failed','uncertain','cancelled') and completed_at is not null and completion_sha256 is not null and coalesce(raw_output_artifact_id,external_receipt_artifact_id) is not null and failure_code is not null and dispatch_owner is null and dispatch_token is null and dispatch_claimed_at is null and dispatch_expires_at is null)),
 check((origin='managed' and external_receipt_artifact_id is null and (state='started' or raw_output_artifact_id is not null)) or (origin='imported' and external_receipt_artifact_id is not null and state<>'started'))
);

alter table evidence.provider_result add column source_provider_attempt_id uuid references evidence.source_provider_attempt(id),
 add column provider_native_result_id text,add column disposition text check(disposition in ('selected','omitted','duplicate'));
alter table evidence.source_encounter add column source_provider_attempt_id uuid references evidence.source_provider_attempt(id),
 add column requested_url text,add column final_url text,add column redirect_urls text[] not null default '{}',
 add column result_disposition text check(result_disposition in ('selected','omitted','duplicate')),
 add column failure_code text check(failure_code is null or failure_code ~ '^[A-Z][A-Z0-9_]{2,127}$');
alter table evidence.source_provider_attempt
 add constraint source_provider_attempt_tenant_query_fk foreign key(tenant_id,source_query_id) references evidence.source_query(tenant_id,id) deferrable initially deferred,
 add constraint source_provider_attempt_tenant_request_artifact_fk foreign key(tenant_id,request_artifact_id) references orchestration.artifact(tenant_id,id) deferrable initially deferred,
 add constraint source_provider_attempt_tenant_raw_artifact_fk foreign key(tenant_id,raw_output_artifact_id) references orchestration.artifact(tenant_id,id) deferrable initially deferred,
 add constraint source_provider_attempt_tenant_external_receipt_fk foreign key(tenant_id,external_receipt_artifact_id) references orchestration.artifact(tenant_id,id) deferrable initially deferred;
alter table evidence.provider_result add constraint provider_result_tenant_attempt_fk foreign key(tenant_id,source_provider_attempt_id) references evidence.source_provider_attempt(tenant_id,id) deferrable initially deferred;
alter table evidence.source_encounter add constraint source_encounter_tenant_attempt_fk foreign key(tenant_id,source_provider_attempt_id) references evidence.source_provider_attempt(tenant_id,id) deferrable initially deferred;
alter table evidence.source_encounter add constraint source_encounter_tenant_capture_fk foreign key(tenant_id,capture_id) references evidence.source_capture(tenant_id,id) deferrable initially deferred;
create unique index provider_result_attempt_rank_uq on evidence.provider_result(tenant_id,source_provider_attempt_id,rank) where source_provider_attempt_id is not null;
create index source_provider_attempt_query_idx on evidence.source_provider_attempt(tenant_id,source_query_id,started_at);
create index source_provider_attempt_terminal_idx on evidence.source_provider_attempt(tenant_id,state,completed_at) where state<>'started';
create index source_encounter_provider_attempt_idx on evidence.source_encounter(tenant_id,source_provider_attempt_id,encountered_at) where source_provider_attempt_id is not null;

create function evidence.guard_source_provider_attempt() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'source provider attempts are retained' using errcode='restrict_violation'; end if;
 if old.id is distinct from new.id or old.tenant_id is distinct from new.tenant_id or old.source_query_id is distinct from new.source_query_id
    or old.provider_code is distinct from new.provider_code or old.origin is distinct from new.origin
    or old.idempotency_key is distinct from new.idempotency_key or old.request_sha256 is distinct from new.request_sha256
    or old.requested_urls is distinct from new.requested_urls
    or old.request_artifact_id is distinct from new.request_artifact_id or old.external_receipt_artifact_id is distinct from new.external_receipt_artifact_id
    or old.provider_native_attempt_id is distinct from new.provider_native_attempt_id or old.attempt_ordinal is distinct from new.attempt_ordinal
    or old.started_at is distinct from new.started_at then raise exception 'source provider attempt identity is immutable' using errcode='restrict_violation'; end if;
 if old.state<>'started' then raise exception 'source provider attempt terminal state is immutable' using errcode='restrict_violation'; end if;
 return new;
end $$;
create trigger source_provider_attempt_guard before update or delete on evidence.source_provider_attempt for each row execute function evidence.guard_source_provider_attempt();

alter table evidence.source_provider_attempt enable row level security;
create policy source_provider_attempt_tenant_access on evidence.source_provider_attempt for all to executor_service,pipeline_agent,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
revoke all on table evidence.source_provider_attempt from public,anon,authenticated,app_reader;
grant select,insert,update on table evidence.source_provider_attempt to executor_service,pipeline_agent;
grant select on table evidence.source_provider_attempt to verifier_agent,control_plane;
commit;
