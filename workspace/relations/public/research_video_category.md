---
id: "rel:public.research_video_category"
kind: table
schema: public
name: research_video_category
domain: research-starter-protected
aliases: []
tokens: [public, research_video_category, public.research_video_category, analysis_id, category_code, assignment_role, confidence, rationale, alternative_rank]
summary: Exactly one primary category and up to three secondary categories per analysis.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_video_category\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_video_category

table in domain `research-starter-protected` — Exactly one primary category and up to three secondary categories per analysis..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `analysis_id` | `uuid` | no | — | PK; FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 2 | `category_code` | `research_engineering_category_code` | no | — | PK |
| 3 | `assignment_role` | `research_category_assignment_role` | no | — | — |
| 4 | `confidence` | `numeric(4,3)` | no | — | — |
| 5 | `rationale` | `text` | no | — | — |
| 6 | `alternative_rank` | `integer` | yes | — | — |

## Constraints

- PK (analysis_id, category_code)
- check `research_video_category_alternative_rank_check`: `((alternative_rank IS NULL) OR (alternative_rank >= 1))`
- check `research_video_category_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade.
Inbound: none.

## Indexes

`research_video_category_code_idx`; `research_video_category_one_primary_uidx` unique where `(assignment_role = 'primary'::research_category_assignment_…`

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

insert: `Database["public"]["Tables"]["research_video_category"]["Insert"]`; row: `Database["public"]["Tables"]["research_video_category"]["Row"]`; update: `Database["public"]["Tables"]["research_video_category"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
