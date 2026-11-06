---
id: "rel:content.conversion_evaluation"
kind: table
schema: content
name: conversion_evaluation
domain: content
aliases: []
tokens: [content, conversion_evaluation, content.conversion_evaluation, id, tenant_id, representation_id, evaluator_identity, procedure_version, conversion_grade, coverage, locator_coverage, report_artifact_id, findings_sha256, disposition, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"conversion_evaluation\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.conversion_evaluation

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `representation_id` | `uuid` | no | — | — |
| 4 | `evaluator_identity` | `text` | no | — | — |
| 5 | `procedure_version` | `text` | no | — | — |
| 6 | `conversion_grade` | `text` | no | — | — |
| 7 | `coverage` | `numeric(6,5)` | yes | — | — |
| 8 | `locator_coverage` | `numeric(6,5)` | yes | — | — |
| 9 | `report_artifact_id` | `uuid` | yes | — | — |
| 10 | `findings_sha256` | `text` | no | — | — |
| 11 | `disposition` | `text` | no | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `conversion_evaluation_coverage_check`: `((coverage >= (0)::numeric) AND (coverage <= (1)::numeric))`
- check `conversion_evaluation_disposition_check`: `(disposition = ANY (ARRAY['accept'::text, 'reject'::text, 'quarantine'::text, 'defer'::text]))`
- check `conversion_evaluation_findings_sha256_check`: `(findings_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `conversion_evaluation_locator_coverage_check`: `((locator_coverage >= (0)::numeric) AND (locator_coverage <= (1)::numeric))`

## Relationships

Outbound: `tenant_id,report_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.conversion_finding`](conversion_finding.md).conversion_evaluation_id, [`content.representation_decision`](representation_decision.md).conversion_evaluation_id.

## Indexes

`conversion_evaluation_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_2c2b7f904535d54449b7edf2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `conversion_evaluation_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["content"]["Tables"]["conversion_evaluation"]["Insert"]`; row: `Database["content"]["Tables"]["conversion_evaluation"]["Row"]`; update: `Database["content"]["Tables"]["conversion_evaluation"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
