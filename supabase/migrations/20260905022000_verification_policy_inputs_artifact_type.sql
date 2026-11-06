-- Immutable recorded mechanical, semantic, authority, risk, and downstream-use inputs for offline policy replay.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_policy_inputs','Immutable recorded verification policy inputs used to recompute a decision without semantic provider calls')
on conflict(code) do update set description=excluded.description;

commit;
