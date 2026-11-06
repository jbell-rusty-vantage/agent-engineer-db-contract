-- 0010 | retrieval: vector spaces, the vector catalog, plans, runs, packets.
--
-- The embedding itself lives in the backend (vector bucket or pgvector). What
-- lives here is the authoritative catalog: what was embedded, from which version
-- of which source, under which projection procedure, and whether it is still
-- current.
--
-- The evidence gate is structural, not advisory: packet_member cannot reference
-- an unverified claim or an under-assured record, enforced by trigger. That is
-- what stops an agent citing a raw vector match.

begin;

create type retrieval.space_class as enum ('canonical','exploratory');

create type retrieval.backend_kind as enum ('vector_bucket','pgvector');

-- ---------------------------------------------------------------------------
-- Spaces, versions, and the projection procedure that fills them.
-- ---------------------------------------------------------------------------
create table retrieval.projection_procedure (
  id          uuid primary key default util.uuidv7(),
  slug        text not null,
  version     integer not null,
  description text,
  code_ref    text,
  chunking    jsonb not null default '{}'::jsonb,
  template    text,
  created_at  timestamptz not null default now(),
  unique (slug, version)
);

create table retrieval.vector_space (
  id         uuid primary key default util.uuidv7(),
  tenant_id  uuid not null default util.default_tenant_id(),
  slug       text not null,
  purpose    text not null,
  class      retrieval.space_class not null default 'exploratory',
  created_at timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table retrieval.vector_space_version (
  id                      uuid primary key default util.uuidv7(),
  vector_space_id         uuid not null references retrieval.vector_space(id) on delete cascade,
  version                 integer not null,
  embedding_model         text not null,
  dims                    integer not null check (dims > 0),
  projection_procedure_id uuid references retrieval.projection_procedure(id),
  backend                 retrieval.backend_kind not null,
  promotion_gate_eval_id  uuid,
  promoted                boolean not null default false,
  created_at              timestamptz not null default now(),
  unique (vector_space_id, version)
);

-- ---------------------------------------------------------------------------
-- The vector catalog. IMMUTABLE; re-embedding is a new row plus supersession.
--
-- The source arc spans 13 typed targets: verified claims, the nine knowledge
-- record types, report versions, videos and talks. Slightly over Fable's ~12
-- rule of thumb, but the alternative it forbids -- an untyped (kind, id) pair --
-- is worse, and every column here is a real FK.
-- ---------------------------------------------------------------------------
create table retrieval.vector_item (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  space_version_id      uuid not null references retrieval.vector_space_version(id),
  claim_id              uuid references evidence.claim(id),
  technical_problem_id  uuid references knowledge.technical_problem(id),
  solution_pattern_id   uuid references knowledge.solution_pattern(id),
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id),
  implementation_example_id uuid references knowledge.implementation_example(id),
  failure_mode_id       uuid references knowledge.failure_mode(id),
  benchmark_result_id   uuid references knowledge.benchmark_result(id),
  compatibility_constraint_id uuid references knowledge.compatibility_constraint(id),
  operational_practice_id uuid references knowledge.operational_practice(id),
  security_consideration_id uuid references knowledge.security_consideration(id),
  report_version_id     uuid references research.report_version(id),
  video_id              uuid references corpus.video(id),
  talk_id               uuid references corpus.talk(id),
  source_kind           text generated always as (
    case
      when claim_id                   is not null then 'claim'
      when technical_problem_id       is not null then 'technical_problem'
      when solution_pattern_id        is not null then 'solution_pattern'
      when advanced_usage_pattern_id  is not null then 'advanced_usage_pattern'
      when implementation_example_id  is not null then 'implementation_example'
      when failure_mode_id            is not null then 'failure_mode'
      when benchmark_result_id        is not null then 'benchmark_result'
      when compatibility_constraint_id is not null then 'compatibility_constraint'
      when operational_practice_id    is not null then 'operational_practice'
      when security_consideration_id  is not null then 'security_consideration'
      when report_version_id          is not null then 'report_version'
      when video_id                   is not null then 'video'
      when talk_id                    is not null then 'talk'
    end) stored,
  source_version_hash   text,
  content_sha256        text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  chunk_index           integer not null default 0,
  backend_location      text,
  -- Optional inline embedding for latency-sensitive spaces. Dimensionality is
  -- validated against space_version.dims by trigger rather than by type, since
  -- vector(n) cannot take n from another column.
  embedding             extensions.vector,
  generation_run_id     uuid,
  receipt_id            uuid references orchestration.operation_receipt(id),
  verification_state    text not null default 'pending'
    check (verification_state in ('pending','verified','failed')),
  superseded_by_id      uuid references retrieval.vector_item(id),
  created_at            timestamptz not null default now(),
  constraint vector_item_exactly_one_source check (
    num_nonnulls(claim_id, technical_problem_id, solution_pattern_id,
                 advanced_usage_pattern_id, implementation_example_id, failure_mode_id,
                 benchmark_result_id, compatibility_constraint_id, operational_practice_id,
                 security_consideration_id, report_version_id, video_id, talk_id) = 1)
);

