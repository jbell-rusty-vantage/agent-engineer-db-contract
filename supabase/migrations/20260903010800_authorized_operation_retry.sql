-- Permit the API's explicit failed -> queued retry transition while preserving
-- immutable operation identity, request, receipts, and terminal outcomes.
begin;

create or replace function knowledge_service.guard_operation_terminal()
returns trigger language plpgsql set search_path='' as $$
declare
  immutable_old jsonb;
  immutable_new jsonb;
begin
  if tg_op='DELETE' then
    raise exception '% state cannot be deleted',tg_table_name using errcode='restrict_violation';
  end if;

  if old.status='failed' and new.status='queued' then
    if tg_table_name='operation' then
      immutable_old:=to_jsonb(old)-array['status','completed_at','row_version','updated_at'];
      immutable_new:=to_jsonb(new)-array['status','completed_at','row_version','updated_at'];
    else
      immutable_old:=to_jsonb(old)-array['status','max_attempts','available_at','completed_at','row_version','updated_at'];
      immutable_new:=to_jsonb(new)-array['status','max_attempts','available_at','completed_at','row_version','updated_at'];
    end if;
    if immutable_new is distinct from immutable_old or new.completed_at is not null then
      raise exception 'retry may only reset execution state' using errcode='restrict_violation';
    end if;
  elsif old.status in ('succeeded','failed','cancelled','superseded') then
    raise exception 'terminal % state is immutable',tg_table_name using errcode='restrict_violation';
  end if;

  new.row_version:=old.row_version+1;
  new.updated_at:=clock_timestamp();
  return new;
end $$;

commit;
