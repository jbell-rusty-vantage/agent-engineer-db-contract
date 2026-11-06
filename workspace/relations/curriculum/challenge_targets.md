---
id: "rel:curriculum.challenge_targets"
kind: table
schema: curriculum
name: challenge_targets
domain: curriculum
aliases: []
tokens: [curriculum, challenge_targets, curriculum.challenge_targets, id, challenge_version_id, concept_id, library_id, mcp_server_id, agent_skill_id, solution_pattern_id, target_kind]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"challenge_targets\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.challenge_targets

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `challenge_version_id` | `uuid` | no | — | FK → [`curriculum.challenge_version`](challenge_version.md).id |
| 3 | `concept_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `library_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 5 | `mcp_server_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 6 | `agent_skill_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 7 | `solution_pattern_id` | `uuid` | yes | — | FK → [`knowledge.solution_pattern`](../knowledge/solution_pattern.md).id |
| 8 | `target_kind` | `text` | yes | — | generated: ` CASE     WHEN (concept_id IS NOT NULL) THEN 'concept'::text     WHEN (library_id IS NOT NULL) THEN 'library'::text     WHEN (mcp_server_id IS NOT NULL) THEN 'mcp_server'::text     WHEN (agent_skill_id IS NOT NULL) THEN 'agent_skill'::text     WHEN (solution_pattern_id IS NOT NULL) THEN 'solution_pattern'::text     ELSE NULL::text END` |

## Constraints

- PK (id)
- check `challenge_targets_exactly_one`: `(num_nonnulls(concept_id, library_id, mcp_server_id, agent_skill_id, solution_pattern_id) = 1)`

## Relationships

Outbound: `agent_skill_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `challenge_version_id` → [`curriculum.challenge_version`](challenge_version.md)`.id` on delete cascade; `concept_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `library_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `mcp_server_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `solution_pattern_id` → [`knowledge.solution_pattern`](../knowledge/solution_pattern.md)`.id`.
Inbound: none.
Polymorphic: exactly one of `concept_id`, `library_id`, `mcp_server_id`, `agent_skill_id`, `solution_pattern_id` → [`corpus.entity`](../corpus/entity.md) | [`knowledge.solution_pattern`](../knowledge/solution_pattern.md) — basis: check constraint challenge_targets_exactly_one.

## Indexes

`challenge_targets_version_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["curriculum"]["Tables"]["challenge_targets"]["Insert"]`; row: `Database["curriculum"]["Tables"]["challenge_targets"]["Row"]`; update: `Database["curriculum"]["Tables"]["challenge_targets"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
