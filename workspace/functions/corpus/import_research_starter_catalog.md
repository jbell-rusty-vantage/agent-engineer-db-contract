---
id: "fn:corpus.import_research_starter_catalog(uuid)"
kind: function
schema: corpus
name: import_research_starter_catalog
domain: research-starter-protected
overloads: ["fn:corpus.import_research_starter_catalog(uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [receipt tenant mismatch]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt, public.research_starter_channels, public.research_starter_videos], writes: [content.document, content.document_identifier, corpus.entity, corpus.entity_identifier, corpus.media_channel, corpus.media_series, corpus.media_work, evidence.source] }
tokens: [corpus, import_research_starter_catalog, corpus.import_research_starter_catalog]
defined_in: ["20260912011200_km_12_projection_workers.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.import_research_starter_catalog

Domain `research-starter-protected`.

## import_research_starter_catalog(uuid) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_receipt` | `uuid` | — | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `receipt tenant mismatch`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`public.research_starter_channels`](../../relations/public/research_starter_channels.md), [`public.research_starter_videos`](../../relations/public/research_starter_videos.md); writes [`content.document`](../../relations/content/document.md), [`content.document_identifier`](../../relations/content/document_identifier.md), [`corpus.entity`](../../relations/corpus/entity.md), [`corpus.entity_identifier`](../../relations/corpus/entity_identifier.md), [`corpus.media_channel`](../../relations/corpus/media_channel.md), [`corpus.media_series`](../../relations/corpus/media_series.md), [`corpus.media_work`](../../relations/corpus/media_work.md), [`evidence.source`](../../relations/evidence/source.md); calls [`temporal.assert_relationship`](../temporal/assert_relationship.md), [`temporal.begin_batch`](../temporal/begin_batch.md), [`temporal.commit_batch`](../temporal/commit_batch.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["corpus"]["Functions"]["import_research_starter_catalog"]`.

Defined in: `20260912011200_km_12_projection_workers.sql`.
