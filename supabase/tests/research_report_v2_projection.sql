-- Sprint V SV-08: research-report.v2 domain projection, exact package read and native use guards
-- (20261024010100_research_report_v2_projection.sql, 20261024010200_research_admission_normalized_values.sql,
-- 20261025010200_research_admission_values_required.sql) over the common knowledge_verification component 2.4.0 (signed
-- seals, normalized values on decisions and required on every writer admission, scoped reviewer grants).
-- Run as the database owner (postgres) on a DISPOSABLE project where `knowledge-db install --application ai-engineer`
-- preceded `db:migrate`. Every block raises on failure; a silent run is a pass; the whole file rolls back.
-- Concurrency (two real sessions) is proved separately by research_report_v2_concurrency.mjs.
\set ON_ERROR_STOP on
begin;
set local role postgres;
select set_config('app.tenant_id', '00000000-0000-7000-8000-0000000008a1', true);
create function pg_temp.d(t text) returns text language sql immutable as $$ select 'sha256:' || encode(sha256(convert_to(t, 'UTF8')), 'hex') $$;
-- Verification-snapshot manifest digests of runs a001/a002 (canonical manifest bytes; see the seal fixture below).
create function pg_temp.md(n int) returns text language sql immutable as $$
  select case n when 1 then 'sha256:5938bc151d876fb1517aa09d9dc4d3717997c087efd90550dcc91f316321a984' when 2 then 'sha256:0973b60d14efc871fd93c96e55c59977d0ec53c2e0b436cd757ce0ba3b86d04b' end $$;
-- Normalized values carried by every decision here: {"value":42} (K01 canonical bytes), and its digest.
create function pg_temp.nv() returns jsonb language sql immutable as $$ select '{"value":42}'::jsonb $$;
create function pg_temp.nvd() returns text language sql immutable as $$ select pg_temp.d('{"value":42}') $$;

