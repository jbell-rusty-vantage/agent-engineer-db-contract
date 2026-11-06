---
id: "rel:public.research_organization_domain_definition"
kind: table
schema: public
name: research_organization_domain_definition
domain: research-starter-protected
aliases: []
tokens: [public, research_organization_domain_definition, public.research_organization_domain_definition, domain_code, label, description, inclusion_criteria, exclusion_criteria, example_organizations, active, sort_order, definition_version]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_organization_domain_definition\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_organization_domain_definition

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `domain_code` | `research_organization_domain_code` | no | — | PK |
| 2 | `label` | `text` | no | — | — |
| 3 | `description` | `text` | no | — | — |
| 4 | `inclusion_criteria` | `text[]` | no | `'{}'::text[]` | — |
| 5 | `exclusion_criteria` | `text[]` | no | `'{}'::text[]` | — |
| 6 | `example_organizations` | `text[]` | no | `'{}'::text[]` | — |
| 7 | `active` | `boolean` | no | `true` | — |
| 8 | `sort_order` | `integer` | no | — | — |
| 9 | `definition_version` | `text` | no | `'1.0.0'::text` | — |

## Constraints

- PK (domain_code)

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.

## Grants

`service_role`: DELETE, INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["research_organization_domain_definition"]["Insert"]`; row: `Database["public"]["Tables"]["research_organization_domain_definition"]["Row"]`; update: `Database["public"]["Tables"]["research_organization_domain_definition"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
