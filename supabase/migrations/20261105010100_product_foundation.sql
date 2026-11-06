-- Build 01 R1+R2, Build 02 R1, Build 03 R1, Build 04 R1: product relations (accepted schema design, 2026-11-05).
-- Lab implementation on branch build-04-product-schema-lab. Disposable targets only until owner disposition.
begin;
set local lock_timeout = '15s';

create schema if not exists authoring;
create schema if not exists learning;
create schema if not exists library;
create schema if not exists conversation;
create schema if not exists access;
create schema if not exists inquiry;   -- Build 07: research requests, deliveries, statements and support
create schema if not exists dataset;   -- Build 07: editable research datasets (versioned fields, rows, cells)
create schema if not exists product;   -- internal guards/helpers; never exposed

do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'product_api_owner') then
    create role product_api_owner nologin noinherit;
  end if;
end $$;
grant product_api_owner to postgres;

-- ------------------------------------------------------------------ helpers
create or replace function product.sha256_text(t text) returns text language sql immutable strict set search_path = '' as
$$ select pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(t, 'UTF8')), 'hex') $$;

create or replace function product.nonblank(t text) returns boolean language sql immutable set search_path = '' as
$$ select t is not null and pg_catalog.btrim(t) <> '' $$;

-- Rows are append-only; TG_ARGV lists columns that may change once from NULL to a value.
create or replace function product.guard_immutable() returns trigger language plpgsql set search_path = '' as $$
declare o jsonb; n jsonb; k text;
begin
  if tg_op = 'DELETE' then
    if pg_catalog.current_setting('product.purge', true) = 'on' then return old; end if;
    raise exception '%.% is append-only', tg_table_schema, tg_table_name using errcode = 'restrict_violation';
  end if;
  o := pg_catalog.to_jsonb(old); n := pg_catalog.to_jsonb(new);
  if tg_nargs > 0 then
    foreach k in array tg_argv loop
      if (o -> k) is distinct from (n -> k) and (o ->> k) is not null then
        raise exception 'column % of %.% may be set only once', k, tg_table_schema, tg_table_name using errcode = 'restrict_violation';
      end if;
      o := o - k; n := n - k;
    end loop;
  end if;
  if o is distinct from n then
    raise exception '%.% row is immutable', tg_table_schema, tg_table_name using errcode = 'restrict_violation';
  end if;
  return new;
end $$;

-- Current-state rows: only TG_ARGV columns may change; deletes only inside a purge.
create or replace function product.guard_mutable() returns trigger language plpgsql set search_path = '' as $$
declare o jsonb; n jsonb; k text;
begin
  if tg_op = 'DELETE' then
    if pg_catalog.current_setting('product.purge', true) = 'on' then return old; end if;
    raise exception '%.% rows are removed only by a tracked removal', tg_table_schema, tg_table_name using errcode = 'restrict_violation';
  end if;
  o := pg_catalog.to_jsonb(old); n := pg_catalog.to_jsonb(new);
  foreach k in array tg_argv loop o := o - k; n := n - k; end loop;
  if o is distinct from n then
    raise exception 'immutable columns of %.% changed', tg_table_schema, tg_table_name using errcode = 'restrict_violation';
  end if;
  return new;
end $$;

-- ------------------------------------------------------------------ access (Build 04) — tenant scoped
create table access.policy_version (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  version integer not null check (version > 0),
  body jsonb not null check (body ->> 'schema' = 'aieng.access-policy.v1'),
  body_sha256 text not null check (body_sha256 ~ '^[0-9a-f]{64}$'),
  approved_by uuid references auth.users(id) on delete restrict,
  active_from timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (tenant_id, id), unique (tenant_id, version)
);

create table access.account_profile (
  tenant_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  seq integer not null check (seq > 0),
  age_band text not null check (age_band in ('adult','teen','child','unknown')),
  jurisdiction text not null check (jurisdiction ~ '^[A-Z]{2}(-[A-Z0-9]{1,3})?$|^ZZ$'),
  established_by text not null check (established_by in ('self_declared','guardian','verified','admin')),
  eligibility text not null check (eligibility in ('eligible','pending_guardian_consent','restricted','suspended')),
  policy_version_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (tenant_id, principal_id, seq),
  foreign key (tenant_id, policy_version_id) references access.policy_version(tenant_id, id) on delete restrict
);

