---
id: "rel:curriculum.requirement"
kind: table
schema: curriculum
name: requirement
domain: curriculum
aliases: []
tokens: [curriculum, requirement, curriculum.requirement, id, tenant_id, workspace_id, revision_id, requirement_key, kind, outcome_id, part_id, rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"requirement\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.requirement

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, requirement_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, requirement_key) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, requirement_key) |
| 5 | `requirement_key` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, requirement_key) |
| 6 | `kind` | `text` | no | — | — |
| 7 | `outcome_id` | `uuid` | yes | — | — |
| 8 | `part_id` | `uuid` | yes | — | — |
| 9 | `rationale` | `text` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, requirement_key)
- check `requirement_check`: `(((kind = 'outcome'::text) AND (outcome_id IS NOT NULL) AND (part_id IS NULL)) OR ((kind = 'mandatory_activity'::text) AND (part_id IS NOT …`
- check `requirement_kind_check`: `(kind = ANY (ARRAY['outcome'::text, 'mandatory_activity'::text]))`
- check `requirement_rationale_check`: `product.nonblank(rationale)`

## Relationships

Outbound: `tenant_id,workspace_id,part_id` → [`curriculum.part`](part.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id,outcome_id` → [`curriculum.outcome`](outcome.md)`.tenant_id,workspace_id,revision_id,id` on delete restrict.
Inbound: [`curriculum.requirement_option`](requirement_option.md).workspace_id,requirement_id, [`curriculum.requirement_transition`](requirement_transition.md).workspace_id,from_requirement_id|workspace_id,to_requirement_id.

## Indexes

`requirement_tenant_id_id_key` unique; `requirement_tenant_id_workspace_id_id_key` unique; `requirement_tenant_id_workspace_id_part_id_fkey_ix`; `requirement_tenant_id_workspace_id_revision_id_outcome__ix`; `requirement_tenant_id_workspace_id_revision_id_requirement__key` unique

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

insert: `Database["curriculum"]["Tables"]["requirement"]["Insert"]`; row: `Database["curriculum"]["Tables"]["requirement"]["Row"]`; update: `Database["curriculum"]["Tables"]["requirement"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
