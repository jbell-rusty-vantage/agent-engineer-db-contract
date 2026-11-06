begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_structured_extraction_source_custody','Canonical listed-file source bytes and hashes for structured extraction runtime custody')
on conflict(code) do update set description=excluded.description;

-- Add guards instead of rewriting already-applied provenance migrations.
create function orchestration.guard_structured_extraction_source_custody()
returns trigger language plpgsql set search_path='' as $$
declare source_id uuid; source_sha text;
begin
 if tg_table_name='verification_structured_extraction_execution' then
  source_id:=new.dirty_artifact_id; source_sha:=new.dirty_sha256;
 else
  select e.dirty_artifact_id,e.dirty_sha256 into source_id,source_sha
   from orchestration.verification_structured_extraction_execution e where e.tenant_id=new.tenant_id and e.operation_id=new.operation_id;
 end if;
 if source_id is not null and not orchestration.verification_artifact_is_admitted(new.tenant_id,source_id,'verification_structured_extraction_source_custody',source_sha) then
  raise exception 'structured extraction typed source custody required' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_execution_source_guard before insert
 on orchestration.verification_structured_extraction_execution for each row execute function orchestration.guard_structured_extraction_source_custody();
create trigger verification_structured_extraction_publication_source_guard before insert
 on orchestration.verification_structured_extraction_publication for each row execute function orchestration.guard_structured_extraction_source_custody();
commit;
