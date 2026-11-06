begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_provider_cost_lookup','Restricted provider generation-cost lookup envelope linked to the original response evidence')
on conflict(code) do update set description=excluded.description;
commit;