create index vector_item_space_idx  on retrieval.vector_item (space_version_id, source_kind);
create index vector_item_source_idx on retrieval.vector_item (source_kind);
create index vector_item_current_idx on retrieval.vector_item (space_version_id)
  where superseded_by_id is null;

-- Immutable except for supersession, which is the legal amendment.
create or replace function retrieval.vector_item_guard() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'retrieval.vector_item is append-only' using errcode = 'restrict_violation';
  end if;
  if (new.id, new.space_version_id, new.content_sha256, new.created_at)
     is distinct from
     (old.id, old.space_version_id, old.content_sha256, old.created_at)
  then
    raise exception 'retrieval.vector_item is immutable; supersede with a new row'
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

create trigger vector_item_immutable
  before update or delete on retrieval.vector_item
  for each row execute function retrieval.vector_item_guard();

-- Canonical spaces may only be filled from accepted content (invariant 3.11).
create or replace function retrieval.enforce_canonical_source() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_class text;
  v_dims  integer;
  v_claim_status text;
begin
  select vs.class::text, vsv.dims into v_class, v_dims
    from retrieval.vector_space_version vsv
    join retrieval.vector_space vs on vs.id = vsv.vector_space_id
   where vsv.id = new.space_version_id;

  if new.embedding is not null
     and v_dims is not null
     and extensions.vector_dims(new.embedding) <> v_dims then
    raise exception 'embedding has % dimensions but space version expects %',
      extensions.vector_dims(new.embedding), v_dims
      using errcode = 'data_exception';
  end if;

  if v_class = 'canonical' and new.claim_id is not null then
    select c.status::text into v_claim_status from evidence.claim c where c.id = new.claim_id;
    if v_claim_status is distinct from 'verified' then
      raise exception
        'canonical vector space requires a verified claim; claim % is %',
        new.claim_id, coalesce(v_claim_status,'missing')
        using errcode = 'restrict_violation';
    end if;
  end if;
  return new;
end;
$$;

create trigger vector_item_canonical_source
  before insert on retrieval.vector_item
  for each row execute function retrieval.enforce_canonical_source();

-- ---------------------------------------------------------------------------
-- Plans, runs, candidates.
-- ---------------------------------------------------------------------------
create table retrieval.retrieval_plan (
  id             uuid primary key default util.uuidv7(),
  tenant_id      uuid not null default util.default_tenant_id(),
  query_intent   text not null,
  decomposition  jsonb not null default '[]'::jsonb,
  spaces         jsonb not null default '[]'::jsonb,
  filters        jsonb not null default '{}'::jsonb,
  policy_version integer not null default 1,
  proposed_by_attempt_id uuid references orchestration.attempt(id),
  validated      boolean not null default false,
  validation_errors jsonb,
  created_at     timestamptz not null default now()
);

create table retrieval.retrieval_run (
  id             uuid primary key default util.uuidv7(),
  plan_id        uuid not null references retrieval.retrieval_plan(id) on delete cascade,
  stage_timings  jsonb not null default '{}'::jsonb,
  fusion_params  jsonb not null default '{}'::jsonb,
  reranker_id    text,
  executed_at    timestamptz not null default now()
);

create table retrieval.retrieval_candidate (
  id             uuid primary key default util.uuidv7(),
  run_id         uuid not null references retrieval.retrieval_run(id) on delete cascade,
  vector_item_id uuid references retrieval.vector_item(id),
  lexical_ref    text,
  stage_scores   jsonb not null default '{}'::jsonb,
  final_score    numeric,
  rank           integer,
  constraint retrieval_candidate_has_ref check (
    num_nonnulls(vector_item_id, lexical_ref) >= 1)
);

