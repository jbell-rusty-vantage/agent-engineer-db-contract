-- Knowledge preparation service: immutable content identity, transformations,
-- structural representations, and tenant-safe lineage.
begin;

create extension if not exists pg_trgm with schema extensions;
create schema if not exists content;
create schema if not exists knowledge_service;

revoke all on schema content, knowledge_service from public, anon, authenticated;

-- Composite identities are the database-level tenant boundary used by all new
-- foreign keys. Existing single-column foreign keys remain for compatibility.
alter table orchestration.artifact add constraint artifact_tenant_id_uq unique (tenant_id, id);
alter table orchestration.attempt add constraint attempt_tenant_id_uq unique (tenant_id, id);
alter table orchestration.work_item add constraint work_item_tenant_id_uq unique (tenant_id, id);
alter table evidence.source add constraint source_tenant_id_uq unique (tenant_id, id);
alter table evidence.source_capture add constraint source_capture_tenant_id_uq unique (tenant_id, id);
alter table evidence.claim add constraint claim_tenant_id_uq unique (tenant_id, id);

create table orchestration.artifact_lineage (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  from_artifact_id uuid not null,
  to_artifact_id uuid not null,
  relation_kind text not null check (relation_kind in
    ('derived_from','supersedes','corrects','produced_by','consumed_by')),
  transformation_run_id uuid,
  receipt_id uuid references orchestration.operation_receipt(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (tenant_id, from_artifact_id)
    references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, to_artifact_id)
    references orchestration.artifact(tenant_id, id) on delete restrict,
  unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind),
  check (from_artifact_id <> to_artifact_id)
);

create table content.document (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_kind text not null,
  canonical_title text not null,
  canonical_source_id uuid,
  lifecycle text not null default 'active'
    check (lifecycle in ('active','deprecated','retracted','deleted','superseded')),
  created_by_attempt_id uuid,
  supersedes_id uuid,
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  foreign key (tenant_id, canonical_source_id)
    references evidence.source(tenant_id, id) on delete restrict,
  foreign key (tenant_id, created_by_attempt_id)
    references orchestration.attempt(tenant_id, id) on delete restrict,
  foreign key (tenant_id, supersedes_id)
    references content.document(tenant_id, id) on delete restrict,
  check (supersedes_id is null or supersedes_id <> id)
);

create table content.document_identifier (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  identifier_type text not null check (identifier_type in
    ('url','doi','arxiv','openreview','isbn','repository','media_id','other')),
  normalized_value text not null,
  authority text,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  foreign key (tenant_id, document_id)
    references content.document(tenant_id, id) on delete restrict,
  unique (tenant_id, identifier_type, normalized_value),
  check (valid_to is null or valid_from is null or valid_to > valid_from)
);

create table content.document_version (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  version_label text not null,
  published_at timestamptz,
  effective_from timestamptz,
  resolved_revision text,
  manifest_sha256 text not null check (manifest_sha256 ~ '^[0-9a-f]{64}$'),
  correction_state text not null default 'current'
    check (correction_state in ('current','corrected','retracted','withdrawn')),
  supersedes_id uuid,
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, document_id, version_label),
  foreign key (tenant_id, document_id)
    references content.document(tenant_id, id) on delete restrict,
  foreign key (tenant_id, supersedes_id)
    references content.document_version(tenant_id, id) on delete restrict,
  check (supersedes_id is null or supersedes_id <> id)
);

create table content.document_version_source_capture (
  tenant_id uuid not null default util.default_tenant_id(),
  document_version_id uuid not null,
  source_capture_id uuid not null,
  capture_role text not null default 'primary',
  identity_confidence numeric(5,4) not null check (identity_confidence between 0 and 1),
  resolution_evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  primary key (tenant_id, document_version_id, source_capture_id),
  foreign key (tenant_id, document_version_id)
    references content.document_version(tenant_id, id) on delete restrict,
  foreign key (tenant_id, source_capture_id)
    references evidence.source_capture(tenant_id, id) on delete restrict
);

