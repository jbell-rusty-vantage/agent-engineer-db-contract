---
id: "rel:curriculum.challenge_version"
kind: table
schema: curriculum
name: challenge_version
domain: curriculum
aliases: []
tokens: [curriculum, challenge_version, curriculum.challenge_version, id, challenge_id, version, statement, difficulty, environment_spec_artifact_id, rubric, status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"challenge_version\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.challenge_version

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `challenge_id` | `uuid` | no | — | unique (challenge_id, version); FK → [`curriculum.challenge`](challenge.md).id |
| 3 | `version` | `integer` | no | — | unique (challenge_id, version) |
| 4 | `statement` | `text` | no | — | — |
| 5 | `difficulty` | `text` | yes | — | — |
| 6 | `environment_spec_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 7 | `rubric` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `status` | `curriculum.publish_status` | no | `'draft'::curriculum.publish_status` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (challenge_id, version)
- check `challenge_version_difficulty_check`: `(difficulty = ANY (ARRAY['introductory'::text, 'intermediate'::text, 'advanced'::text, 'expert'::text]))`

## Relationships

Outbound: `challenge_id` → [`curriculum.challenge`](challenge.md)`.id` on delete cascade; `environment_spec_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id`.
Inbound: [`curriculum.challenge_derived_from`](challenge_derived_from.md).challenge_version_id, [`curriculum.challenge_targets`](challenge_targets.md).challenge_version_id.

## Indexes

`challenge_version_challenge_id_version_key` unique

## Triggers

- `artifact_retirement_370444b0f86ba8e094aa7ff0` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

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

insert: `Database["curriculum"]["Tables"]["challenge_version"]["Insert"]`; row: `Database["curriculum"]["Tables"]["challenge_version"]["Row"]`; update: `Database["curriculum"]["Tables"]["challenge_version"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