-- ---------------------------------------------------------------------------------------------------------------
-- Fixtures in the component (owner inserts; the component's own triggers still run).
-- ---------------------------------------------------------------------------------------------------------------
insert into knowledge_verification.origin (tenant_id, origin_digest, kind, installation_id, application_id, issuer, subject, identity)
values (current_setting('app.tenant_id')::uuid, pg_temp.d('origin'), 'standalone', 'sv08-installation', 'ai-engineer', 'sv08-test-issuer', 'sv08', '{}');
insert into knowledge_verification.verification_task (tenant_id, task_id, schema_version, task_digest, original_task_ref, use_name, audience, minimum_risk, rubric_ref, policy_ref, body)
values (current_setting('app.tenant_id')::uuid, 'task-sv08', 'research-core.task.v2', pg_temp.d('task'), '{}', 'publish', 'internal', 'low', 'rubric:sv08', 'policy:sv08', '{}');
insert into knowledge_verification.verification_run (tenant_id, run_id, task_id, binding, originating_origin_digest)
values (current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000a001', 'task-sv08', 'aiengineer-postgres', pg_temp.d('origin')),
       (current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000a002', 'task-sv08', 'aiengineer-postgres', pg_temp.d('origin')),
       (current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000a003', 'task-sv08', 'aiengineer-postgres', pg_temp.d('origin'));
insert into knowledge_verification.artifact_custody (tenant_id, artifact_id, digest, byte_length, media_type, custody_kind, inline_bytes)
select current_setting('app.tenant_id')::uuid, name, 'sha256:' || encode(sha256(b), 'hex'), octet_length(b), media, 'inline', b
  from (values ('sb-1', 'application/json', convert_to('{"revision":1}', 'UTF8')),
               ('body-1', 'text/markdown', convert_to('# Report revision 1', 'UTF8')),
               ('ledger-1', 'application/json', convert_to('{"ledger":1}', 'UTF8')),
               ('sb-2', 'application/json', convert_to('{"revision":2}', 'UTF8')),
               ('body-2', 'text/markdown', convert_to('# Report revision 2', 'UTF8')),
               ('ledger-2', 'application/json', convert_to('{"ledger":2}', 'UTF8')),
               ('sb-3', 'application/json', convert_to('{"revision":3}', 'UTF8')),
               ('body-3', 'text/markdown', convert_to('# Report revision 3 (unsealed)', 'UTF8')),
               ('ledger-3', 'application/json', convert_to('{"ledger":3}', 'UTF8'))) v(name, media, b);
insert into knowledge_verification.assertion (tenant_id, assertion_id, logical_id, schema_version, digest, kind, proposition, profile_ref, qualifiers, qualifiers_digest, producer_origin_digest, body)
values (current_setting('app.tenant_id')::uuid, 'assertion-1', 'logical-1', 'research-core.assertion.v2', pg_temp.d('assertion-1'), 'world_fact', 'X holds', 'profile:sv08', '{}', pg_temp.d('qualifiers'), pg_temp.d('origin'), '{}');
-- record.kind is the pinned report-kind Ref required from component 2.1.0 (0004); harmless on 2.0.0.
insert into knowledge_verification.report_revision (tenant_id, report_revision_id, report_id, revision, schema_version, report_kind, task_id, run_id,
  structured_body_artifact_id, body_artifact_id, ledger_artifact_id, body_digest, renderer_version, assertion_refs, time_coverage, record, digest)
select current_setting('app.tenant_id')::uuid, 'rr-' || n, 'report-sv08', n, 'research-report.v2', 'evidence_report', 'task-sv08', ('00000000-0000-7000-8000-00000000a00' || n)::uuid,
       'sb-' || n, 'body-' || n, 'ledger-' || n, (select digest from knowledge_verification.artifact_custody where artifact_id = 'body-' || n), 'renderer:1',
       case when n = 3 then '[]'::jsonb else jsonb_build_array(jsonb_build_object('kind', 'assertion', 'id', 'assertion-1', 'version', 'research-core.assertion.v2',
         'digest', pg_temp.d('assertion-1'), 'tenant', current_setting('app.tenant_id')::uuid, 'binding', 'aiengineer-postgres')) end,
       '{}', jsonb_build_object('kind', jsonb_build_object('kind', 'report_kind', 'id', 'evidence_report@1.0.0', 'version', 'research-report-kind.v1', 'digest', pg_temp.d('kind'))),
       pg_temp.d('rr-' || n)
  from generate_series(1, 3) n;
-- Seals (2.2.0): a pinned TEST-ONLY Ed25519 key and real 64-byte signatures over research-core sealSigningBytes
-- (K01 canonical {keyId, manifestDigest, signedAt, signer}), generated by research_report_v2_seal_fixture.mjs.
insert into knowledge_verification.seal_signing_key (key_id, algorithm, public_key, status, issuer)
values ('sv08-test-key-sql', 'Ed25519', '\x3f8fcb9c002940f3cdbe4896fb8530130cbbcd29f190b050b0c5a2a094f31cf8'::bytea, 'active', 'sv08-test') on conflict (key_id) do nothing;
select knowledge_verification.seal_run(current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000a001', null, 'verification_snapshot',
         '{"families":{"capture":"capture-family","claims":"claims-family","observations":"observations-family","report":"report-family"},"predecessor":null,"run":{"id":"00000000-0000-7000-8000-00000000a001"},"snapshot":"verification_snapshot"}'::jsonb, 'sha256:5938bc151d876fb1517aa09d9dc4d3717997c087efd90550dcc91f316321a984', '{"capture":"capture-family","claims":"claims-family","observations":"observations-family","report":"report-family"}'::jsonb, 'signer:sv08',
         'Ed25519', 'sv08-test-key-sql', '\x6392669fb83aa88fbbabd297a5d52bfd1d44536a9b6b09054c8d70534359271346b03c34a5fc51c61b0d00b9f616f0255825dab6a80a836b1f27c465d2ae180b'::bytea, '{"keyId":"sv08-test-key-sql","manifestDigest":"sha256:5938bc151d876fb1517aa09d9dc4d3717997c087efd90550dcc91f316321a984","signedAt":"2026-10-25T00:00:00Z","signer":"signer:sv08"}'::jsonb);
select knowledge_verification.seal_run(current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000a002', null, 'verification_snapshot',
         '{"families":{"capture":"capture-family","claims":"claims-family","observations":"observations-family","report":"report-family"},"predecessor":null,"run":{"id":"00000000-0000-7000-8000-00000000a002"},"snapshot":"verification_snapshot"}'::jsonb, 'sha256:0973b60d14efc871fd93c96e55c59977d0ec53c2e0b436cd757ce0ba3b86d04b', '{"capture":"capture-family","claims":"claims-family","observations":"observations-family","report":"report-family"}'::jsonb, 'signer:sv08',
         'Ed25519', 'sv08-test-key-sql', '\x692a477ea835b72cf755f0824f038088999bc52e0a0905985e0adc77218bdf04ec8d9c7df867eede6447fd250d10c04fbf3a33fdddf95115826d54218eb7f20c'::bytea, '{"keyId":"sv08-test-key-sql","manifestDigest":"sha256:0973b60d14efc871fd93c96e55c59977d0ec53c2e0b436cd757ce0ba3b86d04b","signedAt":"2026-10-25T00:00:00Z","signer":"signer:sv08"}'::jsonb);
-- An unpinned key refuses (SEAL_INVALID) before any CAS.
do $$
begin
  perform knowledge_verification.seal_run(current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000a003', null, 'verification_snapshot',
    jsonb_build_object('snapshot', 'verification_snapshot', 'run', jsonb_build_object('id', '00000000-0000-7000-8000-00000000a003'), 'predecessor', null),
    pg_temp.d('manifest-3'), '{"capture":"capture-family","claims":"claims-family","observations":"observations-family","report":"report-family"}'::jsonb, 'signer:sv08', 'Ed25519', 'sv08-unpinned-key', '\x6392669fb83aa88fbbabd297a5d52bfd1d44536a9b6b09054c8d70534359271346b03c34a5fc51c61b0d00b9f616f0255825dab6a80a836b1f27c465d2ae180b'::bytea,
    jsonb_build_object('keyId', 'sv08-unpinned-key', 'manifestDigest', pg_temp.d('manifest-3'), 'signedAt', '2026-10-25T00:00:00Z', 'signer', 'signer:sv08'));
  raise exception 'fixture: unpinned key sealed a run';
exception when integrity_constraint_violation then
  if sqlerrm <> 'SEAL_INVALID' then raise; end if;
end $$;
select knowledge_verification.bind_effect(current_setting('app.tenant_id')::uuid, 'effect-' || n, pg_temp.d('payload-' || n), pg_temp.d('origin'), pg_temp.d('bound-' || n))
  from generate_series(1, 5) n;
-- Decisions (2.2.0): qualifiers digest only for assertion subjects; normalized values + digest equal record.normalizedValues;
-- record.report names the revision so scoped grants can resolve the report kind.
insert into knowledge_verification.use_decision (tenant_id, use_decision_id, schema_version, subject_kind, subject_id, subject_digest, run_id, bound_effect_digest,
  use_name, audience, disposition, policy_ref, rubric_ref, qualifiers_digest, revocation_epoch, record, digest, normalized_values, normalized_values_digest)
values
  (current_setting('app.tenant_id')::uuid, 'ud-ok', 'research-core.use_decision.v2', 'report', 'rr-1', pg_temp.d('rr-1'), '00000000-0000-7000-8000-00000000a001', pg_temp.d('bound-1'),
   'publish', 'internal', 'admitted', 'policy:sv08', 'rubric:sv08', null, 0,
   jsonb_build_object('report', jsonb_build_object('id', 'rr-1'), 'normalizedValues', pg_temp.nv()), pg_temp.d('ud-ok'), pg_temp.nv(), pg_temp.nvd()),
  (current_setting('app.tenant_id')::uuid, 'ud-revoked', 'research-core.use_decision.v2', 'report', 'rr-1', pg_temp.d('rr-1'), '00000000-0000-7000-8000-00000000a001', pg_temp.d('bound-2'),
   'publish', 'internal', 'admitted', 'policy:sv08', 'rubric:sv08', null, 0,
   jsonb_build_object('report', jsonb_build_object('id', 'rr-1'), 'normalizedValues', pg_temp.nv()), pg_temp.d('ud-revoked'), pg_temp.nv(), pg_temp.nvd()),
  (current_setting('app.tenant_id')::uuid, 'ud-held', 'research-core.use_decision.v2', 'report', 'rr-2', pg_temp.d('rr-2'), '00000000-0000-7000-8000-00000000a002', pg_temp.d('bound-3'),
   'publish', 'internal', 'held', 'policy:sv08', 'rubric:sv08', null, 0,
   jsonb_build_object('report', jsonb_build_object('id', 'rr-2'), 'normalizedValues', pg_temp.nv()), pg_temp.d('ud-held'), pg_temp.nv(), pg_temp.nvd()),
  (current_setting('app.tenant_id')::uuid, 'ud-assertion', 'research-core.use_decision.v2', 'assertion', 'assertion-1', pg_temp.d('assertion-1'), '00000000-0000-7000-8000-00000000a002', pg_temp.d('bound-4'),
   'publish', 'internal', 'admitted', 'policy:sv08', 'rubric:sv08', pg_temp.d('qualifiers'), 0,
   jsonb_build_object('report', jsonb_build_object('id', 'rr-2'), 'normalizedValues', pg_temp.nv()), pg_temp.d('ud-assertion'), pg_temp.nv(), pg_temp.nvd());
-- Scoped reviewer grants (2.2.0): rev-1 covers publish/internal/evidence_report; rev-2 only the public audience.
insert into knowledge_verification.reviewer_grant (tenant_id, grant_id, reviewer_id, scope, granted_by)
values (current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000d001', 'rev-1',
        '{"uses":["publish"],"audiences":["internal"],"reportKinds":["evidence_report"]}', 'sv08-test'),
       (current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-00000000d002', 'rev-2',
        '{"uses":["publish"],"audiences":["public"],"reportKinds":["evidence_report"]}', 'sv08-test');
-- A review-conditioned decision, its approving adjudication (exact subject/effect/qualifiers, in-scope grant) and the
-- admitted successor that names that adjudication.
insert into knowledge_verification.use_decision (tenant_id, use_decision_id, schema_version, subject_kind, subject_id, subject_digest, run_id, bound_effect_digest,
  use_name, audience, disposition, conditions, policy_ref, rubric_ref, qualifiers_digest, revocation_epoch, record, digest, normalized_values, normalized_values_digest)
values (current_setting('app.tenant_id')::uuid, 'ud-review-base', 'research-core.use_decision.v2', 'report', 'rr-2', pg_temp.d('rr-2'), '00000000-0000-7000-8000-00000000a002',
        pg_temp.d('bound-5'), 'publish', 'internal', 'held', '["review_required"]', 'policy:sv08', 'rubric:sv08', null, 0,
        jsonb_build_object('report', jsonb_build_object('id', 'rr-2'), 'normalizedValues', pg_temp.nv()), pg_temp.d('ud-review-base'), pg_temp.nv(), pg_temp.nvd());
insert into knowledge_verification.adjudication (tenant_id, adjudication_id, subject_kind, subject_id, subject_digest, bound_effect_digest, reviewer_id, decision,
  rationale, digest, use_decision_id, qualifiers_digest)
values (current_setting('app.tenant_id')::uuid, 'adj-1', 'report', 'rr-2', pg_temp.d('rr-2'), pg_temp.d('bound-5'), 'rev-1', 'approve',
        'sv08 fixture approval', pg_temp.d('adj-1'), 'ud-review-base', null);
insert into knowledge_verification.use_decision (tenant_id, use_decision_id, schema_version, subject_kind, subject_id, subject_digest, run_id, bound_effect_digest,
  use_name, audience, disposition, conditions, policy_ref, rubric_ref, qualifiers_digest, revocation_epoch, reviewer_adjudication_id, supersedes_use_decision_id,
  record, digest, normalized_values, normalized_values_digest)
values (current_setting('app.tenant_id')::uuid, 'ud-review', 'research-core.use_decision.v2', 'report', 'rr-2', pg_temp.d('rr-2'), '00000000-0000-7000-8000-00000000a002',
        pg_temp.d('bound-5'), 'publish', 'internal', 'admitted', '["review_required"]', 'policy:sv08', 'rubric:sv08', null, 0, 'adj-1', 'ud-review-base',
        jsonb_build_object('report', jsonb_build_object('id', 'rr-2'), 'normalizedValues', pg_temp.nv()), pg_temp.d('ud-review'), pg_temp.nv(), pg_temp.nvd());
-- An out-of-scope reviewer cannot adjudicate the decision.
do $$
begin
  insert into knowledge_verification.adjudication (tenant_id, adjudication_id, subject_kind, subject_id, subject_digest, bound_effect_digest, reviewer_id, decision,
    rationale, digest, use_decision_id, qualifiers_digest)
  values (current_setting('app.tenant_id')::uuid, 'adj-2', 'report', 'rr-2', pg_temp.d('rr-2'), pg_temp.d('bound-5'), 'rev-2', 'approve',
          'out of scope', pg_temp.d('adj-2'), 'ud-review-base', null);
  raise exception 'fixture: out-of-scope reviewer adjudicated';
exception when insufficient_privilege then
  if sqlerrm <> 'REVIEWER_NOT_QUALIFIED' then raise; end if;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- T1 exact read of revision 1 and revision 2 (as app_reader): exact custody refs, digests, assertion refs, manifest index.
-- ---------------------------------------------------------------------------------------------------------------
set local role app_reader;
do $$
declare p record; n int;
begin
  for n in 1..2 loop
    select * into strict p from research.read_report_package(current_setting('app.tenant_id')::uuid, 'report-sv08', n);
    if p.revision <> n or p.report_revision_id <> 'rr-' || n or p.report_revision_digest <> pg_temp.d('rr-' || n) then
      raise exception 'T1 wrong revision returned for %: %', n, p.report_revision_id;
    end if;
    if p.body ->> 'artifactId' <> 'body-' || n or p.body ->> 'digest' <> (select digest from knowledge_verification.artifact_custody where artifact_id = 'body-' || n)
       or p.ledger ->> 'artifactId' <> 'ledger-' || n or p.structured_body ->> 'artifactId' <> 'sb-' || n or p.body ? 'inlineBytes' then
      raise exception 'T1 custody refs wrong for revision %: % %', n, p.body, p.ledger;
    end if;
    if jsonb_array_length(p.assertion_refs) <> 1 or p.assertion_refs -> 0 ->> 'digest' <> pg_temp.d('assertion-1') then
      raise exception 'T1 assertion refs wrong: %', p.assertion_refs;
    end if;
    if jsonb_array_length(p.manifest_index) <> 1 or p.manifest_index -> 0 ->> 'manifestDigest' <> pg_temp.md(n)
       or p.manifest_index -> 0 ->> 'manifestKind' <> 'verification_snapshot' or p.run_head_digest <> pg_temp.md(n) then
      raise exception 'T1 manifest index wrong: %', p.manifest_index;
    end if;
  end loop;
end $$;

-- T2 missing revision and an unsealed revision are EXACT_REVISION_UNAVAILABLE; no fallback to another revision.
do $$
begin
  perform * from research.read_report_package(current_setting('app.tenant_id')::uuid, 'report-sv08', 4);
  raise exception 'T2 missing revision was served';
exception when sqlstate 'KSA05' then
  if sqlerrm <> 'EXACT_REVISION_UNAVAILABLE' then raise; end if;
end $$;
do $$
begin
  perform * from research.read_report_package(current_setting('app.tenant_id')::uuid, 'report-sv08', 3);
  raise exception 'T2 unsealed revision was served';
exception when sqlstate 'KSA05' then null;
end $$;
do $$
begin
  perform * from research.read_report_package(current_setting('app.tenant_id')::uuid, 'report-sv08', null);
  raise exception 'T2 null revision was served';
exception when sqlstate 'KSA05' then null;
end $$;
-- Foreign tenant argument refused by the component tenant check.
do $$
begin
  perform * from research.read_report_package('00000000-0000-7000-8000-0000000008ff', 'report-sv08', 1);
  raise exception 'T2 foreign tenant was served';
exception when insufficient_privilege then null;
end $$;
-- app_reader can read but cannot run the write guard or write projections.
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0, pg_temp.nvd());
  raise exception 'T2 app_reader executed the write guard';
exception when insufficient_privilege then null;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- T3 admitted decision passes the guard inside the native transaction (as executor_service), and the native receipt +
-- canonical row bound to it commit-check cleanly; projections validate against the component.
-- ---------------------------------------------------------------------------------------------------------------
set local role executor_service;
do $$
declare a research.use_admission; b research.use_admission;
begin
  a := research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0, pg_temp.nvd());
  if a.xact_id <> pg_current_xact_id()::text::bigint or a.authoritative_epoch <> 0 or a.effect_key <> 'effect-1' then
    raise exception 'T3 admission row wrong: %', a;
  end if;
  b := research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0, pg_temp.nvd());  -- repeat: same row, re-checked
  if b is distinct from a then raise exception 'T3 repeat returned a different admission row'; end if;
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-assertion', pg_temp.d('bound-4'), 0, pg_temp.nvd());
end $$;

insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state)
values ('00000000-0000-7000-8000-00000000b001', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv08":"admitted"}', 'sv08-admitted', 'approved'),
       ('00000000-0000-7000-8000-00000000b002', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv08":"assertion"}', 'sv08-assertion', 'approved');
insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome, requires_admission, use_decision_id, bound_effect_digest)
values ('00000000-0000-7000-8000-00000000c001', '00000000-0000-7000-8000-00000000b001', 'sv08-test', 'applied', true, 'ud-ok', pg_temp.d('bound-1')),
       ('00000000-0000-7000-8000-00000000c002', '00000000-0000-7000-8000-00000000b002', 'sv08-test', 'applied', true, 'ud-assertion', pg_temp.d('bound-4'));
insert into knowledge.record (tenant_id, kind, title, statement, created_by_receipt_id)
values (current_setting('app.tenant_id')::uuid, 'technical_problem', 'SV-08 admitted write', 'written under an admitted use', '00000000-0000-7000-8000-00000000c001');
set constraints all immediate;  -- fire the deferred commit guards now: they must pass
set constraints all deferred;

insert into research.report_v2_revision (report_id, revision, report_revision_id, report_revision_digest, run_id, verification_snapshot_digest, report_kind, body_digest)
select 'report-sv08', n, 'rr-' || n, pg_temp.d('rr-' || n), ('00000000-0000-7000-8000-00000000a00' || n)::uuid, pg_temp.md(n), 'evidence_report',
       (select digest from knowledge_verification.artifact_custody where artifact_id = 'body-' || n)
  from generate_series(1, 2) n;
insert into research.report_v2_assertion (report_id, revision, assertion_ref_digest, assertion_id, assertion_kind)
values ('report-sv08', 2, pg_temp.d('assertion-1'), 'assertion-1', 'world_fact');
insert into research.report_v2_ingestion (use_decision_id, bound_effect_digest, report_id, revision, assertion_ref_digest, intent_id, receipt_id, outcome)
values ('ud-ok', pg_temp.d('bound-1'), 'report-sv08', 1, null, '00000000-0000-7000-8000-00000000b001', '00000000-0000-7000-8000-00000000c001', 'applied'),
       ('ud-assertion', pg_temp.d('bound-4'), 'report-sv08', 2, pg_temp.d('assertion-1'), '00000000-0000-7000-8000-00000000b002', '00000000-0000-7000-8000-00000000c002', 'applied');

-- Projection mismatches refuse: wrong digest, unsealed run, assertion not cited, decision subject mismatch.
do $$
begin
  insert into research.report_v2_revision (report_id, revision, report_revision_id, report_revision_digest, run_id, verification_snapshot_digest, report_kind, body_digest)
  values ('report-sv08', 3, 'rr-3', pg_temp.d('rr-3'), '00000000-0000-7000-8000-00000000a003', pg_temp.d('manifest-3'), 'evidence_report',
          (select digest from knowledge_verification.artifact_custody where artifact_id = 'body-3'));
  raise exception 'T3 unsealed revision projected';
exception when sqlstate 'KSA05' then null;
end $$;
do $$
begin
  insert into research.report_v2_assertion (report_id, revision, assertion_ref_digest, assertion_id, assertion_kind)
  values ('report-sv08', 1, pg_temp.d('assertion-1'), 'assertion-1', 'forecast');
  raise exception 'T3 assertion with the wrong kind projected';
exception when sqlstate 'KSA07' then null;
end $$;
do $$
declare edited boolean := false;
begin
  begin
    update research.report_v2_revision set body_digest = pg_temp.d('edited') where report_id = 'report-sv08' and revision = 1;
    edited := found;
  exception when insufficient_privilege or integrity_constraint_violation or raise_exception then null;
  end;
  if edited then raise exception 'T3 projection row was edited'; end if;
end $$;
reset role;
set local role postgres;
do $$
declare edited boolean := false;
begin
  begin
    update research.report_v2_revision set body_digest = pg_temp.d('edited') where report_id = 'report-sv08' and revision = 1;
    edited := found;
  exception when others then null;
  end;
  if edited then raise exception 'T3 owner edited an immutable projection row'; end if;
end $$;
set local role executor_service;

-- ---------------------------------------------------------------------------------------------------------------
-- T4 edited effect digest refuses (EFFECT_CONFLICT); held decision needs review; unknown decision is unresolved.
-- ---------------------------------------------------------------------------------------------------------------
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('edited-bound-1'), 0, pg_temp.nvd());
  raise exception 'T4 edited effect digest admitted';