create table access.guardian_link (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  youth_id uuid not null references auth.users(id) on delete restrict,
  guardian_id uuid not null references auth.users(id) on delete restrict,
  state text not null check (state in ('invited','consented','declined','revoked')),
  consent_method text,
  consent_evidence_artifact_id uuid,
  help_scope text[] not null default '{}' check (help_scope <@ array['progress','results','projects','conversations']),
  created_at timestamptz not null default now(),
  consented_at timestamptz,
  revoked_at timestamptz,
  unique (tenant_id, id),
  check (youth_id <> guardian_id),
  check ((state = 'consented') = (consented_at is not null and revoked_at is null) or state in ('revoked','declined')),
  foreign key (tenant_id, consent_evidence_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);
create unique index guardian_link_active_uq on access.guardian_link(tenant_id, youth_id, guardian_id) where state in ('invited','consented');

create table access.processing_authorization (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  processor_class text not null check (processor_class in ('llm_inference','embedding','connector','analytics','third_party_share')),
  processor_key text not null check (processor_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'),
  purpose text not null check (product.nonblank(purpose)),
  basis text not null check (basis in ('self','guardian')),
  guardian_link_id uuid,
  policy_version_id uuid not null,
  granted_by uuid not null references auth.users(id) on delete restrict,
  granted_at timestamptz not null default now(),
  withdrawn_at timestamptz,
  unique (tenant_id, id),
  check ((basis = 'guardian') = (guardian_link_id is not null)),
  foreign key (tenant_id, guardian_link_id) references access.guardian_link(tenant_id, id) on delete restrict,
  foreign key (tenant_id, policy_version_id) references access.policy_version(tenant_id, id) on delete restrict
);
create unique index processing_authorization_active_uq on access.processing_authorization(tenant_id, principal_id, processor_class, processor_key, purpose) where withdrawn_at is null;

create table access.client_grant (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  client_kind text not null check (client_kind in ('mcp','cli','harness','api')),
  label text not null check (product.nonblank(label)),
  token_sha256 text not null unique check (token_sha256 ~ '^[0-9a-f]{64}$'),
  scopes text[] not null check (cardinality(scopes) > 0 and scopes <@ array['read','author','learn','library','assess']),
  workspace_ids uuid[],
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  last_used_at timestamptz,
  revoked_at timestamptz,
  unique (tenant_id, id),
  check (expires_at > created_at)
);

create table access.source_restriction (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  source_id uuid, capture_id uuid, artifact_id uuid,
  kind text not null check (kind in ('takedown','license_change','legal_hold','access_lost','safety')),
  effect text not null check (effect in ('deny_bytes','deny_all','reference_only','hold_no_delete')),
  reason text not null check (product.nonblank(reason)),
  decided_by uuid references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  lifted_at timestamptz,
  unique (tenant_id, id),
  check (num_nonnulls(source_id, capture_id, artifact_id) = 1),
  foreign key (tenant_id, capture_id) references evidence.source_capture(tenant_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

-- ------------------------------------------------------------------ authoring core (Build 01 R1 + amendments)
create table authoring.workspace (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete restrict,
  kind text not null default 'shared' check (kind in ('personal','shared')),
  name text not null check (product.nonblank(name)),
  created_at timestamptz not null default now(),
  unique (tenant_id, id)
);
create unique index workspace_personal_uq on authoring.workspace(tenant_id, owner_id) where kind = 'personal';

-- Re-grant after revoke is permitted (R1's PK(tenant,workspace,principal) made it impossible): lab finding F-01.
create table authoring.workspace_member (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  role text not null check (role in ('owner','editor','reader')),
  granted_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (tenant_id, workspace_id, id),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict
);
create unique index workspace_member_active_uq on authoring.workspace_member(tenant_id, workspace_id, principal_id) where revoked_at is null;
create index workspace_member_principal_ix on authoring.workspace_member(principal_id, workspace_id) where revoked_at is null;

create table authoring.work (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  kind text not null check (kind in ('course','track','module','lesson','activity','report','dataset','decision_definition','action_policy','decision_attempt','brief',
                                     'experience','component','competency','note','wiki','project','document','goal',
                                     'snippet','challenge','project_template','view')),
  slug text not null check (slug ~ '^[a-z0-9][a-z0-9-]{0,99}$'),
  head_revision_id uuid,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, slug),
  unique (tenant_id, workspace_id, id, kind),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict
);

create table authoring.work_revision (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  work_id uuid not null,
  revision_no integer not null check (revision_no > 0),
  parent_revision_id uuid,
  title text not null check (product.nonblank(title)),
  body_schema text not null check (body_schema in ('aieng.work-body.v1','aieng.work-body.v2')),
  body jsonb not null check (jsonb_typeof(body) = 'object' and octet_length(body::text) <= 1048576),
  content_sha256 text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  origin text not null check (origin in ('human','native_harness','import','mc','agent')),
  origin_ref jsonb not null default '{}',
  knowledge_seq bigint,
  world_from timestamptz, world_to timestamptz,
  world_precision text not null default 'unknown' check (world_precision in ('instant','day','unknown')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  purged_at timestamptz,
  purged_by_removal_id uuid,
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  unique (tenant_id, workspace_id, work_id, revision_no), unique (tenant_id, workspace_id, work_id, id),
  foreign key (tenant_id, workspace_id, work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, work_id, parent_revision_id) references authoring.work_revision(tenant_id, workspace_id, work_id, id) on delete restrict,
  foreign key (tenant_id, knowledge_seq) references temporal.knowledge_batch(tenant_id, knowledge_seq) on delete restrict,
  check ((world_precision = 'unknown' and world_from is null and world_to is null)
      or (world_precision = 'instant' and world_from is not null and world_from = world_to)
      or (world_precision = 'day' and world_from is not null and world_from < world_to)),
  check ((purged_at is null) = (purged_by_removal_id is null))
);
alter table authoring.work add constraint work_head_fk foreign key (tenant_id, workspace_id, id, head_revision_id)
  references authoring.work_revision(tenant_id, workspace_id, work_id, id) on delete restrict;

create table authoring.asset_scope (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  artifact_id uuid not null,
  registered_by uuid not null references auth.users(id) on delete restrict,
  rights_basis text not null check (product.nonblank(rights_basis)),
  usage text not null check (usage in ('reference_only','private_copy','redistributable','unknown')),
  retention text not null default 'durable' check (retention in ('durable','temporary')),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (tenant_id, workspace_id, id), unique (tenant_id, artifact_id),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  check ((retention = 'temporary') = (expires_at is not null))
);

-- Build 05: block-type catalog (reference data), per-revision block projection, multi-file sets
create table authoring.block_type (
  code text primary key check (code ~ '^[a-z][a-z_]{1,40}$'),
  tier integer not null check (tier in (1,2)),
  needs_fallback boolean not null,
  required_roles text[] not null default '{}',
  allowed_roles text[] not null default '{}',
  description text not null
);
insert into authoring.block_type(code, tier, needs_fallback, required_roles, allowed_roles, description) values
 ('text',1,false,'{}','{}','Markdown text'),
 ('callout',1,false,'{}','{}','Highlighted note, tip or warning'),
 ('math',1,true,'{}','{}','LaTeX math with plain-language fallback'),
 ('code',1,false,'{}','{source,starter,solution}','Static code listing'),
 ('image',1,true,'{original}','{original,thumbnail,accessible_fallback,source}','Image with alt text'),
 ('diagram',1,true,'{original}','{original,source,static_export,accessible_fallback}','Diagram source plus export'),
 ('video',1,true,'{original,transcript,captions}','{original,transcript,captions,poster,thumbnail,accessible_fallback}','Video with transcript and captions'),
 ('table',1,true,'{}','{dataset}','Table'),
 ('chart',1,true,'{}','{dataset,static_export}','Chart over a dataset'),
 ('quiz',1,true,'{}','{hidden_check}','Check for understanding'),
 ('interactive',1,true,'{}','{build,source,static_export,accessible_fallback,hidden_check}','Trusted interactive component (simulations may carry hidden checks)'),
 ('embedded_site',1,true,'{}','{build,source,static_export}','Harness- or author-built site from the isolated origin or an external deployment'),
 ('external_embed',1,true,'{}','{static_export}','External embed (video platform, sandbox, notebook)'),
 ('sources_panel',1,false,'{}','{}','Sources and decisions'),
 ('challenge_embed',1,true,'{}','{}','Embedded challenge'),
 ('project_milestone',1,true,'{}','{}','Project milestone'),
 ('section',1,false,'{}','{}','Nested section of blocks'),
 ('snippet_ref',1,false,'{}','{}','Reference to a reusable snippet work'),
 ('finding',1,false,'{}','{}','A stated finding with its assertion key and evidence drill-down'),
 ('dataset_view',1,true,'{dataset}','{dataset,static_export}','Table/filter view over a pinned dataset revision'),
 ('runnable_code',2,true,'{}','{starter,solution,environment_spec}','Runnable code cell (browser runtime or sandbox)'),
 ('terminal',2,true,'{}','{environment_spec}','Terminal / launch environment'),
 ('audio',2,true,'{original,transcript}','{original,transcript,accessible_fallback}','Audio with transcript'),
 ('slides',2,true,'{}','{original,static_export,source}','Slide deck');

create table authoring.revision_block (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null,
  block_key uuid not null,
  block_type text not null references authoring.block_type(code) on delete restrict,
  parent_key uuid,
  position integer not null check (position >= 0),
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  unique (tenant_id, workspace_id, id), unique (tenant_id, revision_id, block_key),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);
create index revision_block_key_ix on authoring.revision_block(tenant_id, block_key);

create table authoring.file_set (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  entrypoint text not null check (entrypoint !~ '(^/|\.\.)'),
  tree_sha256 text not null check (tree_sha256 ~ '^[0-9a-f]{64}$'),
  file_count integer not null check (file_count > 0 and file_count <= 5000),
  total_bytes bigint not null check (total_bytes >= 0),
  origin text not null check (origin in ('web','harness','mcp','cli','worker')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict
);

create table authoring.file_set_entry (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  file_set_id uuid not null,
  path text not null check (char_length(path) <= 512 and path ~ '^[A-Za-z0-9._@+-][A-Za-z0-9._@+/-]*$' and path !~ '(^|/)\.\.(/|$)' and path !~ '//'),
  artifact_id uuid not null,
  sha256 text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  size_bytes bigint not null check (size_bytes >= 0),
  media_type text not null,
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, file_set_id, path),
  foreign key (tenant_id, workspace_id, file_set_id) references authoring.file_set(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

create table authoring.event (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  work_id uuid,
  revision_id uuid,
  kind text not null check (kind in ('feedback','revision_proposed','reviewed','change_detected','change_acknowledged','withdrawn',
                                     'sync_conflict','write_back_proposed','write_back_applied','write_back_failed','removal_impact_acknowledged',
                                     'proposal_submitted','accepted','acceptance_withdrawn','delivered','delivery_accepted','delivery_rejected',
                                     'change_proposed','change_applied','change_rejected','watch_paused')),
  related_event_id uuid,
  actor_id uuid not null references auth.users(id) on delete restrict,
  actor_kind text not null check (actor_kind in ('human','agent','system')),
  client_surface text not null check (client_surface in ('web','harness','import','system')),
  author_role text not null check (author_role in ('student','teacher','system_author','learner','maintainer')),
  payload_schema text not null check (payload_schema ~ '^aieng\.[a-z-]+\.v[0-9]+$'),
  payload jsonb not null default '{}',
  dedupe_key text not null check (product.nonblank(dedupe_key)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, dedupe_key),
  check (revision_id is null or work_id is not null),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, work_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, work_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, related_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);

create table authoring.command (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  actor_id uuid not null references auth.users(id) on delete restrict,
  operation text not null,
  idempotency_key text not null check (char_length(idempotency_key) between 8 and 200),
  input_sha256 text not null check (input_sha256 ~ '^[0-9a-f]{64}$'),
  result jsonb not null,
  origin text not null check (origin in ('web','harness','mcp','cli','api','worker','system')),
  origin_ref jsonb not null default '{}',
  client_grant_id uuid,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, actor_id, idempotency_key),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, client_grant_id) references access.client_grant(tenant_id, id) on delete restrict
);

-- ------------------------------------------------------------------ curriculum (Build 01 R1/R2)
create table curriculum.part (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  parent_revision_id uuid not null,
  occurrence_key uuid not null,
  child_revision_id uuid not null,
  ordinal integer not null check (ordinal >= 0),
  role text not null check (role in ('recommended','optional')),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  unique (tenant_id, workspace_id, parent_revision_id, occurrence_key),
  unique (tenant_id, workspace_id, parent_revision_id, ordinal),
  check (parent_revision_id <> child_revision_id),
  foreign key (tenant_id, workspace_id, parent_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, child_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table curriculum.outcome (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null,
  outcome_key uuid not null,
  statement text not null check (product.nonblank(statement)),
  bloom_level text check (bloom_level in ('remember','understand','apply','analyze','evaluate','create')),
  evidence_rule jsonb not null check (evidence_rule ->> 'schema' in ('aieng.evidence-rule.v1','aieng.evidence-rule.v2')),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  unique (tenant_id, workspace_id, revision_id, outcome_key), unique (tenant_id, workspace_id, revision_id, id),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table curriculum.requirement (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null,
  requirement_key uuid not null,
  kind text not null check (kind in ('outcome','mandatory_activity')),
  outcome_id uuid, part_id uuid,
  rationale text not null check (product.nonblank(rationale)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  unique (tenant_id, workspace_id, revision_id, requirement_key),
  check ((kind = 'outcome' and outcome_id is not null and part_id is null) or (kind = 'mandatory_activity' and part_id is not null and outcome_id is null)),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, revision_id, outcome_id) references curriculum.outcome(tenant_id, workspace_id, revision_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, part_id) references curriculum.part(tenant_id, workspace_id, id) on delete restrict
);

create table curriculum.requirement_option (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  requirement_id uuid not null,
  route text not null check (route in ('standard','prior_work','test_out','alternative','generated_eligible','learner_project')),
  activity_revision_id uuid,
  evidence_rule jsonb not null check (evidence_rule ->> 'schema' in ('aieng.evidence-rule.v1','aieng.evidence-rule.v2')),
  approval_state text not null check (approval_state in ('proposed','approved')),
  approved_by uuid references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  check ((approval_state = 'approved') = (approved_by is not null)),
  check ((route in ('standard','test_out')) = (activity_revision_id is not null) or route in ('prior_work','alternative')),
  check (route <> 'learner_project' or activity_revision_id is null),
  check (route <> 'generated_eligible' or activity_revision_id is null),
  foreign key (tenant_id, workspace_id, requirement_id) references curriculum.requirement(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, activity_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table curriculum.prerequisite (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null, required_revision_id uuid not null,
  strength text not null check (strength in ('recommended','required')),
  rationale text not null check (product.nonblank(rationale)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, revision_id, required_revision_id),
  check (revision_id <> required_revision_id),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, required_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table curriculum.outcome_alignment (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  outcome_id uuid not null,
  competency_revision_id uuid not null,         -- same tenant; may be a released official competency (checked in API)
  facet text not null check (facet in ('independent','assisted','agent_directed')),
  coverage text not null check (coverage in ('full','partial')),
  rationale text not null check (product.nonblank(rationale)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet),
  foreign key (tenant_id, workspace_id, outcome_id) references curriculum.outcome(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, competency_revision_id) references authoring.work_revision(tenant_id, id) on delete restrict
);

create table authoring.runtime_requirement (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null,
  local_key text not null check (local_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'),
  kind text not null check (kind in ('language_runtime','package','model','provider_api','service','network_host','secret_name','hardware','renderer_capability')),
  ecosystem text,
  name text not null check (product.nonblank(name)),
  version_spec text not null,
  resolved_version text,
  entity_id uuid,
  phase text not null check (phase in ('build','run','test')),
  optional boolean not null default false,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, revision_id, local_key),
  check (kind not in ('package','model') or ecosystem is not null),
  check (kind <> 'secret_name' or name !~ '(sk-|ghp_|xox[bp]-|AKIA|-----BEGIN)'),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, entity_id) references corpus.entity(tenant_id, id) on delete restrict
);
create index runtime_requirement_lookup_ix on authoring.runtime_requirement(tenant_id, kind, ecosystem, name);

-- ------------------------------------------------------------------ release / distribution (Build 01 R2)
create table authoring.release (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  root_work_id uuid not null,
  root_revision_id uuid not null,
  release_no integer not null check (release_no > 0),
  audience_ceiling text not null check (audience_ceiling in ('workspace','named','public')),
  manifest_artifact_id uuid not null,
  closure_sha256 text not null check (closure_sha256 ~ '^[0-9a-f]{64}$'),
  approved_event_id uuid not null,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, root_work_id, release_no),
  foreign key (tenant_id, workspace_id, root_work_id, root_revision_id) references authoring.work_revision(tenant_id, workspace_id, work_id, id) on delete restrict,
  foreign key (tenant_id, manifest_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, approved_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);

create table authoring.release_item (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  release_id uuid not null,
  item_key text not null,
  revision_id uuid, artifact_id uuid, capture_id uuid, locator_id uuid, claim_id uuid, record_id uuid, entity_id uuid,
  via_binding_id uuid,
  disposition text not null check (disposition in ('include','snapshot','reference','withheld')),
  substitute_artifact_id uuid,
  decided_by uuid references auth.users(id) on delete restrict,
  rationale text,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, release_id, item_key),
  check (num_nonnulls(revision_id, artifact_id, capture_id, locator_id, claim_id, record_id, entity_id) = 1),
  check ((disposition = 'snapshot') = (substitute_artifact_id is not null)),
  check ((decided_by is null) = (rationale is null)),
  foreign key (tenant_id, workspace_id, release_id) references authoring.release(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, substitute_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, capture_id) references evidence.source_capture(tenant_id, id) on delete restrict,
  foreign key (tenant_id, locator_id) references evidence.locator(tenant_id, id) on delete restrict,
  foreign key (tenant_id, claim_id) references evidence.claim(tenant_id, id) on delete restrict,
  foreign key (tenant_id, record_id) references knowledge.record(tenant_id, id) on delete restrict,
  foreign key (tenant_id, entity_id) references corpus.entity(tenant_id, id) on delete restrict
);

create table authoring.revision_binding (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null,
  local_key text not null check (local_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'),
  relation text not null check (relation in ('derived_from','uses','representation','source','supports','contradicts','covers','targets','derived_from_problem',
                                             'has_component','adapted_from','links_to','contains','evaluates_with','generated_under','anchored_to','scenario_of')),
  target_revision_id uuid, target_work_id uuid, artifact_id uuid, capture_id uuid, locator_id uuid, claim_id uuid, entity_id uuid, record_id uuid, release_item_id uuid,
  file_set_id uuid,
  assertion_id uuid,                                   -- Build 07: an exact statement (FK added with inquiry.assertion)
  role text check (role in ('original','transcript','captions','thumbnail','poster','accessible_fallback','source','build','static_export','lockfile',
                            'starter','solution','hidden_check','dataset','environment_spec')),
  block_key uuid,
  usage text not null check (usage in ('reference_only','private_copy','redistributable','unknown')),
  rights_basis text not null check (product.nonblank(rights_basis)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, revision_id, local_key),
  check (num_nonnulls(target_revision_id, target_work_id, artifact_id, capture_id, locator_id, claim_id, entity_id, record_id, release_item_id, file_set_id, assertion_id) = 1),
  check ((target_work_id is not null) <= (relation in ('links_to','contains'))),
  check ((release_item_id is not null) <= (relation in ('adapted_from','generated_under','anchored_to','scenario_of'))),
  check (relation <> 'scenario_of' or release_item_id is not null or target_revision_id is not null),
  check ((assertion_id is not null) <= (relation in ('uses','supports','contradicts','links_to'))),
  check (relation not in ('adapted_from','generated_under') or release_item_id is not null),
  check (relation <> 'anchored_to' or release_item_id is not null or target_revision_id is not null),
  check ((file_set_id is not null) <= (relation in ('representation','uses','evaluates_with'))),
  check (relation not in ('links_to','contains') or target_work_id is not null or target_revision_id is not null or assertion_id is not null),
  check (relation <> 'representation' or artifact_id is not null or file_set_id is not null),
  check (relation <> 'source' or capture_id is not null or locator_id is not null),
  check (relation <> 'has_component' or target_revision_id is not null),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, target_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, target_work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, capture_id) references evidence.source_capture(tenant_id, id) on delete restrict,
  foreign key (tenant_id, locator_id) references evidence.locator(tenant_id, id) on delete restrict,
  foreign key (tenant_id, claim_id) references evidence.claim(tenant_id, id) on delete restrict,
  foreign key (tenant_id, entity_id) references corpus.entity(tenant_id, id) on delete restrict,
  foreign key (tenant_id, record_id) references knowledge.record(tenant_id, id) on delete restrict,
  foreign key (tenant_id, release_item_id) references authoring.release_item(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, file_set_id) references authoring.file_set(tenant_id, workspace_id, id) on delete restrict
);
alter table authoring.release_item add constraint release_item_binding_fk
  foreign key (tenant_id, workspace_id, via_binding_id) references authoring.revision_binding(tenant_id, workspace_id, id) on delete restrict;

create table curriculum.release_transition (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  from_release_id uuid not null, to_release_id uuid not null,
  mapping_schema text not null check (mapping_schema = 'aieng.release-transition.v1'),
  mapping jsonb not null,
  compatibility text not null check (compatibility in ('needs_review','compatible','breaking')),
  reviewed_event_id uuid,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, from_release_id, to_release_id),
  check (from_release_id <> to_release_id),
  check (compatibility <> 'compatible' or reviewed_event_id is not null),
  foreign key (tenant_id, workspace_id, from_release_id) references authoring.release(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, to_release_id) references authoring.release(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, reviewed_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);

create table curriculum.requirement_transition (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  transition_id uuid not null,
  from_requirement_id uuid, to_requirement_id uuid,
  effect text not null check (effect in ('same','equivalent','narrowed','broadened','replaced','removed','added')),
  carry text not null check (carry in ('carry','reassess','not_applicable')),
  rationale text not null check (product.nonblank(rationale)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  check ((effect = 'added') = (from_requirement_id is null)),
  check ((effect = 'removed') = (to_requirement_id is null)),
  check (not (effect in ('broadened','replaced','added') and carry = 'carry')),
  foreign key (tenant_id, workspace_id, transition_id) references curriculum.release_transition(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, from_requirement_id) references curriculum.requirement(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, to_requirement_id) references curriculum.requirement(tenant_id, workspace_id, id) on delete restrict
);
create unique index requirement_transition_pair_uq on curriculum.requirement_transition(tenant_id, workspace_id, transition_id, from_requirement_id, to_requirement_id) nulls not distinct;

create table authoring.distribution (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  root_work_id uuid not null,
  channel text not null check (channel in ('workspace','invited','public_library','official_catalog')),
  title text not null check (product.nonblank(title)),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  closed_at timestamptz,
  closed_event_id uuid,
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  foreign key (tenant_id, workspace_id, root_work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, closed_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);
create unique index distribution_official_open_uq on authoring.distribution(tenant_id, root_work_id) where channel = 'official_catalog' and closed_at is null;

create table authoring.distribution_member (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  distribution_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  grant_basis text not null check (grant_basis in ('invited')),
  granted_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (tenant_id, workspace_id, id),
  foreign key (tenant_id, workspace_id, distribution_id) references authoring.distribution(tenant_id, workspace_id, id) on delete restrict
);
create unique index distribution_member_active_uq on authoring.distribution_member(tenant_id, distribution_id, principal_id) where revoked_at is null;

create table authoring.distribution_offer (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  distribution_id uuid not null,
  release_id uuid not null,
  offer_no integer not null check (offer_no > 0),
  terms_schema text not null check (terms_schema = 'aieng.use-terms.v1'),
  terms jsonb not null,
  approval_event_id uuid not null,
  offered_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  ended_at timestamptz,
  end_kind text check (end_kind in ('retire','revoke')),
  end_event_id uuid,
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  unique (tenant_id, workspace_id, distribution_id, offer_no), unique (tenant_id, workspace_id, distribution_id, release_id),
  check ((ended_at is null) = (end_kind is null) and (ended_at is null) = (end_event_id is null)),
  foreign key (tenant_id, workspace_id, distribution_id) references authoring.distribution(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, release_id) references authoring.release(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, approval_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, end_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);

create table authoring.publisher_grant (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  channel text not null check (channel = 'official_catalog'),
  granted_by uuid references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);
create unique index publisher_grant_active_uq on authoring.publisher_grant(tenant_id, principal_id, channel) where revoked_at is null;

-- ------------------------------------------------------------------ learning (Build 01 R2 amendments + Build 03)
create table learning.enrollment (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,          -- learner's personal workspace
  learner_id uuid not null references auth.users(id) on delete restrict,
  source_workspace_id uuid not null,
  distribution_id uuid not null,
  update_policy text not null default 'manual' check (update_policy in ('manual','auto_compatible')),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, learner_id, distribution_id),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, source_workspace_id, distribution_id) references authoring.distribution(tenant_id, workspace_id, id) on delete restrict
);

create table learning.release_adoption (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  enrollment_id uuid not null,
  sequence_no integer not null check (sequence_no > 0),
  previous_adoption_id uuid,
  source_workspace_id uuid not null,
  offer_id uuid not null,
  transition_id uuid,
  personal_revision_id uuid,
  actor_id uuid not null references auth.users(id) on delete restrict,
  basis text not null check (basis in ('explicit','standing_consent')),
  reason text not null check (product.nonblank(reason)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  unique (tenant_id, workspace_id, enrollment_id, sequence_no), unique (tenant_id, workspace_id, enrollment_id, id),
  check ((sequence_no = 1) = (previous_adoption_id is null)),
  check (previous_adoption_id is null or transition_id is not null),
  foreign key (tenant_id, workspace_id, enrollment_id) references learning.enrollment(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, enrollment_id, previous_adoption_id) references learning.release_adoption(tenant_id, workspace_id, enrollment_id, id) on delete restrict,
  foreign key (tenant_id, source_workspace_id, offer_id) references authoring.distribution_offer(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, source_workspace_id, transition_id) references curriculum.release_transition(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, personal_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table learning.mastery_decision (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  competency_revision_id uuid not null,
  facet text not null check (facet in ('independent','assisted','agent_directed')),
  state text not null check (state in ('not_assessed','developing','demonstrated','retained','transferred')),
  policy_revision_id uuid not null,
  evidence jsonb not null default '[]',
  uncertainty text not null check (product.nonblank(uncertainty)),
  review_due_at timestamptz,
  supersedes_id uuid,
  decided_by text not null check (decided_by in ('policy','human')),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, competency_revision_id) references authoring.work_revision(tenant_id, id) on delete restrict,
  foreign key (tenant_id, policy_revision_id) references authoring.work_revision(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, supersedes_id) references learning.mastery_decision(tenant_id, workspace_id, id) on delete restrict
);
create index mastery_current_ix on learning.mastery_decision(learner_id, competency_revision_id, facet, created_at desc);

-- Build 05: deployments (where a revision/file set is served), learner equivalence requests, environments
create table authoring.deployment (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid,
  file_set_id uuid,
  target text not null check (target in ('platform_static','external')),
  environment text not null check (environment in ('preview','published')),
  url text not null check (url ~ '^https://'),
  external_ref jsonb,
  snapshot_file_set_id uuid,
  status text not null check (status in ('pending','live','failed','retired')),
  origin text not null check (origin in ('web','harness','mcp','cli','worker')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  retired_at timestamptz,
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  check (target <> 'platform_static' or file_set_id is not null),
  check (target <> 'external' or external_ref is not null),
  check ((status = 'retired') = (retired_at is not null)),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, file_set_id) references authoring.file_set(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, snapshot_file_set_id) references authoring.file_set(tenant_id, workspace_id, id) on delete restrict
);

create table learning.equivalence_request (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  enrollment_id uuid not null,
  work_revision_id uuid not null,
  requirement_keys uuid[] not null check (cardinality(requirement_keys) > 0),
  evidence_plan text not null check (product.nonblank(evidence_plan)),
  assistant_check jsonb check (assistant_check is null or assistant_check ->> 'schema' = 'aieng.decision-answer.v1'),
  state text not null check (state in ('proposed','checked','approved','rejected','withdrawn')),
  decided_by uuid references auth.users(id) on delete restrict,
  decision text check (decision in ('maintainer','owner_course_auto')),
  decision_reason text,
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check ((state in ('approved','rejected')) = (decided_at is not null and decision is not null)),
  foreign key (tenant_id, workspace_id, enrollment_id) references learning.enrollment(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, work_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table access.provided_credential (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null,
  principal_id uuid not null references auth.users(id) on delete restrict,
  provider_key text not null check (provider_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'),
  secret_handle text not null check (secret_handle ~ '^[a-z0-9][a-z0-9_./:-]{2,200}$' and secret_handle !~ '(sk-|ghp_|xox[bp]-|AKIA|-----BEGIN)'),
  spend_limit_usd numeric(12,2) not null check (spend_limit_usd >= 0),
  period text not null check (period in ('once','day','month')),
  issued_at timestamptz not null default now(),
  expires_at timestamptz not null,
  revoked_at timestamptz,
  unique (tenant_id, id),
  check (expires_at > issued_at)
);

create table learning.environment_session (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  project_work_id uuid,
  spec_revision_id uuid,
  provider text not null check (provider in ('local_harness','browser_runtime','cloud_sandbox','external')),
  adapter text,
  status text not null check (status in ('requested','provisioning','ready','stopped','expired','failed')),
  key_handles jsonb not null default '[]',
  spend_limit_usd numeric(12,2),
  spent_usd numeric(12,4) not null default 0,
  external_ref jsonb,
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  ended_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check (provider not in ('browser_runtime','cloud_sandbox') or adapter is not null),
  foreign key (tenant_id, workspace_id, project_work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, spec_revision_id) references authoring.work_revision(tenant_id, id) on delete restrict
);

create table learning.attempt (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  task_revision_id uuid,
  task_release_item_id uuid,
  enrollment_id uuid, adoption_id uuid,
  requirement_key uuid, option_id uuid,
  purpose text not null check (purpose in ('practice','official','diagnostic','retention_check','transfer_check')),
  conditions jsonb not null check (conditions ->> 'schema' = 'aieng.attempt-conditions.v1' and conditions ->> 'facet' in ('independent','assisted','agent_directed')),
  previous_attempt_id uuid,
  mastery_decision_id uuid,
  equivalence_request_id uuid,
  environment_session_id uuid,
  state text not null default 'started' check (state in ('started','submitted','abandoned','expired')),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  active_seconds integer check (active_seconds >= 0),
  active_seconds_source text,
  unique (tenant_id, workspace_id, id),
  check (num_nonnulls(task_revision_id, task_release_item_id) = 1),
  check (purpose <> 'official' or (enrollment_id is not null and adoption_id is not null and requirement_key is not null and option_id is not null)),
  check ((purpose in ('retention_check','transfer_check')) = (mastery_decision_id is not null)),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, task_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, task_release_item_id) references authoring.release_item(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, enrollment_id) references learning.enrollment(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, enrollment_id, adoption_id) references learning.release_adoption(tenant_id, workspace_id, enrollment_id, id) on delete restrict,
  foreign key (tenant_id, option_id) references curriculum.requirement_option(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, previous_attempt_id) references learning.attempt(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, mastery_decision_id) references learning.mastery_decision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, equivalence_request_id) references learning.equivalence_request(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, environment_session_id) references learning.environment_session(tenant_id, workspace_id, id) on delete restrict
);
create index attempt_learner_ix on learning.attempt(learner_id, started_at);

create table learning.submission (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  attempt_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  manifest_artifact_id uuid not null,
  closure_sha256 text not null check (closure_sha256 ~ '^[0-9a-f]{64}$'),
  observed_conditions jsonb not null default '{}',
  submitted_via text not null check (submitted_via in ('web','harness','import')),
  created_at timestamptz not null default now(),
  withdrawn_at timestamptz,
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, attempt_id),
  foreign key (tenant_id, workspace_id, attempt_id) references learning.attempt(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, manifest_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

-- ------------------------------------------------------------------ conversation (Build 02)
create table conversation.thread (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete restrict,
  visibility text not null default 'private' check (visibility in ('private','workspace')),
  title text not null check (product.nonblank(title)),
  purpose text not null check (purpose in ('tutor','build','research','authoring','project','general','defense')),
  mode text not null default 'coach' check (mode in ('coach','build_with_me')),
  origin text not null default 'native' check (origin in ('native','import')),
  imported_from jsonb,
  created_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check ((origin = 'import') = (imported_from is not null)),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict
);
create index thread_owner_ix on conversation.thread(owner_id, created_at);

create table conversation.context_snapshot (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  digest text not null check (digest ~ '^[0-9a-f]{64}$'),
  body jsonb not null check (body ->> 'schema' = 'aieng.context.v1'),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, digest),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict
);

create table conversation.message (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  thread_id uuid not null,
  seq integer not null check (seq > 0),
  role text not null check (role in ('user','assistant','tool','system_note')),
  author_id uuid references auth.users(id) on delete restrict,
  agent_identity text,
  client_surface text not null check (client_surface in ('web','harness','import')),
  content jsonb not null check (content ->> 'schema' = 'aieng.message.v1' and octet_length(content::text) <= 262144),
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  context_snapshot_id uuid,
  runtime_ref jsonb not null default '{}',
  usage jsonb not null default '{}',
  created_at timestamptz not null default now(),
  redacted_at timestamptz,
  redacted_by_removal_id uuid,
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, thread_id, seq),
  check ((role = 'user') <= (author_id is not null)),
  foreign key (tenant_id, workspace_id, thread_id) references conversation.thread(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, context_snapshot_id) references conversation.context_snapshot(tenant_id, workspace_id, id) on delete restrict
);

create table learning.evidence_item (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  submission_id uuid not null,
  item_key text not null check (item_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'),
  kind text not null check (kind in ('project_revision','artifact','response','operational_evidence','defense','repository_commit','deployment')),
  revision_id uuid, artifact_id uuid, message_id uuid, file_set_id uuid, deployment_id uuid,
  external_ref jsonb,
  sha256 text check (sha256 ~ '^[0-9a-f]{64}$'),
  availability text not null check (availability in ('preserved','reference_only','unavailable')),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, submission_id, item_key),
  check (num_nonnulls(revision_id, artifact_id, message_id, file_set_id, deployment_id, external_ref) = 1),
  foreign key (tenant_id, workspace_id, file_set_id) references authoring.file_set(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, deployment_id) references authoring.deployment(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, submission_id) references learning.submission(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, message_id) references conversation.message(tenant_id, workspace_id, id) on delete restrict
);

create table learning.grading_run (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  submission_id uuid not null,
  pipeline_revision_id uuid not null,
  kind text not null check (kind in ('deterministic','model_judgment','defense','human_review','mixed')),
  runner jsonb not null default '{}',
  check_bundle_sha256 text check (check_bundle_sha256 ~ '^[0-9a-f]{64}$'),
  status text not null check (status in ('queued','running','completed','unavailable','abstained','error')),
  failure_class text,
  reason text,
  runtime_ref jsonb not null default '{}',
  replay_artifact_id uuid,
  requested_by text not null check (requested_by in ('initial','rerun','appeal','correction')),
  created_at timestamptz not null default now(),
  started_at timestamptz, finished_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check ((status in ('unavailable','error')) = (failure_class is not null)),
  foreign key (tenant_id, workspace_id, submission_id) references learning.submission(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, pipeline_revision_id) references authoring.work_revision(tenant_id, id) on delete restrict,
  foreign key (tenant_id, replay_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

create table learning.criterion_result (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  grading_run_id uuid not null,
  criterion_key text not null,
  value jsonb not null,
  visibility text not null check (visibility in ('student_visible','withheld')),
  judged_by text not null check (judged_by in ('deterministic','model','human')),
  judgment jsonb,
  reviewer_id uuid references auth.users(id) on delete restrict,
  explanation text not null check (product.nonblank(explanation)),
  evidence_refs jsonb not null default '[]',
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, grading_run_id, criterion_key),
  check ((judged_by = 'model') = (judgment is not null and judgment ->> 'schema' = 'aieng.decision-answer.v1')),
  check ((judged_by = 'human') = (reviewer_id is not null)),
  foreign key (tenant_id, workspace_id, grading_run_id) references learning.grading_run(tenant_id, workspace_id, id) on delete restrict
);

create table learning.assessment_result (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  submission_id uuid not null,
  sequence_no integer not null check (sequence_no > 0),
  outcomes jsonb not null,
  status text not null check (status in ('provisional','final','superseded')),
  finalized_by text check (finalized_by in ('auto','human')),
  finalization_policy_revision_id uuid,
  finalized_at timestamptz,
  supersedes_id uuid,
  reason text not null check (product.nonblank(reason)),
  explanation_artifact_id uuid,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, submission_id, sequence_no),
  check ((finalized_by is null) = (finalized_at is null)),
  check (finalized_by <> 'auto' or finalization_policy_revision_id is not null),
  foreign key (tenant_id, workspace_id, submission_id) references learning.submission(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, finalization_policy_revision_id) references authoring.work_revision(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, supersedes_id) references learning.assessment_result(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, explanation_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);

create table learning.credit (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  enrollment_id uuid not null, adoption_id uuid not null,
  requirement_id uuid not null,
  route text not null check (route in ('standard','prior_work','test_out','alternative','generated_eligible','learner_project')),
  facet text not null check (facet in ('independent','assisted','agent_directed')),
  result_id uuid,
  carried_from_credit_id uuid,
  transition_id uuid,
  status text not null check (status in ('active','revoked','superseded')),
  status_reason text,
  created_at timestamptz not null default now(),
  ended_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check (num_nonnulls(result_id, carried_from_credit_id) = 1),
  check ((carried_from_credit_id is null) = (transition_id is null)),
  check ((status = 'active') = (ended_at is null)),
  foreign key (tenant_id, workspace_id, enrollment_id, adoption_id) references learning.release_adoption(tenant_id, workspace_id, enrollment_id, id) on delete restrict,
  foreign key (tenant_id, requirement_id) references curriculum.requirement(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, result_id) references learning.assessment_result(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, carried_from_credit_id) references learning.credit(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, transition_id) references curriculum.release_transition(tenant_id, id) on delete restrict
);
create unique index credit_active_uq on learning.credit(tenant_id, workspace_id, adoption_id, requirement_id) where status = 'active';

create table learning.appeal (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  result_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  grounds text not null check (product.nonblank(grounds) and char_length(grounds) <= 20000),
  new_evidence_submission_id uuid,
  state text not null check (state in ('open','under_review','upheld','modified','rejected','withdrawn')),
  reviewer_id uuid references auth.users(id) on delete restrict,
  resolution_result_id uuid,
  resolution text,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check ((state in ('upheld','modified','rejected')) = (resolved_at is not null and resolution is not null)),
  foreign key (tenant_id, workspace_id, result_id) references learning.assessment_result(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, new_evidence_submission_id) references learning.submission(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, resolution_result_id) references learning.assessment_result(tenant_id, workspace_id, id) on delete restrict
);

create table learning.evidence_grant (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  learner_id uuid not null references auth.users(id) on delete restrict,
  grantee_id uuid not null references auth.users(id) on delete restrict,
  scope_kind text not null check (scope_kind in ('enrollment','all_learning')),
  enrollment_id uuid,
  includes text[] not null check (cardinality(includes) > 0 and includes <@ array['progress','results','submissions','mastery','goals']),
  guardian_link_id uuid,
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check ((scope_kind = 'enrollment') = (enrollment_id is not null)),
  check (learner_id <> grantee_id),
  foreign key (tenant_id, workspace_id, enrollment_id) references learning.enrollment(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, guardian_link_id) references access.guardian_link(tenant_id, id) on delete restrict
);

-- ------------------------------------------------------------------ library (Build 02)
create table library.connection (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  provider text not null check (provider in ('obsidian','notion','google_drive','local_folder')),
  account_label text not null check (product.nonblank(account_label)),
  capabilities text[] not null check (capabilities <@ array['read','write','watch'] and cardinality(capabilities) > 0),
  credential_handle text not null check (credential_handle ~ '^[a-z0-9][a-z0-9_./:-]{2,200}$' and credential_handle !~ '(sk-|ghp_|xox[bp]-|AKIA|secret_)'),
  status text not null check (status in ('active','error','disconnected')),
  connected_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  disconnected_at timestamptz,
  last_error text,
  unique (tenant_id, workspace_id, id),
  check ((status = 'disconnected') = (disconnected_at is not null)),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict
);

create table library.connected_item (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  connection_id uuid not null,
  external_id text not null,
  external_kind text not null check (external_kind in ('page','document','file','folder')),
  external_location text not null,
  selected_via text not null check (selected_via in ('explicit','folder_rule')),
  work_id uuid not null,
  editing_home text not null check (editing_home in ('external','native')),
  remote_revision text,
  synced_revision_id uuid,
  sync_state text not null check (sync_state in ('in_sync','pending','conflict','unavailable','remote_deleted','disconnected')),
  suppressed_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, connection_id, external_id), unique (tenant_id, workspace_id, work_id),
  foreign key (tenant_id, workspace_id, connection_id) references library.connection(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, work_id, synced_revision_id) references authoring.work_revision(tenant_id, workspace_id, work_id, id) on delete restrict
);

create table library.resource_control (
  tenant_id uuid not null, workspace_id uuid not null,
  work_id uuid not null,
  excluded_at timestamptz,
  excluded_by uuid references auth.users(id) on delete restrict,
  semantic_index boolean not null default false,
  updated_by uuid not null references auth.users(id) on delete restrict,
  updated_at timestamptz not null default now(),
  primary key (tenant_id, workspace_id, work_id),
  check ((excluded_at is null) = (excluded_by is null)),
  foreign key (tenant_id, workspace_id, work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict
);

create table library.preparation (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid, artifact_id uuid,
  stage text not null check (stage in ('receive','convert','extract','index_lexical','index_semantic')),
  procedure_version text not null check (product.nonblank(procedure_version)),
  status text not null check (status in ('pending','running','succeeded','failed','skipped')),
  attempt_count integer not null default 0 check (attempt_count >= 0),
  failure_class text,
  output_ref jsonb not null default '{}',
  origin_ref jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  check (num_nonnulls(revision_id, artifact_id) = 1),
  check ((status = 'failed') = (failure_class is not null)),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict
);
create unique index preparation_target_uq on library.preparation(tenant_id, workspace_id, coalesce(revision_id, artifact_id), stage, procedure_version);

create table library.passage (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid, artifact_id uuid, message_id uuid,
  passage_no integer not null check (passage_no >= 0),
  locator jsonb not null check (locator ->> 'schema' = 'aieng.locator.v1'),
  text text not null check (product.nonblank(text) and char_length(text) <= 8000),
  language regconfig not null default 'english',
  tsv tsvector generated always as (to_tsvector(language, text)) stored,
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  procedure_version text not null check (product.nonblank(procedure_version)),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  check (num_nonnulls(revision_id, artifact_id, message_id) = 1),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, message_id) references conversation.message(tenant_id, workspace_id, id) on delete restrict
);
create unique index passage_target_uq on library.passage(tenant_id, workspace_id, coalesce(revision_id, artifact_id, message_id), procedure_version, passage_no);
create index passage_tsv_ix on library.passage using gin (tsv);

create table library.passage_embedding_1536 (
  tenant_id uuid not null, workspace_id uuid not null,
  passage_id uuid not null,
  space_version_id uuid not null,
  embedding extensions.halfvec(1536) not null,
  embedding_sha256 text not null check (embedding_sha256 ~ '^[0-9a-f]{64}$'),
  processor_authorization_id uuid,
  created_at timestamptz not null default now(),
  primary key (tenant_id, workspace_id, passage_id, space_version_id),
  foreign key (tenant_id, workspace_id, passage_id) references library.passage(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, space_version_id) references retrieval.vector_space_version(tenant_id, id) on delete restrict,
  foreign key (tenant_id, processor_authorization_id) references access.processing_authorization(tenant_id, id) on delete restrict
);
create index passage_embedding_hnsw on library.passage_embedding_1536 using hnsw (embedding extensions.halfvec_cosine_ops);

create table library.removal (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  requested_by uuid not null references auth.users(id) on delete restrict,
  targets jsonb not null,
  impact jsonb not null,
  impact_acknowledged_event_id uuid,
  state text not null check (state in ('previewed','acknowledged','in_progress','completed','partial','failed','blocked')),
  steps jsonb not null default '[]',
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (tenant_id, workspace_id, id),
  foreign key (tenant_id, workspace_id) references authoring.workspace(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, impact_acknowledged_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);
alter table authoring.work_revision add constraint work_revision_purge_fk
  foreign key (tenant_id, workspace_id, purged_by_removal_id) references library.removal(tenant_id, workspace_id, id) on delete restrict;
alter table conversation.message add constraint message_redaction_fk
  foreign key (tenant_id, workspace_id, redacted_by_removal_id) references library.removal(tenant_id, workspace_id, id) on delete restrict;

create table conversation.context_item (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  snapshot_id uuid not null,
  item_key text not null,
  reason text not null check (reason in ('view','pinned','retrieved','attached')),
  revision_id uuid, artifact_id uuid, release_item_id uuid, passage_id uuid, offer_id uuid, part_id uuid,
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, snapshot_id, item_key),
  check (num_nonnulls(revision_id, artifact_id, release_item_id, passage_id, offer_id, part_id) = 1),
  foreign key (tenant_id, workspace_id, snapshot_id) references conversation.context_snapshot(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, release_item_id) references authoring.release_item(tenant_id, id) on delete restrict,
  foreign key (tenant_id, offer_id) references authoring.distribution_offer(tenant_id, id) on delete restrict,
  foreign key (tenant_id, part_id) references curriculum.part(tenant_id, id) on delete restrict
);
-- passage_id is deliberately not a foreign key: passages are regenerable projections and a past context must survive
-- their regeneration/removal (lab finding F-03); access is rechecked on display.

-- ------------------------------------------------------------------ Build 07: research requests, datasets, statements and support
-- One accepted scope of research: an exact proposal (brief revision), budget, world window and execution origin.
-- MC coordinates are references to the separately installed Mission Control component (no physical FK).
create table inquiry.acceptance (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  brief_work_id uuid not null,
  brief_revision_id uuid not null,
  acceptance_no integer not null check (acceptance_no > 0),
  revises_acceptance_id uuid,
  accepted_by uuid not null references auth.users(id) on delete restrict,
  accepted_event_id uuid not null,
  budget_limit_usd numeric(10,2) not null check (budget_limit_usd >= 0),
  spent_usd numeric(10,2) not null default 0 check (spent_usd >= 0),
  budget_policy jsonb not null default '{}' check (jsonb_typeof(budget_policy) = 'object'),
  world_from timestamptz, world_to timestamptz,
  world_precision text not null default 'unknown' check (world_precision in ('instant','day','unknown')),
  knowledge_policy text not null check (knowledge_policy in ('sealed','latest_at_run')),
  execution_origin text not null check (execution_origin in ('mc','native_harness','manual')),
  mc_installation_id uuid, mc_application_id text, mc_mission_id uuid, mc_revision_id uuid, mc_run_id uuid,
  state text not null default 'accepted' check (state in ('accepted','running','delivered','closed','cancelled','failed','superseded')),
  state_changed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, brief_work_id, acceptance_no),
  check (execution_origin <> 'mc' or (mc_installation_id is not null and mc_application_id is not null and mc_mission_id is not null and mc_revision_id is not null)),
  check (execution_origin = 'mc' or num_nonnulls(mc_installation_id, mc_application_id, mc_mission_id, mc_revision_id, mc_run_id) = 0),
  check (spent_usd <= budget_limit_usd),
  check ((world_precision = 'unknown' and world_from is null and world_to is null)
      or (world_precision = 'instant' and world_from is not null and world_from = world_to)
      or (world_precision = 'day' and world_from is not null and world_from < world_to)),
  foreign key (tenant_id, workspace_id, brief_work_id, brief_revision_id) references authoring.work_revision(tenant_id, workspace_id, work_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, revises_acceptance_id) references inquiry.acceptance(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, accepted_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);

create table inquiry.obligation (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  acceptance_id uuid not null,
  obligation_key text not null check (obligation_key ~ '^[a-z0-9][a-z0-9._:-]{0,99}$'),
  form text not null check (form in ('dataset','report','experience','finding_set','file','course_content')),
  enforcement text not null check (enforcement in ('required','expected','optional')),
  expected_work_kind text,
  criteria jsonb not null default '{}' check (jsonb_typeof(criteria) = 'object'),
  mc_obligation_key text check (mc_obligation_key ~ '^[a-z0-9][a-z0-9._:-]{0,199}$'),
  position integer not null check (position >= 0),
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, acceptance_id, obligation_key),
  foreign key (tenant_id, workspace_id, acceptance_id) references inquiry.acceptance(tenant_id, workspace_id, id) on delete restrict
);

create table inquiry.delivery (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  obligation_id uuid not null,
  revision_id uuid, artifact_id uuid, file_set_id uuid,
  mc_output_revision_id uuid,
  delivered_by uuid not null references auth.users(id) on delete restrict,
  delivered_kind text not null check (delivered_kind in ('human','agent','system')),
  origin text not null check (origin in ('mc','native_harness','manual')),
  delivered_event_id uuid not null,
  state text not null default 'submitted' check (state in ('submitted','accepted','rejected','withdrawn')),
  assessment jsonb not null default '{}' check (jsonb_typeof(assessment) = 'object'),
  decided_by uuid references auth.users(id) on delete restrict,
  decided_event_id uuid,
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  unique (tenant_id, workspace_id, id),
  check (num_nonnulls(revision_id, artifact_id, file_set_id) = 1),
  check ((state in ('accepted','rejected')) = (decided_by is not null and decided_at is not null and decided_event_id is not null)),
  foreign key (tenant_id, workspace_id, obligation_id) references inquiry.obligation(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, file_set_id) references authoring.file_set(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, delivered_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, decided_event_id) references authoring.event(tenant_id, workspace_id, id) on delete restrict
);

-- Opt-in recurring refresh: configuration only. Each run is an ordinary acceptance revising the previous one.
create table inquiry.watch (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  brief_work_id uuid not null,
  subjects jsonb not null check (jsonb_typeof(subjects) = 'array' and jsonb_array_length(subjects) > 0),
  sources jsonb not null check (jsonb_typeof(sources) = 'array'),
  cadence text not null check (cadence ~ '^P(T?[0-9]+[YMWDHS])+$'),
  budget_per_run_usd numeric(10,2) not null check (budget_per_run_usd >= 0),
  budget_total_usd numeric(10,2) not null check (budget_total_usd >= budget_per_run_usd),
  stop_condition jsonb not null default '{}' check (jsonb_typeof(stop_condition) = 'object'),
  target_work_ids uuid[] not null default '{}',
  mc_schedule_ref text,
  state text not null default 'active' check (state in ('active','paused','stopped')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  state_changed_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  foreign key (tenant_id, workspace_id, brief_work_id) references authoring.work(tenant_id, workspace_id, id) on delete restrict
);

-- Datasets: authoring.work(kind='dataset'). Every field/row/cell version is valid for revisions [from, to).
-- The draft is head revision_no + 1. A version superseded inside the same draft gets to = from (never visible
-- in any revision, kept as edit history). Staged proposal versions have from = NULL until applied.
create table dataset.field (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  dataset_work_id uuid not null,
  dataset_kind text not null default 'dataset' check (dataset_kind = 'dataset'),
  field_key uuid not null,
  name text not null check (product.nonblank(name) and char_length(name) <= 200),
  value_type text not null check (value_type in ('text','number','integer','boolean','date','datetime','money','percent','entity','url','json')),
  unit text, currency text check (currency ~ '^[A-Z]{3}$'),
  meaning text not null check (product.nonblank(meaning)),
  required boolean not null default false,
  position integer not null check (position >= 0),
  entered_by uuid not null references auth.users(id) on delete restrict,
  from_revision_no integer not null check (from_revision_no > 0),
  to_revision_no integer,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  check (to_revision_no is null or to_revision_no >= from_revision_no),
  check ((value_type = 'money') = (currency is not null)),
  foreign key (tenant_id, workspace_id, dataset_work_id, dataset_kind) references authoring.work(tenant_id, workspace_id, id, kind) on delete restrict
);
create unique index field_open_uq on dataset.field(dataset_work_id, field_key) where to_revision_no is null;
create unique index field_open_name_uq on dataset.field(dataset_work_id, lower(name)) where to_revision_no is null;

create table dataset.proposal (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  dataset_work_id uuid not null,
  dataset_kind text not null default 'dataset' check (dataset_kind = 'dataset'),
  base_revision_no integer not null check (base_revision_no > 0),
  reason text not null check (reason in ('refresh','correction','watch','agent_edit','import')),
  acceptance_id uuid,
  summary jsonb not null check (jsonb_typeof(summary) = 'object'),
  dedupe_key text not null check (product.nonblank(dedupe_key)),
  state text not null default 'open' check (state in ('open','applied','rejected','stale')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_kind text not null check (created_kind in ('human','agent','system')),
  created_at timestamptz not null default now(),
  decided_by uuid references auth.users(id) on delete restrict,
  decided_at timestamptz,
  applied_revision_id uuid,
  unique (tenant_id, workspace_id, id), unique (tenant_id, workspace_id, dataset_work_id, dedupe_key),
  check ((state = 'applied') = (applied_revision_id is not null)),
  check ((state in ('applied','rejected')) = (decided_by is not null)),
  foreign key (tenant_id, workspace_id, dataset_work_id, dataset_kind) references authoring.work(tenant_id, workspace_id, id, kind) on delete restrict,
  foreign key (tenant_id, workspace_id, acceptance_id) references inquiry.acceptance(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, applied_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);

create table dataset.row (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  dataset_work_id uuid not null,
  dataset_kind text not null default 'dataset' check (dataset_kind = 'dataset'),
  row_key uuid not null,
  entity_id uuid,
  label text check (char_length(label) <= 300),
  position integer not null check (position >= 0),
  entered_by uuid not null references auth.users(id) on delete restrict,
  proposal_id uuid,
  from_revision_no integer check (from_revision_no > 0),
  to_revision_no integer,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  check (from_revision_no is not null or proposal_id is not null),
  check (to_revision_no is null or (from_revision_no is not null and to_revision_no >= from_revision_no)),
  foreign key (tenant_id, workspace_id, dataset_work_id, dataset_kind) references authoring.work(tenant_id, workspace_id, id, kind) on delete restrict,
  foreign key (tenant_id, entity_id) references corpus.entity(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, proposal_id) references dataset.proposal(tenant_id, workspace_id, id) on delete restrict
);
create unique index row_open_uq on dataset.row(dataset_work_id, row_key) where to_revision_no is null and from_revision_no is not null;

create table dataset.cell (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  dataset_work_id uuid not null,
  dataset_kind text not null default 'dataset' check (dataset_kind = 'dataset'),
  row_key uuid not null,
  field_key uuid not null,
  value jsonb,
  value_status text not null check (value_status in ('observed','calculated','inferred','estimated','unknown','not_found','undisclosed','conflicting','not_applicable')),
  observed_at timestamptz,
  entered_by uuid not null references auth.users(id) on delete restrict,
  entered_kind text not null check (entered_kind in ('human','agent','import')),
  entered_origin_ref jsonb not null default '{}',
  proposal_id uuid,
  from_revision_no integer check (from_revision_no > 0),
  to_revision_no integer,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id),
  check (from_revision_no is not null or proposal_id is not null),
  check (to_revision_no is null or (from_revision_no is not null and to_revision_no >= from_revision_no)),
  check ((value is not null) = (value_status in ('observed','calculated','inferred','estimated'))),
  check (value is null or octet_length(value::text) <= 16384),
  foreign key (tenant_id, workspace_id, dataset_work_id, dataset_kind) references authoring.work(tenant_id, workspace_id, id, kind) on delete restrict,
  foreign key (tenant_id, workspace_id, proposal_id) references dataset.proposal(tenant_id, workspace_id, id) on delete restrict
);
create unique index cell_open_uq on dataset.cell(dataset_work_id, row_key, field_key) where to_revision_no is null and from_revision_no is not null;
create index cell_revision_ix on dataset.cell(dataset_work_id, from_revision_no, to_revision_no);

-- One statement made in an exact work revision (report finding, estimate, assumption ...). Workspace-scoped:
-- private findings never become tenant-shared evidence.claim rows; shared claims are cited by id.
create table inquiry.assertion (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  revision_id uuid not null,
  assertion_key uuid not null,
  block_key uuid,
  kind text not null check (kind in ('finding','claim','estimate','comparison','recommendation','assumption','limitation','question')),
  statement text not null check (product.nonblank(statement) and char_length(statement) <= 4000),
  structured jsonb,
  support_status text not null check (support_status in ('supported','partially_supported','contradicted','unsupported','judgment','unknown','undisclosed','not_applicable')),
  entity_ids uuid[] not null default '{}',
  world_from timestamptz, world_to timestamptz,
  world_precision text not null default 'unknown' check (world_precision in ('instant','day','unknown')),
  uses_claim_id uuid,
  promoted_claim_id uuid,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id), unique (tenant_id, id), unique (tenant_id, workspace_id, revision_id, assertion_key),
  check ((world_precision = 'unknown' and world_from is null and world_to is null)
      or (world_precision = 'instant' and world_from is not null and world_from = world_to)
      or (world_precision = 'day' and world_from is not null and world_from < world_to)),
  foreign key (tenant_id, workspace_id, revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, uses_claim_id) references evidence.claim(tenant_id, id) on delete restrict,
  foreign key (tenant_id, promoted_claim_id) references evidence.claim(tenant_id, id) on delete restrict
);
create index assertion_key_ix on inquiry.assertion(tenant_id, assertion_key);
alter table authoring.revision_binding add constraint revision_binding_assertion_fk
  foreign key (tenant_id, assertion_id) references inquiry.assertion(tenant_id, id) on delete restrict;

-- One piece of support, contradiction, calculation or inference for a statement or a dataset value/row/dataset.
-- Lab finding F-25: shared evidence.source_capture rows require an MC attempt or KS operation, so pages fetched for a
-- workspace are `document` work revisions; support then targets that exact revision plus a selector into its bytes.
create table inquiry.support (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null, workspace_id uuid not null,
  assertion_id uuid,
  dataset_work_id uuid, row_key uuid, field_key uuid, cell_id uuid,
  role text not null check (role in ('supports','contradicts','qualifies','context','calculated_from','inferred_by')),
  source_revision_id uuid, locator_id uuid, capture_id uuid, claim_id uuid, record_id uuid,
  target_assertion_id uuid, target_cell_id uuid,
  decision_revision_id uuid, answer_key text,
  selector jsonb check (selector is null or jsonb_typeof(selector) = 'object'),
  excerpt text check (char_length(excerpt) <= 2000),
  method jsonb check (method is null or jsonb_typeof(method) = 'object'),
  assessed_by uuid not null references auth.users(id) on delete restrict,
  assessed_kind text not null check (assessed_kind in ('human','agent','verification')),
  verification_ref text,
  assessed_at timestamptz not null default now(),
  unique (tenant_id, workspace_id, id),
  check (num_nonnulls(assertion_id, dataset_work_id) = 1),
  check (dataset_work_id is not null or num_nonnulls(row_key, field_key, cell_id) = 0),
  check (cell_id is null or (row_key is not null and field_key is not null)),
  check (num_nonnulls(source_revision_id, locator_id, capture_id, claim_id, record_id, target_assertion_id, target_cell_id, decision_revision_id)
         = case when role = 'calculated_from' then least(1, num_nonnulls(source_revision_id, locator_id, capture_id, claim_id, record_id, target_assertion_id, target_cell_id, decision_revision_id)) else 1 end),
  check (role <> 'calculated_from' or method ? 'expression'),
  check (role <> 'inferred_by' or decision_revision_id is not null or (assessed_kind = 'agent' and method is not null)),
  check ((decision_revision_id is null) = (answer_key is null)),
  check (selector is null or source_revision_id is not null),
  check ((assessed_kind = 'verification') = (verification_ref is not null)),
  foreign key (tenant_id, workspace_id, assertion_id) references inquiry.assertion(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, cell_id) references dataset.cell(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, source_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, locator_id) references evidence.locator(tenant_id, id) on delete restrict,
  foreign key (tenant_id, capture_id) references evidence.source_capture(tenant_id, id) on delete restrict,
  foreign key (tenant_id, claim_id) references evidence.claim(tenant_id, id) on delete restrict,
  foreign key (tenant_id, record_id) references knowledge.record(tenant_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, target_assertion_id) references inquiry.assertion(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, target_cell_id) references dataset.cell(tenant_id, workspace_id, id) on delete restrict,
  foreign key (tenant_id, workspace_id, decision_revision_id) references authoring.work_revision(tenant_id, workspace_id, id) on delete restrict
);
create index support_dataset_ix on inquiry.support(dataset_work_id, row_key, field_key) where dataset_work_id is not null;
create index support_source_ix on inquiry.support(source_revision_id) where source_revision_id is not null;

-- ------------------------------------------------------------------ guards
-- Sealed revisions: only content_sha256 (once) and purge columns (inside a purge) change.
create or replace function product.guard_revision() returns trigger language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'authoring.work_revision is append-only' using errcode = 'restrict_violation'; end if;
  if pg_catalog.current_setting('product.purge', true) = 'on' and old.purged_at is null and new.purged_at is not null then
    if (pg_catalog.to_jsonb(new) - array['body','purged_at','purged_by_removal_id']) is distinct from (pg_catalog.to_jsonb(old) - array['body','purged_at','purged_by_removal_id']) then
      raise exception 'purge may change only body and purge columns' using errcode = 'restrict_violation';
    end if;
    return new;
  end if;
  if old.content_sha256 is not null or new.content_sha256 is null
     or (pg_catalog.to_jsonb(new) - 'content_sha256') is distinct from (pg_catalog.to_jsonb(old) - 'content_sha256') then
    raise exception 'saved revisions are immutable' using errcode = 'restrict_violation';
  end if;
  return new;
end $$;
create trigger work_revision_guard before update or delete on authoring.work_revision for each row execute function product.guard_revision();

-- Lab finding F-07: deferred constraint triggers fire at COMMIT as the session role (after the SECURITY DEFINER API
-- function returned), so this check must itself be SECURITY DEFINER (owner set in the API migration).
create or replace function product.check_revision_sealed() returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if exists (select 1 from authoring.work_revision r where r.id = new.id and r.content_sha256 is null) then
    raise exception 'revision % committed without a seal', new.id using errcode = 'check_violation';
  end if;
  return null;
end $$;
create constraint trigger work_revision_sealed_at_commit after insert on authoring.work_revision
  deferrable initially deferred for each row execute function product.check_revision_sealed();

create or replace function product.guard_unsealed_parent() returns trigger language plpgsql set search_path = '' as $$
declare rid uuid := (pg_catalog.to_jsonb(new) ->> tg_argv[0])::uuid;
begin
  if rid is null then
    select o.revision_id into rid from curriculum.outcome o where o.id = (pg_catalog.to_jsonb(new) ->> 'outcome_id')::uuid;
    if rid is null then select q.revision_id into rid from curriculum.requirement q where q.id = (pg_catalog.to_jsonb(new) ->> 'requirement_id')::uuid; end if;
  end if;
  if exists (select 1 from authoring.work_revision r where r.id = rid and r.content_sha256 is not null) then
    raise exception 'cannot add to sealed revision %', rid using errcode = 'restrict_violation';
  end if;
  return new;
end $$;

do $$
declare t record;
begin
  -- children of a revision: insert only while unsealed, immutable afterwards
  for t in select * from (values
      ('authoring.revision_binding','revision_id'), ('authoring.runtime_requirement','revision_id'), ('curriculum.part','parent_revision_id'),
      ('curriculum.outcome','revision_id'), ('curriculum.requirement','revision_id'), ('curriculum.prerequisite','revision_id'),
      ('curriculum.requirement_option','requirement_id'), ('curriculum.outcome_alignment','outcome_id'), ('authoring.revision_block','revision_id'),
      ('inquiry.assertion','revision_id')) v(tbl, col)
  loop
    execute format('create trigger seal_guard before insert on %s for each row execute function product.guard_unsealed_parent(%L)', t.tbl,
      case when t.col in ('requirement_id','outcome_id') then 'none' else t.col end);
  end loop;
  -- fully append-only
  for t in select unnest(array['authoring.revision_binding','authoring.runtime_requirement','curriculum.part','curriculum.outcome','curriculum.requirement',
      'curriculum.prerequisite','curriculum.requirement_option','curriculum.outcome_alignment','authoring.event','authoring.command','authoring.release',
      'authoring.release_item','curriculum.release_transition','curriculum.requirement_transition','learning.enrollment','learning.release_adoption',
      'learning.submission','learning.evidence_item','learning.criterion_result','learning.mastery_decision','conversation.context_snapshot',
      'conversation.context_item','access.policy_version','access.account_profile',
      'authoring.revision_block','authoring.file_set','authoring.file_set_entry','authoring.block_type',
      'inquiry.obligation','inquiry.support']) as tbl
  loop
    execute format('create trigger immutable_guard before update or delete on %s for each row execute function product.guard_immutable()', t.tbl);
  end loop;
end $$;

-- set-once columns
create trigger immutable_guard before update or delete on authoring.workspace for each row execute function product.guard_immutable();
create trigger immutable_guard before update or delete on authoring.workspace_member for each row execute function product.guard_immutable('revoked_at');
create trigger immutable_guard before update or delete on authoring.asset_scope for each row execute function product.guard_immutable('revoked_at');
create trigger immutable_guard before update or delete on authoring.distribution for each row execute function product.guard_immutable('closed_at','closed_event_id');
create trigger immutable_guard before update or delete on authoring.distribution_member for each row execute function product.guard_immutable('revoked_at');
create trigger immutable_guard before update or delete on authoring.distribution_offer for each row execute function product.guard_immutable('ended_at','end_kind','end_event_id');
create trigger immutable_guard before update or delete on authoring.publisher_grant for each row execute function product.guard_immutable('revoked_at');
create trigger immutable_guard before update or delete on learning.evidence_grant for each row execute function product.guard_immutable('revoked_at');
create trigger immutable_guard before update or delete on learning.credit for each row execute function product.guard_immutable('ended_at');
create trigger immutable_guard before update or delete on access.guardian_link for each row execute function product.guard_mutable('state','consented_at','revoked_at','help_scope','consent_method','consent_evidence_artifact_id');
create trigger immutable_guard before update or delete on access.processing_authorization for each row execute function product.guard_immutable('withdrawn_at');
create trigger immutable_guard before update or delete on access.client_grant for each row execute function product.guard_mutable('last_used_at','revoked_at');
create trigger immutable_guard before update or delete on access.provided_credential for each row execute function product.guard_immutable('revoked_at');
create trigger mutable_guard before update or delete on authoring.deployment for each row execute function product.guard_mutable('status','retired_at');
create trigger mutable_guard before update or delete on learning.equivalence_request for each row execute function product.guard_mutable('assistant_check','state','decided_by','decision','decision_reason','decided_at');
create trigger mutable_guard before update or delete on learning.environment_session for each row execute function product.guard_mutable('status','external_ref','spent_usd','expires_at','ended_at');
create trigger immutable_guard before update or delete on access.source_restriction for each row execute function product.guard_immutable('lifted_at');
create trigger immutable_guard before update or delete on library.connection for each row execute function product.guard_mutable('status','disconnected_at','last_error');
-- Build 07
create trigger immutable_guard before update or delete on inquiry.assertion for each row execute function product.guard_immutable('promoted_claim_id');
create trigger mutable_guard before update or delete on inquiry.acceptance for each row execute function product.guard_mutable('state','state_changed_at','spent_usd','budget_policy','mc_run_id');
create trigger mutable_guard before update or delete on inquiry.delivery for each row execute function product.guard_mutable('state','assessment','decided_by','decided_event_id','decided_at');
create trigger mutable_guard before update or delete on inquiry.watch for each row execute function product.guard_mutable('state','state_changed_at','mc_schedule_ref');
create trigger mutable_guard before update or delete on dataset.proposal for each row execute function product.guard_mutable('state','decided_by','decided_at','applied_revision_id');
create trigger immutable_guard before update or delete on dataset.field for each row execute function product.guard_immutable('to_revision_no');
create trigger immutable_guard before update or delete on dataset.row for each row execute function product.guard_immutable('from_revision_no','to_revision_no');
create trigger immutable_guard before update or delete on dataset.cell for each row execute function product.guard_immutable('from_revision_no','to_revision_no');
-- current-state rows
create trigger mutable_guard before update or delete on authoring.work for each row execute function product.guard_mutable('head_revision_id');
create trigger mutable_guard before update or delete on learning.attempt for each row execute function product.guard_mutable('state','ended_at','active_seconds','active_seconds_source');
create trigger mutable_guard before update or delete on learning.grading_run for each row execute function product.guard_mutable('status','failure_class','reason','runtime_ref','replay_artifact_id','started_at','finished_at');
create trigger mutable_guard before update or delete on learning.assessment_result for each row execute function product.guard_mutable('status');
create trigger mutable_guard before update or delete on learning.appeal for each row execute function product.guard_mutable('state','reviewer_id','resolution_result_id','resolution','resolved_at');
create trigger mutable_guard before update or delete on library.connected_item for each row execute function product.guard_mutable('remote_revision','synced_revision_id','sync_state','suppressed_at','updated_at','editing_home');
create trigger mutable_guard before update or delete on library.resource_control for each row execute function product.guard_mutable('excluded_at','excluded_by','semantic_index','updated_by','updated_at');
create trigger mutable_guard before update or delete on library.preparation for each row execute function product.guard_mutable('status','attempt_count','failure_class','output_ref','origin_ref','updated_at');
create trigger mutable_guard before update or delete on library.passage for each row execute function product.guard_mutable();
create trigger mutable_guard before update or delete on library.passage_embedding_1536 for each row execute function product.guard_mutable();
create trigger mutable_guard before update or delete on library.removal for each row execute function product.guard_mutable('impact_acknowledged_event_id','state','steps','completed_at');
create trigger mutable_guard before update or delete on conversation.thread for each row execute function product.guard_mutable('visibility','title','archived_at','mode');
create trigger mutable_guard before update or delete on conversation.message for each row execute function product.guard_mutable('content','redacted_at','redacted_by_removal_id');

-- ------------------------------------------------------------------ FK indexes, RLS, grants (all new relations)
do $$
declare c record; r record; cols text;
begin
  for c in
    select con.conrelid::regclass as tbl, con.conkey, con.conname
    from pg_constraint con join pg_class cl on cl.oid = con.conrelid join pg_namespace n on n.oid = cl.relnamespace
    where con.contype = 'f' and n.nspname in ('authoring','curriculum','learning','library','conversation','access','inquiry','dataset')
      and cl.relname not in ('curriculum','track','module','lesson','lesson_version','challenge','challenge_version','learning_objective',
                             'lesson_covers_concept','challenge_targets','lesson_backed_by','challenge_derived_from','lesson_prerequisite')
  loop
    if not exists (select 1 from pg_index i where i.indrelid = c.tbl::oid
                   and (string_to_array(i.indkey::text, ' ')::int2[])[1:array_length(c.conkey,1)] = c.conkey) then
      select string_agg(quote_ident(a.attname), ',' order by k.ord) into cols
        from unnest(c.conkey) with ordinality k(attnum, ord) join pg_attribute a on a.attrelid = c.tbl::oid and a.attnum = k.attnum;
      execute format('create index %I on %s (%s)', left(c.conname, 55) || '_ix', c.tbl, cols);
    end if;
  end loop;

  for r in
    select n.nspname, cl.relname from pg_class cl join pg_namespace n on n.oid = cl.relnamespace
    where cl.relkind = 'r' and n.nspname in ('authoring','learning','library','conversation','access','inquiry','dataset')
       or (cl.relkind = 'r' and n.nspname = 'curriculum' and cl.relname in ('part','outcome','requirement','requirement_option','prerequisite',
                                                                           'outcome_alignment','release_transition','requirement_transition'))
  loop
    execute format('alter table %I.%I enable row level security', r.nspname, r.relname);
    execute format('alter table %I.%I force row level security', r.nspname, r.relname);
    execute format('revoke all on %I.%I from public, anon, authenticated, service_role', r.nspname, r.relname);
    execute format('grant select, insert, update, delete on %I.%I to product_api_owner', r.nspname, r.relname);
    execute format('create policy product_api_all on %I.%I to product_api_owner using (true) with check (true)', r.nspname, r.relname);
  end loop;
end $$;

grant usage on schema authoring, curriculum, learning, library, conversation, access, inquiry, dataset, product to product_api_owner;
revoke all on schema authoring, learning, library, conversation, access, inquiry, dataset, product from public, anon, authenticated;
grant usage on schema util, extensions, evidence, corpus, knowledge, orchestration, retrieval, temporal to product_api_owner;
grant execute on all functions in schema product to product_api_owner;
grant select on evidence.source_capture, evidence.locator, evidence.claim, corpus.entity, knowledge.record, retrieval.vector_space_version to product_api_owner;
grant select, insert, update on orchestration.artifact to product_api_owner;
grant select, insert on orchestration.artifact_tombstone to product_api_owner;

-- Product artifacts only: the API owner sees and writes rows in the private product bucket, nothing else.
create policy product_api_workspace_artifacts on orchestration.artifact to product_api_owner
  using (storage_bucket = 'aieng-workspaces') with check (storage_bucket = 'aieng-workspaces' and bucket_class = 'workspace' and verification_contract_version is null);
create policy product_api_workspace_tombstones on orchestration.artifact_tombstone to product_api_owner using (true) with check (true);

insert into orchestration.artifact_type(code, description) values
  ('authored_work_asset','File attached to an authored work revision in a product workspace'),
  ('course_release_manifest','Frozen release closure manifest'),
  ('course_source_capture','Source capture registered by a product workspace'),
  ('experience_bundle','Built interactive experience bundle'),
  ('uploaded_document','Learner/author uploaded document'),
  ('converted_document','Converted representation of an uploaded document'),
  ('project_bundle','Project source bundle or file manifest'),
  ('submission_manifest','Frozen submission evidence manifest'),
  ('grading_replay','Grading run replay/log artifact'),
  ('file_set_file','One file of a multi-file set (site, repository snapshot, build)'),
  ('media_derivative','Transcript, captions, poster or other media derivative'),
  ('result_explanation','Assessment result explanation')
on conflict (code) do nothing;

insert into storage.buckets(id, name, public) values ('aieng-workspaces','aieng-workspaces', false) on conflict (id) do nothing;

commit;
