---
id: "rel:api.agent_skills"
kind: view
schema: api
name: agent_skills
domain: api-surface
lens: corpus
aliases: []
tokens: [api, agent_skills, api.agent_skills, software_id, kind, software, slug, ecosystem, package_name, category, docs_url, repository_url, developers, maintainers, latest_release, latest_release_on, license, stars, downloads, mcp_hosting, mcp_auth, mcp_is_official, protocols, concepts, summary]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"agent_skills\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.agent_skills

view in domain `api-surface`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `software_id` | `uuid` | yes | — | — |
| 2 | `kind` | `text` | yes | — | — |
| 3 | `software` | `text` | yes | — | — |
| 4 | `slug` | `text` | yes | — | — |
| 5 | `ecosystem` | `text` | yes | — | — |
| 6 | `package_name` | `text` | yes | — | — |
| 7 | `category` | `text` | yes | — | — |
| 8 | `docs_url` | `text` | yes | — | — |
| 9 | `repository_url` | `text` | yes | — | — |
| 10 | `developers` | `text[]` | yes | — | — |
| 11 | `maintainers` | `text[]` | yes | — | — |
| 12 | `latest_release` | `text` | yes | — | — |
| 13 | `latest_release_on` | `date` | yes | — | — |
| 14 | `license` | `text` | yes | — | — |
| 15 | `stars` | `numeric` | yes | — | — |
| 16 | `downloads` | `numeric` | yes | — | — |
| 17 | `mcp_hosting` | `text` | yes | — | — |
| 18 | `mcp_auth` | `text` | yes | — | — |
| 19 | `mcp_is_official` | `boolean` | yes | — | — |
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

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

```sql
SELECT software_id,
    kind,
    software,
    slug,
    ecosystem,
    package_name,
    category,
    docs_url,
    repository_url,
    developers,
    maintainers,
    latest_release,
    latest_release_on,
    license,
    stars,
    downloads,
    mcp_hosting,
    mcp_auth,
    mcp_is_official,
    protocols,
    concepts,
    summary
   FROM api.software
  WHERE kind = 'agent_skill'::text;
```

## TypeScript

row: `Database["api"]["Views"]["agent_skills"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
