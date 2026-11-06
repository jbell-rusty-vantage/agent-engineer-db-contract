---
id: "rel:ranking.group_membership"
kind: table
schema: ranking
name: group_membership
domain: ranking
aliases: []
tokens: [ranking, group_membership, ranking.group_membership, id, group_version_id, library_id, repository_id, person_id, organization_id, paper_id, video_id, ai_model_version_id, mcp_server_id, agent_skill_id, product_id, entity_kind, valid_from, valid_to, provenance_claim_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"group_membership\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.group_membership

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `group_version_id` | `uuid` | no | — | FK → [`ranking.entity_group_version`](entity_group_version.md).id |
| 3 | `library_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `repository_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 5 | `person_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 6 | `organization_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 7 | `paper_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 8 | `video_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 9 | `ai_model_version_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 10 | `mcp_server_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 11 | `agent_skill_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 12 | `product_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 13 | `entity_kind` | `text` | yes | — | generated: ` CASE     WHEN (library_id IS NOT NULL) THEN 'library'::text     WHEN (repository_id IS NOT NULL) THEN 'repository'::text     WHEN (person_id IS NOT NULL) THEN 'person'::text     WHEN (organization_id IS NOT NULL) THEN 'organization'::text     WHEN (paper_id IS NOT NULL) THEN 'paper'::text     WHEN (video_id IS NOT NULL) THEN 'video'::text     WHEN (ai_model_version_id IS NOT NULL) THEN 'ai_model_version'::text     WHEN (mcp_server_id IS NOT NULL) THEN 'mcp_server'::text     WHEN (agent_skill_id IS NOT NULL) THEN 'agent_skill'::text     WHEN (product_id IS NOT NULL) THEN 'product'::text     ELSE NULL::text END` |
| 14 | `valid_from` | `timestamp with time zone` | no | `now()` | — |
| 15 | `valid_to` | `timestamp with time zone` | yes | — | — |
| 16 | `provenance_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 17 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `group_membership_exactly_one_entity`: `(num_nonnulls(library_id, repository_id, person_id, organization_id, paper_id, video_id, ai_model_version_id, mcp_server_id, agent_skill_id…`

## Relationships

Outbound: `agent_skill_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `ai_model_version_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `group_version_id` → [`ranking.entity_group_version`](entity_group_version.md)`.id` on delete cascade; `library_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `mcp_server_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `organization_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `paper_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `person_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `product_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `provenance_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `repository_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `video_id` → [`corpus.entity`](../corpus/entity.md)`.id`.
Inbound: none.
Polymorphic: exactly one of `library_id`, `repository_id`, `person_id`, `organization_id`, `paper_id`, `video_id`, `ai_model_version_id`, `mcp_server_id`, `agent_skill_id`, `product_id` → [`corpus.entity`](../corpus/entity.md) — basis: check constraint group_membership_exactly_one_entity.

## Indexes

`group_membership_version_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["group_membership"]["Insert"]`; row: `Database["ranking"]["Tables"]["group_membership"]["Row"]`; update: `Database["ranking"]["Tables"]["group_membership"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
