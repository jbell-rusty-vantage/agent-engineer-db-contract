begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(13);

select extensions.has_table('evidence','source_provider_attempt','provider requests have a durable attempt ledger');
select extensions.has_column('evidence','provider_result','source_provider_attempt_id','provider results bind to one durable attempt');
select extensions.has_column('evidence','source_encounter','source_provider_attempt_id','source encounters retain discovery-attempt lineage');
select extensions.has_column('evidence','source_encounter','requested_url','encounters retain the requested URL');
select extensions.has_column('evidence','source_encounter','final_url','encounters retain the final URL after redirects');
select extensions.has_column('evidence','source_encounter','redirect_urls','encounters retain the redirect chain');
select extensions.has_column('evidence','source_provider_attempt','requested_urls','attempts retain requested URLs even when a provider fails');
select extensions.has_column('evidence','source_provider_attempt','completion_sha256','terminal completions retain a parity digest');
select extensions.has_column('evidence','source_encounter','failure_code','failure encounters preserve the failure reason');
select extensions.ok(exists(select 1 from pg_constraint where conrelid='evidence.source_provider_attempt'::regclass and contype='u' and pg_get_constraintdef(oid) like '%idempotency_key%'), 'attempt idempotency is database-enforced');
select extensions.ok(exists(select 1 from pg_constraint where conrelid='evidence.provider_result'::regclass and conname='provider_result_tenant_attempt_fk'), 'provider results retain tenant-scoped attempt lineage');
select extensions.ok(exists(select 1 from pg_constraint where conrelid='evidence.source_encounter'::regclass and conname='source_encounter_tenant_attempt_fk'), 'encounters retain tenant-scoped attempt lineage');
select extensions.ok(exists(select 1 from pg_proc where oid='evidence.rebuild_source_state()'::regprocedure), 'attempt recording reuses the canonical source-state projection');

select * from extensions.finish();
rollback;
