---
id: "voc:temporal.stream_kind"
kind: vocabulary
schema: temporal
name: stream_kind
rows: 32
rows_sha256: "sha256:e9aa4edc86ebb9daf511a0ceae56c6c04ac34907fb092c140f2ef3bf98c283c1"
codes: [benchmark_score, engagement_role, entity_name, library_license, library_maintenance, media_views, model_availability, model_capability, model_context_window, model_knowledge_cutoff, model_max_output_tokens, model_offering_availability, model_version_spec, offering_limit, offering_price, organization_headcount, organization_status, ownership_stake, package_downloads, paper_citations, product_feature_availability, protocol_feature_support, registry_listing_status, relationship_active, repository_archival, repository_forks, repository_location, repository_open_issues, repository_stars, repository_visibility, valuation, work_disposition]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# temporal.stream_kind

Reference data snapshot (32 rows, digest `sha256:e9aa4edc86ebb9daf511a0ceae56c6c04ac34907fb092c140f2ef3bf98c283c1`). Codes are enforced wherever a column has a foreign key to [`temporal.stream_kind`](../relations/temporal/stream_kind.md).

| code | description | payload_schema | ref_entity_kinds | requires_amount | requires_ref_entity | status_values | subject_kinds | subject_mode | unit_values |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `benchmark_score` | A benchmark result: subject (model version, product version, library release or compute system), ref benchmark_version … | `{"additionalProperties":true,"properties":{"attempts":{"type":"integer"},"bench…` | benchmark, benchmark_version | yes | yes | — | ai_model_version, product_version, paper, library_release, compute_device, compute_offering | entity | pass_at_1, tokens_per_second, usd, ms, samples_per_second, score, seconds, count, elo, percent |
| `engagement_role` | engagement role | `{"properties":{"title":{"type":"string"}},"required":["title"],"type":"object"}` | — | no | no | — | employed_by | relationship | — |
| `entity_name` | entity name | `{"properties":{"display_name":{"type":"string"},"legal_name":{"type":"string"}}…` | — | no | no | — | person, organization, product, product_version, product_feature, ai_model, ai_model_version, model_offering, technique, dataset, benchmark, benchmark_run, repository, library, library_release, mcp_server, agent_skill, ai_protocol, ai_protocol_version, ai_protocol_feature, paper, media_channel, media_series, media_work, event_series, industry_event, talk, story, case_study, concept, funding_round, corporate_transaction, registry, security_advisory, compute_device, compute_offering | entity | — |
| `library_license` | License of a software thing or open-weights model (payload spdx), as stated by the publisher | `{"properties":{"license_code":{"type":"string"}},"required":["license_code"],"t…` | — | no | no | — | library, repository, mcp_server, agent_skill, product, ai_model_version | entity | — |
| `library_maintenance` | library maintenance | `{}` | — | no | no | active, maintenance_only, deprecated, abandoned | library | entity | — |
| `media_views` | Recording views at observation | `{"properties":{"platform":{"type":"string"}},"type":"object"}` | — | yes | no | — | media_work, talk | entity | count |
| `model_availability` | Lifecycle availability of a model version or offering | `{"type":"object"}` | — | no | no | announced, preview, generally_available, deprecated, retired | ai_model_version, model_offering | entity | — |
| `model_capability` | Capability status per scope_key: tool_use, structured_output, reasoning, vision, audio, open_weights, prompt_caching, b… | `{"properties":{"detail":{"type":"string"}},"type":"object"}` | — | no | no | supported, unsupported, preview, unknown | ai_model_version | entity | — |
| `model_context_window` | Maximum context window in tokens | `{"type":"object"}` | — | yes | no | — | ai_model_version | entity | tokens |
| `model_knowledge_cutoff` | Training data cutoff as stated by the developer | `{"properties":{"cutoff_on":{"type":"string"}},"required":["cutoff_on"],"type":"…` | — | no | no | — | ai_model_version | entity | — |
| `model_max_output_tokens` | Maximum output tokens | `{"type":"object"}` | — | yes | no | — | ai_model_version | entity | tokens |
| `model_offering_availability` | model offering availability | `{}` | — | no | no | announced, preview, ga, deprecated, retired | model_offering | entity | — |
| `model_version_spec` | model version spec | `{}` | — | no | no | — | ai_model_version | entity | — |
| `offering_limit` | A stated limit of an offering (max session duration, concurrency, memory, rate limits); scope_key = limit_name\|plan | `{"additionalProperties":true,"properties":{"condition":{"type":"string"},"limit…` | — | yes | no | — | model_offering, compute_offering | entity | context_tokens, max_output_tokens, rpm, tpm, batch_size, seconds, minutes, hours, count, GiB, vcpu, GB |
| `offering_price` | Price of one meter of an offering (input_tokens, output_tokens, gpu_hour, vcpu_second, gib_second ...); scope_key = met… | `{"additionalProperties":true,"properties":{"commitment":{"enum":["on_demand","s…` | — | yes | no | — | model_offering, compute_offering | entity | USD_per_1K_images, USD_per_GB_month, USD_per_minute, USD_per_1M_creations, USD_per_image, USD_per_GiB_second, USD_per_GB_hour, USD_per_month, USD_per_GB, USD_per_1K_tokens, USD_per_hour, USD_per_node_hour, USD_per_GPU_hour, USD_per_vcpu_second, USD_per_1M_tokens, USD_per_chip_hour, USD_per_vcpu_hour, USD_per_request, USD_per_sandbox_hour |
| `organization_headcount` | Headcount at observation | `{"properties":{"source":{"type":"string"}},"type":"object"}` | — | yes | no | — | organization | entity | count |
| `organization_status` | organization status | `{}` | — | no | no | operating, acquired, merged, dissolved, stealth | organization | entity | — |
| `ownership_stake` | ownership stake | `{}` | — | yes | no | — | owns_stake_in | relationship | percent |
| `package_downloads` | Package downloads for a window | `{"properties":{"registry":{"type":"string"}},"type":"object"}` | — | yes | no | — | library | entity | per_week, per_month, total |
| `paper_citations` | Citation count at observation | `{"properties":{"source":{"type":"string"}},"type":"object"}` | — | yes | no | — | paper | entity | count |
| `product_feature_availability` | product feature availability | `{}` | — | no | no | announced, preview, ga, deprecated, removed | product_feature | entity | — |
| `protocol_feature_support` | protocol feature support | `{}` | — | no | no | full, partial, experimental, removed | implements_protocol | relationship | — |
| `registry_listing_status` | registry listing status | `{}` | — | no | no | listed, delisted, flagged, verified, official, archived | listed_in | relationship | — |
| `relationship_active` | relationship active | `{}` | — | no | no | active, suspended, ended | person, organization, product, product_version, product_feature, ai_model, ai_model_version, model_offering, technique, dataset, benchmark, benchmark_run, repository, library, library_release, mcp_server, agent_skill, ai_protocol, ai_protocol_version, ai_protocol_feature, paper, media_channel, media_series, media_work, event_series, industry_event, talk, story, case_study, concept, funding_round, corporate_transaction, registry, security_advisory, compute_device, compute_offering | relationship | — |
| `repository_archival` | repository archival | `{}` | — | no | no | active, archived | repository | entity | — |
| `repository_forks` | Forks at observation | `{"type":"object"}` | — | yes | no | — | repository | entity | count |
| `repository_location` | repository location | `{"properties":{"host":{"type":"string"},"name":{"type":"string"},"owner":{"type…` | — | no | no | — | repository | entity | — |
| `repository_open_issues` | Open issues at observation | `{"type":"object"}` | — | yes | no | — | repository | entity | count |
| `repository_stars` | GitHub stars at observation | `{"type":"object"}` | — | yes | no | — | repository | entity | count |
| `repository_visibility` | repository visibility | `{}` | — | no | no | public, private | repository | entity | — |
| `valuation` | valuation | `{}` | — | yes | no | — | organization | entity | post_money, pre_money, secondary |
| `work_disposition` | work disposition | `{}` | — | no | no | current, corrected, expression_of_concern, retracted, withdrawn | paper, story, media_work | entity | — |
