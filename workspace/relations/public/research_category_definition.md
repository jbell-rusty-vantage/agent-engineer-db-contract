---
id: "rel:public.research_category_definition"
kind: table
schema: public
name: research_category_definition
domain: research-starter-protected
aliases: []
tokens: [public, research_category_definition, public.research_category_definition, taxonomy_version_id, category_code, label, description, inclusion_criteria, exclusion_criteria, example_topics, sort_order]
summary: Per-version definitions for the stable engineering category enum.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_category_definition\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_category_definition

table in domain `research-starter-protected` — Per-version definitions for the stable engineering category enum..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `taxonomy_version_id` | `uuid` | no | — | PK; FK → [`public.research_taxonomy_version`](research_taxonomy_version.md).taxonomy_version_id |
| 2 | `category_code` | `research_engineering_category_code` | no | — | PK |
| 3 | `label` | `text` | no | — | — |
| 4 | `description` | `text` | no | — | — |
| 5 | `inclusion_criteria` | `text[]` | no | `'{}'::text[]` | — |
| 6 | `exclusion_criteria` | `text[]` | no | `'{}'::text[]` | — |
| 7 | `example_topics` | `text[]` | no | `'{}'::text[]` | — |
| 8 | `sort_order` | `integer` | no | — | — |

## Constraints

- PK (taxonomy_version_id, category_code)

## Relationships

Outbound: `taxonomy_version_id` → [`public.research_taxonomy_version`](research_taxonomy_version.md)`.taxonomy_version_id` on delete cascade.
Inbound: none.

## Indexes

`research_category_definition_sort_idx`

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

insert: `Database["public"]["Tables"]["research_category_definition"]["Insert"]`; row: `Database["public"]["Tables"]["research_category_definition"]["Row"]`; update: `Database["public"]["Tables"]["research_category_definition"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
