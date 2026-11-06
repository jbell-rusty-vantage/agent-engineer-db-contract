---
id: "rel:public.factory_score_vector"
kind: table
schema: public
name: factory_score_vector
domain: research-starter-protected
aliases: []
tokens: [public, factory_score_vector, public.factory_score_vector, factory_score_vector_id, factory_episode_id, reward_contract_version, vector, weighted_score, eligible_for_promotion, ineligibility_reasons, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_score_vector\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.factory_score_vector

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_score_vector_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_episode_id` | `uuid` | no | — | unique (factory_episode_id, reward_contract_version); FK → [`public.factory_episode`](factory_episode.md).factory_episode_id |
| 3 | `reward_contract_version` | `text` | no | — | unique (factory_episode_id, reward_contract_version) |
| 4 | `vector` | `jsonb` | no | — | — |
| 5 | `weighted_score` | `numeric` | yes | — | — |
| 6 | `eligible_for_promotion` | `boolean` | no | `false` | — |
| 7 | `ineligibility_reasons` | `text[]` | no | `'{}'::text[]` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_score_vector_id)
- unique (factory_episode_id, reward_contract_version)
- check `factory_score_weighted_check`: `((weighted_score IS NULL) OR ((weighted_score >= (0)::numeric) AND (weighted_score <= (1)::numeric)))`

## Relationships

Outbound: `factory_episode_id` → [`public.factory_episode`](factory_episode.md)`.factory_episode_id` on delete cascade.
Inbound: none.

## Indexes

`factory_score_episode_contract_uniq` unique

## Triggers

_None._

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["factory_score_vector"]["Insert"]`; row: `Database["public"]["Tables"]["factory_score_vector"]["Row"]`; update: `Database["public"]["Tables"]["factory_score_vector"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
