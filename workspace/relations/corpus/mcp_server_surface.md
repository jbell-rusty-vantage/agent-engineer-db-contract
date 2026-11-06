---
id: "rel:corpus.mcp_server_surface"
kind: table
schema: corpus
name: mcp_server_surface
domain: identity
aliases: []
tokens: [corpus, mcp_server_surface, corpus.mcp_server_surface, id, tenant_id, server_id, surface_kind, name, schema_artifact_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"mcp_server_surface\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.mcp_server_surface

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, server_id, surface_kind, name) |
| 3 | `server_id` | `uuid` | no | — | unique (tenant_id, server_id, surface_kind, name); FK → [`corpus.mcp_server`](mcp_server.md).id |
| 4 | `surface_kind` | `text` | no | — | unique (tenant_id, server_id, surface_kind, name) |
| 5 | `name` | `text` | no | — | unique (tenant_id, server_id, surface_kind, name) |
| 6 | `schema_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, server_id, surface_kind, name)
- check `mcp_server_surface_surface_kind_check`: `(surface_kind = ANY (ARRAY['tool'::text, 'resource'::text, 'prompt'::text]))`

## Relationships

Outbound: `schema_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `server_id` → [`corpus.mcp_server`](mcp_server.md)`.id` (+tenant).
Inbound: none.

## Indexes

`mcp_server_surface_tenant_id_id_key` unique; `mcp_server_surface_tenant_id_server_id_surface_kind_name_key` unique

## Triggers

- `artifact_retirement_99f8d759389a9c2836326c19` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_c0ff9fbf6f6d28a731c1b1d2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

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

insert: `Database["corpus"]["Tables"]["mcp_server_surface"]["Insert"]`; row: `Database["corpus"]["Tables"]["mcp_server_surface"]["Row"]`; update: `Database["corpus"]["Tables"]["mcp_server_surface"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
