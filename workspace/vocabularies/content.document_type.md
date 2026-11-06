---
id: "voc:content.document_type"
kind: vocabulary
schema: content
name: document_type
rows: 54
rows_sha256: "sha256:06f4463e3e99b176322f83e6be7a4dc9e0c84b023569571ed336b8f44c188b44"
codes: [agent_skill_manifest, analysis_post, api_reference, arxiv_paper, changelog, conference_paper, dataset_card, document_summary, earnings_call_transcript, earnings_release, entity_profile, forum_thread, funding_announcement, interview, investor_letter, job_posting, journal_article, livestream_transcript, market_report, mcp_server_manifest, model_card, model_hub_page, news_article, newsletter_issue, notebook, official_blog_post, official_docs_page, package_manifest, package_version_page, patent, podcast_transcript, press_release, pricing_page, product_page, registry_listing_page, release_notes, repository_file, repository_readme, research_report, sec_10k, sec_10q, sec_8k, sec_form_d, sec_s1, security_advisory_page, social_post, status_incident, system_card, tech_report, terms_of_service, thirdparty_blog_post, timeline_digest, video_transcript, webinar_transcript]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_type

Reference data snapshot (54 rows, digest `sha256:06f4463e3e99b176322f83e6be7a4dc9e0c84b023569571ed336b8f44c188b44`). Codes are enforced wherever a column has a foreign key to [`content.document_type`](../relations/content/document_type.md).

| code | default_chunking_slug | default_extraction_kinds | default_spaces | default_summary_kinds | description | family | is_primary_source | published_at_is_world_time | work_entity_kind |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `agent_skill_manifest` | structural_heading | claim, entity, relationship | source_native_sections, implementation_examples, tool_capabilities | abstract, technical | agent skill manifest | code | yes | yes | — |
| `analysis_post` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | analysis post | editorial | no | yes | story |
| `api_reference` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | api reference | vendor | yes | yes | — |
| `arxiv_paper` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | arxiv paper | research | yes | yes | paper |
| `changelog` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | changelog | vendor | yes | yes | — |
| `conference_paper` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | conference paper | research | yes | yes | paper |
| `dataset_card` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | dataset card | research | yes | yes | — |
| `document_summary` | structural_heading | claim, entity, relationship | source_native_sections, document_summaries | abstract, technical | document summary | system_generated | no | yes | — |
| `earnings_call_transcript` | transcript_window | claim, entity, relationship | source_native_sections, engineering_claims | abstract, timeline, entity_centric | earnings call transcript | media_transcript | yes | yes | media_work |
| `earnings_release` | structural_heading | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | earnings release | market | yes | yes | — |
| `entity_profile` | structural_heading | claim, entity, relationship | source_native_sections, entity_profiles | abstract, technical | entity profile | system_generated | no | yes | — |
| `forum_thread` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | forum thread | editorial | no | yes | story |
| `funding_announcement` | structural_heading | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | funding announcement | market | yes | yes | — |
| `interview` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | interview | editorial | no | yes | story |
| `investor_letter` | structural_heading | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | investor letter | market | yes | yes | — |
| `job_posting` | structural_heading | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | job posting | market | yes | yes | — |
| `journal_article` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | journal article | research | yes | yes | paper |
| `livestream_transcript` | transcript_window | claim, entity, relationship | source_native_sections, engineering_claims | abstract, timeline, entity_centric | livestream transcript | media_transcript | yes | yes | media_work |
| `market_report` | structural_heading | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | market report | market | yes | yes | — |
| `mcp_server_manifest` | structural_heading | claim, entity, relationship | source_native_sections, implementation_examples, tool_capabilities | abstract, technical | mcp server manifest | code | yes | yes | — |
| `model_card` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | model card | research | yes | yes | — |
| `model_hub_page` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | model hub page | registry | yes | yes | — |
| `news_article` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | news article | editorial | no | yes | story |
| `newsletter_issue` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | newsletter issue | editorial | no | yes | story |
| `notebook` | structural_heading | claim, entity, relationship | source_native_sections, implementation_examples, tool_capabilities | abstract, technical | notebook | code | yes | yes | — |
| `official_blog_post` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | official blog post | vendor | yes | yes | — |
| `official_docs_page` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | official docs page | vendor | yes | yes | — |
| `package_manifest` | structural_heading | claim, entity, relationship | source_native_sections, implementation_examples, tool_capabilities | abstract, technical | package manifest | code | yes | yes | — |
| `package_version_page` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | package version page | registry | yes | yes | — |
| `patent` | semantic_boundary | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | patent | regulatory_filing | yes | yes | — |
| `podcast_transcript` | transcript_window | claim, entity, relationship | source_native_sections, engineering_claims | abstract, timeline, entity_centric | podcast transcript | media_transcript | yes | yes | media_work |
| `press_release` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | press release | vendor | yes | yes | — |
| `pricing_page` | table_row | claim, entity, relationship | source_native_sections, market_intelligence | abstract, technical | pricing page | vendor | yes | yes | — |
| `product_page` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | product page | vendor | yes | yes | — |
| `registry_listing_page` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | registry listing page | registry | yes | yes | — |
| `release_notes` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | release notes | vendor | yes | yes | — |
| `repository_file` | code_symbol | claim, entity, relationship | source_native_sections, implementation_examples, tool_capabilities | abstract, technical | repository file | code | yes | yes | — |
| `repository_readme` | structural_heading | claim, entity, relationship | source_native_sections, implementation_examples, tool_capabilities | abstract, technical | repository readme | code | yes | yes | — |
| `research_report` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | research report | system_generated | no | yes | — |
| `sec_10k` | semantic_boundary | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | sec 10k | regulatory_filing | yes | yes | — |
| `sec_10q` | semantic_boundary | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | sec 10q | regulatory_filing | yes | yes | — |
| `sec_8k` | semantic_boundary | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | sec 8k | regulatory_filing | yes | yes | — |
| `sec_form_d` | semantic_boundary | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | sec form d | regulatory_filing | yes | yes | — |
| `sec_s1` | semantic_boundary | claim, entity, relationship | source_native_sections, market_intelligence | executive, investor_brief, timeline | sec s1 | regulatory_filing | yes | yes | — |
| `security_advisory_page` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | security advisory page | vendor | yes | yes | security_advisory |
| `social_post` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | social post | editorial | no | yes | story |
| `status_incident` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | status incident | vendor | yes | yes | — |
| `system_card` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | system card | research | yes | yes | — |
| `tech_report` | semantic_boundary | claim, entity, relationship | source_native_sections, paper_case_study_knowledge | abstract, key_claims | tech report | research | yes | yes | paper |
| `terms_of_service` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | terms of service | vendor | yes | yes | — |
| `thirdparty_blog_post` | structural_heading | claim, entity, relationship | source_native_sections, engineering_claims | abstract, technical | thirdparty blog post | editorial | no | yes | story |
| `timeline_digest` | structural_heading | claim, entity, relationship | source_native_sections, entity_timeline | abstract, technical | timeline digest | system_generated | no | yes | — |
| `video_transcript` | transcript_window | claim, entity, relationship | source_native_sections, engineering_claims | abstract, timeline, entity_centric | video transcript | media_transcript | yes | yes | media_work |
| `webinar_transcript` | transcript_window | claim, entity, relationship | source_native_sections, engineering_claims | abstract, timeline, entity_centric | webinar transcript | media_transcript | yes | yes | media_work |