create index retrieval_candidate_run_idx on retrieval.retrieval_candidate (run_id, rank);

-- ---------------------------------------------------------------------------
-- Evidence packets. IMMUTABLE product, and the gate that makes citation honest.
-- ---------------------------------------------------------------------------
create table retrieval.evidence_packet (
  id             uuid primary key default util.uuidv7(),
  tenant_id      uuid not null default util.default_tenant_id(),
  run_id         uuid references retrieval.retrieval_run(id),
  packet         jsonb not null,
  packet_schema_version integer not null default 1,
  artifact_id    uuid references orchestration.artifact(id),
  created_at     timestamptz not null default now()
);

create trigger evidence_packet_immutable
  before update or delete on retrieval.evidence_packet
  for each row execute function util.reject_mutation();

create table retrieval.packet_member (
  id                    uuid primary key default util.uuidv7(),
  packet_id             uuid not null references retrieval.evidence_packet(id) on delete cascade,
  claim_id              uuid references evidence.claim(id),
  technical_problem_id  uuid references knowledge.technical_problem(id),
  solution_pattern_id   uuid references knowledge.solution_pattern(id),
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id),
  implementation_example_id uuid references knowledge.implementation_example(id),
  failure_mode_id       uuid references knowledge.failure_mode(id),
  benchmark_result_id   uuid references knowledge.benchmark_result(id),
  compatibility_constraint_id uuid references knowledge.compatibility_constraint(id),
  operational_practice_id uuid references knowledge.operational_practice(id),
  security_consideration_id uuid references knowledge.security_consideration(id),
  member_kind           text generated always as (
    case
      when claim_id                   is not null then 'claim'
      when technical_problem_id       is not null then 'technical_problem'
      when solution_pattern_id        is not null then 'solution_pattern'
      when advanced_usage_pattern_id  is not null then 'advanced_usage_pattern'
      when implementation_example_id  is not null then 'implementation_example'
      when failure_mode_id            is not null then 'failure_mode'
      when benchmark_result_id        is not null then 'benchmark_result'
      when compatibility_constraint_id is not null then 'compatibility_constraint'
      when operational_practice_id    is not null then 'operational_practice'
      when security_consideration_id  is not null then 'security_consideration'
    end) stored,
  locators              jsonb not null default '[]'::jsonb,
  verification_state    text,
  freshness             text,
  contradiction_flags   jsonb not null default '[]'::jsonb,
  coverage_role         text,
  created_at            timestamptz not null default now(),
  constraint packet_member_exactly_one check (
    num_nonnulls(claim_id, technical_problem_id, solution_pattern_id,
                 advanced_usage_pattern_id, implementation_example_id, failure_mode_id,
                 benchmark_result_id, compatibility_constraint_id, operational_practice_id,
                 security_consideration_id) = 1)
);

create index packet_member_packet_idx on retrieval.packet_member (packet_id);

-- THE evidence gate. A packet member must resolve to a verified claim or to a
-- knowledge record at or above the assurance floor. This is why an agent cannot
-- cite a vector match directly.
create or replace function retrieval.enforce_evidence_gate() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_status text;
  v_rank   integer;
  c_floor  constant integer := 20;   -- source_inspection
begin
  if new.claim_id is not null then
    select c.status::text into v_status from evidence.claim c where c.id = new.claim_id;
    if v_status is distinct from 'verified' then
      raise exception 'evidence gate: claim % is %, not verified',
        new.claim_id, coalesce(v_status,'missing')
        using errcode = 'restrict_violation';
    end if;
    return new;
  end if;

  execute format(
    'select al.rank from knowledge.%I r join knowledge.assurance_level al on al.code = r.assurance_level where r.id = $1',
    new.member_kind)
    into v_rank
    using coalesce(
      new.technical_problem_id, new.solution_pattern_id, new.advanced_usage_pattern_id,
      new.implementation_example_id, new.failure_mode_id, new.benchmark_result_id,
      new.compatibility_constraint_id, new.operational_practice_id, new.security_consideration_id);

  if v_rank is null or v_rank < c_floor then
    raise exception 'evidence gate: % record is below the assurance floor (rank %, floor %)',
      new.member_kind, coalesce(v_rank, -1), c_floor
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

create trigger packet_member_evidence_gate
  before insert or update on retrieval.packet_member
  for each row execute function retrieval.enforce_evidence_gate();

commit;
