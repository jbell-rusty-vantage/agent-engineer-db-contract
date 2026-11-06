---
id: "voc:temporal.stream_kind"
kind: vocabulary
schema: temporal
name: stream_kind
rows: 20
rows_sha256: "sha256:226f95a38f839862a4e19948e2177451355260c8b807f3751c4fbce1319fcab5"
codes: [compute_offering_price, engagement_role, entity_name, library_license, library_maintenance, model_offering_availability, model_offering_limit, model_offering_price, model_version_spec, organization_status, ownership_stake, product_feature_availability, protocol_feature_support, registry_listing_status, relationship_active, repository_archival, repository_location, repository_visibility, valuation, work_disposition]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.stream_kind

Reference data snapshot (20 rows, digest `sha256:226f95a38f839862a4e19948e2177451355260c8b807f3751c4fbce1319fcab5`). Codes are enforced wherever a column has a foreign key to [`temporal.stream_kind`](../relations/temporal/stream_kind.md).

| code | description | payload_schema | ref_entity_kinds | requires_amount | requires_ref_entity | status_values | subject_kinds | subject_mode | unit_values |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `compute_offering_price` | compute offering price | `{}` | — | yes | no | — | compute_offering | entity | per_hour, per_month, spot_per_hour |
| `engagement_role` | engagement role | `{"properties":{"title":{"type":"string"}},"required":["title"],"type":"object"}` | — | no | no | — | employed_by | relationship | — |
| `entity_name` | entity name | `{"properties":{"display_name":{"type":"string"},"legal_name":{"type":"string"}}…` | — | no | no | — | person, organization, product, product_version, product_feature, ai_model, ai_model_version, model_offering, technique, dataset, benchmark, benchmark_run, repository, library, library_release, mcp_server, agent_skill, ai_protocol, ai_protocol_version, ai_protocol_feature, paper, media_channel, media_series, media_work, event_series, industry_event, talk, story, case_study, concept, funding_round, corporate_transaction, registry, security_advisory, compute_device, compute_offering | entity | — |
| `library_license` | library license | `{"properties":{"license_code":{"type":"string"}},"required":["license_code"],"t…` | — | no | no | — | library, library_release | entity | — |
| `library_maintenance` | library maintenance | `{}` | — | no | no | active, maintenance_only, deprecated, abandoned | library | entity | — |
| `model_offering_availability` | model offering availability | `{}` | — | no | no | announced, preview, ga, deprecated, retired | model_offering | entity | — |
| `model_offering_limit` | model offering limit | `{}` | — | yes | no | — | model_offering | entity | context_tokens, max_output_tokens, rpm, tpm, batch_size |
| `model_offering_price` | model offering price | `{}` | — | yes | no | — | model_offering | entity | per_1m_input_tokens, per_1m_output_tokens, per_1m_cached_input_tokens, per_hour, per_seat_month, per_request, per_image, per_minute_audio |
| `model_version_spec` | model version spec | `{}` | — | no | no | — | ai_model_version | entity | — |
| `organization_status` | organization status | `{}` | — | no | no | operating, acquired, merged, dissolved, stealth | organization | entity | — |
| `ownership_stake` | ownership stake | `{}` | — | yes | no | — | owns_stake_in | relationship | percent |
| `product_feature_availability` | product feature availability | `{}` | — | no | no | announced, preview, ga, deprecated, removed | product_feature | entity | — |
| `protocol_feature_support` | protocol feature support | `{}` | — | no | no | full, partial, experimental, removed | implements_protocol | relationship | — |
| `registry_listing_status` | registry listing status | `{}` | — | no | no | listed, delisted, flagged, verified, official, archived | listed_in | relationship | — |
| `relationship_active` | relationship active | `{}` | — | no | no | active, suspended, ended | person, organization, product, product_version, product_feature, ai_model, ai_model_version, model_offering, technique, dataset, benchmark, benchmark_run, repository, library, library_release, mcp_server, agent_skill, ai_protocol, ai_protocol_version, ai_protocol_feature, paper, media_channel, media_series, media_work, event_series, industry_event, talk, story, case_study, concept, funding_round, corporate_transaction, registry, security_advisory, compute_device, compute_offering | relationship | — |
| `repository_archival` | repository archival | `{}` | — | no | no | active, archived | repository | entity | — |
| `repository_location` | repository location | `{"properties":{"host":{"type":"string"},"name":{"type":"string"},"owner":{"type…` | — | no | no | — | repository | entity | — |
| `repository_visibility` | repository visibility | `{}` | — | no | no | public, private | repository | entity | — |
| `valuation` | valuation | `{}` | — | yes | no | — | organization | entity | post_money, pre_money, secondary |
| `work_disposition` | work disposition | `{}` | — | no | no | current, corrected, expression_of_concern, retracted, withdrawn | paper, story, media_work | entity | — |
