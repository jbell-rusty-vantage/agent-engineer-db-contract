-- Compact inspection receipts are distinct from the sealed audit bundle they inspect.
-- This vocabulary row grants no signing, replay, reviewer, or operation authority.
begin;
set local lock_timeout = '10s';
set local statement_timeout = '120s';

insert into orchestration.artifact_type(code, description) values
 ('verification_audit_inspection_result', 'Immutable compact inspection result bound to an exact signed audit bundle; no new policy admission')
on conflict(code) do nothing;

commit;
