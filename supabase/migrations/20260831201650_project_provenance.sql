-- Project provenance: the citation graph for local design work.
--
-- This is not research mission control. It records what conversations, docs,
-- specs, and tracker issues produced each other so a Linear ticket can load a
-- sealed bundle. Local files stay the working copy; promote seals bytes here.
--
-- Schema: provenance (internal). Not added to the PostgREST `api` surface.
-- Writes: service_role, or authenticated team members (RLS tenant-scoped).
-- Reads:  the same. anon: none.
--
-- Bucket: ai-engineer-project-provenance (private).
--   cas/sha256/{aa}/{sha256}   content-addressed payload (md, jsonl, json, …)
--   The revision row is the manifest. Do not store a second copy of the bytes.

begin;

create schema if not exists provenance;

comment on schema provenance is
  'Citation graph for product/system design: conversations, local docs, specs, and tracker projections. Not the research flywheel.';

revoke all on schema provenance from public;

grant usage on schema provenance to service_role, authenticated;

-- ---------------------------------------------------------------------------
-- 1. object — stable identity. Mutable title/local_uri. Paths change; ids do not.
--
--    kind + key is the human handle:
--      architecture_doc / adr / spec / feature  key = path slug
--      conversation                             key = {system}:{external_id}
--      issue / pr                               key = {system}:{identifier}
--    local_uri = {repo_slug}:{posix_relative_path} when the object is a file.
-- ---------------------------------------------------------------------------
create table provenance.object (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  kind        text not null check (kind in (
    'conversation',
    'architecture_doc',
    'adr',
    'spec',
    'feature',
    'issue',
    'pr'
  )),
  key         text not null,
  title       text not null,
  local_uri   text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint object_key_nonempty check (btrim(key) <> '' and btrim(title) <> ''),
  unique (tenant_id, kind, key)
);

comment on table provenance.object is
  'Stable design-object identity. One row per conversation, doc, spec, issue, or PR.';
comment on column provenance.object.key is
  'Tenant-unique handle with kind. File slugs, or {system}:{external_id} for conversations and projections.';
comment on column provenance.object.local_uri is
  'Working-copy locator: {repo_slug}:{posix_relative_path}. Null for tracker-only or conversation objects.';

create trigger object_set_updated_at
  before update on provenance.object
  for each row execute function util.set_updated_at();

create index object_kind_idx on provenance.object (tenant_id, kind);

-- ---------------------------------------------------------------------------
-- 2. revision — sealed bytes. Append-only. Promote creates a new row.
-- ---------------------------------------------------------------------------
create table provenance.revision (
  id              uuid primary key default util.uuidv7(),
  tenant_id       uuid not null default util.default_tenant_id(),
  object_id       uuid not null references provenance.object(id),
  revision_no     integer not null check (revision_no > 0),
  sha256          text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  storage_bucket  text not null default 'ai-engineer-project-provenance',
  object_path     text not null,
  media_type      text,
  size_bytes      bigint check (size_bytes is null or size_bytes >= 0),
  summary         text,
  sealed_at       timestamptz not null default now(),
  constraint revision_path_cas check (
    object_path ~ '^cas/sha256/[0-9a-f]{2}/[0-9a-f]{64}$'
  ),
  unique (object_id, revision_no),
  unique (storage_bucket, object_path, object_id)
);

comment on table provenance.revision is
  'Immutable sealed content for one object version. Bytes live at object_path in the provenance bucket.';
comment on column provenance.revision.object_path is
  'CAS key: cas/sha256/{first two hex chars of sha256}/{sha256}.';

create trigger revision_immutable
  before update or delete on provenance.revision
  for each row execute function util.reject_mutation();

create index revision_object_idx on provenance.revision (object_id, revision_no desc);
create index revision_sha256_idx on provenance.revision (sha256);

