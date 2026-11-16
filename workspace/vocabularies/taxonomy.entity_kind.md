---
id: "voc:taxonomy.entity_kind"
kind: vocabulary
schema: taxonomy
name: entity_kind
rows: 39
rows_sha256: "sha256:ee57f07b282646556557a324da36333474eb55d23437a1ec7786a9928c094e8e"
codes: [agent_plugin, agent_skill, ai_model, ai_model_version, ai_protocol, ai_protocol_feature, ai_protocol_version, benchmark, benchmark_version, case_study, community_actor, compute_device, compute_offering, concept, corporate_transaction, dataset, event_series, funding_round, industry_event, library, library_release, mcp_server, media_channel, media_series, media_work, model_offering, organization, paper, person, product, product_feature, product_version, registry, repository, security_advisory, source_channel, story, talk, technique]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# taxonomy.entity_kind

Reference data snapshot (39 rows, digest `sha256:ee57f07b282646556557a324da36333474eb55d23437a1ec7786a9928c094e8e`). Codes are enforced wherever a column has a foreign key to [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md).

| code | attributes_schema | canonical_schema | canonical_table | description | is_work | label | lens | parent_kind |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `agent_plugin` | `{"additionalProperties":true,"properties":{"author":{"type":"string"},"componen…` | catalog | entity | A harness plugin: a named bundle of skills, MCP servers, hooks, commands and prompts installed as one unit (CAP-D6). Ho… | no | Agent Plugin | corpus | — |
| `agent_skill` | `{"additionalProperties":true,"properties":{"declared_clis":{"items":{"type":"st…` | catalog | entity | agent_skill | no | Agent Skill | corpus | — |
| `ai_model` | `{"additionalProperties":true,"properties":{"description":{"type":"string"},"mod…` | catalog | entity | ai_model | no | Ai Model | corpus | — |
| `ai_model_version` | `{"additionalProperties":true,"properties":{"modalities":{"items":{"type":"strin…` | catalog | entity | Model version (the thing that is released, priced and evaluated); version_of -> ai_model | no | Ai Model Version | corpus | ai_model |
| `ai_protocol` | `{"type":"object"}` | catalog | entity | ai_protocol | no | Ai Protocol | corpus | — |
| `ai_protocol_feature` | `{"type":"object"}` | catalog | entity | ai_protocol_feature | no | Ai Protocol Feature | corpus | ai_protocol |
| `ai_protocol_version` | `{"additionalProperties":true,"properties":{"changelog_url":{"type":"string"},"d…` | catalog | entity | One revision of a protocol (MCP 2026-07-28); status current/final/draft from the versioning page | no | Ai Protocol Version | corpus | ai_protocol |
| `benchmark` | `{"additionalProperties":true,"properties":{"agentic":{"type":"boolean"},"canoni…` | catalog | entity | A benchmark (task set + metric) that scores models, agents or systems; versions/editions are benchmark_version children | no | Benchmark | corpus | — |
| `benchmark_version` | `{"additionalProperties":true,"properties":{"canonical_url":{"type":"string"},"c…` | catalog | entity | One edition/cohort of a benchmark (SWE-bench Verified, Terminal-Bench 4.1, ARC-AGI-2, OSWorld v2.1); scores reference t… | no | Benchmark Version | corpus | benchmark |
| `case_study` | `{"type":"object"}` | catalog | work | case_study | yes | Case Study | corpus | — |
| `community_actor` | `{"additionalProperties":false,"properties":{"first_seen_at":{"type":"string"},"…` | catalog | entity | A handle that published statements on a channel, kept as published (platform + handle) with the platform's own role lab… | no | Community actor | corpus | — |
| `compute_device` | `{"additionalProperties":true,"properties":{"announced_on":{"type":"string"},"av…` | catalog | entity | An accelerator or system (GPU, TPU, NPU, CPU or a multi-GPU system such as GB200 NVL72); specs are attributes with clai… | no | Compute Device | corpus | — |
| `compute_offering` | `{"additionalProperties":true,"properties":{"billing_granularity":{"type":"strin…` | catalog | entity | A sellable compute offering: an instance type, a serverless GPU, a sandbox product, a managed cluster or an inference e… | no | Compute Offering | corpus | — |
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
| `registry` | `{"additionalProperties":true,"properties":{"api_url":{"type":"string"},"descrip…` | catalog | entity | registry | no | Registry | corpus | — |
| `repository` | `{"additionalProperties":true,"properties":{"default_branch":{"type":"string"},"…` | catalog | entity | repository | no | Repository | corpus | — |
| `security_advisory` | `{"additionalProperties":true,"properties":{"affected_range":{"type":"string"},"…` | catalog | entity | A published security advisory (GHSA/CVE) affecting software; the record itself, not the vulnerability concept | no | Security Advisory | corpus | — |
| `source_channel` | `{"additionalProperties":true,"properties":{"access":{"type":"object"},"channel_…` | catalog | entity | A place statements are published: an issue tracker of one repository, a forum, a Q&A tag, an aggregator, a blog or news… | no | Source channel | corpus | — |
| `story` | `{"type":"object"}` | catalog | work | story | yes | Story | corpus | — |
| `talk` | `{"additionalProperties":true,"properties":{"edition":{"type":"string"},"level":…` | catalog | work | A conference talk/session (ai.engineer World's Fair, Code Summit ...): presented_by -> person, presented_at -> industry… | yes | Talk | corpus | — |
| `technique` | `{"additionalProperties":true,"properties":{"description":{"type":"string"},"tec…` | catalog | entity | technique | no | Technique | corpus | — |
