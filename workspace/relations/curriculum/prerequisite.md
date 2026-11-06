---
id: "rel:curriculum.prerequisite"
kind: table
schema: curriculum
name: prerequisite
domain: curriculum
aliases: []
tokens: [curriculum, prerequisite, curriculum.prerequisite, id, tenant_id, workspace_id, revision_id, required_revision_id, strength, rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"prerequisite\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.prerequisite

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, required_revision_id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, required_revision_id) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, required_revision_id) |
| 5 | `required_revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, required_revision_id) |
| 6 | `strength` | `text` | no | — | — |
| 7 | `rationale` | `text` | no | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, required_revision_id)
- check `prerequisite_check`: `(revision_id <> required_revision_id)`
- check `prerequisite_rationale_check`: `product.nonblank(rationale)`
- check `prerequisite_strength_check`: `(strength = ANY (ARRAY['recommended'::text, 'required'::text]))`

## Relationships

Outbound: `tenant_id,workspace_id,required_revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`prerequisite_tenant_id_workspace_id_id_key` unique; `prerequisite_tenant_id_workspace_id_required_revision_i_ix`; `prerequisite_tenant_id_workspace_id_revision_id_required_re_key` unique

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

insert: `Database["curriculum"]["Tables"]["prerequisite"]["Insert"]`; row: `Database["curriculum"]["Tables"]["prerequisite"]["Row"]`; update: `Database["curriculum"]["Tables"]["prerequisite"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
