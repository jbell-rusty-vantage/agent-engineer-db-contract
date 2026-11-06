---
id: "rel:public.research_evidence_anchor"
kind: table
schema: public
name: research_evidence_anchor
domain: research-starter-protected
aliases: []
tokens: [public, research_evidence_anchor, public.research_evidence_anchor, evidence_id, analysis_id, source_kind, source_url, transcript_segment, start_seconds, end_seconds, start_character, end_character, short_excerpt, supports]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_evidence_anchor\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_evidence_anchor

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `evidence_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `analysis_id` | `uuid` | no | — | FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 3 | `source_kind` | `research_evidence_source_kind` | no | — | — |
| 4 | `source_url` | `text` | yes | — | — |
| 5 | `transcript_segment` | `text` | yes | — | — |
| 6 | `start_seconds` | `numeric` | yes | — | — |
| 7 | `end_seconds` | `numeric` | yes | — | — |
| 8 | `start_character` | `integer` | yes | — | — |
| 9 | `end_character` | `integer` | yes | — | — |
| 10 | `short_excerpt` | `text` | no | — | — |
| 11 | `supports` | `text` | no | — | — |

## Constraints

- PK (evidence_id)
- check `research_evidence_anchor_characters_check`: `((start_character IS NULL) OR (end_character IS NULL) OR (end_character >= start_character))`
- check `research_evidence_anchor_seconds_check`: `((start_seconds IS NULL) OR (end_seconds IS NULL) OR (end_seconds >= start_seconds))`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade.
Inbound: [`public.research_organization_source`](research_organization_source.md).evidence_id.

## Indexes

`research_evidence_anchor_analysis_idx`

## Triggers

_None._

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["research_evidence_anchor"]["Insert"]`; row: `Database["public"]["Tables"]["research_evidence_anchor"]["Row"]`; update: `Database["public"]["Tables"]["research_evidence_anchor"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
