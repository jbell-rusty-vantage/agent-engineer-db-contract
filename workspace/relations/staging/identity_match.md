---
id: "rel:staging.identity_match"
kind: table
schema: staging
name: identity_match
domain: staging
aliases: [match]
tokens: [staging, identity_match, staging.identity_match, id, tenant_id, candidate_id, entity_id, confidence, method]
summary: Scored match between a candidate and an existing entity.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"staging\"][\"Tables\"][\"identity_match\"][\"Row\"]"
defined_in: ["20260826000700_staging.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# staging.identity_match

table in domain `staging`.

> curated (model_assisted, unreviewed) — Scored match between a candidate and an existing entity.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `candidate_id` | `uuid` | no | — | FK → [`staging.candidate`](candidate.md).id |
| 4 | `entity_id` | `uuid` | no | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 5 | `confidence` | `numeric` | no | — | _curated:_ 0..1. |
| 6 | `method` | `text` | no | — | _curated:_ How the match was produced. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `identity_match_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`

## Relationships

Outbound: `candidate_id` → [`staging.candidate`](candidate.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: none.

## Indexes

`identity_match_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["staging"]["Tables"]["identity_match"]["Insert"]`; row: `Database["staging"]["Tables"]["identity_match"]["Row"]`; update: `Database["staging"]["Tables"]["identity_match"]["Update"]`

## Examples

Candidates of one kind

```bash
knowledge db query staging.candidates_for_kind --param limit=50 --param proposed_kind=organization
```
Inspect identity_match rows for those candidate ids next.

Defined in: `20260826000700_staging.sql`, `20260912010900_km_09_ranking_staging.sql`.
