---
id: "rel:public.research_entity_candidate"
kind: table
schema: public
name: research_entity_candidate
domain: research-starter-protected
aliases: []
tokens: [public, research_entity_candidate, public.research_entity_candidate, candidate_id, analysis_id, entity_kind, name, normalized_name, canonical_url, organization_name, relationship_to_video, confidence, verification_status, evidence_ids]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_entity_candidate\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_entity_candidate

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `candidate_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `analysis_id` | `uuid` | no | — | FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 3 | `entity_kind` | `research_entity_kind` | no | — | — |
| 4 | `name` | `text` | no | — | — |
| 5 | `normalized_name` | `text` | no | — | — |
| 6 | `canonical_url` | `text` | yes | — | — |
| 7 | `organization_name` | `text` | yes | — | — |
| 8 | `relationship_to_video` | `text` | no | — | — |
| 9 | `confidence` | `numeric(4,3)` | no | — | — |
| 10 | `verification_status` | `research_verification_status` | no | — | — |
| 11 | `evidence_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |

## Constraints

- PK (candidate_id)
- check `research_entity_candidate_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade.
Inbound: none.

## Indexes

`research_entity_candidate_analysis_idx`; `research_entity_candidate_normalized_idx`

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

insert: `Database["public"]["Tables"]["research_entity_candidate"]["Insert"]`; row: `Database["public"]["Tables"]["research_entity_candidate"]["Row"]`; update: `Database["public"]["Tables"]["research_entity_candidate"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
