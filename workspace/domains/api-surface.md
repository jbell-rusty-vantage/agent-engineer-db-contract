---
id: "dom:api-surface"
kind: domain
schemas: [api]
aliases: [rpc, views, app_reader]
relations: [api.entities, api.current_facts, api.current_relationships, api.events_current, api.library_profile, api.technical_record_search, api.review_queue, api.mission_progress]
functions: [api.entity_at, api.entity_card, api.entity_timeline, api.evidence_packet, api.hybrid_knowledge_search_1536, api.knowledge_head, api.leaderboard, api.relationships, api.resolve_entity, api.summary_evidence, api.what_changed]
tasks: [check-knowledge-head, run-hybrid-search, what-do-we-know-about-entity]
summary: Invoker views and security-definer RPCs for app_reader.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# API surface

Invoker views and security-definer RPCs for app_reader.

> curated (model_assisted, unreviewed) — `api` has no tables. Eight invoker views are backed by tenant-filtered definer
> functions so `app_reader` and `authenticated` can read without grants on
> corpus or temporal tables. Views: `api.entities`, `api.current_facts`,
> `api.current_relationships`, `api.events_current`, `api.library_profile`,
> `api.technical_record_search`, `api.review_queue`, `api.mission_progress`.
> 
> RPCs implement the named-query catalog for identity, replay, and retrieval.
> `api.current_facts` applies `k_to is null` and `valid_during @> now()` — that is the
> usual trap. Historical reads must use `api.entity_at`. `util.current_tenant_id`
> reads the app.tenant_id GUC and fails closed; every API call needs that GUC.
> 
> Long-tail reads are new catalog entries, not raw SQL. `api.submit_intent` exists
> for older orchestration flows; knowledge ingestion goes through the executor, not
> this RPC. `api.hybrid_knowledge_search_1536` requires a published space and an embedding.
> 
> Invariant: `app_reader` never SELECTs corpus or temporal tables. Trap: using
> `api.current_facts` for a 2025 price. Prefer `what-do-we-know-about-entity`
> (`q:entity.resolve`, `q:entity.card`), `check-knowledge-head` (`q:knowledge.head`),
> and `run-hybrid-search` (`q:retrieval.hybrid_search`). Historical replay is
> `q:entity.at`, `q:entity.timeline`, `q:entity.what_changed`. `util` helpers
> (`util.current_tenant_id`) are the tenant seam for every invoker view.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`api.entities`](../relations/api/entities.md) | Invoker view of tenant entities plus alias array. | — | helpers only |
| [`api.current_facts`](../relations/api/current_facts.md) | Current segments whose valid_during contains now(). | — | helpers only |
| [`api.current_relationships`](../relations/api/current_relationships.md) | Current relationships, hiding inactive temporal edges. | — | helpers only |
| [`api.events_current`](../relations/api/events_current.md) | Current event occurrences for the tenant. | — | helpers only |
| [`api.library_profile`](../relations/api/library_profile.md) | Invoker view of library identities with ecosystem and package_name. | — | helpers only |
| [`api.technical_record_search`](../relations/api/technical_record_search.md) | Invoker view of knowledge.record for app_reader. | — | helpers only |
| [`api.review_queue`](../relations/api/review_queue.md) | Invoker view of evaluation.review_task for app_reader. | — | helpers only |
| [`api.mission_progress`](../relations/api/mission_progress.md) | Invoker view of mission status and work-item counts. | — | helpers only |

## Functions

[`api.entity_at`](../functions/api/entity_at.md), [`api.entity_card`](../functions/api/entity_card.md), [`api.entity_timeline`](../functions/api/entity_timeline.md), [`api.evidence_packet`](../functions/api/evidence_packet.md), [`api.hybrid_knowledge_search_1536`](../functions/api/hybrid_knowledge_search_1536.md), [`api.knowledge_head`](../functions/api/knowledge_head.md), [`api.leaderboard`](../functions/api/leaderboard.md), [`api.relationships`](../functions/api/relationships.md), [`api.resolve_entity`](../functions/api/resolve_entity.md), [`api.summary_evidence`](../functions/api/summary_evidence.md), [`api.what_changed`](../functions/api/what_changed.md)

## Named queries

[`q:entity.at`](../queries/README.md), [`q:entity.card`](../queries/README.md), [`q:entity.relationships`](../queries/README.md), [`q:entity.resolve`](../queries/README.md), [`q:entity.timeline`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md), [`q:events.current_for_entity`](../queries/README.md), [`q:facts.current_by_stream`](../queries/README.md), [`q:knowledge.head`](../queries/README.md), [`q:relationships.current_by_kind`](../queries/README.md), [`q:retrieval.evidence_packet`](../queries/README.md), [`q:retrieval.hybrid_search`](../queries/README.md)

## Tasks

[`check-knowledge-head`](../tasks/check-knowledge-head.md), [`run-hybrid-search`](../tasks/run-hybrid-search.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`api`](../schemas/api/README.md).
