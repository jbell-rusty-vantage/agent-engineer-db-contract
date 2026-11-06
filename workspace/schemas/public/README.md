---
id: "sch:public"
kind: schema
name: public
domains: [research-starter-protected]
relations: 41
functions: 3
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public

standard public schema Domains: [`research-starter-protected`](../../domains/research-starter-protected.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`factory_artifact`](../../relations/public/factory_artifact.md) | table | unknown | — | → `public.factory_episode` |
| [`factory_assertion_result`](../../relations/public/factory_assertion_result.md) | table | unknown | — | → `public.factory_episode` |
| [`factory_canary_result`](../../relations/public/factory_canary_result.md) | table | unknown | — | → `public.factory_promotion_decision` |
| [`factory_candidate`](../../relations/public/factory_candidate.md) | table | unknown | — | — |
| [`factory_component_version`](../../relations/public/factory_component_version.md) | table | unknown | — | — |
| [`factory_environment_version`](../../relations/public/factory_environment_version.md) | table | unknown | — | — |
| [`factory_episode`](../../relations/public/factory_episode.md) | table | unknown | Immutable-identity app-factory or optimization rollout. External artifacts and OTel trace… | → `public.factory_environment_version`, → `public.factory_candidate`, → `public.factory_task` |
| [`factory_evolution_proposal`](../../relations/public/factory_evolution_proposal.md) | table | unknown | Bounded, evidence-backed proposal. The optimizer may propose a candidate but cannot alter… | → `public.factory_failure_cluster`, → `public.factory_candidate`, → `public.factory_component_version` |
| [`factory_experiment`](../../relations/public/factory_experiment.md) | table | unknown | — | → `public.factory_evolution_proposal` |
| [`factory_experiment_arm`](../../relations/public/factory_experiment_arm.md) | table | unknown | — | → `public.factory_candidate`, → `public.factory_experiment` |
| [`factory_failure_cluster`](../../relations/public/factory_failure_cluster.md) | table | unknown | — | — |
| [`factory_promotion_decision`](../../relations/public/factory_promotion_decision.md) | table | unknown | Independent signed promotion outcome with evidence and an explicit rollback target. | → `public.factory_candidate`, → `public.factory_experiment`, → `public.factory_component_version` |
| [`factory_runtime_event`](../../relations/public/factory_runtime_event.md) | table | unknown | Append-only, redacted copy of Eve root-agent durable stream events. Eve event ids provide… | → `public.factory_episode` |
| [`factory_score_vector`](../../relations/public/factory_score_vector.md) | table | unknown | — | → `public.factory_episode` |
| [`factory_task`](../../relations/public/factory_task.md) | table | unknown | — | — |
| [`factory_trace_span_ref`](../../relations/public/factory_trace_span_ref.md) | table | unknown | — | → `public.factory_artifact`, → `public.factory_episode` |
| [`research_application_domain`](../../relations/public/research_application_domain.md) | table | unknown | Evolving application-domain lookup. Not a Postgres enum. | — |
| [`research_category_definition`](../../relations/public/research_category_definition.md) | table | unknown | Per-version definitions for the stable engineering category enum. | → `public.research_taxonomy_version` |
| [`research_entity_candidate`](../../relations/public/research_entity_candidate.md) | table | unknown | — | → `public.research_video_analysis` |
| [`research_evidence_anchor`](../../relations/public/research_evidence_anchor.md) | table | unknown | — | → `public.research_video_analysis` |
| [`research_ingestion_intent`](../../relations/public/research_ingestion_intent.md) | table | unknown | — | → `public.research_pre_research_run`, → `public.research_starter_videos` |
| [`research_ingestion_intent_event`](../../relations/public/research_ingestion_intent_event.md) | table | unknown | — | → `public.research_ingestion_intent` |
| [`research_organization_candidate`](../../relations/public/research_organization_candidate.md) | table | unknown | — | → `public.research_video_analysis`, → `public.research_starter_videos` |
| [`research_organization_domain_definition`](../../relations/public/research_organization_domain_definition.md) | table | unknown | — | — |
| [`research_organization_source`](../../relations/public/research_organization_source.md) | table | unknown | — | → `public.research_evidence_anchor`, → `public.research_organization_candidate` |
| [`research_pre_research_artifact`](../../relations/public/research_pre_research_artifact.md) | table | unknown | — | → `public.research_ingestion_intent`, → `public.research_pre_research_run` |
| [`research_pre_research_run`](../../relations/public/research_pre_research_run.md) | table | unknown | One claimable orchestration row per video+transcript-hash attempt. | → `public.research_taxonomy_version`, → `public.research_starter_videos` |
| [`research_pre_research_session`](../../relations/public/research_pre_research_session.md) | table | unknown | — | → `public.research_pre_research_run` |
| [`research_pre_research_stage_execution`](../../relations/public/research_pre_research_stage_execution.md) | table | unknown | — | → `public.research_pre_research_run` |
| [`research_pre_research_video_state`](../../relations/public/research_pre_research_video_state.md) | table | unknown | — | → `public.research_ingestion_intent`, → `public.research_pre_research_run`, → `public.research_starter_videos` |
| [`research_resource_candidate`](../../relations/public/research_resource_candidate.md) | table | unknown | — | → `public.research_video_analysis` |
| [`research_starter_channels`](../../relations/public/research_starter_channels.md) | table | unknown | YouTube channels whose videos are ingested into research_starter_videos. One channel has … | — |
| [`research_starter_videos`](../../relations/public/research_starter_videos.md) | table | unknown | YouTube videos for the research starter catalog. Each video belongs to one research_start… | → `public.research_starter_channels` |
| [`research_taxonomy_version`](../../relations/public/research_taxonomy_version.md) | table | unknown | Versioned AI engineering taxonomy. Exactly one row may be active. | — |
| [`research_video_analysis`](../../relations/public/research_video_analysis.md) | table | unknown | Immutable analysis packet for one completed pre-research run. | → `public.research_pre_research_run`, → `public.research_starter_videos` |
| [`research_video_category`](../../relations/public/research_video_category.md) | table | unknown | Exactly one primary category and up to three secondary categories per analysis. | → `public.research_video_analysis` |
| [`research_video_domain`](../../relations/public/research_video_domain.md) | table | unknown | — | → `public.research_video_analysis`, → `public.research_application_domain` |
| [`research_video_initial_summary`](../../relations/public/research_video_initial_summary.md) | table | unknown | — | → `public.research_video_analysis`, → `public.research_starter_videos` |
| [`research_video_lifecycle`](../../relations/public/research_video_lifecycle.md) | table | unknown | — | → `public.research_video_analysis` |
| [`research_video_technology_summary`](../../relations/public/research_video_technology_summary.md) | table | unknown | — | → `public.research_video_analysis`, → `public.research_starter_videos` |
| [`research_web_search_event`](../../relations/public/research_web_search_event.md) | table | unknown | — | → `public.research_pre_research_run` |

Functions: [`protect_factory_episode_identity_and_terminal`](../../functions/public/protect_factory_episode_identity_and_terminal.md), [`reject_immutable_row_change`](../../functions/public/reject_immutable_row_change.md), [`set_updated_at`](../../functions/public/set_updated_at.md).

Types: [`types/public.md`](../../types/public.md).
