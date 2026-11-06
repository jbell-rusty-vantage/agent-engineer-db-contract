---
id: "rel:corpus.repository_module"
kind: table
schema: corpus
name: repository_module
domain: identity
aliases: []
tokens: [corpus, repository_module, corpus.repository_module, id, tenant_id, repository_id, path, module_kind, name, language, manifest_path, manifest_kind, library_id, first_seen_revision_id, last_seen_revision_id, description]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"repository_module\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.repository_module

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, repository_id, path) |
| 3 | `repository_id` | `uuid` | no | — | unique (tenant_id, repository_id, path); FK → [`corpus.repository`](repository.md).id |
| 4 | `path` | `text` | no | — | unique (tenant_id, repository_id, path) |
| 5 | `module_kind` | `text` | no | — | — |
| 6 | `name` | `text` | yes | — | — |
| 7 | `language` | `text` | yes | — | — |
| 8 | `manifest_path` | `text` | yes | — | — |
| 9 | `manifest_kind` | `text` | yes | — | — |
| 10 | `library_id` | `uuid` | yes | — | FK → [`corpus.library`](library.md).id |
| 11 | `first_seen_revision_id` | `uuid` | yes | — | FK → [`corpus.repository_revision`](repository_revision.md).id |
| 12 | `last_seen_revision_id` | `uuid` | yes | — | FK → [`corpus.repository_revision`](repository_revision.md).id |
| 13 | `description` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, repository_id, path)
- check `repository_module_manifest_kind_check`: `(manifest_kind = ANY (ARRAY['package_json'::text, 'pyproject'::text, 'cargo_toml'::text, 'go_mod'::text, 'pom'::text, 'gemspec'::text, 'doc…`
- check `repository_module_module_kind_check`: `(module_kind = ANY (ARRAY['root'::text, 'package'::text, 'app'::text, 'service'::text, 'library'::text, 'docs'::text, 'examples'::text, 'in…`

## Relationships

Outbound: `first_seen_revision_id` → [`corpus.repository_revision`](repository_revision.md)`.id` (+tenant); `last_seen_revision_id` → [`corpus.repository_revision`](repository_revision.md)`.id` (+tenant); `library_id` → [`corpus.library`](library.md)`.id` (+tenant); `repository_id` → [`corpus.repository`](repository.md)`.id` (+tenant).
Inbound: [`corpus.repository_file`](repository_file.md).module_id.

## Indexes

`repository_module_tenant_id_id_key` unique; `repository_module_tenant_id_repository_id_path_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["repository_module"]["Insert"]`; row: `Database["corpus"]["Tables"]["repository_module"]["Row"]`; update: `Database["corpus"]["Tables"]["repository_module"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
