---
id: "rel:authoring.runtime_requirement"
kind: table
schema: authoring
name: runtime_requirement
domain: authoring
lens: ours
aliases: []
tokens: [authoring, runtime_requirement, authoring.runtime_requirement, id, tenant_id, workspace_id, revision_id, local_key, kind, ecosystem, name, version_spec, resolved_version, entity_id, phase, optional, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"runtime_requirement\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# authoring.runtime_requirement

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, local_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, local_key) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, local_key) |
| 5 | `local_key` | `text` | no | — | unique (tenant_id, workspace_id, revision_id, local_key) |
| 6 | `kind` | `text` | no | — | — |
| 7 | `ecosystem` | `text` | yes | — | — |
| 8 | `name` | `text` | no | — | — |
| 9 | `version_spec` | `text` | no | — | — |
| 10 | `resolved_version` | `text` | yes | — | — |
| 11 | `entity_id` | `uuid` | yes | — | — |
| 12 | `phase` | `text` | no | — | — |
| 13 | `optional` | `boolean` | no | `false` | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, local_key)
- check `runtime_requirement_check`: `((kind <> ALL (ARRAY['package'::text, 'model'::text])) OR (ecosystem IS NOT NULL))`
- check `runtime_requirement_check1`: `((kind <> 'secret_name'::text) OR (name !~ '(sk-\|ghp_\|xox[bp]-\|AKIA\|-----BEGIN)'::text))`
- check `runtime_requirement_kind_check`: `(kind = ANY (ARRAY['language_runtime'::text, 'package'::text, 'model'::text, 'provider_api'::text, 'service'::text, 'network_host'::text, '…`
- check `runtime_requirement_local_key_check`: `(local_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'::text)`
- check `runtime_requirement_name_check`: `product.nonblank(name)`
- check `runtime_requirement_phase_check`: `(phase = ANY (ARRAY['build'::text, 'run'::text, 'test'::text]))`

## Relationships

Outbound: `tenant_id,entity_id` → [`catalog.entity`](../catalog/entity.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`runtime_requirement_lookup_ix`; `runtime_requirement_tenant_id_entity_id_fkey_ix`; `runtime_requirement_tenant_id_workspace_id_id_key` unique; `runtime_requirement_tenant_id_workspace_id_revision_id_loca_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)
- `seal_guard` → [`product.guard_unsealed_parent`](../../functions/product/guard_unsealed_parent.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:ours.modules_affected_by_release`, `q:ours.works_authored`.
- Exposed through: [`api.works_authored`](../api/works_authored.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.insert_revision`](../../functions/product/insert_revision.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["runtime_requirement"]["Insert"]`; row: `Database["authoring"]["Tables"]["runtime_requirement"]["Row"]`; update: `Database["authoring"]["Tables"]["runtime_requirement"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
