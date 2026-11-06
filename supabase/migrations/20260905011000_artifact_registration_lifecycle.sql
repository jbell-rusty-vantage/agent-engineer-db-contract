-- Reserve canonical artifact identities before object upload and expose incomplete
-- writes explicitly for reconciliation. Existing rows are known available.
begin;

alter table orchestration.artifact
 add column storage_state text not null default 'available'
  check(storage_state in('pending','available','failed')),
 add column available_at timestamptz default now(),
 add column registration_error_class text;

alter table orchestration.artifact drop constraint verification_bucket_cas_path_ck;
alter table orchestration.artifact add constraint verification_bucket_cas_path_ck check(
 verification_contract_version is null
 or (storage_bucket='ai-engineer-cloud-bucket'
     and object_path ~ ('^'||tenant_id::text||'/[0-9a-f]{2}/[0-9a-f]{64}$')
     and split_part(object_path,'/',2)=left(sha256,2)
     and split_part(object_path,'/',3)=sha256
     and media_type is not null and btrim(media_type)<>''
     and size_bytes is not null and size_bytes>=0)
);
alter table orchestration.artifact add constraint artifact_storage_lifecycle_ck check(
 (storage_state='pending' and available_at is null and registration_error_class is null)
 or (storage_state='available' and available_at is not null and registration_error_class is null)
 or (storage_state='failed' and available_at is null and registration_error_class is not null)
);

create or replace function orchestration.artifact_guard() returns trigger
language plpgsql set search_path='' as $$
declare successor_created timestamptz;
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
 if new.storage_state is distinct from old.storage_state then
  if not ((old.storage_state='pending' and new.storage_state in('available','failed'))
       or (old.storage_state='failed' and new.storage_state='available')) then
   raise exception 'invalid artifact storage-state transition' using errcode='restrict_violation';
  end if;
 else
  if new.available_at is distinct from old.available_at
     or new.registration_error_class is distinct from old.registration_error_class then
   raise exception 'artifact storage metadata requires a state transition' using errcode='restrict_violation';
  end if;
 end if;
 return new;
end $$;

create index artifact_pending_storage_idx on orchestration.artifact(tenant_id,created_at)
 where storage_state in('pending','failed');

comment on column orchestration.artifact.storage_state is
 'Registration-first object lifecycle. Receipts may only reference available rows; pending/failed rows are reconciliation evidence.';

commit;
