---
id: "rel:public.factory_failure_cluster"
kind: table
schema: public
name: factory_failure_cluster
domain: research-starter-protected
aliases: []
tokens: [public, factory_failure_cluster, public.factory_failure_cluster, factory_failure_cluster_id, signature, title, taxonomy_code, severity, affected_episode_ids, evidence, status, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_failure_cluster\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_failure_cluster

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_failure_cluster_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `signature` | `text` | no | — | unique (signature) |
| 3 | `title` | `text` | no | — | — |
| 4 | `taxonomy_code` | `text` | no | — | — |
| 5 | `severity` | `text` | no | — | — |
| 6 | `affected_episode_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 7 | `evidence` | `jsonb` | no | — | — |
| 8 | `status` | `text` | no | `'open'::text` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 10 | `updated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_failure_cluster_id)
- unique (signature)
- check `factory_failure_severity_check`: `(severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]))`
- check `factory_failure_status_check`: `(status = ANY (ARRAY['open'::text, 'triaged'::text, 'eval_drafted'::text, 'mitigated'::text, 'accepted'::text, 'invalid'::text]))`

## Relationships

Outbound: none.
Inbound: [`public.factory_evolution_proposal`](factory_evolution_proposal.md).failure_cluster_id.

## Indexes

`factory_failure_cluster_signature_key` unique

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

insert: `Database["public"]["Tables"]["factory_failure_cluster"]["Insert"]`; row: `Database["public"]["Tables"]["factory_failure_cluster"]["Row"]`; update: `Database["public"]["Tables"]["factory_failure_cluster"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
