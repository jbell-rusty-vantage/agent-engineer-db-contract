---
id: "rel:curriculum.outcome"
kind: table
schema: curriculum
name: outcome
domain: curriculum
aliases: []
tokens: [curriculum, outcome, curriculum.outcome, id, tenant_id, workspace_id, revision_id, outcome_key, statement, bloom_level, evidence_rule, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"outcome\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.outcome

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, id); unique (tenant_id, workspace_id, revision_id, outcome_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, id); unique (tenant_id, workspace_id, revision_id, outcome_key) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, id); unique (tenant_id, workspace_id, revision_id, outcome_key) |
| 5 | `outcome_key` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, outcome_key) |
| 6 | `statement` | `text` | no | — | — |
| 7 | `bloom_level` | `text` | yes | — | — |
| 8 | `evidence_rule` | `jsonb` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, id)
- unique (tenant_id, workspace_id, revision_id, outcome_key)
- check `outcome_bloom_level_check`: `(bloom_level = ANY (ARRAY['remember'::text, 'understand'::text, 'apply'::text, 'analyze'::text, 'evaluate'::text, 'create'::text]))`
- check `outcome_evidence_rule_check`: `((evidence_rule ->> 'schema'::text) = ANY (ARRAY['aieng.evidence-rule.v1'::text, 'aieng.evidence-rule.v2'::text]))`
- check `outcome_statement_check`: `product.nonblank(statement)`

## Relationships

Outbound: `tenant_id,workspace_id,revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`curriculum.outcome_alignment`](outcome_alignment.md).workspace_id,outcome_id, [`curriculum.requirement`](requirement.md).workspace_id,revision_id,outcome_id.

## Indexes

`outcome_tenant_id_id_key` unique; `outcome_tenant_id_workspace_id_id_key` unique; `outcome_tenant_id_workspace_id_revision_id_id_key` unique; `outcome_tenant_id_workspace_id_revision_id_outcome_key_key` unique

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

insert: `Database["curriculum"]["Tables"]["outcome"]["Insert"]`; row: `Database["curriculum"]["Tables"]["outcome"]["Row"]`; update: `Database["curriculum"]["Tables"]["outcome"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