exception when sqlstate 'KSA03' then
  if sqlerrm <> 'EFFECT_CONFLICT' then raise; end if;
end $$;
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-held', pg_temp.d('bound-3'), 0, pg_temp.nvd());
  raise exception 'T4 held decision admitted';
exception when sqlstate 'KSA02' then
  if sqlerrm <> 'REVIEW_REQUIRED' then raise; end if;
end $$;
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-missing', pg_temp.d('bound-1'), 0);
  raise exception 'T4 unknown decision admitted';
exception when sqlstate 'KSA04' then
  if sqlerrm <> 'UNRESOLVED_EFFECT' then raise; end if;
end $$;
-- Component 2.4.0: a writer that omits the normalized values digest of a decision that binds values is refused
-- (NORMALIZED_VALUES_REQUIRED -> UNRESOLVED_EFFECT KSA04, 20261025010200); the guard never falls back to no comparison.
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0);
  raise exception 'T4 a decision with normalized values was admitted without a digest';
exception when sqlstate 'KSA04' then
  if sqlerrm <> 'UNRESOLVED_EFFECT' then raise; end if;
end $$;
-- A direct insert cannot fake an admission: the insert trigger re-runs the component check.
do $$
begin
  insert into research.use_admission (use_decision_id, bound_effect_digest, xact_id, processed_epoch, authoritative_epoch, effect_key, normalized_values_digest)
  values ('ud-held', pg_temp.d('bound-3'), 0, 0, 0, 'effect-3', pg_temp.nvd());
  raise exception 'T4 direct insert faked an admission';
