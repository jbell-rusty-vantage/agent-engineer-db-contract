---
id: "voc:taxonomy.entity_kind"
kind: vocabulary
schema: taxonomy
name: entity_kind
rows: 36
rows_sha256: "sha256:1f2b8f9ff88fcbc5a6bc3151247dd416ce265f826695b78c4fbcd18716b9d5b9"
codes: [agent_skill, ai_model, ai_model_version, ai_protocol, ai_protocol_feature, ai_protocol_version, benchmark, benchmark_run, case_study, compute_device, compute_offering, concept, corporate_transaction, dataset, event_series, funding_round, industry_event, library, library_release, mcp_server, media_channel, media_series, media_work, model_offering, organization, paper, person, product, product_feature, product_version, registry, repository, security_advisory, story, talk, technique]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# taxonomy.entity_kind

Reference data snapshot (36 rows, digest `sha256:1f2b8f9ff88fcbc5a6bc3151247dd416ce265f826695b78c4fbcd18716b9d5b9`). Codes are enforced wherever a column has a foreign key to [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md).

| code | attributes_schema | canonical_schema | canonical_table | description | is_work | label | lens | parent_kind |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `agent_skill` | `{"type":"object"}` | catalog | entity | agent_skill | no | Agent Skill | corpus | — |
| `ai_model` | `{"additionalProperties":true,"properties":{"description":{"type":"string"},"mod…` | catalog | entity | ai_model | no | Ai Model | corpus | — |
| `ai_model_version` | `{"additionalProperties":true,"properties":{"modalities":{"items":{"type":"strin…` | catalog | entity | Model version (the thing that is released, priced and evaluated); version_of -> ai_model | no | Ai Model Version | corpus | ai_model |
| `ai_protocol` | `{"type":"object"}` | catalog | entity | ai_protocol | no | Ai Protocol | corpus | — |
| `ai_protocol_feature` | `{"type":"object"}` | catalog | entity | ai_protocol_feature | no | Ai Protocol Feature | corpus | ai_protocol |
| `ai_protocol_version` | `{"type":"object"}` | catalog | entity | ai_protocol_version | no | Ai Protocol Version | corpus | ai_protocol |
| `benchmark` | `{"additionalProperties":true,"properties":{"canonical_url":{"type":"string"},"h…` | catalog | entity | benchmark | no | Benchmark | corpus | — |
| `benchmark_run` | `{"type":"object"}` | catalog | entity | benchmark_run | no | Benchmark Run | corpus | benchmark |
| `case_study` | `{"type":"object"}` | catalog | work | case_study | yes | Case Study | corpus | — |
| `compute_device` | `{"type":"object"}` | catalog | entity | compute_device | no | Compute Device | corpus | — |
| `compute_offering` | `{"type":"object"}` | catalog | entity | compute_offering | no | Compute Offering | corpus | — |
| `concept` | `{"additionalProperties":true,"properties":{"component":{"enum":["rag","context"…` | catalog | entity | concept | no | Concept | corpus | — |
| `corporate_transaction` | `{"type":"object"}` | catalog | entity | corporate_transaction | no | Corporate Transaction | corpus | — |
| `dataset` | `{"type":"object"}` | catalog | entity | dataset | no | Dataset | corpus | — |
| `event_series` | `{"additionalProperties":true,"properties":{"series_kind":{"type":"string"},"web…` | catalog | entity | event_series | no | Event Series | corpus | — |
| `funding_round` | `{"type":"object"}` | catalog | entity | funding_round | no | Funding Round | corpus | — |
| `industry_event` | `{"additionalProperties":true,"properties":{"city":{"type":"string"},"country":{…` | catalog | entity | industry_event | no | Industry Event | corpus | event_series |
| `library` | `{"additionalProperties":true,"properties":{"category":{"type":"string"},"descri…` | catalog | entity | library | no | Library | corpus | — |
| `library_release` | `{"additionalProperties":true,"properties":{"breaking":{"type":"boolean"},"highl…` | catalog | entity | library_release | no | Library Release | corpus | library |
| `mcp_server` | `{"additionalProperties":true,"properties":{"auth":{"type":"string"},"descriptio…` | catalog | entity | mcp_server | no | Mcp Server | corpus | — |
| `media_channel` | `{"type":"object"}` | catalog | entity | media_channel | no | Media Channel | corpus | — |
| `media_series` | `{"type":"object"}` | catalog | entity | media_series | no | Media Series | corpus | media_channel |
| `media_work` | `{"type":"object"}` | catalog | work | media_work | yes | Media Work | corpus | — |
| `model_offering` | `{"additionalProperties":true,"properties":{"offering_key":{"type":"string"},"pr…` | catalog | entity | A model as sold on one API/provider: offered_as <- ai_model_version, offered_by -> organization; prices are offering_pr… | no | Model Offering | corpus | ai_model_version |
| `organization` | `{"additionalProperties":true,"properties":{"country_code":{"type":"string"},"fo…` | catalog | entity | organization | no | Organization | corpus | — |
| `paper` | `{"additionalProperties":true,"properties":{"arxiv_id":{"type":"string"},"doi":{…` | catalog | work | paper | yes | Paper | corpus | — |
| `person` | `{"additionalProperties":true,"properties":{"affiliation_text":{"type":"string"}…` | catalog | entity | person | no | Person | corpus | — |
| `product` | `{"type":"object"}` | catalog | entity | product | no | Product | corpus | — |
| `product_feature` | `{"type":"object"}` | catalog | entity | product_feature | no | Product Feature | corpus | product |
| `product_version` | `{"type":"object"}` | catalog | entity | product_version | no | Product Version | corpus | product |
| `registry` | `{"type":"object"}` | catalog | entity | registry | no | Registry | corpus | — |
| `repository` | `{"additionalProperties":true,"properties":{"default_branch":{"type":"string"},"…` | catalog | entity | repository | no | Repository | corpus | — |
| `security_advisory` | `{"type":"object"}` | catalog | entity | security_advisory | no | Security Advisory | corpus | — |
| `story` | `{"type":"object"}` | catalog | work | story | yes | Story | corpus | — |
| `talk` | `{"additionalProperties":true,"properties":{"edition":{"type":"string"},"level":…` | catalog | work | A conference talk/session (ai.engineer World's Fair, Code Summit ...): presented_by -> person, presented_at -> industry… | yes | Talk | corpus | — |
| `technique` | `{"additionalProperties":true,"properties":{"description":{"type":"string"},"tec…` | catalog | entity | technique | no | Technique | corpus | — |
