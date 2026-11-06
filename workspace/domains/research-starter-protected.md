---
id: "dom:research-starter-protected"
kind: domain
schemas: [public, research_private]
aliases: [pre-research, starter videos, factory]
relations: [public.research_starter_channels, public.research_starter_videos, public.research_pre_research_run, public.research_pre_research_video_state, public.research_video_analysis, public.research_ingestion_intent, public.research_evidence_anchor, public.research_pre_research_artifact, public.research_taxonomy_version]
functions: [corpus.import_research_starter_catalog, research_private.claim_pre_research_video, research_private.complete_pre_research_stage, research_private.list_finished_pre_research_videos]
tasks: [what-do-we-know-about-entity]
summary: Protected pre-research starter catalog and factory tables; do not mutate.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Research-starter protected

Protected pre-research starter catalog and factory tables; do not mutate.

> curated (model_assisted, unreviewed) — `public` holds twenty-five protected research-starter / pre-research tables and
> sixteen retained factory tables. Both YouTube channels and all starter videos are
> unchanged by the knowledge-model migrations. `research_private` holds the pipeline
> routines that claim videos, checkpoint stages, and list finished packets.
> 
> This is intake, not the canonical graph. `corpus.import_research_starter_catalog`
> can project channels and videos into media identities, but it was not run on the
> shared cloud catalog and must not invent capture hashes. Factory tables such as
> `public.factory_experiment` record canaries and promotions for the retained factory,
> not industry facts.
> 
> Agents on the schema-workspace mission should treat these relations as read-only
> context. Do not add migrations here. Do not confuse `public.research_ingestion_intent`
> with `orchestration.operation_intent`. Transcript bytes live in storage buckets, not
> in these tables.
> 
> Invariant: starter channel and video ids are stable across knowledge-model
> migrations. Trap: treating a pre-research packet as already-admitted corpus
> knowledge. Resolve names with `q:entity.resolve` / `what-do-we-know-about-entity`
> after import, never by joining factory tables. `research_private` routines are
> for the starter pipeline only; they are not temporal helpers. Do not confuse
> `public.research_evidence_anchor` with `evidence.locator`. Operators may read
> these tables as context; writers on this mission must not mutate them.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`public.research_starter_channels`](../relations/public/research_starter_channels.md) | YouTube channels whose videos are ingested into research_starter_videos. One channel has many videos. AI Engi… | PK (channel_id); RLS | helpers only |
| [`public.research_starter_videos`](../relations/public/research_starter_videos.md) | YouTube videos for the research starter catalog. Each video belongs to one research_starter_channels row. Tra… | PK (video_id); RLS | helpers only |
| [`public.research_pre_research_run`](../relations/public/research_pre_research_run.md) | One claimable orchestration row per video+transcript-hash attempt. | PK (run_id); RLS | helpers only |
| [`public.research_pre_research_video_state`](../relations/public/research_pre_research_video_state.md) | table | PK (video_id); RLS | helpers only |
| [`public.research_video_analysis`](../relations/public/research_video_analysis.md) | Immutable analysis packet for one completed pre-research run. | PK (analysis_id); unique (run_id); RLS | helpers only |
| [`public.research_ingestion_intent`](../relations/public/research_ingestion_intent.md) | table | PK (intent_id); unique (idempotency_key), (run_id); RLS | helpers only |
| [`public.research_evidence_anchor`](../relations/public/research_evidence_anchor.md) | table | PK (evidence_id); RLS | helpers only |
| [`public.research_pre_research_artifact`](../relations/public/research_pre_research_artifact.md) | table | PK (artifact_id); unique (run_id, artifact_kind), (storage_bucket, storage_path); RLS | helpers only |
| [`public.research_taxonomy_version`](../relations/public/research_taxonomy_version.md) | Versioned AI engineering taxonomy. Exactly one row may be active. | PK (taxonomy_version_id); unique (version); RLS | helpers only |

## Functions

[`corpus.import_research_starter_catalog`](../functions/corpus/import_research_starter_catalog.md), [`research_private.claim_pre_research_video`](../functions/research_private/claim_pre_research_video.md), [`research_private.complete_pre_research_stage`](../functions/research_private/complete_pre_research_stage.md), [`research_private.list_finished_pre_research_videos`](../functions/research_private/list_finished_pre_research_videos.md)

## Named queries

[`q:entity.resolve`](../queries/README.md)

## Tasks

[`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`public`](../schemas/public/README.md), [`research_private`](../schemas/research_private/README.md).
