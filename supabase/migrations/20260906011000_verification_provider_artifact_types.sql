begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_provider_input','Restricted bytes supplied to a bounded verification provider call'),
 ('verification_provider_request','Exact restricted outbound bounded verification provider request'),
 ('verification_provider_raw_response','Restricted exact raw response from a bounded verification provider'),
 ('verification_provider_precontext','Restricted provider precontext projection retained outside semantic model context')
on conflict(code) do update set description=excluded.description;
commit;
