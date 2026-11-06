---
id: queries
kind: entry
queries: 33
catalog_version: "sha256:d0a86e191016afa9eda24c66882d781537d1f680ce2ee2f2109848f91c160903"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Named queries

Every entry runs as data from `catalog.json` (`knowledge-query-catalog.v1`, digest `sha256:d0a86e191016afa9eda24c66882d781537d1f680ce2ee2f2109848f91c160903`): the executor opens a read-only transaction, sets `app.tenant_id`, `SET LOCAL ROLE <role>`, applies the statement timeout of the cost class, binds `paramOrder` positionally, and caps rows at `limit` (default 200, max 2000). Run one with `knowledge db query <name> --param k=v`, or batch several in a `knowledge-read-intent.v1` (`knowledge db read-intent intent.json`). The snapshot records the knowledge head so your ingestion intent can cite it.

| Query | Role | Cost | Params | Shape | Domain | Summary |
| --- | --- | --- | --- | --- | --- | --- |
| <a id="artifactsbytype"></a>`artifacts.by_type` | pipeline_agent | cheap | `artifact_type`, `limit` | rows | [`orchestration-ledger`](../domains/orchestration-ledger.md) | Artifacts of one artifact_type for the current tenant |
| <a id="entityat"></a>`entity.at` | app_reader | cheap | `entity_id`, `at`, `k` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Facts for one entity at a world time as known at a knowledge seq |
| <a id="entitybyidentifier"></a>`entity.by_identifier` | pipeline_agent | cheap | `scheme`, `value` | rows | [`identity`](../domains/identity.md) | Find a canonical entity by external identifier scheme and value |
| <a id="entitycard"></a>`entity.card` | app_reader | cheap | `entity_id` | single_json | [`identity`](../domains/identity.md) | Current overview of one entity |
| <a id="entityrelationships"></a>`entity.relationships` | app_reader | cheap | `entity_id`, `kind`, `at`, `k`, `direction` | rows | [`relationships`](../domains/relationships.md) | Relationships touching one entity at a world time and knowledge seq |
| <a id="entityresolve"></a>`entity.resolve` | app_reader | cheap | `text` | rows | [`identity`](../domains/identity.md) | Find entities by name, alias, or identifier |
| <a id="entitytimeline"></a>`entity.timeline` | app_reader | medium | `entity_id`, `from`, `to`, `k` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Segments, events, and unknown gaps for one entity over a world interval |
| <a id="entitytypedrow"></a>`entity.typed_row` | pipeline_agent | cheap | `entity_id`, `kind` | single_row | [`identity`](../domains/identity.md) | Canonical entity plus the kind-dispatched typed child row |
| <a id="entitywhatchanged"></a>`entity.what_changed` | app_reader | cheap | `entity_id`, `k_from`, `k_to` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Opened and closed items for one entity between two knowledge heads |
| <a id="eventscurrentforentity"></a>`events.current_for_entity` | app_reader | cheap | `entity_id` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Current event occurrences for one subject entity |
| <a id="evidencecapturesforsource"></a>`evidence.captures_for_source` | pipeline_agent | cheap | `source_id` | rows | [`evidence`](../domains/evidence.md) | Captures registered for one source |
| <a id="evidenceclaimsupport"></a>`evidence.claim_support` | pipeline_agent | cheap | `claim_id` | rows | [`evidence`](../domains/evidence.md) | Segment and occurrence support rows for one claim |
| <a id="evidenceclaimsforentity"></a>`evidence.claims_for_entity` | pipeline_agent | cheap | `entity_id`, `limit` | rows | [`evidence`](../domains/evidence.md) | Claims that name one entity as subject, object, or context |
| <a id="evidencesourcesbydomain"></a>`evidence.sources_by_domain` | pipeline_agent | cheap | `domain`, `limit` | rows | [`evidence`](../domains/evidence.md) | Sources filtered by registrable domain |
| <a id="factscurrentbystream"></a>`facts.current_by_stream` | app_reader | cheap | `stream_kind`, `entity_id`, `limit` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Current facts (k_to is null and valid_during contains now) by stream kind |
| <a id="factshistoryforstream"></a>`facts.history_for_stream` | pipeline_agent | medium | `entity_id`, `stream_kind`, `scope_key`, `limit`, `offset` | rows | [`temporal-facts`](../domains/temporal-facts.md) | All segments on one entity stream slot, including closed history |
| <a id="knowledgehead"></a>`knowledge.head` | app_reader | cheap | — | single_row | [`temporal-facts`](../domains/temporal-facts.md) | Current tenant knowledge sequence |
| <a id="receiptsforintent"></a>`receipts.for_intent` | pipeline_agent | cheap | `intent_id` | rows | [`orchestration-ledger`](../domains/orchestration-ledger.md) | Intent row and sealed batch for one operation intent |
| <a id="receiptsrecentformission"></a>`receipts.recent_for_mission` | pipeline_agent | cheap | `mission_id`, `limit` | rows | [`orchestration-ledger`](../domains/orchestration-ledger.md) | Recent intents and sealed batches for one mission |
| <a id="relationshipscurrentbykind"></a>`relationships.current_by_kind` | app_reader | cheap | `kind`, `entity_id`, `limit` | rows | [`relationships`](../domains/relationships.md) | Current relationships, optionally filtered by kind or endpoint |
| <a id="reportsartifacts"></a>`reports.artifacts` | pipeline_agent | cheap | `report_version_id` | rows | [`research`](../domains/research.md) | Registered report renditions and artifact metadata |
| <a id="reportsassertions"></a>`reports.assertions` | pipeline_agent | cheap | `report_version_id` | rows | [`research`](../domains/research.md) | Assertions and run-qualified evidence bindings |
| <a id="reportsdependencies"></a>`reports.dependencies` | pipeline_agent | cheap | `report_version_id` | rows | [`research`](../domains/research.md) | Exact section revisions needed for reuse |
| <a id="reportsquestions"></a>`reports.questions` | pipeline_agent | cheap | `report_version_id` | rows | [`research`](../domains/research.md) | Question coverage and answering sections |
| <a id="reportssections"></a>`reports.sections` | pipeline_agent | cheap | `report_version_id` | rows | [`research`](../domains/research.md) | Ordered sections with stable keys |
| <a id="reportsversions"></a>`reports.versions` | pipeline_agent | cheap | `report_id` | rows | [`research`](../domains/research.md) | Versions and package status for a report |
| <a id="retrievalevidencepacket"></a>`retrieval.evidence_packet` | app_reader | cheap | `packet_id` | single_json | [`retrieval`](../domains/retrieval.md) | One evidence packet with members and node timecodes |
| <a id="retrievalhybridsearch"></a>`retrieval.hybrid_search` | app_reader | heavy | `$embedding`, `vector_space_version_id`, `query_text`, `filters`, `limit` | rows | [`retrieval`](../domains/retrieval.md) | Hybrid search over a published 1536-d vector-space version |
| <a id="stagingcandidatesforkind"></a>`staging.candidates_for_kind` | pipeline_agent | cheap | `proposed_kind`, `limit` | rows | [`staging`](../domains/staging.md) | Staging candidates of one proposed entity kind |
| <a id="stagingunresolved"></a>`staging.unresolved` | pipeline_agent | cheap | `limit` | rows | [`staging`](../domains/staging.md) | Candidates with no create, match, or reject decision |
| <a id="vocabeventkind"></a>`vocab.event_kind` | pipeline_agent | cheap | `code` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Event-kind vocabulary |
| <a id="vocabrelationshipkind"></a>`vocab.relationship_kind` | pipeline_agent | cheap | `code` | rows | [`relationships`](../domains/relationships.md) | Relationship-kind vocabulary with endpoint constraints |
| <a id="vocabstreamkind"></a>`vocab.stream_kind` | pipeline_agent | cheap | `code` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Stream-kind vocabulary and slot rules |

