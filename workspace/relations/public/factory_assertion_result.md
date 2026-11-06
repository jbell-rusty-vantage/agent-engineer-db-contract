---
id: "rel:public.factory_assertion_result"
kind: table
schema: public
name: factory_assertion_result
domain: research-starter-protected
aliases: []
tokens: [public, factory_assertion_result, public.factory_assertion_result, factory_assertion_result_id, factory_episode_id, assertion_key, assertion_kind, evaluator_version, passed, hard_gate, score, details, evidence_artifact_ids, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_assertion_result\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.factory_assertion_result

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_assertion_result_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_episode_id` | `uuid` | no | — | unique (factory_episode_id, assertion_key, evaluator_version); FK → [`public.factory_episode`](factory_episode.md).factory_episode_id |
| 3 | `assertion_key` | `text` | no | — | unique (factory_episode_id, assertion_key, evaluator_version) |
| 4 | `assertion_kind` | `text` | no | — | — |
| 5 | `evaluator_version` | `text` | no | — | unique (factory_episode_id, assertion_key, evaluator_version) |
| 6 | `passed` | `boolean` | no | — | — |
| 7 | `hard_gate` | `boolean` | no | `false` | — |
| 8 | `score` | `numeric` | yes | — | — |
| 9 | `details` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `evidence_artifact_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 11 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_assertion_result_id)
- unique (factory_episode_id, assertion_key, evaluator_version)
- check `factory_assertion_score_check`: `((score IS NULL) OR ((score >= (0)::numeric) AND (score <= (1)::numeric)))`

## Relationships

Outbound: `factory_episode_id` → [`public.factory_episode`](factory_episode.md)`.factory_episode_id` on delete cascade.
Inbound: none.

## Indexes

`factory_assertion_episode_key_uniq` unique

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

insert: `Database["public"]["Tables"]["factory_assertion_result"]["Insert"]`; row: `Database["public"]["Tables"]["factory_assertion_result"]["Row"]`; update: `Database["public"]["Tables"]["factory_assertion_result"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
