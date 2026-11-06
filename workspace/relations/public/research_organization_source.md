---
id: "rel:public.research_organization_source"
kind: table
schema: public
name: research_organization_source
domain: research-starter-protected
aliases: []
tokens: [public, research_organization_source, public.research_organization_source, organization_source_id, organization_candidate_id, source_rank, source_role, authority_tier, title, publisher, url, normalized_url, publicly_retrievable, retrieved_at, source_published_at, supports, verification_status, is_required_core_source, evidence_id]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_organization_source\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_organization_source

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `organization_source_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `organization_candidate_id` | `uuid` | no | — | unique (organization_candidate_id, normalized_url); FK → [`public.research_organization_candidate`](research_organization_candidate.md).organization_candidate_id |
| 3 | `source_rank` | `integer` | no | — | — |
| 4 | `source_role` | `text` | no | — | — |
| 5 | `authority_tier` | `text` | no | — | — |
| 6 | `title` | `text` | no | — | — |
| 7 | `publisher` | `text` | no | — | — |
| 8 | `url` | `text` | no | — | — |
| 9 | `normalized_url` | `text` | no | — | unique (organization_candidate_id, normalized_url) |
| 10 | `publicly_retrievable` | `boolean` | no | — | — |
| 11 | `retrieved_at` | `timestamp with time zone` | no | — | — |
| 12 | `source_published_at` | `timestamp with time zone` | yes | — | — |
| 13 | `supports` | `jsonb` | no | `'[]'::jsonb` | — |
| 14 | `verification_status` | `research_verification_status` | no | — | — |
| 15 | `is_required_core_source` | `boolean` | no | `false` | — |
| 16 | `evidence_id` | `uuid` | yes | — | FK → [`public.research_evidence_anchor`](research_evidence_anchor.md).evidence_id |

## Constraints

- PK (organization_source_id)
- unique (organization_candidate_id, normalized_url)
- check `research_organization_source_authority_check`: `(authority_tier = ANY (ARRAY['first_party'::text, 'official_registry'::text, 'standards_body'::text, 'reputable_secondary'::text]))`
- check `research_organization_source_rank_check`: `(source_rank >= 1)`
- check `research_organization_source_role_check`: `(source_role = ANY (ARRAY['official_homepage'::text, 'official_about'::text, 'official_product'::text, 'official_documentation'::text, 'off…`
- check `research_organization_source_supports_check`: `(jsonb_typeof(supports) = 'array'::text)`

## Relationships

Outbound: `evidence_id` → [`public.research_evidence_anchor`](research_evidence_anchor.md)`.evidence_id`; `organization_candidate_id` → [`public.research_organization_candidate`](research_organization_candidate.md)`.organization_candidate_id` on delete cascade.
Inbound: none.

## Indexes

`research_organization_source_candidate_idx`; `research_organization_source_organization_candidate_id_norm_key` unique

## Triggers

_None._

## Row-level security

Enabled.

## Grants

`service_role`: DELETE, INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["research_organization_source"]["Insert"]`; row: `Database["public"]["Tables"]["research_organization_source"]["Row"]`; update: `Database["public"]["Tables"]["research_organization_source"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