## Pending (not executed at build)

- `retrieval.hybrid_search`: requires embedding

## Parameters

- `artifacts.by_type`: `artifact_type` string|null?, `limit` integer? — example `{"artifact_type":"knowledge_ingestion_receipt","limit":50}`
- `entity.at`: `at` string, `entity_id` string, `k` integer|null? — example `{"at":"2026-03-15T00:00:00Z","entity_id":"0192b000-0000-7000-8000-000000000001","k":0}`
- `entity.by_identifier`: `scheme` string, `value` string — example `{"scheme":"github","value":"openai/openai-python"}`
- `entity.card`: `entity_id` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001"}`
- `entity.relationships`: `at` string?, `direction` string?, `entity_id` string, `k` integer|null?, `kind` string|null? — example `{"at":"2026-09-11T00:00:00Z","direction":"both","entity_id":"0192b000-0000-7000-8000-000000000001","k":null,"kind":null}`
- `entity.resolve`: `text` string — example `{"text":"OpenAI"}`
- `entity.timeline`: `entity_id` string, `from` string, `k` integer|null?, `to` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","from":"2025-01-01T00:00:00Z","k":null,"to":"2026-09-11T00:00:00Z"}`
- `entity.typed_row`: `entity_id` string, `kind` string|null? — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","kind":"organization"}`
- `entity.what_changed`: `entity_id` string, `k_from` integer, `k_to` integer — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","k_from":0,"k_to":0}`
- `events.current_for_entity`: `entity_id` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001"}`
- `evidence.captures_for_source`: `source_id` string — example `{"source_id":"0192e000-0000-7000-8000-000000000001"}`
- `evidence.claim_support`: `claim_id` string — example `{"claim_id":"0192d000-0000-7000-8000-000000000001"}`
- `evidence.claims_for_entity`: `entity_id` string, `limit` integer? — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","limit":100}`
- `evidence.sources_by_domain`: `domain` string|null?, `limit` integer? — example `{"domain":"openai.com","limit":50}`
- `facts.current_by_stream`: `entity_id` string|null?, `limit` integer?, `stream_kind` string|null? — example `{"entity_id":null,"limit":50,"stream_kind":"model_offering_price"}`
- `facts.history_for_stream`: `entity_id` string, `limit` integer?, `offset` integer?, `scope_key` string|null?, `stream_kind` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","limit":50,"offset":0,"scope_key":"per_1m_input_tokens","stream_kind":"model_offering_price"}`
- `knowledge.head`: none
- `receipts.for_intent`: `intent_id` string — example `{"intent_id":"0192f000-0000-7000-8000-000000000001"}`
- `receipts.recent_for_mission`: `limit` integer?, `mission_id` string — example `{"limit":20,"mission_id":"0192a000-0000-7000-8000-000000000001"}`
- `relationships.current_by_kind`: `entity_id` string|null?, `kind` string|null?, `limit` integer? — example `{"entity_id":null,"kind":"develops","limit":50}`
- `reports.artifacts`: `report_version_id` string — example `{"report_version_id":"00000000-0000-7000-8000-000000000001"}`
- `reports.assertions`: `report_version_id` string — example `{"report_version_id":"00000000-0000-7000-8000-000000000001"}`
- `reports.dependencies`: `report_version_id` string — example `{"report_version_id":"00000000-0000-7000-8000-000000000001"}`
- `reports.questions`: `report_version_id` string — example `{"report_version_id":"00000000-0000-7000-8000-000000000001"}`
- `reports.sections`: `report_version_id` string — example `{"report_version_id":"00000000-0000-7000-8000-000000000001"}`
- `reports.versions`: `report_id` string — example `{"report_id":"00000000-0000-7000-8000-000000000001"}`
- `retrieval.evidence_packet`: `packet_id` string — example `{"packet_id":"0192c000-0000-7000-8000-000000000001"}`
- `retrieval.hybrid_search`: `filters` object?, `limit` integer?, `query_text` string, `vector_space_version_id` string — example `{"filters":{},"limit":20,"query_text":"OpenAI API pricing 2026","vector_space_version_id":"0192b100-0000-7000-8000-000000000001"}`
- `staging.candidates_for_kind`: `limit` integer?, `proposed_kind` string|null? — example `{"limit":50,"proposed_kind":"organization"}`
- `staging.unresolved`: `limit` integer? — example `{"limit":50}`
- `vocab.event_kind`: `code` string|null? — example `{"code":"price_changed"}`
- `vocab.relationship_kind`: `code` string|null? — example `{"code":"employed_by"}`
- `vocab.stream_kind`: `code` string|null? — example `{"code":"model_offering_price"}`
