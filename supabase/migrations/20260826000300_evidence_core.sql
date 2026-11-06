-- 0003 | evidence: sources, captures, locators, signatures, claims, support,
--        verification, revalidation.
--
-- PROVISIONAL. This is the one schema expected to churn before the attribution
-- lab stabilizes the locator/signature/support contracts. Do not build api views
-- over it yet.
--
-- The 14 claim_<entity> per-type association tables live in 0014, because they
-- FK into corpus, which is created in 0005.
--
-- Two columns are forward references to evaluation.review_task (0011); they are
-- plain uuid here and get their FKs in 0014.

begin;

-- Frozen by checkpoint section 14 -> enum.
create type evidence.support_verdict as enum (
  'directly_supported',
  'supported_with_qualification',
  'partially_supported',
  'context_only',
  'contradicted',
  'not_supported',
  'unverifiable'
);

create type evidence.claim_status as enum (
  'proposed', 'verified', 'disputed', 'retracted', 'superseded'
);

-- Still evolving -> lookup table.
create table evidence.claim_type (
  code        text primary key,
  description text not null,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Sources and captures.
-- ---------------------------------------------------------------------------
create table evidence.source (
  id             uuid primary key default util.uuidv7(),
  tenant_id      uuid not null default util.default_tenant_id(),
  source_class   text not null
    check (source_class in ('web_page','api','repository','pdf','transcript','dataset','registry','other')),
  canonical_url  text,
  url_pattern    text,
  publisher      text,
  sensitivity    text not null default 'public'
    check (sensitivity in ('public','restricted','confidential')),
  license_spdx   text,
  license_notes  text,
  terms_url      text,
  robots_policy  text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create unique index source_canonical_url_uq on evidence.source (canonical_url)
  where canonical_url is not null;

create trigger source_set_updated_at
  before update on evidence.source
  for each row execute function util.set_updated_at();

-- IMMUTABLE. The bytes that were actually seen.
create table evidence.source_capture (
  id                     uuid primary key default util.uuidv7(),
  tenant_id              uuid not null default util.default_tenant_id(),
  source_id              uuid not null references evidence.source(id),
  artifact_id            uuid not null references orchestration.artifact(id),
  content_sha256         text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  media_type             text not null,
  captured_at            timestamptz not null default now(),
  capture_method         text not null,
  capture_method_version text not null,
  request_url            text,
  http_status            integer,
  http_headers           jsonb,
  context                jsonb not null default '{}'::jsonb,
  produced_by_attempt_id uuid references orchestration.attempt(id)
);

create index source_capture_source_idx on evidence.source_capture (source_id, captured_at desc);
create index source_capture_sha_idx    on evidence.source_capture (content_sha256);

create trigger source_capture_immutable
  before update or delete on evidence.source_capture
  for each row execute function util.reject_mutation();

-- The explicit, review-gated alternative when capture is impossible.
create table evidence.degraded_assurance (
  id                 uuid primary key default util.uuidv7(),
  source_id          uuid not null references evidence.source(id),
  reason             text not null,
  what_was_seen      text not null,
  attempted_methods  jsonb not null default '[]'::jsonb,
  -- forward reference: evaluation.review_task (0011), FK added in 0014
  approved_by_review_task_id uuid,
  approved_at        timestamptz,
  created_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Locators and extraction signatures.
-- ---------------------------------------------------------------------------
create table evidence.locator (
  id                      uuid primary key default util.uuidv7(),
  capture_id              uuid not null references evidence.source_capture(id),
  media_type              text not null,
  -- JSON Pointer / commit+path+lines / DOM selector+quote / pdf page+bbox /
  -- transcript segment. Shape is per media_type, validated in application code
  -- against a versioned schema.
  selector                jsonb not null,
  selected_content_sha256 text check (selected_content_sha256 ~ '^[0-9a-f]{64}$'),
  normalized_value        text,
  context_fingerprint     text,
  extractor_name          text not null,
  extractor_version       text not null,
  extraction_params       jsonb not null default '{}'::jsonb,
  created_at              timestamptz not null default now()
);

create index locator_capture_idx on evidence.locator (capture_id);

-- IMMUTABLE. Hash of capture + locator + method + params + normalized output.
-- This is what makes an extraction replayable.
create table evidence.extraction_signature (
  id              uuid primary key default util.uuidv7(),
  locator_id      uuid not null references evidence.locator(id),
  signature_sha256 text not null check (signature_sha256 ~ '^[0-9a-f]{64}$'),
  produced_by_attempt_id uuid references orchestration.attempt(id),
  created_at      timestamptz not null default now(),
  unique (locator_id, signature_sha256)
);

create trigger extraction_signature_immutable
  before update or delete on evidence.extraction_signature
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------
-- Claims.
-- ---------------------------------------------------------------------------
create table evidence.claim (
  id                  uuid primary key default util.uuidv7(),
  tenant_id           uuid not null default util.default_tenant_id(),
  claim_type          text not null references evidence.claim_type(code),
  statement           text not null,
  structured          jsonb,
  status              evidence.claim_status not null default 'proposed',
  composite           boolean not null default false,
  atomized_from_id    uuid references evidence.claim(id),
  -- Needed for the producer-cannot-verify check in section 3.2.
  producer_attempt_id uuid references orchestration.attempt(id),
  superseded_by_id    uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index claim_status_idx on evidence.claim (status, created_at desc);
create index claim_type_idx   on evidence.claim (claim_type);
create index claim_producer_idx on evidence.claim (producer_attempt_id);

create trigger claim_set_updated_at
  before update on evidence.claim
  for each row execute function util.set_updated_at();

create table evidence.verification_run (
  id                 uuid primary key default util.uuidv7(),
  work_item_id       uuid references orchestration.work_item(id),
  verifier_attempt_id uuid not null references orchestration.attempt(id),
  policy_version     text not null,
  started_at         timestamptz not null default now(),
  ended_at           timestamptz
);

create index verification_run_attempt_idx on evidence.verification_run (verifier_attempt_id);

create table evidence.claim_evidence_link (
  id                   uuid primary key default util.uuidv7(),
  claim_id             uuid not null references evidence.claim(id) on delete cascade,
  locator_id           uuid not null references evidence.locator(id),
  role                 text not null
    check (role in ('supports','contradicts','qualifies','context')),
  support_verdict      evidence.support_verdict,
  -- authority, independence, directness, freshness, methodology,
  -- conflict_of_interest -- the section 14 source-role assessment.
  authority_assessment jsonb,
  verified_by_run_id   uuid references evidence.verification_run(id),
  created_at           timestamptz not null default now(),
  unique (claim_id, locator_id, role)
);

create index claim_evidence_link_locator_idx on evidence.claim_evidence_link (locator_id);

create table evidence.verification_finding (
  id                     uuid primary key default util.uuidv7(),
  run_id                 uuid not null references evidence.verification_run(id) on delete cascade,
  claim_id               uuid not null references evidence.claim(id) on delete cascade,
  verdict                evidence.support_verdict not null,
  rationale              text,
  deterministic          boolean not null default false,
  replay_signature_match boolean,
  created_at             timestamptz not null default now(),
  unique (run_id, claim_id)
);

-- ---------------------------------------------------------------------------
-- Invariant 3.2, enforced structurally: the agent deployment that produced a
-- claim may not verify it. Comparing deployment ids, not attempt ids, so a
-- second attempt by the same deployment does not count as independent.
-- ---------------------------------------------------------------------------
create or replace function evidence.enforce_producer_not_verifier() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_producer text;
  v_verifier text;
begin
  select pa.agent_deployment_id into v_producer
    from evidence.claim c
    join orchestration.attempt pa on pa.id = c.producer_attempt_id
   where c.id = new.claim_id;

  select va.agent_deployment_id into v_verifier
    from evidence.verification_run r
    join orchestration.attempt va on va.id = r.verifier_attempt_id
   where r.id = new.run_id;

  if v_producer is not null and v_verifier is not null and v_producer = v_verifier then
    raise exception
      'producer may not verify its own claim: deployment % produced claim % and is verifying it',
      v_verifier, new.claim_id
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

create trigger verification_finding_independence
  before insert or update on evidence.verification_finding
  for each row execute function evidence.enforce_producer_not_verifier();

-- ---------------------------------------------------------------------------
-- Conflict and reconciliation.
-- ---------------------------------------------------------------------------
create table evidence.claim_conflict (
  id            uuid primary key default util.uuidv7(),
  claim_a_id    uuid not null references evidence.claim(id) on delete cascade,
  claim_b_id    uuid not null references evidence.claim(id) on delete cascade,
  conflict_kind text not null
    check (conflict_kind in ('contradiction','scope_mismatch','staleness','measurement','definitional')),
  detected_by   text not null,
  detected_at   timestamptz not null default now(),
  constraint claim_conflict_distinct check (claim_a_id <> claim_b_id),
  unique (claim_a_id, claim_b_id, conflict_kind)
);

create table evidence.conflict_reconciliation (
  id            uuid primary key default util.uuidv7(),
  conflict_id   uuid not null references evidence.claim_conflict(id) on delete cascade,
  outcome       text not null
    check (outcome in ('reject','supersede','scope','retain_dispute','experiment','review')),
  rationale     text not null,
  -- forward reference: evaluation.review_task (0011), FK added in 0014
  review_task_id uuid,
  decided_at    timestamptz not null default now()
);

-- IMMUTABLE. The strongest assurance level: it actually ran.
create table evidence.executable_verification (
  id               uuid primary key default util.uuidv7(),
  repository_url   text,
  commit_sha       text,
  image_digest     text,
  lockfile_hashes  jsonb not null default '{}'::jsonb,
  commands         jsonb not null default '[]'::jsonb,
  exit_codes       jsonb not null default '[]'::jsonb,
  log_artifact_id  uuid references orchestration.artifact(id),
  assurance_level  text not null,
  trace_id         text,
  executed_at      timestamptz not null default now()
);

create trigger executable_verification_immutable
  before update or delete on evidence.executable_verification
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------
-- Revalidation: time / release / source-change / security / retraction /
-- contradiction / eval-failure / downstream-use triggers, as jsonb rules.
-- ---------------------------------------------------------------------------
create table evidence.revalidation_policy (
  id           uuid primary key default util.uuidv7(),
  slug         text not null unique,
  applies_to   text not null,
  rules        jsonb not null default '{}'::jsonb,
  max_age      interval,
  created_at   timestamptz not null default now()
);

create table evidence.revalidation_event (
  id            uuid primary key default util.uuidv7(),
  policy_id     uuid references evidence.revalidation_policy(id),
  trigger_kind  text not null
    check (trigger_kind in ('time','release','source_change','security','retraction',
                            'contradiction','eval_failure','downstream_use','manual')),
  affected_refs jsonb not null default '[]'::jsonb,
  work_item_id  uuid references orchestration.work_item(id),
  fired_at      timestamptz not null default now()
);

create index revalidation_event_fired_idx on evidence.revalidation_event (fired_at desc);

-- ---------------------------------------------------------------------------
-- Seed claim types.
-- ---------------------------------------------------------------------------
insert into evidence.claim_type (code, description) values
  ('attribute',      'An intrinsic property of an entity'),
  ('relationship',   'A relationship between two entities'),
  ('measurement',    'A quantitative observation'),
  ('capability',     'A stated capability or limitation'),
  ('compatibility',  'A version or platform compatibility assertion'),
  ('event',          'Something that happened at a point in time'),
  ('recommendation', 'A normative engineering recommendation'),
  ('definition',     'A definitional or terminological assertion'),
  ('provenance',     'An assertion about the origin of something')
on conflict (code) do nothing;

commit;
