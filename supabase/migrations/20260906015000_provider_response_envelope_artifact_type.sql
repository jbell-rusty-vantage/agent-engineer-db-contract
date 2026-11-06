begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_provider_response_envelope','Restricted request-bound lineage envelope for a content-addressed raw provider response')
on conflict(code) do update set description=excluded.description;
commit;
