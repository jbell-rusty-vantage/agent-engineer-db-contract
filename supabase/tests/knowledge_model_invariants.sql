begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(1);
set local app.tenant_id='00000000-0000-7000-8000-000000000001';
do $$ declare i uuid;r uuid;e uuid;
begin
 if(select count(*) from pg_inherits where inhparent='retrieval.vector_item_embedding_1536'::regclass)<>11 then raise exception 'expected eleven vector partitions';end if;
 if(select count(*) from pg_index idx join pg_class c on c.oid=idx.indexrelid join pg_am am on am.oid=c.relam where am.amname='hnsw' and idx.indrelid in(select inhrelid from pg_inherits where inhparent='retrieval.vector_item_embedding_1536'::regclass))<>11 then raise exception 'expected eleven HNSW indexes';end if;
 begin
  perform temporal.begin_batch();
  set constraints all immediate;
  raise exception 'unsealed empty batch was accepted';
 exception when check_violation then null;end;
 set constraints all deferred;
 perform set_config('temporal.k','999',true);
 if temporal.current_k() is not null then raise exception 'forged GUC opened a batch';end if;
 if temporal.payload_valid('{"name":2}','{"type":"object","properties":{"name":{"type":"string"}},"required":["name"]}') then raise exception 'JSON schema validation failed';end if;
 insert into orchestration.operation_intent(intent_type,payload,idempotency_key) values('upsert_entity','{}','km-invariants-'||util.uuidv7()) returning id into i;
 insert into orchestration.operation_receipt(intent_id,executor_version,outcome) values(i,'test','applied') returning id into r;
 begin
  insert into corpus.entity(tenant_id,kind,display_name,slug,created_by_receipt_id) values('11111111-1111-7111-8111-111111111111','person','Bad tenant','bad-tenant',r);
  raise exception 'cross-tenant receipt accepted';
 exception when raise_exception then if sqlerrm='cross-tenant receipt accepted' then raise;end if;end;
end $$;
select pass('knowledge_model_invariants invariants hold');
select * from finish();
rollback;
