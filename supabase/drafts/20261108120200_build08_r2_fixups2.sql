-- Build 08 R2 draft, fixup 2: vector_item_guard must ignore generated tsvector columns in BEFORE UPDATE.
begin;
create or replace function retrieval.vector_item_guard() returns trigger language plpgsql set search_path = '' as $$
declare successor_created timestamptz; begin
 if tg_op='DELETE' then raise exception 'retrieval.vector_item is append-only' using errcode='restrict_violation'; end if;
 -- generated columns (search_tsv, search_tsv_en) are not computed yet in a BEFORE trigger, so they are excluded from the comparison
 if (to_jsonb(new)-'{lifecycle,search_tsv,search_tsv_en}'::text[]) = (to_jsonb(old)-'{lifecycle,search_tsv,search_tsv_en}'::text[]) and old.lifecycle='active' and new.lifecycle in ('retired','superseded') then return new; end if;
 if (to_jsonb(new)-'{superseded_by_id,search_tsv,search_tsv_en}'::text[]) is distinct from (to_jsonb(old)-'{superseded_by_id,search_tsv,search_tsv_en}'::text[])
    or old.superseded_by_id is not null or new.superseded_by_id is null or new.superseded_by_id=new.id then
  raise exception 'vector item is immutable; only a first successor assignment or retirement is allowed' using errcode='restrict_violation';
 end if;
 select created_at into successor_created from retrieval.vector_item where tenant_id=old.tenant_id and id=new.superseded_by_id;
 if successor_created is null or successor_created<=old.created_at then raise exception 'vector successor must be newer and same-tenant' using errcode='check_violation'; end if;
 return new;
end $$;

commit;
