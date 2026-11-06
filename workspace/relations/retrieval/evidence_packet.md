---
id: "rel:retrieval.evidence_packet"
kind: table
schema: retrieval
name: evidence_packet
domain: retrieval
aliases: [packet]
tokens: [retrieval, evidence_packet, retrieval.evidence_packet, id, tenant_id, run_id, packet, packet_schema_version, artifact_id, created_at, packet_sha256, normalized_query, authorization_context, omitted_results, coverage, abstention, event_ids, receipt_ids]
summary: Assembled evidence bundle for one question.
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"evidence_packet\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.evidence_packet

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Assembled evidence bundle for one question.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `run_id` | `uuid` | yes | — | FK → [`retrieval.retrieval_run`](retrieval_run.md).id; _curated:_ Retrieval run that built it. |
| 4 | `packet` | `jsonb` | no | — | — |
| 5 | `packet_schema_version` | `integer` | no | `1` | — |
| 6 | `artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `packet_sha256` | `text` | yes | — | generated: `encode(digest((packet)::text, 'sha256'::text), 'hex'::text)`; _curated:_ Digest of the packet JSON. |
| 9 | `normalized_query` | `text` | yes | — | — |
| 10 | `authorization_context` | `jsonb` | yes | — | — |
| 11 | `omitted_results` | `jsonb` | no | `'[]'::jsonb` | — |
| 12 | `coverage` | `jsonb` | no | `'[]'::jsonb` | — |
| 13 | `abstention` | `jsonb` | yes | — | — |
| 14 | `event_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 15 | `receipt_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `evidence_packet_sha256_ck`: `(packet_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id`; `run_id` → [`retrieval.retrieval_run`](retrieval_run.md)`.id` (+tenant).
Inbound: [`retrieval.packet_member`](packet_member.md).packet_id.

## Indexes

`evidence_packet_tenant_id_uq` unique

## Triggers

- `artifact_retirement_8f584457426324ef7c2f6faa` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `evidence_packet_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.evidence_packet`.
- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["evidence_packet"]["Insert"]`; row: `Database["retrieval"]["Tables"]["evidence_packet"]["Row"]`; update: `Database["retrieval"]["Tables"]["evidence_packet"]["Update"]`

## Examples

Load one packet

```bash
knowledge db query retrieval.evidence_packet --param packet_id=0192c000-0000-7000-8000-000000000001
```
Returns null JSON when the id is unknown to the tenant.

Defined in: `20260826001000_retrieval.sql`.
