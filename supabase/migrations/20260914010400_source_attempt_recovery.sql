begin;
set local lock_timeout='15s';
alter table evidence.source_provider_attempt
 add column provider_version text not null default 'unspecified' check(length(btrim(provider_version)) between 1 and 128),
 add column retry_of_attempt_id uuid,
 add column root_attempt_id uuid,
 add column original_dispatch_token uuid,
 add column original_dispatch_fencing_token bigint,
 add column completion_artifact_id uuid,
 add constraint source_attempt_retry_tenant_fk foreign key(tenant_id,retry_of_attempt_id) references evidence.source_provider_attempt(tenant_id,id),
 add constraint source_attempt_root_tenant_fk foreign key(tenant_id,root_attempt_id) references evidence.source_provider_attempt(tenant_id,id),
 add constraint source_attempt_completion_tenant_fk foreign key(tenant_id,completion_artifact_id) references orchestration.artifact(tenant_id,id),
 add constraint source_attempt_original_dispatch_ck check((original_dispatch_token is null and original_dispatch_fencing_token is null) or (original_dispatch_token is not null and original_dispatch_fencing_token is not null and original_dispatch_fencing_token>0)),
 add constraint source_attempt_retry_ck check(retry_of_attempt_id is null or (retry_of_attempt_id<>id and root_attempt_id is not null and attempt_ordinal>0));
-- Existing in-flight dispatches retain their original identity; no provider call is repeated by migration.
update evidence.source_provider_attempt set original_dispatch_token=dispatch_token,original_dispatch_fencing_token=dispatch_fencing_token
 where state='started' and dispatch_token is not null;
create or replace function evidence.guard_source_provider_attempt() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'source provider attempts are retained' using errcode='restrict_violation'; end if;
 if old.id is distinct from new.id or old.tenant_id is distinct from new.tenant_id or old.source_query_id is distinct from new.source_query_id
    or old.provider_code is distinct from new.provider_code or old.origin is distinct from new.origin
    or old.idempotency_key is distinct from new.idempotency_key or old.request_sha256 is distinct from new.request_sha256
    or old.requested_urls is distinct from new.requested_urls
    or old.request_artifact_id is distinct from new.request_artifact_id or old.external_receipt_artifact_id is distinct from new.external_receipt_artifact_id
    or old.provider_native_attempt_id is distinct from new.provider_native_attempt_id or old.attempt_ordinal is distinct from new.attempt_ordinal
    or old.provider_version is distinct from new.provider_version or old.retry_of_attempt_id is distinct from new.retry_of_attempt_id or old.root_attempt_id is distinct from new.root_attempt_id
    or old.started_at is distinct from new.started_at then raise exception 'source provider attempt identity is immutable' using errcode='restrict_violation'; end if;
 if old.original_dispatch_token is not null and (old.original_dispatch_token is distinct from new.original_dispatch_token or old.original_dispatch_fencing_token is distinct from new.original_dispatch_fencing_token) then raise exception 'original source dispatch is immutable' using errcode='restrict_violation'; end if;
 if old.state<>'started' then raise exception 'source provider attempt terminal state is immutable' using errcode='restrict_violation'; end if;
 return new;
end $$;

alter table evidence.provider_result drop constraint provider_result_disposition_check;
-- Typed retries share the original query but have independent provider-result ranks.
alter table evidence.provider_result drop constraint provider_result_tenant_id_query_id_rank_key;
create unique index provider_result_legacy_query_rank_uq on evidence.provider_result(tenant_id,query_id,rank)
 where source_provider_attempt_id is null;
