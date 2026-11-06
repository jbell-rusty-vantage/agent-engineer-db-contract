---
id: "rel:orchestration.verification_semantic_response_observation"
kind: table
schema: orchestration
name: verification_semantic_response_observation
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_semantic_response_observation, orchestration.verification_semantic_response_observation, tenant_id, producer_attempt_id, provider_attempt_id, operation_id, operation_step_id, profile_artifact_id, profile_sha256, dispatch_fencing_token, blinded_input_artifact_id, blinded_input_sha256, request_artifact_id, request_sha256, raw_response_artifact_id, raw_response_sha256, response_envelope_artifact_id, response_envelope_sha256, observation_artifact_id, observation_sha256, requested_model, observed_model, model_status, revalidation_required, prompt_tokens, completion_tokens, total_tokens, reported_cost_status, reported_cost_micros, recorded_at]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_semantic_response_observation\"][\"Row\"]"
defined_in: ["20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_semantic_response_observation

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `producer_attempt_id` | `uuid` | no | — | — |
| 3 | `provider_attempt_id` | `uuid` | no | — | PK |
| 4 | `operation_id` | `uuid` | no | — | — |
| 5 | `operation_step_id` | `uuid` | no | — | — |
| 6 | `profile_artifact_id` | `uuid` | no | — | — |
| 7 | `profile_sha256` | `text` | no | — | — |
| 8 | `dispatch_fencing_token` | `bigint` | no | — | — |
| 9 | `blinded_input_artifact_id` | `uuid` | no | — | — |
| 10 | `blinded_input_sha256` | `text` | no | — | — |
| 11 | `request_artifact_id` | `uuid` | no | — | — |
| 12 | `request_sha256` | `text` | no | — | — |
| 13 | `raw_response_artifact_id` | `uuid` | no | — | — |
| 14 | `raw_response_sha256` | `text` | no | — | — |
| 15 | `response_envelope_artifact_id` | `uuid` | no | — | — |
| 16 | `response_envelope_sha256` | `text` | no | — | — |
| 17 | `observation_artifact_id` | `uuid` | no | — | — |
| 18 | `observation_sha256` | `text` | no | — | — |
| 19 | `requested_model` | `text` | no | — | — |
| 20 | `observed_model` | `text` | yes | — | — |
| 21 | `model_status` | `text` | no | — | — |
| 22 | `revalidation_required` | `boolean` | no | — | — |
| 23 | `prompt_tokens` | `integer` | yes | — | — |
| 24 | `completion_tokens` | `integer` | yes | — | — |
| 25 | `total_tokens` | `integer` | yes | — | — |
| 26 | `reported_cost_status` | `text` | no | — | — |
| 27 | `reported_cost_micros` | `bigint` | yes | — | — |
| 28 | `recorded_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, provider_attempt_id)
- 20 check constraints; see [details](verification_semantic_response_observation.details.md)

## Relationships

10 outbound and 0 inbound foreign keys; full list in [details](verification_semantic_response_observation.details.md).

## Indexes

0 indexes; see [details](verification_semantic_response_observation.details.md).

## Triggers

7 triggers; see [details](verification_semantic_response_observation.details.md).

## Row-level security

Enabled; 2 policies in [details](verification_semantic_response_observation.details.md).

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_semantic_response_observation"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_semantic_response_observation"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_semantic_response_observation"]["Update"]`

Defined in: `20260907013000_verification_semantic_provider_observation.sql`.