exception when sqlstate 'KSA02' then null;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- T4b normalized values (2.2.0): the presented digest must equal the decision's; scoped review gates admission.
-- ---------------------------------------------------------------------------------------------------------------
do $$
declare a research.use_admission;
begin
  a := research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0, pg_temp.nvd());
  if a.normalized_values_digest is distinct from pg_temp.nvd() then raise exception 'T4b admission did not record the normalized digest: %', a; end if;
  begin
    perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0, pg_temp.d('{"value":43}'));
    raise exception 'T4b mismatching normalized values admitted';
  exception when sqlstate 'KSA03' then
    if sqlerrm <> 'EFFECT_CONFLICT' then raise; end if;
  end;
  begin
    perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-review-base', pg_temp.d('bound-5'), 0, pg_temp.nvd());
    raise exception 'T4b superseded review base admitted';
  exception when sqlstate 'KSA01' then null;
  end;
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-review', pg_temp.d('bound-5'), 0, pg_temp.nvd());
end $$;
reset role;
set local role postgres;
update knowledge_verification.reviewer_grant set revoked_at = now()
 where tenant_id = current_setting('app.tenant_id')::uuid and grant_id = '00000000-0000-7000-8000-00000000d001';
set local role executor_service;
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-review', pg_temp.d('bound-5'), 0, pg_temp.nvd());
  raise exception 'T4b admitted after the reviewer grant was revoked';
