---
id: "rel:knowledge_service.eve_operation_invocation"
kind: table
schema: knowledge_service
name: eve_operation_invocation
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, eve_operation_invocation, knowledge_service.eve_operation_invocation, id, tenant_id, operation_id, issuer, key_id, jti, invocation_kind, envelope, envelope_sha256, lineage_sha256, observed_external_execution, issued_at, expires_at, accepted_at]
summary: "Append-only full public Eve attestation envelopes, including signature, for offline authorization replay. It grants no authority itself."
summary_basis: comment
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"eve_operation_invocation\"][\"Row\"]"
defined_in: ["20260908010000_eve_verification_binding.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.eve_operation_invocation

table in domain `knowledge-service-runtime` — Append-only full public Eve attestation envelopes, including signature, for offline authorization replay. It grants no authority itself..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `operation_id` | `uuid` | no | — | — |
| 4 | `issuer` | `text` | no | — | unique (issuer, jti) |
| 5 | `key_id` | `text` | no | — | — |
| 6 | `jti` | `text` | no | — | unique (issuer, jti) |
| 7 | `invocation_kind` | `text` | no | — | — |
| 8 | `envelope` | `jsonb` | no | — | — |
| 9 | `envelope_sha256` | `text` | no | — | — |
| 10 | `lineage_sha256` | `text` | no | — | — |
| 11 | `observed_external_execution` | `jsonb` | no | — | — |
| 12 | `issued_at` | `timestamp with time zone` | no | — | — |
| 13 | `expires_at` | `timestamp with time zone` | no | — | — |
| 14 | `accepted_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (id)
- unique (issuer, jti)
- check `eve_operation_invocation_check`: `(expires_at > issued_at)`
- check `eve_operation_invocation_envelope_check`: `(envelope ?& ARRAY['payload'::text, 'signatureBase64'::text])`
- check `eve_operation_invocation_envelope_sha256_check`: `(envelope_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `eve_operation_invocation_invocation_kind_check`: `(invocation_kind = ANY (ARRAY['original'::text, 'retry'::text]))`
- check `eve_operation_invocation_issuer_check`: `((issuer = btrim(issuer)) AND ((char_length(issuer) >= 1) AND (char_length(issuer) <= 255)))`
- check `eve_operation_invocation_jti_check`: `((jti = btrim(jti)) AND ((char_length(jti) >= 1) AND (char_length(jti) <= 255)))`
- check `eve_operation_invocation_key_id_check`: `((key_id = btrim(key_id)) AND ((char_length(key_id) >= 1) AND (char_length(key_id) <= 255)))`
- check `eve_operation_invocation_lineage_sha256_check`: `(lineage_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `eve_operation_invocation_observed_external_execution_check`: `((observed_external_execution ?& ARRAY['runtime'::text, 'runId'::text, 'sessionId'::text, 'turnId'::text, 'toolCallId'::text]) AND ((observ…`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.eve_operation_binding`](eve_operation_binding.md)`.tenant_id,operation_id` on delete restrict.
Inbound: none.

## Indexes

`eve_operation_invocation_binding_idx`; `eve_operation_invocation_issuer_jti_key` unique

## Triggers

- `eve_operation_invocation_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `eve_operation_invocation_control_plane` (ALL) for `control_plane`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["eve_operation_invocation"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["eve_operation_invocation"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["eve_operation_invocation"]["Update"]`

Defined in: `20260908010000_eve_verification_binding.sql`.
