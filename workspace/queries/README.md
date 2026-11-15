---
id: queries
kind: entry
queries: 55
catalog_version: "sha256:911b2d8651a2bfecd07037cb12fb5b7e4fd47bf50d5d70c7ecd2b4da7496f3eb"
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# Named queries

Every entry runs as data from `catalog.json` (`knowledge-query-catalog.v1`, digest `sha256:911b2d8651a2bfecd07037cb12fb5b7e4fd47bf50d5d70c7ecd2b4da7496f3eb`): the executor opens a read-only transaction, sets `app.tenant_id`, `SET LOCAL ROLE <role>`, applies the statement timeout of the cost class, binds `paramOrder` positionally, and caps rows at `limit` (default 200, max 2000). Run one with `knowledge db query <name> --param k=v`, or batch several in a `knowledge-read-intent.v1` (`knowledge db read-intent intent.json`). The snapshot records the knowledge head so your ingestion intent can cite it.

| Query | Role | Cost | Params | Shape | Domain | Summary |
| --- | --- | --- | --- | --- | --- | --- |
| <a id="acquisitionfetchesforurl"></a>`acquisition.fetches_for_url` | pipeline_agent | cheap | `url`, `limit` | rows | [`acquisition`](../domains/acquisition.md) | Fetch ledger rows for a URL (who fetched, with what tool, outcome, hash, spend) |
| <a id="artifactsbytype"></a>`artifacts.by_type` | pipeline_agent | cheap | `artifact_type`, `limit` | rows | [`orchestration-ledger`](../domains/orchestration-ledger.md) | Artifacts of one artifact_type for the current tenant |
| <a id="catalogbenchmarkscores"></a>`catalog.benchmark_scores` | app_reader | medium | `subject_id`, `benchmark`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 benchmark results as facts (one home for numbers) by subject or benchmark |
| <a id="catalogconcepts"></a>`catalog.concepts` | app_reader | medium | `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 concepts and techniques with how many works, software, guidance items and our modules cover them |
| <a id="catalogevents"></a>`catalog.events` | app_reader | medium | `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 industry events (conference editions) with dates, place, organizers, tracks and talk counts |
| <a id="catalogmodelofferings"></a>`catalog.model_offerings` | app_reader | medium | `model_version_id`, `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 offerings (model as sold by a provider) with normalized USD per 1M tokens and the price claim/locator |
| <a id="catalogmodelofferingsat"></a>`catalog.model_offerings_at` | app_reader | medium | `at` | rows | [`api-surface`](../domains/api-surface.md) | The offerings table as it stood at a world time (L2 replay of L1) |
| <a id="catalogmodels"></a>`catalog.models` | app_reader | medium | `text`, `availability`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 models (one row per model version) with developer, capabilities, availability and minimum current price |
| <a id="catalogmodelsat"></a>`catalog.models_at` | app_reader | medium | `at` | rows | [`api-surface`](../domains/api-surface.md) | The models table as it stood at a world time (L2 replay of L1) |
| <a id="catalogorganizations"></a>`catalog.organizations` | app_reader | medium | `text`, `org_kind`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 organizations with kind, site, country, founding date and counts |
| <a id="catalogpapers"></a>`catalog.papers` | app_reader | medium | `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 papers with identifiers, authors, code repositories, techniques and the talks that discuss them |
| <a id="catalogpeople"></a>`catalog.people` | app_reader | medium | `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 people with current affiliations and talk/work counts |
| <a id="catalogsoftware"></a>`catalog.software` | app_reader | medium | `kind`, `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 software (libraries, repositories, MCP servers, agent skills, products, protocols) in one table |
| <a id="catalogsoftwarereleases"></a>`catalog.software_releases` | app_reader | medium | `software_id`, `text`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | Releases of a software thing, newest first, with breaking flag and the knowledge seq they were learned at |
| <a id="catalogtalks"></a>`catalog.talks` | app_reader | medium | `text`, `event_id`, `limit` | rows | [`api-surface`](../domains/api-surface.md) | L1 talks with event, speakers, topics, linked repositories and recording links |
| <a id="contentdocumentdigest"></a>`content.document_digest` | app_reader | cheap | `document_id` | rows | [`content`](../domains/content.md) | Structured digest of a document's newest version (key points, entity roles, assertions, changes, open questions) |
| <a id="contentdocumentunits"></a>`content.document_units` | app_reader | cheap | `document_id`, `unit_kinds` | rows | [`content`](../domains/content.md) | Typed units of a document across its versions (newest first) |
| <a id="contentrefreshchecks"></a>`content.refresh_checks` | pipeline_agent | cheap | `document_id`, `outcome`, `limit` | rows | [`content`](../domains/content.md) | Refresh outcomes for a document (unchanged, changed, failed) and the version each created |
| <a id="contenttalksegments"></a>`content.talk_segments` | app_reader | cheap | `talk_id`, `from_ms`, `to_ms`, `query` | rows | [`content`](../domains/content.md) | Transcript segments and slides of a talk inside a timecode window, optionally filtered by text |
| <a id="contentunitchanges"></a>`content.unit_changes` | pipeline_agent | cheap | `document_id`, `since`, `limit` | rows | [`content`](../domains/content.md) | Unit-level diffs between document versions, matched by logical key |
| <a id="entityat"></a>`entity.at` | app_reader | cheap | `entity_id`, `at`, `k` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Facts for one entity at a world time as known at a knowledge seq |
| <a id="entityattributes"></a>`entity.attributes` | pipeline_agent | cheap | `entity_id`, `kind` | single_row | [`identity`](../domains/identity.md) | Canonical entity row with its kind-validated attributes and the kind's attribute schema |
| <a id="entitybyidentifier"></a>`entity.by_identifier` | pipeline_agent | cheap | `scheme`, `value` | rows | [`identity`](../domains/identity.md) | Find a canonical entity by external identifier scheme and value |
| <a id="entitycard"></a>`entity.card` | app_reader | cheap | `entity_id` | single_json | [`identity`](../domains/identity.md) | Current overview of one entity |
| <a id="entityrelationships"></a>`entity.relationships` | app_reader | cheap | `entity_id`, `kind`, `at`, `k`, `direction` | rows | [`relationships`](../domains/relationships.md) | Relationships touching one entity at a world time and knowledge seq |
| <a id="entityresolve"></a>`entity.resolve` | app_reader | cheap | `text` | rows | [`identity`](../domains/identity.md) | Find entities by name, alias, or identifier |
| <a id="entitytimeline"></a>`entity.timeline` | app_reader | medium | `entity_id`, `from`, `to`, `k` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Segments, events, and unknown gaps for one entity over a world interval |
| <a id="entitywhatchanged"></a>`entity.what_changed` | app_reader | cheap | `entity_id`, `k_from`, `k_to` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Opened and closed items for one entity between two knowledge heads |
| <a id="eventscurrentforentity"></a>`events.current_for_entity` | app_reader | cheap | `entity_id` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Current event occurrences for one subject entity |
| <a id="evidencecapturesforsource"></a>`evidence.captures_for_source` | pipeline_agent | cheap | `source_id` | rows | [`evidence`](../domains/evidence.md) | Captures registered for one source, with the acquisition fetch that produced them |
| <a id="evidenceclaimsupport"></a>`evidence.claim_support` | pipeline_agent | cheap | `claim_id` | rows | [`evidence`](../domains/evidence.md) | Segment and occurrence support rows for one claim |
| <a id="evidenceclaimsforentity"></a>`evidence.claims_for_entity` | pipeline_agent | cheap | `entity_id`, `limit` | rows | [`evidence`](../domains/evidence.md) | Claims that name one entity as subject, object, or context |
| <a id="evidencesourcesbydomain"></a>`evidence.sources_by_domain` | pipeline_agent | cheap | `domain`, `limit` | rows | [`evidence`](../domains/evidence.md) | Sources filtered by registrable domain |
| <a id="factschangessince"></a>`facts.changes_since` | app_reader | medium | `since`, `stream_kinds`, `entity_kinds`, `document_types` | rows | [`temporal-facts`](../domains/temporal-facts.md) | What changed since a date, on both clocks (facts opened/replaced, events, unit-level document diffs) |
| <a id="factscurrentbystream"></a>`facts.current_by_stream` | app_reader | cheap | `stream_kind`, `entity_id`, `limit` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Current facts (k_to is null and valid_during contains now) by stream kind |
| <a id="factshistoryforstream"></a>`facts.history_for_stream` | pipeline_agent | medium | `entity_id`, `stream_kind`, `scope_key`, `limit`, `offset` | rows | [`temporal-facts`](../domains/temporal-facts.md) | All segments on one entity stream slot, including closed history |
| <a id="factslocators"></a>`facts.locators` | app_reader | cheap | `entity_id`, `stream_kind`, `scope_key` | rows | [`evidence`](../domains/evidence.md) | A current fact with its claim, exact locator, capture and the typed unit it was read from |
| <a id="factspricehistory"></a>`facts.price_history` | app_reader | cheap | `offering_id`, `meter` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Every price segment of an offering and meter with both clocks, including superseded beliefs |
| <a id="guidanceitems"></a>`guidance.items` | app_reader | medium | `kind`, `entity_id`, `text`, `limit` | rows | [`guidance`](../domains/guidance.md) | Expert guidance items (problems, solution patterns, failure modes, …) with their subject entities |
| <a id="knowledgehead"></a>`knowledge.head` | app_reader | cheap | — | single_row | [`temporal-facts`](../domains/temporal-facts.md) | Current tenant knowledge sequence |
| <a id="oursmodulesaffectedbyrelease"></a>`ours.modules_affected_by_release` | app_reader | cheap | `release_id` | rows | [`authoring`](../domains/authoring.md) | Our head revisions that bind or require the software a release belongs to and were authored before it |
| <a id="oursworksauthored"></a>`ours.works_authored` | app_reader | medium | `kind`, `released`, `text`, `limit` | rows | [`authoring`](../domains/authoring.md) | Our courses, modules, lessons, activities, reports and templates at head revision (lens ours, tier 1) |
| <a id="rankingleaderboard"></a>`ranking.leaderboard` | app_reader | cheap | `slug`, `limit` | rows | [`ranking`](../domains/ranking.md) | Latest published edition of a named leaderboard (ranked entities with the fact segments behind each score) |
| <a id="receiptsforintent"></a>`receipts.for_intent` | pipeline_agent | cheap | `intent_id` | rows | [`orchestration-ledger`](../domains/orchestration-ledger.md) | Intent row and sealed batch for one operation intent |
| <a id="receiptsrecentformission"></a>`receipts.recent_for_mission` | pipeline_agent | cheap | `mission_id`, `limit` | rows | [`orchestration-ledger`](../domains/orchestration-ledger.md) | Recent intents and sealed batches for one mission |
| <a id="relationshipscurrentbykind"></a>`relationships.current_by_kind` | app_reader | cheap | `kind`, `entity_id`, `limit` | rows | [`relationships`](../domains/relationships.md) | Current relationships, optionally filtered by kind or endpoint |
| <a id="retrievalevidencepacket"></a>`retrieval.evidence_packet` | app_reader | cheap | `packet_id` | single_json | [`retrieval`](../domains/retrieval.md) | One evidence packet with members and node timecodes |
| <a id="retrievalhybridsearch"></a>`retrieval.hybrid_search` | app_reader | heavy | `$embedding`, `vector_space_version_id`, `query_text`, `filters`, `limit` | rows | [`retrieval`](../domains/retrieval.md) | Hybrid search over a published 1536-d vector-space version (legacy per-space entry; prefer retrieval.search_unified) |
| <a id="retrievalsearchunified"></a>`retrieval.search_unified` | app_reader | heavy | `query`, `lenses`, `tiers`, `space_slugs`, `document_types`, `unit_kinds`, `entity_ids`, `as_of`, `workspace_ids`, `source_roles`, `content_kinds`, `limit` | rows | [`retrieval`](../domains/retrieval.md) | L3 scoped semantic search over the one stack (lexical channels; the executor adds the ANN channel when it embeds) |
| <a id="stagingcandidatesforkind"></a>`staging.candidates_for_kind` | pipeline_agent | cheap | `proposed_kind`, `limit` | rows | [`staging`](../domains/staging.md) | Staging candidates of one proposed entity kind |
| <a id="stagingunresolved"></a>`staging.unresolved` | pipeline_agent | cheap | `limit` | rows | [`staging`](../domains/staging.md) | Candidates with no create, match, or reject decision |
| <a id="vocabeventkind"></a>`vocab.event_kind` | pipeline_agent | cheap | `code` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Event-kind vocabulary |
| <a id="vocabrelationshipkind"></a>`vocab.relationship_kind` | pipeline_agent | cheap | `code` | rows | [`relationships`](../domains/relationships.md) | Relationship-kind vocabulary with endpoint constraints |
| <a id="vocabstreamkind"></a>`vocab.stream_kind` | pipeline_agent | cheap | `code` | rows | [`temporal-facts`](../domains/temporal-facts.md) | Stream-kind vocabulary and slot rules |
| <a id="vocabunitkind"></a>`vocab.unit_kind` | app_reader | cheap | `code`, `document_type` | rows | [`content`](../domains/content.md) | Unit-kind grammar (typed units, logical-key attributes, locator kind, retrieval role, entity roles) |

