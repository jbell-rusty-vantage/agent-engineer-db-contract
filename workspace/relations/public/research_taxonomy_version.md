---
id: "rel:public.research_taxonomy_version"
kind: table
schema: public
name: research_taxonomy_version
domain: research-starter-protected
aliases: []
tokens: [public, research_taxonomy_version, public.research_taxonomy_version, taxonomy_version_id, version, status, definition_sha256, created_at, activated_at, retired_at, notes]
summary: Versioned AI engineering taxonomy. Exactly one row may be active.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_taxonomy_version\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_taxonomy_version

table in domain `research-starter-protected` — Versioned AI engineering taxonomy. Exactly one row may be active..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `taxonomy_version_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `version` | `text` | no | — | unique (version) |
| 3 | `status` | `research_taxonomy_status` | no | `'draft'::research_taxonomy_status` | — |
| 4 | `definition_sha256` | `text` | no | — | — |
| 5 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 6 | `activated_at` | `timestamp with time zone` | yes | — | — |
| 7 | `retired_at` | `timestamp with time zone` | yes | — | — |
| 8 | `notes` | `text` | yes | — | — |

## Constraints

- PK (taxonomy_version_id)
- unique (version)
- check `research_taxonomy_version_sha256_check`: `(definition_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: none.
Inbound: [`public.research_category_definition`](research_category_definition.md).taxonomy_version_id, [`public.research_pre_research_run`](research_pre_research_run.md).taxonomy_version_id.

## Indexes

`research_taxonomy_version_one_active_uidx` unique where `(status = 'active'::research_taxonomy_status)`; `research_taxonomy_version_version_key` unique

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

insert: `Database["public"]["Tables"]["research_taxonomy_version"]["Insert"]`; row: `Database["public"]["Tables"]["research_taxonomy_version"]["Row"]`; update: `Database["public"]["Tables"]["research_taxonomy_version"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
