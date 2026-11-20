---
id: "rel:api.software"
kind: view
schema: api
name: software
domain: api-surface
lens: corpus
aliases: [software table, libraries, mcp servers, repositories, agent skills]
tokens: [api, software, api.software, software_id, kind, software, slug, ecosystem, package_name, category, docs_url, repository_url, developers, maintainers, latest_release, latest_release_on, license, stars, downloads, mcp_hosting, mcp_auth, mcp_is_official, protocols, concepts, summary]
summary: "L1 — libraries, repositories, MCP servers, agent skills, products and protocols in one table with ecosystem, links, developers, latest release, license, stars, downloads and MCP flags."
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"software\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.software

view in domain `api-surface`, lens `corpus` — L1: libraries, repositories, MCP servers, agent skills, products and protocols in one table with ecosystem, docs/repo links, developers, latest release, license, stars/downloads, MCP hosting/auth/official flags, protocols and concepts..

> curated (model_assisted, unreviewed) — L1 — libraries, repositories, MCP servers, agent skills, products and protocols in one table with ecosystem, links, developers, latest release, license, stars, downloads and MCP flags.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `software_id` | `uuid` | yes | — | — |
| 2 | `kind` | `text` | yes | — | _curated:_ library, repository, mcp_server, agent_skill, product or ai_protocol; api.libraries / api.repositories / api.mcp_servers / api.agent_skills are kind slices. |
| 3 | `software` | `text` | yes | — | — |
| 4 | `slug` | `text` | yes | — | — |
| 5 | `ecosystem` | `text` | yes | — | — |
| 6 | `package_name` | `text` | yes | — | — |
| 7 | `category` | `text` | yes | — | — |
| 8 | `docs_url` | `text` | yes | — | — |
| 9 | `repository_url` | `text` | yes | — | — |
| 10 | `developers` | `text[]` | yes | — | — |
| 11 | `maintainers` | `text[]` | yes | — | — |
| 12 | `latest_release` | `text` | yes | — | _curated:_ Newest library_release entity (api.software_releases has them all). |
| 13 | `latest_release_on` | `date` | yes | — | — |
| 14 | `license` | `text` | yes | — | — |
| 15 | `stars` | `numeric` | yes | — | — |
| 16 | `downloads` | `numeric` | yes | — | — |
| 17 | `mcp_hosting` | `text` | yes | — | — |
| 18 | `mcp_auth` | `text` | yes | — | — |
| 19 | `mcp_is_official` | `boolean` | yes | — | _curated:_ For MCP servers: published by the protocol or vendor owner. |
| 20 | `protocols` | `text[]` | yes | — | — |
| 21 | `concepts` | `text[]` | yes | — | — |
| 22 | `summary` | `text` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Named queries: `q:catalog.software`.
- Exposed through: [`api.agent_skills`](agent_skills.md), [`api.libraries`](libraries.md), [`api.mcp_servers`](mcp_servers.md), [`api.repositories`](repositories.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](software.details.md).

## TypeScript

row: `Database["api"]["Views"]["software"]["Row"]`

## Examples

MCP servers

```bash
knowledge db query catalog.software --param kind=mcp_server --param limit=50 --param text=null
```
Stars desc.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
