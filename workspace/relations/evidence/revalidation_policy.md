---
id: "rel:evidence.revalidation_policy"
kind: table
schema: evidence
name: revalidation_policy
domain: evidence
aliases: []
tokens: [evidence, revalidation_policy, evidence.revalidation_policy, id, slug, applies_to, rules, max_age, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"revalidation_policy\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.revalidation_policy

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `slug` | `text` | no | — | unique (slug) |
| 3 | `applies_to` | `text` | no | — | — |
| 4 | `rules` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `max_age` | `interval` | yes | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (slug)

## Relationships

Outbound: none.
Inbound: [`evidence.revalidation_event`](revalidation_event.md).policy_id.

## Indexes

`revalidation_policy_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`.

## Read paths

- Direct SELECT: `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["evidence"]["Tables"]["revalidation_policy"]["Insert"]`; row: `Database["evidence"]["Tables"]["revalidation_policy"]["Row"]`; update: `Database["evidence"]["Tables"]["revalidation_policy"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
