---
id: "rel:content.source_role"
kind: table
schema: content
name: source_role
domain: content
lens: corpus
aliases: [who speaks, source role]
tokens: [content, source_role, content.source_role, code, description, authority_rank, default_source_tier]
summary: "Who speaks — first party about itself, filer, academic, registry, third-party editorial, community, own, system; feeds authority and the default source tier."
summary_basis: curated
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"content\"][\"Tables\"][\"source_role\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# content.source_role

table in domain `content`, lens `corpus` — Who speaks: first party about itself, filer, academic, registry, third-party editorial, community, our own content, system. Feeds attribution/authority and the source tier..

> curated (model_assisted, unreviewed) — Who speaks — first party about itself, filer, academic, registry, third-party editorial, community, own, system; feeds authority and the default source tier.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |
| 3 | `authority_rank` | `smallint` | no | — | _curated:_ Ordering for attribution/authority. |
| 4 | `default_source_tier` | `smallint` | no | — | _curated:_ Seeds retrieval.vector_item.source_tier (first_party → 2, own → 1, third_party_editorial → 3). |

## Constraints

- PK (code)
- check `source_role_default_source_tier_check`: `((default_source_tier >= 0) AND (default_source_tier <= 4))`

## Relationships

Outbound: none.
Inbound: [`content.document`](document.md).source_role_code, [`content.unit_assertion_mapping`](unit_assertion_mapping.md).source_role_code, [`evidence.source_assessment`](../evidence/source_assessment.md).source_role_code, [`retrieval.vector_item`](../retrieval/vector_item.md).source_role_code.

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

insert: `Database["content"]["Tables"]["source_role"]["Insert"]`; row: `Database["content"]["Tables"]["source_role"]["Row"]`; update: `Database["content"]["Tables"]["source_role"]["Update"]`

## Examples

Restrict search to first-party sources

```bash
knowledge db query retrieval.search_unified --param lenses=["corpus"] --param limit=20 --param query=pricing --param source_roles=["first_party"]
```
source_roles is a facet of api.search_unified.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
