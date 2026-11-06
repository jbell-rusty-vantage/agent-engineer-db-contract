---
id: "sch:api"
kind: schema
name: api
domains: [api-surface]
relations: 8
functions: 22
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api

Views and functions only. The sole surface exposed to apps and agents. Domains: [`api-surface`](../../domains/api-surface.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`current_facts`](../../relations/api/current_facts.md) | view | unknown | Current segments whose valid_during contains now(). | — |
| [`current_relationships`](../../relations/api/current_relationships.md) | view | unknown | Current relationships, hiding inactive temporal edges. | — |
| [`entities`](../../relations/api/entities.md) | view | unknown | Invoker view of tenant entities plus alias array. | — |
| [`events_current`](../../relations/api/events_current.md) | view | unknown | Current event occurrences for the tenant. | — |
| [`library_profile`](../../relations/api/library_profile.md) | view | unknown | Invoker view of library identities with ecosystem and package_name. | — |
| [`mission_progress`](../../relations/api/mission_progress.md) | view | unknown | Invoker view of mission status and work-item counts. | — |
| [`review_queue`](../../relations/api/review_queue.md) | view | unknown | Invoker view of evaluation.review_task for app_reader. | — |
| [`technical_record_search`](../../relations/api/technical_record_search.md) | view | unknown | Invoker view of knowledge.record for app_reader. | — |

Functions: [`current_event_rows`](../../functions/api/current_event_rows.md), [`current_fact_rows`](../../functions/api/current_fact_rows.md), [`current_relationship_rows`](../../functions/api/current_relationship_rows.md), [`entity_aliases`](../../functions/api/entity_aliases.md), [`entity_at`](../../functions/api/entity_at.md), [`entity_card`](../../functions/api/entity_card.md), [`entity_rows`](../../functions/api/entity_rows.md), [`entity_timeline`](../../functions/api/entity_timeline.md), [`evidence_packet`](../../functions/api/evidence_packet.md), [`hybrid_knowledge_search_1536`](../../functions/api/hybrid_knowledge_search_1536.md), [`hybrid_knowledge_search_history_1536`](../../functions/api/hybrid_knowledge_search_history_1536.md), [`knowledge_head`](../../functions/api/knowledge_head.md), [`leaderboard`](../../functions/api/leaderboard.md), [`product_command`](../../functions/api/product_command.md), [`product_read`](../../functions/api/product_read.md), [`product_worker`](../../functions/api/product_worker.md), [`relationships`](../../functions/api/relationships.md), [`resolve_entity`](../../functions/api/resolve_entity.md), [`search_knowledge_1536`](../../functions/api/search_knowledge_1536.md), [`submit_intent`](../../functions/api/submit_intent.md), [`summary_evidence`](../../functions/api/summary_evidence.md), [`what_changed`](../../functions/api/what_changed.md).

Types: none.
