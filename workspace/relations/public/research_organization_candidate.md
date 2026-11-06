---
id: "rel:public.research_organization_candidate"
kind: table
schema: public
name: research_organization_candidate
domain: research-starter-protected
aliases: []
tokens: [public, research_organization_candidate, public.research_organization_candidate, organization_candidate_id, analysis_id, video_id, canonical_name, normalized_name, organization_scope, relationship_roles, is_primary_featured, featured_rank, primary_domain_code, secondary_domain_codes, parent_name, parent_canonical_url, official_url, authoritative_summary, relationship_to_implementation, current_status, status_as_of, video_time_name, video_time_parent_name, ownership_changed_since_video, confidence, evidence_ids, generated_at]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_organization_candidate\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_organization_candidate

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `organization_candidate_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `analysis_id` | `uuid` | no | — | unique (analysis_id, normalized_name); FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 3 | `video_id` | `text` | no | — | FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 4 | `canonical_name` | `text` | no | — | — |
| 5 | `normalized_name` | `text` | no | — | unique (analysis_id, normalized_name) |
| 6 | `organization_scope` | `research_organization_scope` | no | — | — |
| 7 | `relationship_roles` | `research_video_organization_role[]` | no | — | — |
| 8 | `is_primary_featured` | `boolean` | no | `false` | — |
| 9 | `featured_rank` | `integer` | no | — | — |
| 10 | `primary_domain_code` | `research_organization_domain_code` | no | — | — |
| 11 | `secondary_domain_codes` | `research_organization_domain_code[]` | no | `'{}'::research_organization_domain_code[]` | — |
| 12 | `parent_name` | `text` | yes | — | — |
| 13 | `parent_canonical_url` | `text` | yes | — | — |
| 14 | `official_url` | `text` | no | — | — |
| 15 | `authoritative_summary` | `text` | no | — | — |
| 16 | `relationship_to_implementation` | `text` | no | — | — |
| 17 | `current_status` | `text` | no | — | — |
| 18 | `status_as_of` | `date` | no | — | — |
| 19 | `video_time_name` | `text` | yes | — | — |
| 20 | `video_time_parent_name` | `text` | yes | — | — |
| 21 | `ownership_changed_since_video` | `boolean` | no | `false` | — |
| 22 | `confidence` | `numeric(4,3)` | no | — | — |
| 23 | `evidence_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 24 | `generated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (organization_candidate_id)
- unique (analysis_id, normalized_name)
- check `research_organization_candidate_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `research_organization_candidate_rank_check`: `(featured_rank >= 1)`
- check `research_organization_candidate_secondary_len_check`: `(cardinality(secondary_domain_codes) <= 2)`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: [`public.research_organization_source`](research_organization_source.md).organization_candidate_id.

## Indexes

`research_organization_candidate_analysis_id_normalized_name_key` unique; `research_organization_candidate_analysis_idx`; `research_organization_candidate_one_primary_uidx` unique where `is_primary_featured`; `research_organization_candidate_one_rank1_uidx` unique where `(featured_rank = 1)`

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

insert: `Database["public"]["Tables"]["research_organization_candidate"]["Insert"]`; row: `Database["public"]["Tables"]["research_organization_candidate"]["Row"]`; update: `Database["public"]["Tables"]["research_organization_candidate"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
