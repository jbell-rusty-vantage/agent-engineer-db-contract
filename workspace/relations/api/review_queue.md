---
id: "rel:api.review_queue"
kind: view
schema: api
name: review_queue
domain: api-surface
lens: machinery
aliases: []
tokens: [api, review_queue, api.review_queue, id, tenant_id, task_kind, state, priority, assignee, quorum_required, summary, detail, candidate_id, claim_id, claim_conflict_id, entity_merge_id, operation_intent_id, capability_version_id, vector_space_version_id, created_at, updated_at, subject_kind]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"review_queue\"][\"Row\"]"
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.review_queue

view in domain `api-surface`, lens `machinery`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `task_kind` | `text` | yes | — | — |
| 4 | `state` | `evaluation.review_state` | yes | — | — |
| 5 | `priority` | `integer` | yes | — | — |
| 6 | `assignee` | `text` | yes | — | — |
| 7 | `quorum_required` | `integer` | yes | — | — |
| 8 | `summary` | `text` | yes | — | — |
| 9 | `detail` | `jsonb` | yes | — | — |
| 10 | `candidate_id` | `uuid` | yes | — | — |
| 11 | `claim_id` | `uuid` | yes | — | — |
| 12 | `claim_conflict_id` | `uuid` | yes | — | — |
| 13 | `entity_merge_id` | `uuid` | yes | — | — |
| 14 | `operation_intent_id` | `uuid` | yes | — | — |
| 15 | `capability_version_id` | `uuid` | yes | — | — |
| 16 | `vector_space_version_id` | `uuid` | yes | — | — |
| 17 | `created_at` | `timestamp with time zone` | yes | — | — |
| 18 | `updated_at` | `timestamp with time zone` | yes | — | — |
| 19 | `subject_kind` | `text` | yes | — | — |

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
SELECT id,
    tenant_id,
    task_kind,
    state,
    priority,
    assignee,
    quorum_required,
    summary,
    detail,
    candidate_id,
    claim_id,
    claim_conflict_id,
    entity_merge_id,
    operation_intent_id,
    capability_version_id,
    vector_space_version_id,
    created_at,
    updated_at,
    subject_kind
   FROM evaluation.review_task;
```

## TypeScript

row: `Database["api"]["Views"]["review_queue"]["Row"]`

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
