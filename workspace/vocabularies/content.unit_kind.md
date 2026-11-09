---
id: "voc:content.unit_kind"
kind: vocabulary
schema: content
name: unit_kind
rows: 30
rows_sha256: "sha256:07b73b2e82a29a36531f732ca281c37bbd4fc8fce2fa1e2cf105c835cfa07113"
codes: [change_item, code_block, code_example, docs_section, document_root, eval_row, figure, link, list, list_item, media_segment, metadata_field, model_card_section, module_block, paragraph, plan_section, post_paragraph, price_row, quote, readme_section, release_entry, section, slide, spec_field, table, table_row, talk_header, talk_resource, talk_writeup, transcript_segment]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# content.unit_kind

Reference data snapshot (30 rows, digest `sha256:07b73b2e82a29a36531f732ca281c37bbd4fc8fce2fa1e2cf105c835cfa07113`). Codes are enforced wherever a column has a foreign key to [`content.unit_kind`](../relations/content/unit_kind.md).

| code | applicable_document_types | attributes_schema | description | entity_roles | is_universal | logical_key_attributes | parent_kinds | retrieval_role | selector_kind | status | version |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `change_item` | changelog, release_notes, github_release | `{"properties":{"component":{"type":"string"},"kind":{"enum":["added","changed",…` | One change line inside a release entry | software, component, mentions | no | ordinal | release_entry, list | embed | text_quote | active | 1 |
| `code_block` | — | `{"properties":{"language":{"type":"string"},"lines":{"type":"integer"}},"type":…` | Code block with language | demonstrates | yes | — | section, list_item, document_root | embed | character_position | active | 1 |
| `code_example` | framework_docs_page, official_docs_page, repository_readme | `{"properties":{"demonstrates":{"type":"string"},"language":{"type":"string"},"p…` | Code example in docs with language and the API it demonstrates | software, demonstrates | no | path, language | docs_section, section | embed | character_position | active | 1 |
| `docs_section` | framework_docs_page, official_docs_page, api_reference | `{"properties":{"heading":{"type":"string"},"path":{"type":"string"},"version_no…` | Documentation section | software, concept | no | path | document_root, section | embed | text_quote | active | 1 |
| `document_root` | — | `{"type":"object"}` | Root of a representation tree | — | yes | — | — | structure_only | character_position | active | 1 |
| `eval_row` | model_card, system_card, product_page | `{"properties":{"benchmark":{"type":"string"},"comparison_model":{"type":"string…` | One benchmark result row | model, benchmark | no | benchmark, setting, model | model_card_section, table | embed | table | active | 1 |
| `figure` | — | `{"properties":{"caption":{"type":"string"},"src":{"type":"string"}},"type":"obj…` | Figure/image with caption | — | yes | — | section, document_root | embed | bounding_box | active | 1 |
| `link` | — | `{"properties":{"href":{"type":"string"},"text":{"type":"string"}},"required":["…` | Hyperlink with anchor text | references | yes | href | paragraph, list_item, section | filter | text_quote | active | 1 |
| `list` | — | `{"properties":{"items":{"type":"integer"},"ordered":{"type":"boolean"}},"type":…` | Ordered or unordered list | — | yes | — | section, document_root | structure_only | text_quote | active | 1 |
| `list_item` | — | `{"properties":{"ordinal":{"type":"integer"}},"type":"object"}` | List item | mentions | yes | — | list | embed | text_quote | active | 1 |
| `media_segment` | — | `{"properties":{"speaker":{"type":"string"},"t0_ms":{"type":"integer"},"t1_ms":{…` | Timed segment of a transcript | speaker, mentions | yes | t0_ms | document_root, section | embed | media_timecode | active | 1 |
| `metadata_field` | — | `{"properties":{"key":{"type":"string"},"value":{}},"required":["key"],"type":"o…` | Machine-readable field (frontmatter, JSON key, meta tag) | — | yes | key | document_root | filter | json_pointer | active | 1 |
| `model_card_section` | model_card, system_card, product_page | `{"properties":{"heading":{"type":"string"},"section_kind":{"enum":["overview","…` | Named section of a model/system card or model page | model | no | section_kind | document_root, section | embed | text_quote | active | 1 |
| `module_block` | course_module, guide | `{"properties":{"block_key":{"type":"string"},"block_type":{"type":"string"}},"r…` | A block of our own module/lesson/guide revision | covers, uses | no | block_key | document_root, section | embed | character_position | active | 1 |
| `paragraph` | — | `{"properties":{"ordinal_in_section":{"type":"integer"}},"type":"object"}` | Prose paragraph | mentions | yes | — | section, document_root, list_item | embed | text_quote | active | 1 |
| `plan_section` | pricing_page | `{"properties":{"plan":{"type":"string"},"tier":{"type":"string"}},"required":["…` | A pricing plan/model family section | offering | no | plan | document_root, section | embed | text_quote | active | 1 |
| `post_paragraph` | news_article, social_post, thirdparty_blog_post, official_blog_post, analysis_post, newsletter_issue | `{"properties":{"byline":{"type":"string"},"ordinal":{"type":"integer"},"publish…` | A paragraph of a post/article that may carry claims | mentions, quotes | no | ordinal | document_root, section | embed | text_quote | active | 1 |
| `price_row` | pricing_page | `{"properties":{"amount":{"type":"number"},"condition":{"type":"string"},"curren…` | One priced meter for an offering | offering, provider | no | offering, meter, tier, region | plan_section, table | embed | table | active | 1 |
| `quote` | news_article, social_post, thirdparty_blog_post, official_blog_post, analysis_post, newsletter_issue, aie_talk | `{"properties":{"ordinal":{"type":"integer"},"speaker":{"type":"string"}},"type"…` | A quotation attributed to a speaker | speaker | no | ordinal | post_paragraph, paragraph, transcript_segment | embed | text_quote | active | 1 |
| `readme_section` | repository_readme | `{"properties":{"heading":{"type":"string"},"path":{"type":"string"}},"type":"ob…` | README section | software, concept | no | path | document_root, section | embed | text_quote | active | 1 |
| `release_entry` | changelog, release_notes, github_release | `{"properties":{"breaking":{"type":"boolean"},"released_on":{"type":"string"},"t…` | One dated release/version entry | software, release | no | version | document_root, section | embed | text_quote | active | 1 |
| `section` | — | `{"properties":{"heading":{"type":"string"},"level":{"type":"integer"},"path":{"…` | Heading-delimited section | — | yes | path | document_root, section | embed | text_quote | active | 1 |
| `slide` | aie_talk | `{"properties":{"n":{"type":"integer"},"t0_ms":{"type":"integer"},"title":{"type…` | A slide with its start timecode | — | no | n | document_root, section | embed | media_timecode | active | 1 |
| `spec_field` | model_card, system_card, product_page | `{"properties":{"field":{"type":"string"},"unit":{"type":"string"},"value":{}},"…` | A specification field of a model page (context window, cutoff, modalities, pricing) | model | no | field | model_card_section, metadata_field, table | embed | text_quote | active | 1 |
| `table` | — | `{"properties":{"caption":{"type":"string"},"header":{"items":{"type":"string"},…` | Table with header signature | — | yes | header | section, document_root | structure_only | table | active | 1 |
| `table_row` | — | `{"properties":{"cells":{"items":{"type":"string"},"type":"array"},"row_key":{"t…` | Table row keyed by its first cell | subject | yes | row_key | table | embed | table | active | 1 |
| `talk_header` | aie_talk | `{"properties":{"event":{"type":"string"},"session_id":{"type":"string"},"speake…` | Talk title, speakers, track and event fields from the page/sessions record | speaker, event | no | session_id | document_root | filter | json_pointer | active | 1 |
| `talk_resource` | aie_talk | `{"properties":{"href":{"type":"string"},"resource_kind":{"enum":["repository","…` | A resource link listed on a talk page (repository, paper, docs) | references | no | href | document_root, section, list | filter | text_quote | active | 1 |
| `talk_writeup` | aie_talk | `{"properties":{"heading":{"type":"string"},"path":{"type":"string"}},"type":"ob…` | Organizer/AI write-up section of a talk page: claim candidates, never facts | mentions | no | path | document_root, section | embed | text_quote | active | 1 |
| `transcript_segment` | aie_talk, video_transcript, podcast_transcript | `{"properties":{"slide_n":{"type":"integer"},"speaker":{"type":"string"},"t0_ms"…` | Timestamped transcript window (no speaker labels on ai.engineer pages) | speaker, mentions | no | t0_ms | document_root, section | embed | media_timecode | active | 1 |