-- ---------------------------------------------------------------------------
-- 3. edge — declared citation. Append-only. Direction: from was produced
--    using to.
--
--    informed_by   doc|spec|issue  → conversation
--    derived_from  spec|issue|pr   → doc|spec|issue
--    supersedes    same object, newer revision → older revision
-- ---------------------------------------------------------------------------
create table provenance.edge (
  id                uuid primary key default util.uuidv7(),
  tenant_id         uuid not null default util.default_tenant_id(),
  kind              text not null check (kind in (
    'informed_by',
    'derived_from',
    'supersedes'
  )),
  from_object_id    uuid not null references provenance.object(id),
  from_revision_id  uuid references provenance.revision(id),
  to_object_id      uuid not null references provenance.object(id),
  to_revision_id    uuid references provenance.revision(id),
  created_at        timestamptz not null default now(),
  constraint edge_shape check (
    (
      kind = 'supersedes'
      and from_object_id = to_object_id
      and from_revision_id is not null
      and to_revision_id is not null
      and from_revision_id <> to_revision_id
    )
    or
    (
      kind in ('informed_by', 'derived_from')
      and from_object_id <> to_object_id
    )
  ),
  unique nulls not distinct (
    from_object_id, from_revision_id, to_object_id, to_revision_id, kind
  )
);

comment on table provenance.edge is
  'Declared citation. from was informed by / derived from / supersedes to. Not a causal debugger log.';

create trigger edge_immutable
  before update or delete on provenance.edge
  for each row execute function util.reject_mutation();

create index edge_from_idx on provenance.edge (from_object_id, kind);
create index edge_to_idx on provenance.edge (to_object_id, kind);

-- ---------------------------------------------------------------------------
-- 4. binding — external projection (Linear, GitHub, Cursor transcript).
-- ---------------------------------------------------------------------------
create table provenance.binding (
  id           uuid primary key default util.uuidv7(),
  tenant_id    uuid not null default util.default_tenant_id(),
  object_id    uuid not null references provenance.object(id),
  system       text not null check (system in (
    'linear',
    'github',
    'cursor_local',
    'cursor_cloud'
  )),
  external_id  text not null,
  url          text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint binding_external_id_nonempty check (btrim(external_id) <> ''),
  unique (tenant_id, system, external_id)
);

comment on table provenance.binding is
  'Pointer to Linear, GitHub, or a Cursor conversation. The ledger stays here; those systems are projections.';
comment on column provenance.binding.external_id is
  'Linear issue identifier (AIE-123) or UUID; GitHub issue/PR number as owner/repo#n; Cursor transcript or agent id.';

create trigger binding_set_updated_at
  before update on provenance.binding
  for each row execute function util.set_updated_at();

create index binding_object_idx on provenance.binding (object_id);

-- ---------------------------------------------------------------------------
-- 5. Access
-- ---------------------------------------------------------------------------
alter table provenance.object enable row level security;
alter table provenance.revision enable row level security;
alter table provenance.edge enable row level security;
alter table provenance.binding enable row level security;

grant execute on function util.current_tenant_id() to authenticated;

create policy object_tenant on provenance.object
  for all to authenticated, service_role
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());

create policy revision_tenant on provenance.revision
  for all to authenticated, service_role
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());

create policy edge_tenant on provenance.edge
  for all to authenticated, service_role
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());

create policy binding_tenant on provenance.binding
  for all to authenticated, service_role
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());

grant select, insert, update on provenance.object, provenance.binding
  to authenticated, service_role;
grant select, insert on provenance.revision, provenance.edge
  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. Bucket (already created remotely). Keep it private. No deletes.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit)
values (
  'ai-engineer-project-provenance',
  'ai-engineer-project-provenance',
  false,
  52428800
)
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit;

drop policy if exists "ai_engineer_project_provenance_select"
  on storage.objects;
drop policy if exists "ai_engineer_project_provenance_insert"
  on storage.objects;
drop policy if exists "ai_engineer_project_provenance_update"
  on storage.objects;

create policy "ai_engineer_project_provenance_select"
  on storage.objects
  for select
  to authenticated, service_role
  using (bucket_id = 'ai-engineer-project-provenance');

create policy "ai_engineer_project_provenance_insert"
  on storage.objects
  for insert
  to authenticated, service_role
  with check (
    bucket_id = 'ai-engineer-project-provenance'
    and name ~ '^cas/sha256/[0-9a-f]{2}/[0-9a-f]{64}$'
  );

create policy "ai_engineer_project_provenance_update"
  on storage.objects
  for update
  to authenticated, service_role
  using (bucket_id = 'ai-engineer-project-provenance')
  with check (
    bucket_id = 'ai-engineer-project-provenance'
    and name ~ '^cas/sha256/[0-9a-f]{2}/[0-9a-f]{64}$'
  );

commit;