create table content.transformation_run (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  transformation_kind text not null,
  contract_version text not null,
  capability_version_id uuid references orchestration.capability_version(id) on delete restrict,
  code_ref text,
  package_lock_sha256 text check (package_lock_sha256 is null or package_lock_sha256 ~ '^[0-9a-f]{64}$'),
  environment_sha256 text check (environment_sha256 is null or environment_sha256 ~ '^[0-9a-f]{64}$'),
  model_identity text,
  provider_route text,
  parameters jsonb not null default '{}'::jsonb,
  parameters_sha256 text not null check (parameters_sha256 ~ '^[0-9a-f]{64}$'),
  operation_id uuid,
  attempt_id uuid,
  status text not null default 'queued' check (status in
    ('proposed','queued','running','needs_review','succeeded','failed','cancelled','quarantined','superseded')),
  idempotency_key text not null,
  input_manifest_sha256 text check (input_manifest_sha256 is null or input_manifest_sha256 ~ '^[0-9a-f]{64}$'),
  output_manifest_sha256 text check (output_manifest_sha256 is null or output_manifest_sha256 ~ '^[0-9a-f]{64}$'),
  receipt jsonb,
  failure_class text,
  resource_observations jsonb not null default '{}'::jsonb,
  cost_usd numeric(14,6),
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, idempotency_key),
  foreign key (tenant_id, attempt_id) references orchestration.attempt(tenant_id, id) on delete restrict,
  check ((status in ('succeeded','failed','cancelled','superseded')) = (ended_at is not null))
);

alter table orchestration.artifact_lineage
  add constraint artifact_lineage_transformation_fk
  foreign key (tenant_id, transformation_run_id)
  references content.transformation_run(tenant_id, id) on delete restrict;

create table content.document_representation (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_version_id uuid not null,
  artifact_id uuid not null,
  representation_kind text not null,
  representation_class text not null check (representation_class in
    ('source_native','rendered_snapshot','faithful_normalization','structural_extraction','semantic_projection','retrieval_projection')),
  media_type text not null,
  language text,
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  transformation_run_id uuid,
  acceptance_state text not null default 'pending' check (acceptance_state in
    ('pending','accepted','rejected','quarantined','deferred','superseded')),
  source_native_byte_identical boolean not null default false,
  supersedes_id uuid,
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  foreign key (tenant_id, document_version_id) references content.document_version(tenant_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, transformation_run_id) references content.transformation_run(tenant_id, id) on delete restrict,
  foreign key (tenant_id, supersedes_id) references content.document_representation(tenant_id, id) on delete restrict,
  check (supersedes_id is null or supersedes_id <> id),
  check (not source_native_byte_identical or representation_class = 'source_native')
);

