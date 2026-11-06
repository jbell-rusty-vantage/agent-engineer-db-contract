begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(1);
set local app.tenant_id = '00000000-0000-7000-8000-000000000001';
do $$ declare i uuid;r uuid;a uuid;b uuid;
begin
 insert into orchestration.operation_intent(intent_type,payload,idempotency_key) values('upsert_entity','{}','km-relation:'||util.uuidv7()) returning id into i;
 insert into orchestration.operation_receipt(intent_id,executor_version,outcome) values(i,'test','applied') returning id into r;
 insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('person','Person','test-person',r) returning id into a;
 insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('paper','Paper','test-paper',r) returning id into b;
 perform temporal.begin_batch();
 begin
  perform temporal.assert_relationship('employed_by',a,b,tstzrange(now(),null,'[)'));raise exception 'invalid endpoint pair accepted';
 exception when check_violation then null;end;
 begin
  perform temporal.assert_relationship('authored_by',b,a,tstzrange(now(),null,'[)'));raise exception 'non-temporal interval accepted';
 exception when raise_exception then if sqlerrm='non-temporal interval accepted' then raise;end if;end;
 perform temporal.assert_relationship('authored_by',b,a);
 perform temporal.commit_batch(r,'km-relations',repeat('d',64));
 set constraints all immediate;
end $$;
select pass('knowledge_model_relationship invariants hold');
select * from finish();
rollback;
