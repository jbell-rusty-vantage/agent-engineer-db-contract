-- Registers the sealed, server-resolved runtime principal binding used by claims/report audit replay.
-- Apply through the canonical migration runner before enabling a native claims/report proof that emits this artifact.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_runtime_principal_binding','Canonical server-resolved runtime principal binding retained for claims and report audit replay')
on conflict(code) do update set description=excluded.description;

commit;
