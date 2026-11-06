---
id: "rel:curriculum.part"
kind: table
schema: curriculum
name: part
domain: curriculum
aliases: []
tokens: [curriculum, part, curriculum.part, id, tenant_id, workspace_id, parent_revision_id, occurrence_key, child_revision_id, ordinal, role, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"part\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.part

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, parent_revision_id, occurrence_key); unique (tenant_id, workspace_id, parent_revision_id, ordinal) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, parent_revision_id, occurrence_key); unique (tenant_id, workspace_id, parent_revision_id, ordinal) |
| 4 | `parent_revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, parent_revision_id, occurrence_key); unique (tenant_id, workspace_id, parent_revision_id, ordinal) |
| 5 | `occurrence_key` | `uuid` | no | — | unique (tenant_id, workspace_id, parent_revision_id, occurrence_key) |
| 6 | `child_revision_id` | `uuid` | no | — | — |
| 7 | `ordinal` | `integer` | no | — | unique (tenant_id, workspace_id, parent_revision_id, ordinal) |
| 8 | `role` | `text` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, parent_revision_id, occurrence_key)
- unique (tenant_id, workspace_id, parent_revision_id, ordinal)
- check `part_check`: `(parent_revision_id <> child_revision_id)`
- check `part_ordinal_check`: `(ordinal >= 0)`
- check `part_role_check`: `(role = ANY (ARRAY['recommended'::text, 'optional'::text]))`

## Relationships

Outbound: `tenant_id,workspace_id,child_revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,parent_revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`curriculum.requirement`](requirement.md).workspace_id,part_id.

## Indexes

`part_tenant_id_id_key` unique; `part_tenant_id_workspace_id_child_revision_id_fkey_ix`; `part_tenant_id_workspace_id_id_key` unique; `part_tenant_id_workspace_id_parent_revision_id_occurrence_k_key` unique; `part_tenant_id_workspace_id_parent_revision_id_ordinal_key` unique

## Triggers

- `immutable_guard` → `product.guard_immutable`
- `seal_guard` → `product.guard_unsealed_parent`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["curriculum"]["Tables"]["part"]["Insert"]`; row: `Database["curriculum"]["Tables"]["part"]["Row"]`; update: `Database["curriculum"]["Tables"]["part"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