exception when sqlstate 'KSA02' then
  if sqlerrm <> 'REVIEW_REQUIRED' then raise; end if;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- T5 a write to a guarded table under a receipt that declares a use decision, without admission, refuses at commit.
-- ---------------------------------------------------------------------------------------------------------------
do $$
begin
  insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state)
  values ('00000000-0000-7000-8000-00000000b003', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv08":"unadmitted"}', 'sv08-unadmitted', 'approved');
  insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome, requires_admission, use_decision_id, bound_effect_digest)
  values ('00000000-0000-7000-8000-00000000c003', '00000000-0000-7000-8000-00000000b003', 'sv08-test', 'applied', true, 'ud-revoked', pg_temp.d('bound-2'));
  insert into knowledge.record (tenant_id, kind, title, statement, created_by_receipt_id)
  values (current_setting('app.tenant_id')::uuid, 'technical_problem', 'SV-08 unadmitted write', 'must not commit', '00000000-0000-7000-8000-00000000c003');
  set constraints all immediate;
  raise exception 'T5 unadmitted receipt/canonical write passed the commit guard';
exception when sqlstate 'KSA06' then
  if sqlerrm <> 'ADMISSION_REQUIRED' then raise; end if;
end $$;
set constraints all deferred;
-- A receipt cannot declare admission without naming both the decision and the bound effect digest.
do $$
begin
  insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state)
  values ('00000000-0000-7000-8000-00000000b004', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv08":"half"}', 'sv08-half', 'approved');
  insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome, requires_admission, use_decision_id)
  values ('00000000-0000-7000-8000-00000000c004', '00000000-0000-7000-8000-00000000b004', 'sv08-test', 'applied', true, 'ud-ok');
  raise exception 'T5 half-bound receipt accepted';
