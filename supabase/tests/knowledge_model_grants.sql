begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(1);
set local app.tenant_id = '00000000-0000-7000-8000-000000000001';
do $$ begin
 if has_table_privilege('pipeline_agent','temporal.segment','INSERT') then raise exception 'pipeline has direct temporal write'; end if;
 if has_table_privilege('executor_service','temporal.segment','INSERT') then raise exception 'executor has direct temporal write'; end if;
 if has_table_privilege('service_role','corpus.relationship','INSERT') then raise exception 'service role bypasses admission'; end if;
 if has_function_privilege('pipeline_agent','temporal.begin_batch(bigint)','EXECUTE') then raise exception 'pipeline may open batch'; end if;
 if not has_function_privilege('executor_service','temporal.begin_batch(bigint)','EXECUTE') then raise exception 'executor cannot open batch'; end if;
 if has_function_privilege('anon','api.entity_card(uuid)','EXECUTE') then raise exception 'anonymous API access'; end if;
end $$;
set local role executor_service;
select temporal.begin_batch(0);
reset role;
select pass('knowledge_model_grants invariants hold');
select * from finish();
rollback;