## Pending (not executed at build)

- `retrieval.hybrid_search`: requires embedding

## Parameters

- `acquisition.fetches_for_url`: `limit` integer?, `url` string|null? — example `{"limit":50,"url":null}`
- `artifacts.by_type`: `artifact_type` string|null?, `limit` integer? — example `{"artifact_type":"knowledge_ingestion_receipt","limit":50}`
- `catalog.benchmark_scores`: `benchmark` string|null?, `limit` integer?, `subject_id` string|null? — example `{"benchmark":null,"limit":100,"subject_id":null}`
- `catalog.concepts`: `limit` integer?, `text` string|null? — example `{"limit":50,"text":null}`
- `catalog.events`: `limit` integer?, `text` string|null? — example `{"limit":50,"text":null}`
- `catalog.model_offerings`: `limit` integer?, `model_version_id` string|null?, `text` string|null? — example `{"limit":50,"model_version_id":null,"text":null}`
- `catalog.model_offerings_at`: `at` string — example `{"at":"2026-06-01T00:00:00Z"}`
- `catalog.models`: `availability` string|null?, `limit` integer?, `text` string|null? — example `{"availability":null,"limit":50,"text":null}`
- `catalog.models_at`: `at` string — example `{"at":"2026-06-01T00:00:00Z"}`
- `catalog.organizations`: `limit` integer?, `org_kind` string|null?, `text` string|null? — example `{"limit":50,"org_kind":null,"text":null}`
- `catalog.papers`: `limit` integer?, `text` string|null? — example `{"limit":50,"text":null}`
- `catalog.people`: `limit` integer?, `text` string|null? — example `{"limit":50,"text":null}`
- `catalog.software`: `kind` string|null?, `limit` integer?, `text` string|null? — example `{"kind":null,"limit":50,"text":null}`
- `catalog.software_releases`: `limit` integer?, `software_id` string|null?, `text` string|null? — example `{"limit":50,"software_id":null,"text":null}`
- `catalog.talks`: `event_id` string|null?, `limit` integer?, `text` string|null? — example `{"event_id":null,"limit":50,"text":null}`
- `content.document_digest`: `document_id` string — example `{"document_id":"0192b000-0000-7000-8000-000000000001"}`
- `content.document_units`: `document_id` string, `unit_kinds` array|null? — example `{"document_id":"0192b000-0000-7000-8000-000000000001","unit_kinds":null}`
- `content.refresh_checks`: `document_id` string|null?, `limit` integer?, `outcome` string|null? — example `{"document_id":null,"limit":50,"outcome":null}`
- `content.talk_segments`: `from_ms` integer|null?, `query` string|null?, `talk_id` string, `to_ms` integer|null? — example `{"from_ms":0,"query":null,"talk_id":"0192b000-0000-7000-8000-000000000001","to_ms":600000}`
- `content.unit_changes`: `document_id` string|null?, `limit` integer?, `since` string|null? — example `{"document_id":null,"limit":100,"since":"2026-10-01T00:00:00Z"}`
- `entity.at`: `at` string, `entity_id` string, `k` integer|null? — example `{"at":"2026-03-15T00:00:00Z","entity_id":"0192b000-0000-7000-8000-000000000001","k":0}`
- `entity.attributes`: `entity_id` string, `kind` string|null? — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","kind":"organization"}`
- `entity.by_identifier`: `scheme` string, `value` string — example `{"scheme":"github","value":"openai/openai-python"}`
- `entity.card`: `entity_id` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001"}`
- `entity.relationships`: `at` string?, `direction` string?, `entity_id` string, `k` integer|null?, `kind` string|null? — example `{"at":"2026-11-08T00:00:00Z","direction":"both","entity_id":"0192b000-0000-7000-8000-000000000001","k":null,"kind":null}`
- `entity.resolve`: `text` string — example `{"text":"OpenAI"}`
- `entity.timeline`: `entity_id` string, `from` string, `k` integer|null?, `to` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","from":"2025-01-01T00:00:00Z","k":null,"to":"2026-11-08T00:00:00Z"}`
- `entity.what_changed`: `entity_id` string, `k_from` integer, `k_to` integer — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","k_from":0,"k_to":0}`
- `events.current_for_entity`: `entity_id` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001"}`
- `evidence.captures_for_source`: `source_id` string — example `{"source_id":"0192e000-0000-7000-8000-000000000001"}`
- `evidence.claim_support`: `claim_id` string — example `{"claim_id":"0192d000-0000-7000-8000-000000000001"}`
- `evidence.claims_for_entity`: `entity_id` string, `limit` integer? — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","limit":100}`
- `evidence.sources_by_domain`: `domain` string|null?, `limit` integer? — example `{"domain":"openai.com","limit":50}`
- `facts.changes_since`: `document_types` array|null?, `entity_kinds` array|null?, `since` string, `stream_kinds` array|null? — example `{"document_types":null,"entity_kinds":null,"since":"2026-10-01T00:00:00Z","stream_kinds":null}`
- `facts.current_by_stream`: `entity_id` string|null?, `limit` integer?, `stream_kind` string|null? — example `{"entity_id":null,"limit":50,"stream_kind":"offering_price"}`
- `facts.history_for_stream`: `entity_id` string, `limit` integer?, `offset` integer?, `scope_key` string|null?, `stream_kind` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","limit":50,"offset":0,"scope_key":"input_tokens\|\|","stream_kind":"offering_price"}`
- `facts.locators`: `entity_id` string, `scope_key` string|null?, `stream_kind` string — example `{"entity_id":"0192b000-0000-7000-8000-000000000001","scope_key":null,"stream_kind":"offering_price"}`
- `facts.price_history`: `meter` string?, `offering_id` string — example `{"meter":"input_tokens","offering_id":"0192b000-0000-7000-8000-000000000001"}`
- `guidance.items`: `entity_id` string|null?, `kind` string|null?, `limit` integer?, `text` string|null? — example `{"entity_id":null,"kind":null,"limit":50,"text":null}`
- `knowledge.head`: none
- `ours.modules_affected_by_release`: `release_id` string — example `{"release_id":"0192b000-0000-7000-8000-000000000001"}`
- `ours.works_authored`: `kind` string|null?, `limit` integer?, `released` boolean|null?, `text` string|null? — example `{"kind":null,"limit":50,"released":null,"text":null}`
- `ranking.leaderboard`: `limit` integer?, `slug` string — example `{"limit":20,"slug":"cheapest-frontier-input"}`
- `receipts.for_intent`: `intent_id` string — example `{"intent_id":"0192f000-0000-7000-8000-000000000001"}`
- `receipts.recent_for_mission`: `limit` integer?, `mission_id` string — example `{"limit":20,"mission_id":"0192a000-0000-7000-8000-000000000001"}`
- `relationships.current_by_kind`: `entity_id` string|null?, `kind` string|null?, `limit` integer? — example `{"entity_id":null,"kind":"develops","limit":50}`
- `retrieval.evidence_packet`: `packet_id` string — example `{"packet_id":"0192c000-0000-7000-8000-000000000001"}`
- `retrieval.hybrid_search`: `filters` object?, `limit` integer?, `query_text` string, `vector_space_version_id` string — example `{"filters":{},"limit":20,"query_text":"OpenAI API pricing 2026","vector_space_version_id":"0192b100-0000-7000-8000-000000000001"}`
- `retrieval.search_unified`: `as_of` string|null?, `content_kinds` array|null?, `document_types` array|null?, `entity_ids` array|null?, `lenses` array?, `limit` integer?, `query` string, `source_roles` array|null?, `space_slugs` array|null?, `tiers` array|null?, `unit_kinds` array|null?, `workspace_ids` array|null? — example `{"as_of":null,"content_kinds":null,"document_types":null,"entity_ids":null,"lenses":["corpus","ours"],"limit":20,"query":"context engineering","source_roles":null,"space_slugs":null,"tiers":null,"unit_kinds":null,"workspace_ids":null}`
- `staging.candidates_for_kind`: `limit` integer?, `proposed_kind` string|null? — example `{"limit":50,"proposed_kind":"organization"}`
- `staging.unresolved`: `limit` integer? — example `{"limit":50}`
- `vocab.event_kind`: `code` string|null? — example `{"code":"price_changed"}`
- `vocab.relationship_kind`: `code` string|null? — example `{"code":"employed_by"}`
- `vocab.stream_kind`: `code` string|null? — example `{"code":"offering_price"}`
- `vocab.unit_kind`: `code` string|null?, `document_type` string|null? — example `{"code":null,"document_type":"pricing_page"}`