exception when check_violation then null;
end $$;
-- Legacy receipts that name no decision are unaffected.
insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state)
values ('00000000-0000-7000-8000-00000000b005', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv08":"legacy"}', 'sv08-legacy', 'approved');
insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome)
values ('00000000-0000-7000-8000-00000000c005', '00000000-0000-7000-8000-00000000b005', 'sv08-test', 'applied');
insert into knowledge.record (tenant_id, kind, title, statement, created_by_receipt_id)
values (current_setting('app.tenant_id')::uuid, 'technical_problem', 'SV-08 legacy write', 'no decision named', '00000000-0000-7000-8000-00000000c005');
set constraints all immediate;
set constraints all deferred;

-- ---------------------------------------------------------------------------------------------------------------
-- T6 stale epoch holds (STALE_DECISION) until the caller has processed the authoritative epoch.
-- ---------------------------------------------------------------------------------------------------------------
select knowledge_verification.advance_revocation_epoch(current_setting('app.tenant_id')::uuid, 'sv08 source correction') as epoch_after_advance \gset
do $$
begin
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 0, pg_temp.nvd());
  raise exception 'T6 stale processed epoch admitted';
exception when sqlstate 'KSA01' then
  if sqlerrm <> 'STALE_DECISION' then raise; end if;
