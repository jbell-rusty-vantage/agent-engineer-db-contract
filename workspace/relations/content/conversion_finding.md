---
id: "rel:content.conversion_finding"
kind: table
schema: content
name: conversion_finding
domain: content
aliases: []
tokens: [content, conversion_finding, content.conversion_finding, id, tenant_id, conversion_evaluation_id, severity, finding_kind, node_id, locator_id, observed_defect, expected_behavior, evidence_artifact_id, recommended_action, resolution, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"conversion_finding\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.conversion_finding

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `conversion_evaluation_id` | `uuid` | no | — | — |
| 4 | `severity` | `text` | no | — | — |
| 5 | `finding_kind` | `text` | no | — | — |
| 6 | `node_id` | `uuid` | yes | — | — |
| 7 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id |
| 8 | `observed_defect` | `text` | no | — | — |
| 9 | `expected_behavior` | `text` | yes | — | — |
| 10 | `evidence_artifact_id` | `uuid` | yes | — | — |
| 11 | `recommended_action` | `text` | yes | — | — |
| 12 | `resolution` | `text` | yes | — | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `conversion_finding_severity_check`: `(severity = ANY (ARRAY['info'::text, 'warning'::text, 'error'::text, 'critical'::text]))`

## Relationships

Outbound: `locator_id` → [`evidence.locator`](../evidence/locator.md)`.id` on delete restrict; `tenant_id,conversion_evaluation_id` → [`content.conversion_evaluation`](conversion_evaluation.md)`.tenant_id,id` on delete restrict; `tenant_id,evidence_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,node_id` → [`content.document_node`](document_node.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_541baa9bc65822984734c2da` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `conversion_finding_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["conversion_finding"]["Insert"]`; row: `Database["content"]["Tables"]["conversion_finding"]["Row"]`; update: `Database["content"]["Tables"]["conversion_finding"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
