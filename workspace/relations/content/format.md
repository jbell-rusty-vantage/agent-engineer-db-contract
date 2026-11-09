---
id: "rel:content.format"
kind: table
schema: content
name: format
domain: content
lens: corpus
aliases: [format axis, media format]
tokens: [content, format, content.format, code, description, default_locator_kinds]
summary: Media/format axis of a captured version; decides the parser and the locator kinds.
summary_basis: curated
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"content\"][\"Tables\"][\"format\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# content.format

table in domain `content`, lens `corpus` — Media/format axis of a captured version: decides the parser and the locator kinds (page+bbox, timecode, table cell, JSON pointer, line range)..

> curated (model_assisted, unreviewed) — Media/format axis of a captured version; decides the parser and the locator kinds.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |
| 3 | `default_locator_kinds` | `text[]` | no | `'{}'::text[]` | _curated:_ Locator selector kinds this format supports (page+bbox, timecode, table cell, JSON pointer, line range). |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`content.document_version`](document_version.md).format_code, [`content.structure_census`](structure_census.md).format_code.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["content"]["Tables"]["format"]["Insert"]`; row: `Database["content"]["Tables"]["format"]["Row"]`; update: `Database["content"]["Tables"]["format"]["Update"]`

## Examples

Units carry the format's locator kind

```bash
knowledge db query vocab.unit_kind --param code=transcript_segment --param document_type=null
```
timed_text formats yield media_timecode locators.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