end $$;
do $$
declare a research.use_admission;
begin
  a := research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), 1, pg_temp.nvd());
  if a.authoritative_epoch <> 1 or a.processed_epoch <> 1 then raise exception 'T6 caught-up admission wrong: %', a; end if;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- T7 revoked decision refuses (invalidation closure lists it); an unrelated decision stays admissible.
-- ---------------------------------------------------------------------------------------------------------------
do $$
declare inv knowledge_verification.invalidation;
begin
  inv := knowledge_verification.record_invalidation(current_setting('app.tenant_id')::uuid, 'report', 'rr-1', 'sv08 explicit revocation');
  -- closure still open: every admission holds
  begin
    perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), inv.epoch, pg_temp.nvd());
    raise exception 'T7 admitted while the invalidation closure was incomplete';
  exception when sqlstate 'KSA01' then null;
  end;
  insert into knowledge_verification.invalidation_affected (tenant_id, invalidation_id, affected_kind, affected_id)
  values (current_setting('app.tenant_id')::uuid, inv.invalidation_id, 'use_decision', 'ud-revoked');
  update knowledge_verification.invalidation set closure_processed_at = now()
   where tenant_id = current_setting('app.tenant_id')::uuid and invalidation_id = inv.invalidation_id;
  begin
    perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-revoked', pg_temp.d('bound-2'), inv.epoch, pg_temp.nvd());
    raise exception 'T7 revoked decision admitted';
  exception when sqlstate 'KSA01' then
    if sqlerrm <> 'STALE_DECISION' then raise; end if;
  end;
  perform research.assert_admitted_use(current_setting('app.tenant_id')::uuid, 'ud-ok', pg_temp.d('bound-1'), inv.epoch, pg_temp.nvd());
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- T8 privilege review: nothing new is reachable by PUBLIC, anon or authenticated; writes are executor_service only.
-- ---------------------------------------------------------------------------------------------------------------
reset role;
set local role postgres;
do $$
declare f text; t text; r text;
begin
  foreach f in array array['research.assert_admitted_use(uuid,text,text,bigint,text)', 'research.require_admitted_use(uuid,text,text,bigint,text)',
                           'research.read_report_package(uuid,text,integer)', 'research.require_receipt_admission()', 'research.guard_use_admission()',
                           'research.guard_report_v2_revision()', 'research.guard_report_v2_assertion()', 'research.guard_report_v2_ingestion()'] loop
    foreach r in array array['public', 'anon', 'authenticated'] loop
      if has_function_privilege(r, f, 'execute') then raise exception 'T8 % can execute %', r, f; end if;
    end loop;
  end loop;
  foreach t in array array['research.use_admission', 'research.report_v2_revision', 'research.report_v2_assertion', 'research.report_v2_ingestion'] loop
    foreach r in array array['public', 'anon', 'authenticated'] loop
      if has_table_privilege(r, t, 'select,insert,update,delete') then raise exception 'T8 % has privileges on %', r, t; end if;
    end loop;
    foreach r in array array['app_reader', 'pipeline_agent', 'control_plane', 'verifier_agent'] loop
      if has_table_privilege(r, t, 'insert,update,delete') then raise exception 'T8 % can write %', r, t; end if;
    end loop;
    if has_table_privilege('executor_service', t, 'update,delete') then raise exception 'T8 executor_service can rewrite %', t; end if;
  end loop;
  if not has_function_privilege('app_reader', 'research.read_report_package(uuid,text,integer)', 'execute') then raise exception 'T8 app_reader cannot read packages'; end if;
  if not has_function_privilege('pipeline_agent', 'research.read_report_package(uuid,text,integer)', 'execute') then raise exception 'T8 pipeline_agent cannot read packages'; end if;
  if has_function_privilege('pipeline_agent', 'research.assert_admitted_use(uuid,text,text,bigint,text)', 'execute') then raise exception 'T8 pipeline_agent can admit'; end if;
  if to_regprocedure('research.assert_admitted_use(uuid,text,text,bigint)') is not null then raise exception 'T8 the 4-argument guard still exists'; end if;
  if not has_table_privilege('control_plane', 'research.use_admission', 'select') then raise exception 'T8 control_plane cannot review admissions'; end if;
  if (select count(*) from pg_constraint where conname in ('operation_receipt_admission_pair', 'operation_receipt_admission_declared')) <> 2 then
    raise exception 'T8 receipt binding checks missing';
  end if;
end $$;

rollback;
