begin;
set local lock_timeout='15s';
alter table knowledge_service.scoped_checkpoint add column harness_request_digest text
 check(harness_request_digest is null or harness_request_digest ~ '^sha256:[0-9a-f]{64}$');
comment on column knowledge_service.scoped_checkpoint.harness_request_digest is
 'Stable original harness input binding for acknowledgement recovery before capturing a fresh executor snapshot; separate from full manifest request_digest.';
-- Preserve the existing artifact lifecycle; only an admitted immutable tombstone permits retirement.
create or replace function orchestration.artifact_guard() returns trigger
language plpgsql security definer set search_path='' as $$
declare successor_created timestamptz; retiring boolean;
begin
 if tg_op='DELETE' then raise exception 'orchestration.artifact is append-only' using errcode='restrict_violation'; end if;
 if (to_jsonb(new)-array['superseded_by_id','storage_state','available_at','registration_error_class'])
    is distinct from
    (to_jsonb(old)-array['superseded_by_id','storage_state','available_at','registration_error_class']) then
  raise exception 'artifact immutable identity changed' using errcode='restrict_violation';
 end if;
 if new.superseded_by_id is distinct from old.superseded_by_id then
  if old.superseded_by_id is not null or new.superseded_by_id is null or new.superseded_by_id=new.id then
   raise exception 'artifact successor may be assigned once' using errcode='restrict_violation';
  end if;
  select created_at into successor_created from orchestration.artifact
   where tenant_id=old.tenant_id and id=new.superseded_by_id;
  if successor_created is null or successor_created<=old.created_at then
   raise exception 'artifact successor must be newer and same-tenant' using errcode='check_violation';
  end if;
 end if;
 retiring := new.storage_state='failed' and new.registration_error_class is not distinct from 'retired' and new.available_at is null
  and exists(select 1 from orchestration.artifact_tombstone t where t.tenant_id=new.tenant_id and t.artifact_id=new.id);
 if new.storage_state is distinct from old.storage_state then
  if not ((old.storage_state='pending' and new.storage_state in('available','failed'))
       or (old.storage_state='failed' and new.storage_state='available')
       or retiring) then
   raise exception 'invalid artifact storage-state transition' using errcode='restrict_violation';
  end if;
 else
  if not retiring and (new.available_at is distinct from old.available_at
     or new.registration_error_class is distinct from old.registration_error_class) then
   raise exception 'artifact storage metadata requires a state transition' using errcode='restrict_violation';
  end if;
 end if;
 return new;
end $$;
revoke all on function orchestration.artifact_guard() from public;
commit;
