---
id: "rel:public.research_application_domain"
kind: table
schema: public
name: research_application_domain
domain: research-starter-protected
aliases: []
tokens: [public, research_application_domain, public.research_application_domain, domain_code, label, description, parent_domain_code, active, sort_order]
summary: Evolving application-domain lookup. Not a Postgres enum.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_application_domain\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_application_domain

table in domain `research-starter-protected` — Evolving application-domain lookup. Not a Postgres enum..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `domain_code` | `text` | no | — | PK |
| 2 | `label` | `text` | no | — | — |
| 3 | `description` | `text` | no | — | — |
| 4 | `parent_domain_code` | `text` | yes | — | FK → [`public.research_application_domain`](research_application_domain.md).domain_code |
| 5 | `active` | `boolean` | no | `true` | — |
| 6 | `sort_order` | `integer` | no | `100` | — |

## Constraints

- PK (domain_code)

## Relationships

Outbound: `parent_domain_code` → [`public.research_application_domain`](research_application_domain.md)`.domain_code`.
Inbound: [`public.research_application_domain`](research_application_domain.md).parent_domain_code, [`public.research_video_domain`](research_video_domain.md).domain_code.

## Indexes

_None._

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

insert: `Database["public"]["Tables"]["research_application_domain"]["Insert"]`; row: `Database["public"]["Tables"]["research_application_domain"]["Row"]`; update: `Database["public"]["Tables"]["research_application_domain"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
