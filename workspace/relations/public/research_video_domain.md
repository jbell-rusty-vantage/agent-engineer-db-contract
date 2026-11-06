---
id: "rel:public.research_video_domain"
kind: table
schema: public
name: research_video_domain
domain: research-starter-protected
aliases: []
tokens: [public, research_video_domain, public.research_video_domain, analysis_id, domain_code, confidence, rationale]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_video_domain\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_video_domain

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `analysis_id` | `uuid` | no | — | PK; FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 2 | `domain_code` | `text` | no | — | PK; FK → [`public.research_application_domain`](research_application_domain.md).domain_code |
| 3 | `confidence` | `numeric(4,3)` | no | — | — |
| 4 | `rationale` | `text` | no | — | — |

## Constraints

- PK (analysis_id, domain_code)
- check `research_video_domain_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade; `domain_code` → [`public.research_application_domain`](research_application_domain.md)`.domain_code`.
Inbound: none.

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

insert: `Database["public"]["Tables"]["research_video_domain"]["Insert"]`; row: `Database["public"]["Tables"]["research_video_domain"]["Row"]`; update: `Database["public"]["Tables"]["research_video_domain"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
