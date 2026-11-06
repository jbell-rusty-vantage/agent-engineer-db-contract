-- Immutable claim/report inputs use the existing verification.v1 CAS ledger.
-- This vocabulary registration grants no operation, worker or reviewer authority.
begin;
set local lock_timeout = '10s';
set local statement_timeout = '120s';

insert into orchestration.artifact_type(code, description) values
 ('verification_claims_artifact', 'Immutable claim assertions and declared evidence; not verified judgments'),
 ('verification_report_ledger', 'Immutable report assertion spans and declared citation edges; not verified judgments'),
 ('verification_report_result', 'Immutable report-wide mechanical gate bound to a sealed verification run'),
 ('verification_parse_result', 'Immutable canonical parser custody result; no extraction or policy admission'),
 ('verification_audit_bundle', 'Portable sealed verification audit bundle; must pass signature and content checks'),
 ('verification_adjudication_packet', 'Bounded immutable review request with original evidence custody'),
 ('verification_adjudication_decision', 'Append-only authorized reviewer decision bound to a review packet')
on conflict(code) do nothing;

commit;
