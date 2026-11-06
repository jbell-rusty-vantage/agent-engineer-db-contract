---
id: "rel:orchestration.verification_artifact_metadata"
kind: table
schema: orchestration
name: verification_artifact_metadata
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_artifact_metadata, orchestration.verification_artifact_metadata, tenant_id, artifact_id, producer_activity_id, producer_version, content_encoding, encryption_class, retention_class, data_classification, parent_artifact_ids, transformation_signature, attestation_artifact_id, created_at, logical_object_key]
summary: Immutable verification.v1 metadata for an artifact whose canonical identity remains orchestration.artifact.
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_artifact_metadata\"][\"Row\"]"
defined_in: ["20260905012000_verification_artifact_metadata.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_artifact_metadata

table in domain `orchestration-ledger` — Immutable verification.v1 metadata for an artifact whose canonical identity remains orchestration.artifact..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `artifact_id` | `uuid` | no | — | PK |
| 3 | `producer_activity_id` | `text` | no | — | — |
| 4 | `producer_version` | `text` | no | — | — |
| 5 | `content_encoding` | `text` | yes | — | — |
| 6 | `encryption_class` | `text` | no | — | — |
| 7 | `retention_class` | `text` | no | — | — |
| 8 | `data_classification` | `text` | no | — | — |
| 9 | `parent_artifact_ids` | `uuid[]` | no | `'{}'::uuid[]` | Ordered immutable parent IDs as serialized in the verification artifact handle; normalized lineage edges remain authoritative relations. |
| 10 | `transformation_signature` | `text` | yes | — | — |
| 11 | `attestation_artifact_id` | `uuid` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `logical_object_key` | `text` | yes | — | Original immutable executor handle key. Null preserves historical CAS handles. Remote custody address remains artifact.storage_bucket/object_path. |

## Constraints

- PK (tenant_id, artifact_id)
- check `verification_artifact_metadata_data_classification_check`: `(data_classification = ANY (ARRAY['public'::text, 'internal'::text, 'confidential'::text, 'restricted'::text]))`
- check `verification_artifact_metadata_encryption_class_check`: `(btrim(encryption_class) <> ''::text)`
- check `verification_artifact_metadata_logical_object_key_check`: `((logical_object_key IS NULL) OR ((length(logical_object_key) >= 1) AND (length(logical_object_key) <= 4096)))`
- check `verification_artifact_metadata_producer_activity_id_check`: `(btrim(producer_activity_id) <> ''::text)`
- check `verification_artifact_metadata_producer_version_check`: `(btrim(producer_version) <> ''::text)`
- check `verification_artifact_metadata_retention_class_check`: `(btrim(retention_class) <> ''::text)`
- check `verification_artifact_metadata_transformation_signature_check`: `((transformation_signature IS NULL) OR (transformation_signature ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `tenant_id,attestation_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_00f3537c343aa58e6cac6c4d` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_artifact_metadata_admission` → [`orchestration.validate_verification_artifact_metadata`](../../functions/orchestration/validate_verification_artifact_metadata.md)
- `verification_artifact_metadata_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `verification_blob_policy_guard` → [`orchestration.guard_verification_blob_policy`](../../functions/orchestration/guard_verification_blob_policy.md)
- `verification_parent_edge_completeness` → [`orchestration.validate_verification_parent_edge_completeness`](../../functions/orchestration/validate_verification_parent_edge_completeness.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_artifact_metadata"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_artifact_metadata"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_artifact_metadata"]["Update"]`

Defined in: `20260905012000_verification_artifact_metadata.sql`.
