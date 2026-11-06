---
id: "rel:evaluation.verification_benchmark_comparison"
kind: table
schema: evaluation
name: verification_benchmark_comparison
domain: evaluation
aliases: []
tokens: [evaluation, verification_benchmark_comparison, evaluation.verification_benchmark_comparison, id, tenant_id, operation_id, baseline_run_id, candidate_run_id, baseline_publication_artifact_id, baseline_publication_sha256, baseline_payload_sha256, candidate_publication_artifact_id, candidate_publication_sha256, candidate_payload_sha256, profile_id, profile_artifact_id, profile_sha256, runtime, runtime_sha256, status, started_at, completed_at, result_artifact_id, result_sha256, result_digest_sha256, engineering_gate_outcome, publication_artifact_id, publication_sha256, publication_payload_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"verification_benchmark_comparison\"][\"Row\"]"
defined_in: ["20260906030500_verification_benchmark_comparison_lifecycle.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.verification_benchmark_comparison

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, operation_id) |
| 3 | `operation_id` | `uuid` | no | — | unique (tenant_id, operation_id) |
| 4 | `baseline_run_id` | `uuid` | no | — | — |
| 5 | `candidate_run_id` | `uuid` | no | — | — |
| 6 | `baseline_publication_artifact_id` | `uuid` | no | — | — |
| 7 | `baseline_publication_sha256` | `text` | no | — | — |
| 8 | `baseline_payload_sha256` | `text` | no | — | — |
| 9 | `candidate_publication_artifact_id` | `uuid` | no | — | — |
| 10 | `candidate_publication_sha256` | `text` | no | — | — |
| 11 | `candidate_payload_sha256` | `text` | no | — | — |
| 12 | `profile_id` | `text` | no | — | — |
| 13 | `profile_artifact_id` | `uuid` | no | — | — |
| 14 | `profile_sha256` | `text` | no | — | — |
| 15 | `runtime` | `jsonb` | no | — | — |
| 16 | `runtime_sha256` | `text` | no | — | — |
| 17 | `status` | `text` | no | `'running'::text` | — |
| 18 | `started_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |
| 19 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 20 | `result_artifact_id` | `uuid` | yes | — | — |
| 21 | `result_sha256` | `text` | yes | — | — |
| 22 | `result_digest_sha256` | `text` | yes | — | — |
| 23 | `engineering_gate_outcome` | `text` | yes | — | — |
| 24 | `publication_artifact_id` | `uuid` | yes | — | — |
| 25 | `publication_sha256` | `text` | yes | — | — |
| 26 | `publication_payload_sha256` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, operation_id)
- 18 check constraints; see [details](verification_benchmark_comparison.details.md)

## Relationships

8 outbound and 0 inbound foreign keys; full list in [details](verification_benchmark_comparison.details.md).

## Indexes

2 indexes; see [details](verification_benchmark_comparison.details.md).

## Triggers

10 triggers; see [details](verification_benchmark_comparison.details.md).

## Row-level security

Enabled; 1 policies in [details](verification_benchmark_comparison.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["verification_benchmark_comparison"]["Insert"]`; row: `Database["evaluation"]["Tables"]["verification_benchmark_comparison"]["Row"]`; update: `Database["evaluation"]["Tables"]["verification_benchmark_comparison"]["Update"]`

Defined in: `20260906030500_verification_benchmark_comparison_lifecycle.sql`.