create table content.transformation_input (
  tenant_id uuid not null default util.default_tenant_id(),
  transformation_run_id uuid not null,
  ordinal integer not null check (ordinal >= 0),
  role text not null,
  artifact_id uuid,
  representation_id uuid,
  source_capture_id uuid,
  created_at timestamptz not null default now(),
  primary key (tenant_id, transformation_run_id, ordinal),
  foreign key (tenant_id, transformation_run_id) references content.transformation_run(tenant_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  foreign key (tenant_id, source_capture_id) references evidence.source_capture(tenant_id, id) on delete restrict,
  check (num_nonnulls(artifact_id, representation_id, source_capture_id) = 1)
);

create table content.transformation_output (
  tenant_id uuid not null default util.default_tenant_id(),
  transformation_run_id uuid not null,
  ordinal integer not null check (ordinal >= 0),
  role text not null,
  artifact_id uuid,
  representation_id uuid,
  created_at timestamptz not null default now(),
  primary key (tenant_id, transformation_run_id, ordinal),
  foreign key (tenant_id, transformation_run_id) references content.transformation_run(tenant_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  check (num_nonnulls(artifact_id, representation_id) = 1)
);

create table content.document_node (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  representation_id uuid not null,
  parent_id uuid,
  ordinal integer not null check (ordinal >= 0),
  stable_local_key text not null,
  node_kind text not null,
  role text,
  inline_text text,
  artifact_id uuid,
  selector jsonb not null default '{}'::jsonb,
  page_number integer,
  start_offset integer,
  end_offset integer,
  bbox jsonb,
  language text,
  normalized_content_sha256 text not null check (normalized_content_sha256 ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, representation_id, stable_local_key),
  unique (tenant_id, representation_id, parent_id, ordinal),
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  foreign key (tenant_id, parent_id) references content.document_node(tenant_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  check (parent_id is null or parent_id <> id),
  check (start_offset is null or start_offset >= 0),
  check (end_offset is null or (start_offset is not null and end_offset >= start_offset))
);

create table content.document_node_edge (
  tenant_id uuid not null default util.default_tenant_id(),
  from_node_id uuid not null,
  to_node_id uuid not null,
  relation_kind text not null check (relation_kind in
    ('citation','footnote','caption','cross_reference','continues','same_table','same_symbol')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  primary key (tenant_id, from_node_id, to_node_id, relation_kind),
  foreign key (tenant_id, from_node_id) references content.document_node(tenant_id, id) on delete restrict,
  foreign key (tenant_id, to_node_id) references content.document_node(tenant_id, id) on delete restrict,
  check (from_node_id <> to_node_id)
);

create table content.conversion_evaluation (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  representation_id uuid not null,
  evaluator_identity text not null,
  procedure_version text not null,
  conversion_grade text not null,
  coverage numeric(6,5) check (coverage between 0 and 1),
  locator_coverage numeric(6,5) check (locator_coverage between 0 and 1),
  report_artifact_id uuid,
  findings_sha256 text not null check (findings_sha256 ~ '^[0-9a-f]{64}$'),
  disposition text not null check (disposition in ('accept','reject','quarantine','defer')),
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  foreign key (tenant_id, report_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

create table content.conversion_finding (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  conversion_evaluation_id uuid not null,
  severity text not null check (severity in ('info','warning','error','critical')),
  finding_kind text not null,
  node_id uuid,
  locator_id uuid references evidence.locator(id) on delete restrict,
  observed_defect text not null,
  expected_behavior text,
  evidence_artifact_id uuid,
  recommended_action text,
  resolution text,
  created_at timestamptz not null default now(),
  foreign key (tenant_id, conversion_evaluation_id) references content.conversion_evaluation(tenant_id, id) on delete restrict,
  foreign key (tenant_id, node_id) references content.document_node(tenant_id, id) on delete restrict,
  foreign key (tenant_id, evidence_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

create table content.representation_decision (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  representation_id uuid not null,
  conversion_evaluation_id uuid,
  guarded_sha256 text not null check (guarded_sha256 ~ '^[0-9a-f]{64}$'),
  decision text not null check (decision in ('accept','reject','quarantine','defer','request_changes')),
  reviewer_identity text not null,
  policy_version text not null,
  rationale text not null,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  foreign key (tenant_id, conversion_evaluation_id) references content.conversion_evaluation(tenant_id, id) on delete restrict
);

create index document_title_trgm_idx on content.document using gin (canonical_title extensions.gin_trgm_ops);
create index document_version_document_idx on content.document_version (tenant_id, document_id, created_at desc);
create index representation_version_idx on content.document_representation (tenant_id, document_version_id, created_at desc);
create index document_node_tree_idx on content.document_node (tenant_id, representation_id, parent_id, ordinal);
create index transformation_operation_idx on content.transformation_run (tenant_id, operation_id, created_at desc);

-- All provenance-bearing rows above are append-only. A correction is a new row.
do $$
declare t text;
begin
  foreach t in array array[
    'artifact_lineage'
  ] loop
    execute format('create trigger %I_immutable before update or delete on orchestration.%I for each row execute function util.reject_mutation()', t, t);
  end loop;
  foreach t in array array[
    'document','document_identifier','document_version','document_version_source_capture',
    'document_representation','transformation_input','transformation_output','document_node',
    'document_node_edge','conversion_evaluation','conversion_finding','representation_decision'
  ] loop
    execute format('create trigger %I_immutable before update or delete on content.%I for each row execute function util.reject_mutation()', t, t);
  end loop;
end $$;

-- Runs may advance while active; after terminalization they become immutable.
create function content.guard_terminal_transformation() returns trigger language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'transformation runs cannot be deleted' using errcode='restrict_violation'; end if;
  if old.status in ('succeeded','failed','cancelled','superseded') then
    raise exception 'terminal transformation runs are immutable' using errcode='restrict_violation';
  end if;
  return new;
end $$;
create trigger transformation_run_terminal_guard before update or delete on content.transformation_run
for each row execute function content.guard_terminal_transformation();

comment on schema content is 'Immutable authored-work identity, representations, structural nodes, transformations and conversion evaluation.';
commit;
