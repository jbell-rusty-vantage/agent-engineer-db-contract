---
id: "rel:content.structure_census"
kind: table
schema: content
name: structure_census
domain: content
lens: corpus
aliases: [census]
tokens: [content, structure_census, content.structure_census, id, tenant_id, representation_id, census_version, format_code, counts, signatures, language, digest, created_at]
summary: What a representation structurally contains before a kind or grammar is assigned; promotion candidates come from census statistics.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"structure_census\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# content.structure_census

table in domain `content`, lens `corpus` — What a captured representation structurally contains (headings, tables, lists, code, timecodes, speakers, figures, machine blocks) before a kind or grammar is assigned. Promotion candidates come from census statistics..

> curated (model_assisted, unreviewed) — What a representation structurally contains before a kind or grammar is assigned; promotion candidates come from census statistics.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, representation_id, census_version) |
| 3 | `representation_id` | `uuid` | no | — | unique (tenant_id, representation_id, census_version) |
| 4 | `census_version` | `text` | no | — | unique (tenant_id, representation_id, census_version) |
| 5 | `format_code` | `text` | no | — | FK → [`content.format`](format.md).code |
| 6 | `counts` | `jsonb` | no | — | _curated:_ Headings, tables, lists, code blocks, timecodes, speakers, figures, machine blocks. |
| 7 | `signatures` | `jsonb` | no | `'{}'::jsonb` | _curated:_ Structural fingerprints used to cluster unclassified documents into candidate kinds. |
| 8 | `language` | `text` | yes | — | — |
| 9 | `digest` | `text` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, representation_id, census_version)
- check `structure_census_counts_shape`: `jsonb_matches_schema('{"type":"object","properties":{"headings":{"type":"integer"},"heading_depth":{"type":"integer"},"paragraphs":{"type":…`
- check `structure_census_digest_check`: `(digest ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `format_code` → [`content.format`](format.md)`.code`; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`structure_census_tenant_id_representation_id_census_version_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["structure_census"]["Insert"]`; row: `Database["content"]["Tables"]["structure_census"]["Row"]`; update: `Database["content"]["Tables"]["structure_census"]["Update"]`

## Examples

Candidate kinds come from census

```bash
knowledge db query vocab.unit_kind --param code=null --param document_type=null
```
content.document_type.status candidate marks kinds whose grammar is not settled.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
