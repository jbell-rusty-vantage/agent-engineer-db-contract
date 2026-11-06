begin;

insert into orchestration.artifact_type(code,description) values
 ('canonical_source_projection','Canonical source representation derived from immutable capture bytes for selector replay')
on conflict(code) do update set description=excluded.description;

commit;
