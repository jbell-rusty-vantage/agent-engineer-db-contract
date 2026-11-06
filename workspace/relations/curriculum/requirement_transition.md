---
id: "rel:curriculum.requirement_transition"
kind: table
schema: curriculum
name: requirement_transition
domain: curriculum
aliases: []
tokens: [curriculum, requirement_transition, curriculum.requirement_transition, id, tenant_id, workspace_id, transition_id, from_requirement_id, to_requirement_id, effect, carry, rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"requirement_transition\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.requirement_transition

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `transition_id` | `uuid` | no | — | — |
| 5 | `from_requirement_id` | `uuid` | yes | — | — |
| 6 | `to_requirement_id` | `uuid` | yes | — | — |
| 7 | `effect` | `text` | no | — | — |
| 8 | `carry` | `text` | no | — | — |
| 9 | `rationale` | `text` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `requirement_transition_carry_check`: `(carry = ANY (ARRAY['carry'::text, 'reassess'::text, 'not_applicable'::text]))`
- check `requirement_transition_check`: `((effect = 'added'::text) = (from_requirement_id IS NULL))`
- check `requirement_transition_check1`: `((effect = 'removed'::text) = (to_requirement_id IS NULL))`
- check `requirement_transition_check2`: `(NOT ((effect = ANY (ARRAY['broadened'::text, 'replaced'::text, 'added'::text])) AND (carry = 'carry'::text)))`
- check `requirement_transition_effect_check`: `(effect = ANY (ARRAY['same'::text, 'equivalent'::text, 'narrowed'::text, 'broadened'::text, 'replaced'::text, 'removed'::text, 'added'::tex…`
- check `requirement_transition_rationale_check`: `product.nonblank(rationale)`

## Relationships

Outbound: `tenant_id,workspace_id,from_requirement_id` → [`curriculum.requirement`](requirement.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,to_requirement_id` → [`curriculum.requirement`](requirement.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,transition_id` → [`curriculum.release_transition`](release_transition.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`requirement_transition_pair_uq` unique; `requirement_transition_tenant_id_workspace_id_from_requ_ix`; `requirement_transition_tenant_id_workspace_id_id_key` unique; `requirement_transition_tenant_id_workspace_id_to_requir_ix`

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

insert: `Database["curriculum"]["Tables"]["requirement_transition"]["Insert"]`; row: `Database["curriculum"]["Tables"]["requirement_transition"]["Row"]`; update: `Database["curriculum"]["Tables"]["requirement_transition"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
