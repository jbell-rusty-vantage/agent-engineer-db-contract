-- Registered native parser output and parent-specific admission envelopes.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_parser_native_output','Bounded native parser response retained before canonical projection admission'),
 ('verification_canonical_projection','Strict canonical selector projection content; parent-specific lineage is retained by a transformation envelope'),
 ('verification_transformation_envelope','Canonical authenticated binding between capture bytes, native parser output, canonical projection, and parser deployment identity')
on conflict(code) do update set description=excluded.description;

commit;
