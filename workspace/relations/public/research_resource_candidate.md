---
id: "rel:public.research_resource_candidate"
kind: table
schema: public
name: research_resource_candidate
domain: research-starter-protected
aliases: []
tokens: [public, research_resource_candidate, public.research_resource_candidate, resource_candidate_id, analysis_id, resource_type, title, url, normalized_url, publisher, relationship_to_video, why_valuable, verification_status, is_first_party, license, confidence, evidence_ids]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_resource_candidate\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_resource_candidate

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `resource_candidate_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `analysis_id` | `uuid` | no | — | FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 3 | `resource_type` | `research_resource_type` | no | — | — |
| 4 | `title` | `text` | no | — | — |
| 5 | `url` | `text` | no | — | — |
| 6 | `normalized_url` | `text` | no | — | — |
| 7 | `publisher` | `text` | yes | — | — |
| 8 | `relationship_to_video` | `text` | no | — | — |
| 9 | `why_valuable` | `text` | no | — | — |
| 10 | `verification_status` | `research_verification_status` | no | — | — |
| 11 | `is_first_party` | `boolean` | no | `false` | — |
| 12 | `license` | `text` | yes | — | — |
| 13 | `confidence` | `numeric(4,3)` | no | — | — |
| 14 | `evidence_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |

## Constraints

- PK (resource_candidate_id)
- check `research_resource_candidate_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade.
Inbound: none.

## Indexes

`research_resource_candidate_analysis_idx`; `research_resource_candidate_analysis_url_uidx` unique

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

insert: `Database["public"]["Tables"]["research_resource_candidate"]["Insert"]`; row: `Database["public"]["Tables"]["research_resource_candidate"]["Row"]`; update: `Database["public"]["Tables"]["research_resource_candidate"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
