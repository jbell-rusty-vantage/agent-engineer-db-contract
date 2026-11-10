-- Build 08 loop 2 draft, fixup 3 (2026-11-09): D-35 the version_of pair check names its pairs explicitly; the new
-- benchmark_version -> benchmark pair joins the list (the pair list is the data-level rule behind taxonomy.relationship_kind.version_of).
begin;
create or replace function catalog.check_relationship_kinds() returns trigger language plpgsql set search_path = '' as $$
declare f text; t text; r taxonomy.relationship_kind;
begin
 select kind into strict f from catalog.entity where tenant_id=new.tenant_id and id=new.from_entity_id;
 select kind into strict t from catalog.entity where tenant_id=new.tenant_id and id=new.to_entity_id;
 select * into strict r from taxonomy.relationship_kind where code=new.kind;
 if not(f=any(r.from_kinds)) or not(t=any(r.to_kinds)) then raise exception 'invalid relationship endpoint kinds' using errcode='23514'; end if;
 if new.kind='version_of' and (f,t) not in (('product_version','product'),('ai_model_version','ai_model'),('library_release','library'),('ai_protocol_version','ai_protocol'),('benchmark_version','benchmark')) then raise exception 'invalid version pair' using errcode='23514'; end if;
 return new;
end $$;
comment on function catalog.check_relationship_kinds is 'Relationship endpoints must match the kind vocabulary; version_of pairs are enumerated: product_version→product, ai_model_version→ai_model, library_release→library, ai_protocol_version→ai_protocol, benchmark_version→benchmark (loop 2).';
commit;
