---
id: "rel:knowledge_service.outbox"
kind: table
schema: knowledge_service
name: outbox
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, outbox, knowledge_service.outbox, id, tenant_id, operation_id, event_id, topic, payload, payload_sha256, available_at, delivery_attempts, published_at, archived_at, last_error, created_at, claim_owner, claim_token, claimed_at, visibility_expires_at, max_delivery_attempts]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"outbox\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.outbox

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `operation_id` | `uuid` | no | — | — |
| 4 | `event_id` | `uuid` | no | — | — |
| 5 | `topic` | `text` | no | — | — |
| 6 | `payload` | `jsonb` | no | — | — |
| 7 | `payload_sha256` | `text` | no | — | — |
| 8 | `available_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `delivery_attempts` | `integer` | no | `0` | — |
| 10 | `published_at` | `timestamp with time zone` | yes | — | — |
| 11 | `archived_at` | `timestamp with time zone` | yes | — | — |
| 12 | `last_error` | `text` | yes | — | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `claim_owner` | `text` | yes | — | — |
| 15 | `claim_token` | `uuid` | yes | — | — |
| 16 | `claimed_at` | `timestamp with time zone` | yes | — | — |
| 17 | `visibility_expires_at` | `timestamp with time zone` | yes | — | — |
| 18 | `max_delivery_attempts` | `integer` | no | `12` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `outbox_claim_shape_ck`: `(((claim_owner IS NULL) AND (claim_token IS NULL) AND (claimed_at IS NULL) AND (visibility_expires_at IS NULL)) OR ((claim_owner IS NOT NUL…`
- check `outbox_max_delivery_attempts_check`: `((max_delivery_attempts >= 1) AND (max_delivery_attempts <= 1000))`
- check `outbox_payload_sha256_check`: `(payload_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,event_id,operation_id` → [`knowledge_service.operation_event`](operation_event.md)`.tenant_id,id,operation_id` on delete restrict; `tenant_id,event_id` → [`knowledge_service.operation_event`](operation_event.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`knowledge_outbox_claim_token_uq` unique where `(claim_token IS NOT NULL)`; `knowledge_outbox_claimable_idx` where `((published_at IS NULL) AND (archived_at IS NULL))`; `knowledge_outbox_event_idx`; `knowledge_outbox_pending_idx` where `((published_at IS NULL) AND (archived_at IS NULL))`; `outbox_tenant_id_id_key` unique

## Triggers

- `outbox_mutation_guard` → [`knowledge_service.guard_outbox_mutation`](../../functions/knowledge_service/guard_outbox_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.
- Via functions (best effort): [`knowledge_service.ack_outbox`](../../functions/knowledge_service/ack_outbox.md), [`knowledge_service.claim_outbox`](../../functions/knowledge_service/claim_outbox.md), [`knowledge_service.extend_outbox_claim`](../../functions/knowledge_service/extend_outbox_claim.md), [`knowledge_service.nack_outbox`](../../functions/knowledge_service/nack_outbox.md), [`temporal.emit_outbox`](../../functions/temporal/emit_outbox.md).

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["outbox"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["outbox"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["outbox"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
