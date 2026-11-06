begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_provider_reconciliation','Operator-signed original provider accounting decision with immutable evidence; never authorizes redispatch')
on conflict(code) do update set description=excluded.description;
commit;
