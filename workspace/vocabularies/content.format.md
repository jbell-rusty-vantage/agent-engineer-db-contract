---
id: "voc:content.format"
kind: vocabulary
schema: content
name: format
rows: 14
rows_sha256: "sha256:6ac5f27f154c0f92d4412bcfc864356a4dde1ed6177b18709917f184ca7e8551"
codes: [archive, audio, code, html, image, json, markdown, pdf, slides, tabular, text, timed_text, unknown, video]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# content.format

Reference data snapshot (14 rows, digest `sha256:6ac5f27f154c0f92d4412bcfc864356a4dde1ed6177b18709917f184ca7e8551`). Codes are enforced wherever a column has a foreign key to [`content.format`](../relations/content/format.md).

| code | default_locator_kinds | description |
| --- | --- | --- |
| `archive` | repository | Archive/bundle |
| `audio` | media_timecode | Audio |
| `code` | repository, character_position | Source code or notebook |
| `html` | text_quote, html, table | HTML page |
| `image` | bounding_box, media_region | Image/diagram/screenshot |
| `json` | json_pointer, api_record | Machine-structured JSON or API record |
| `markdown` | text_quote, character_position | Markdown text (including rendered .md of a talk page) |
| `pdf` | pdf_text, bounding_box, table | PDF document |
| `slides` | bounding_box, pdf_text | Slide deck |
| `tabular` | table, dataset | CSV/Parquet/spreadsheet |
| `text` | text_quote, character_position | Plain text |
| `timed_text` | media_timecode, text_quote | Timestamped transcript/captions |
| `unknown` | — | Not yet determined |
| `video` | media_timecode, media_region | Video file or page |
