---
id: "rel:learning.evidence_item"
kind: table
schema: learning
name: evidence_item
domain: learning
lens: ours
aliases: []
tokens: [learning, evidence_item, learning.evidence_item, id, tenant_id, workspace_id, submission_id, item_key, kind, revision_id, artifact_id, message_id, file_set_id, deployment_id, external_ref, sha256, availability, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"evidence_item\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# learning.evidence_item

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, submission_id, item_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, submission_id, item_key) |
| 4 | `submission_id` | `uuid` | no | — | unique (tenant_id, workspace_id, submission_id, item_key) |
| 5 | `item_key` | `text` | no | — | unique (tenant_id, workspace_id, submission_id, item_key) |
| 6 | `kind` | `text` | no | — | — |
| 7 | `revision_id` | `uuid` | yes | — | — |
| 8 | `artifact_id` | `uuid` | yes | — | — |
| 9 | `message_id` | `uuid` | yes | — | — |
| 10 | `file_set_id` | `uuid` | yes | — | — |
| 11 | `deployment_id` | `uuid` | yes | — | — |
| 12 | `external_ref` | `jsonb` | yes | — | — |
| 13 | `sha256` | `text` | yes | — | — |
| 14 | `availability` | `text` | no | — | — |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, submission_id, item_key)
- check `evidence_item_availability_check`: `(availability = ANY (ARRAY['preserved'::text, 'reference_only'::text, 'unavailable'::text]))`
- check `evidence_item_check`: `(num_nonnulls(revision_id, artifact_id, message_id, file_set_id, deployment_id, external_ref) = 1)`
- check `evidence_item_item_key_check`: `(item_key ~ '^[a-z0-9][a-z0-9_.-]{0,62}$'::text)`
- check `evidence_item_kind_check`: `(kind = ANY (ARRAY['project_revision'::text, 'artifact'::text, 'response'::text, 'operational_evidence'::text, 'defense'::text, 'repository…`
- check `evidence_item_sha256_check`: `(sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,deployment_id` → [`authoring.deployment`](../authoring/deployment.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,file_set_id` → [`authoring.file_set`](../authoring/file_set.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,message_id` → [`conversation.message`](../conversation/message.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,submission_id` → [`learning.submission`](submission.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`evidence_item_tenant_id_artifact_id_fkey_ix`; `evidence_item_tenant_id_workspace_id_deployment_id_fkey_ix`; `evidence_item_tenant_id_workspace_id_file_set_id_fkey_ix`; `evidence_item_tenant_id_workspace_id_id_key` unique; `evidence_item_tenant_id_workspace_id_message_id_fkey_ix`; `evidence_item_tenant_id_workspace_id_revision_id_fkey_ix`; `evidence_item_tenant_id_workspace_id_submission_id_item_key_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`submit_attempt`](../../ops/submit_attempt.md).

## TypeScript

insert: `Database["learning"]["Tables"]["evidence_item"]["Insert"]`; row: `Database["learning"]["Tables"]["evidence_item"]["Row"]`; update: `Database["learning"]["Tables"]["evidence_item"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
