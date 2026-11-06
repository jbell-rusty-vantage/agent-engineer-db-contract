---
id: "rel:curriculum.release_transition"
kind: table
schema: curriculum
name: release_transition
domain: curriculum
aliases: []
tokens: [curriculum, release_transition, curriculum.release_transition, id, tenant_id, workspace_id, from_release_id, to_release_id, mapping_schema, mapping, compatibility, reviewed_event_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"release_transition\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.release_transition

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, from_release_id, to_release_id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, from_release_id, to_release_id); unique (tenant_id, workspace_id, id) |
| 4 | `from_release_id` | `uuid` | no | — | unique (tenant_id, workspace_id, from_release_id, to_release_id) |
| 5 | `to_release_id` | `uuid` | no | — | unique (tenant_id, workspace_id, from_release_id, to_release_id) |
| 6 | `mapping_schema` | `text` | no | — | — |
| 7 | `mapping` | `jsonb` | no | — | — |
| 8 | `compatibility` | `text` | no | — | — |
| 9 | `reviewed_event_id` | `uuid` | yes | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, from_release_id, to_release_id)
- unique (tenant_id, workspace_id, id)
- check `release_transition_check`: `(from_release_id <> to_release_id)`
- check `release_transition_check1`: `((compatibility <> 'compatible'::text) OR (reviewed_event_id IS NOT NULL))`
- check `release_transition_compatibility_check`: `(compatibility = ANY (ARRAY['needs_review'::text, 'compatible'::text, 'breaking'::text]))`
- check `release_transition_mapping_schema_check`: `(mapping_schema = 'aieng.release-transition.v1'::text)`

## Relationships

Outbound: `tenant_id,workspace_id,from_release_id` → `authoring.release``.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,reviewed_event_id` → `authoring.event``.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,to_release_id` → `authoring.release``.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`curriculum.requirement_transition`](requirement_transition.md).workspace_id,transition_id.

## Indexes

`release_transition_tenant_id_id_key` unique; `release_transition_tenant_id_workspace_id_from_release_id_t_key` unique; `release_transition_tenant_id_workspace_id_id_key` unique; `release_transition_tenant_id_workspace_id_reviewed_even_ix`; `release_transition_tenant_id_workspace_id_to_release_id_ix`

## Triggers

- `immutable_guard` → `product.guard_immutable`

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

insert: `Database["curriculum"]["Tables"]["release_transition"]["Insert"]`; row: `Database["curriculum"]["Tables"]["release_transition"]["Row"]`; update: `Database["curriculum"]["Tables"]["release_transition"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