alter table evidence.provider_result add constraint provider_result_disposition_check check(disposition in('selected','omitted','duplicate','unreviewed'));
alter table evidence.source_encounter drop constraint source_encounter_result_disposition_check;
alter table evidence.source_encounter add constraint source_encounter_result_disposition_check check(result_disposition in('selected','omitted','duplicate','unreviewed'));
create table evidence.source_selection_revision (
 tenant_id uuid not null,attempt_id uuid not null,revision bigint not null check(revision>0),
 idempotency_key text not null check(length(btrim(idempotency_key)) between 1 and 256),request_sha256 text not null check(request_sha256 ~ '^[0-9a-f]{64}$'),
 selection_artifact_id uuid not null,created_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,attempt_id,revision),unique(tenant_id,attempt_id,idempotency_key),
 unique(tenant_id,attempt_id,revision,idempotency_key,selection_artifact_id),
 foreign key(tenant_id,attempt_id) references evidence.source_provider_attempt(tenant_id,id),
 foreign key(tenant_id,selection_artifact_id) references orchestration.artifact(tenant_id,id)
);
create trigger source_selection_revision_immutable before update or delete on evidence.source_selection_revision for each row execute function util.reject_mutation();
alter table evidence.source_selection_revision enable row level security;
create policy source_selection_revision_tenant on evidence.source_selection_revision for all to executor_service,pipeline_agent,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on evidence.source_selection_revision to executor_service,pipeline_agent;
grant select on evidence.source_selection_revision to verifier_agent,control_plane;
create table evidence.source_result_selection (
 tenant_id uuid not null,
 attempt_id uuid not null,
 revision bigint not null check(revision>0),
 rank integer not null check(rank>0),
 disposition text not null check(disposition in('selected','omitted','duplicate')),
 reason text not null check(length(btrim(reason)) between 1 and 2000),
 idempotency_key text not null,
 selection_artifact_id uuid not null,
 created_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,attempt_id,rank,revision),
 foreign key(tenant_id,attempt_id,revision,idempotency_key,selection_artifact_id) references evidence.source_selection_revision(tenant_id,attempt_id,revision,idempotency_key,selection_artifact_id),
 foreign key(tenant_id,attempt_id) references evidence.source_provider_attempt(tenant_id,id),
 foreign key(tenant_id,selection_artifact_id) references orchestration.artifact(tenant_id,id)
);
create trigger source_result_selection_immutable before update or delete on evidence.source_result_selection for each row execute function util.reject_mutation();
alter table evidence.source_result_selection enable row level security;
create policy source_result_selection_tenant on evidence.source_result_selection for all to executor_service,pipeline_agent,verifier_agent,control_plane
 using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on evidence.source_result_selection to executor_service,pipeline_agent;
grant select on evidence.source_result_selection to verifier_agent,control_plane;

create function evidence.guard_source_result_selection() returns trigger language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from evidence.source_provider_attempt p
  join evidence.provider_result r on r.tenant_id=p.tenant_id and r.source_provider_attempt_id=p.id and r.rank=new.rank
  join orchestration.artifact a on a.tenant_id=p.tenant_id and a.id=new.selection_artifact_id and a.storage_state='available'
  join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
  where p.tenant_id=new.tenant_id and p.id=new.attempt_id and p.state='succeeded'
   and m.parent_artifact_ids=array[coalesce(p.raw_output_artifact_id,p.external_receipt_artifact_id)]::uuid[]) then
  raise exception 'selection requires a successful result and available parent-bound receipt' using errcode='23514';
 end if;
 return new;
end $$;
create trigger source_result_selection_admission before insert on evidence.source_result_selection for each row execute function evidence.guard_source_result_selection();
create function evidence.require_source_selection_decisions() returns trigger language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from evidence.source_result_selection s where s.tenant_id=new.tenant_id and s.attempt_id=new.attempt_id and s.revision=new.revision) then
  raise exception 'selection revision requires at least one admitted decision' using errcode='23514';
 end if;
 return new;
end $$;
create constraint trigger source_selection_revision_nonempty after insert on evidence.source_selection_revision
 deferrable initially deferred for each row execute function evidence.require_source_selection_decisions();
comment on table evidence.source_result_selection is 'Append-only research inclusion revisions per provider result; reads choose the latest recorded rank decision without redispatching discovery.';
commit;
