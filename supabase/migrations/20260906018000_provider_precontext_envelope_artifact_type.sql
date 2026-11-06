begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_provider_precontext_envelope','Restricted request-bound lineage envelope for a content-addressed provider precontext projection')
on conflict(code) do update set description=excluded.description;
commit;
