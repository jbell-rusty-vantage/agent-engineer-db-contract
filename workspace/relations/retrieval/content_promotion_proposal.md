---
id: "rel:retrieval.content_promotion_proposal"
kind: table
schema: retrieval
name: content_promotion_proposal
domain: retrieval
aliases: []
tokens: [retrieval, content_promotion_proposal, retrieval.content_promotion_proposal, id, tenant_id, proposal_sha256, source_manifest, chunk_manifest, projection_manifest, target_domains, expected_value, risks, exclusions, procedures, reason, proposed_by, created_at, operation_id, legacy_provenance]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"content_promotion_proposal\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.content_promotion_proposal

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, proposal_sha256) |
| 3 | `proposal_sha256` | `text` | no | — | unique (tenant_id, proposal_sha256) |
| 4 | `source_manifest` | `jsonb` | no | — | — |
| 5 | `chunk_manifest` | `jsonb` | no | — | — |
| 6 | `projection_manifest` | `jsonb` | no | — | — |
| 7 | `target_domains` | `text[]` | no | — | — |
| 8 | `expected_value` | `text` | no | — | — |
| 9 | `risks` | `text[]` | no | `'{}'::text[]` | — |
| 10 | `exclusions` | `text[]` | no | `'{}'::text[]` | — |
| 11 | `procedures` | `jsonb` | no | — | — |
| 12 | `reason` | `text` | no | — | — |
| 13 | `proposed_by` | `text` | no | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `operation_id` | `uuid` | yes | — | — |
| 16 | `legacy_provenance` | `boolean` | no | `false` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, proposal_sha256)
- check `content_promotion_proposal_proposal_sha256_check`: `(proposal_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `content_promotion_proposal_provenance_required_ck`: `(legacy_provenance OR (operation_id IS NOT NULL))`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.content_promotion_decision`](content_promotion_decision.md).proposal_id.

## Indexes

`content_promotion_proposal_tenant_id_id_key` unique; `content_promotion_proposal_tenant_id_proposal_sha256_key` unique

## Triggers

- `content_promotion_proposal_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `promotion_proposal_no_new_legacy` → [`retrieval.reject_new_legacy_governance_provenance`](../../functions/retrieval/reject_new_legacy_governance_provenance.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["content_promotion_proposal"]["Insert"]`; row: `Database["retrieval"]["Tables"]["content_promotion_proposal"]["Row"]`; update: `Database["retrieval"]["Tables"]["content_promotion_proposal"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
