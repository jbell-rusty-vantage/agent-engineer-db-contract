---
id: "rel:orchestration.operation_intent"
kind: table
schema: orchestration
name: operation_intent
domain: orchestration-ledger
aliases: [intent]
tokens: [orchestration, operation_intent, orchestration.operation_intent, id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, proposed_by_attempt, mission_id, approval_state, policy_decision, created_at, origin_digest, origin_kind, mc_mission_id, mc_run_id, mc_activation_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane]
summary: Durable proposed operation with unique idempotency_key.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [control_plane, executor_service, pipeline_agent, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"operation_intent\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.operation_intent

table in domain `orchestration-ledger`.

> curated (model_assisted, unreviewed) — Durable proposed operation with unique idempotency_key.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `intent_type` | `text` | no | — | FK → [`orchestration.intent_type`](intent_type.md).code; _curated:_ FK to orchestration.intent_type; knowledge_ingestion is the workspace write. |
| 4 | `schema_version` | `integer` | no | `1` | — |
| 5 | `payload` | `jsonb` | no | — | — |
| 6 | `preconditions` | `jsonb` | no | `'{}'::jsonb` | _curated:_ Includes expectedKnowledgeHead and snapshotDigest. |
| 7 | `idempotency_key` | `text` | no | — | unique (idempotency_key); _curated:_ Unique; duplicate submits return duplicate_of. |
| 8 | `proposed_by_attempt` | `uuid` | yes | — | FK → [`orchestration.attempt`](attempt.md).id |
| 9 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](mission.md).id |
| 10 | `approval_state` | `text` | no | `'pending'::text` | — |
| 11 | `policy_decision` | `jsonb` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `origin_digest` | `text` | yes | — | Digest (K01 originDigest) of the originating origin the KS executor admitted; restates knowledge_verification.origin.origin_digest (no cross-schema FK). Null for intents without an exact-use origin. |
| 14 | `origin_kind` | `text` | yes | — | — |
| 15 | `mc_mission_id` | `text` | yes | — | — |
| 16 | `mc_run_id` | `text` | yes | — | Mission Control run id from the originating origin's mission coordinates (text; not orchestration.mission). Present exactly when origin_kind = mission_invocation, with mc_mission_id, mc_operation_id, mc_operation_attempt, mc_execution_generation and mc_lane. |
| 17 | `mc_activation_id` | `text` | yes | — | — |
| 18 | `mc_operation_id` | `text` | yes | — | — |
| 19 | `mc_operation_attempt` | `integer` | yes | — | — |
| 20 | `mc_execution_generation` | `integer` | yes | — | — |
| 21 | `mc_lane` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (idempotency_key)
- unique (tenant_id, id)
- check `operation_intent_approval_state_check`: `(approval_state = ANY (ARRAY['pending'::text, 'approved'::text, 'budgeted'::text, 'denied'::text, 'escalated'::text]))`
- check `operation_intent_mc_execution_generation_check`: `(mc_execution_generation >= 0)`
- check `operation_intent_mc_operation_attempt_check`: `(mc_operation_attempt >= 0)`
- check `operation_intent_mission_coordinates`: `((NOT (origin_kind IS DISTINCT FROM 'mission_invocation'::text)) = ((mc_mission_id IS NOT NULL) AND (mc_run_id IS NOT NULL) AND (mc_operati…`
- check `operation_intent_origin_digest_check`: `(origin_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `operation_intent_origin_kind_check`: `(origin_kind = ANY (ARRAY['mission_invocation'::text, 'standalone'::text, 'recovery'::text, 'durable_worker'::text]))`
- check `operation_intent_origin_pair`: `((origin_digest IS NULL) = (origin_kind IS NULL))`

## Relationships

3 outbound and 3 inbound foreign keys; full list in [details](operation_intent.details.md).

## Indexes

6 indexes; see [details](operation_intent.details.md).

## Triggers

1 triggers; see [details](operation_intent.details.md).

## Row-level security

Enabled; 1 policies in [details](operation_intent.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Named queries: `q:receipts.for_intent`, `q:receipts.recent_for_mission`.
- Exposed through: [`orchestration.mission_run_effects`](mission_run_effects.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `pipeline_agent`.
- Via functions (best effort): [`api.submit_intent`](../../functions/api/submit_intent.md).

## TypeScript

insert: `Database["orchestration"]["Tables"]["operation_intent"]["Insert"]`; row: `Database["orchestration"]["Tables"]["operation_intent"]["Row"]`; update: `Database["orchestration"]["Tables"]["operation_intent"]["Update"]`

## Examples

One intent

```bash
knowledge db query receipts.for_intent --param intent_id=0192f000-0000-7000-8000-000000000001
```
Returns the intent even when no batch has sealed.

Defined in: `20260826000200_orchestration.sql`.
