begin;
-- Raw provider precontext is content-addressed once. A scoped envelope retains
-- its exact emitted bytes without changing the raw artifact's immutable parents.
insert into orchestration.artifact_type(code,description) values
 ('verification_structured_extraction_precontext','Operation-bound envelope preserving exact replay-emitted provider precontext')
on conflict(code) do update set description=excluded.description;
commit;
