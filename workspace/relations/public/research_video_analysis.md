---
id: "rel:public.research_video_analysis"
kind: table
schema: public
name: research_video_analysis
domain: research-starter-protected
aliases: []
tokens: [public, research_video_analysis, public.research_video_analysis, analysis_id, run_id, video_id, initial_summary, structured_summary, contextualized_abstract, why_it_matters, key_takeaways, concepts, prerequisites, learning_outcomes, limitations, quantitative_claims, demonstrations, curriculum_roles, challenge_seeds, difficulty, content_form, evidence_level, overall_confidence, generated_at]
summary: Immutable analysis packet for one completed pre-research run.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_video_analysis\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_video_analysis

table in domain `research-starter-protected` — Immutable analysis packet for one completed pre-research run..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `analysis_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `run_id` | `uuid` | no | — | unique (run_id); FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 3 | `video_id` | `text` | no | — | FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 4 | `initial_summary` | `text` | no | — | 75-125 word transcript-only abstract. No web-derived claims. |
| 5 | `structured_summary` | `text` | no | — | 200-400 word transcript-grounded structured summary. |
| 6 | `contextualized_abstract` | `text` | no | — | Transcript plus verified web context. Distinguish evidence grades. |
| 7 | `why_it_matters` | `text` | no | — | — |
| 8 | `key_takeaways` | `jsonb` | no | `'[]'::jsonb` | — |
| 9 | `concepts` | `jsonb` | no | `'[]'::jsonb` | — |
| 10 | `prerequisites` | `jsonb` | no | `'[]'::jsonb` | — |
| 11 | `learning_outcomes` | `jsonb` | no | `'[]'::jsonb` | — |
| 12 | `limitations` | `jsonb` | no | `'[]'::jsonb` | — |
| 13 | `quantitative_claims` | `jsonb` | no | `'[]'::jsonb` | — |
| 14 | `demonstrations` | `jsonb` | no | `'[]'::jsonb` | — |
| 15 | `curriculum_roles` | `text[]` | no | `'{}'::text[]` | — |
| 16 | `challenge_seeds` | `jsonb` | no | `'[]'::jsonb` | — |
| 17 | `difficulty` | `research_difficulty` | no | — | — |
| 18 | `content_form` | `research_content_form` | no | — | — |
| 19 | `evidence_level` | `research_evidence_level` | no | — | — |
| 20 | `overall_confidence` | `numeric(4,3)` | no | — | — |
| 21 | `generated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (analysis_id)
- unique (run_id)
- check `research_video_analysis_challenge_seeds_check`: `(jsonb_typeof(challenge_seeds) = 'array'::text)`
- check `research_video_analysis_concepts_check`: `(jsonb_typeof(concepts) = 'array'::text)`
- check `research_video_analysis_confidence_check`: `((overall_confidence >= (0)::numeric) AND (overall_confidence <= (1)::numeric))`
- check `research_video_analysis_demonstrations_check`: `(jsonb_typeof(demonstrations) = 'array'::text)`
- check `research_video_analysis_key_takeaways_check`: `(jsonb_typeof(key_takeaways) = 'array'::text)`
- check `research_video_analysis_learning_outcomes_check`: `(jsonb_typeof(learning_outcomes) = 'array'::text)`
- check `research_video_analysis_limitations_check`: `(jsonb_typeof(limitations) = 'array'::text)`
- check `research_video_analysis_prerequisites_check`: `(jsonb_typeof(prerequisites) = 'array'::text)`
- check `research_video_analysis_quantitative_claims_check`: `(jsonb_typeof(quantitative_claims) = 'array'::text)`

## Relationships

Outbound: `run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id`; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: [`public.research_entity_candidate`](research_entity_candidate.md).analysis_id, [`public.research_evidence_anchor`](research_evidence_anchor.md).analysis_id, [`public.research_organization_candidate`](research_organization_candidate.md).analysis_id, [`public.research_resource_candidate`](research_resource_candidate.md).analysis_id, [`public.research_video_category`](research_video_category.md).analysis_id, [`public.research_video_domain`](research_video_domain.md).analysis_id, [`public.research_video_initial_summary`](research_video_initial_summary.md).analysis_id, [`public.research_video_lifecycle`](research_video_lifecycle.md).analysis_id, [`public.research_video_technology_summary`](research_video_technology_summary.md).analysis_id.

## Indexes

`research_video_analysis_run_id_key` unique; `research_video_analysis_video_id_idx`

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

insert: `Database["public"]["Tables"]["research_video_analysis"]["Insert"]`; row: `Database["public"]["Tables"]["research_video_analysis"]["Row"]`; update: `Database["public"]["Tables"]["research_video_analysis"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
