---
id: "rel:orchestration.artifact_lineage"
kind: table
schema: orchestration
name: artifact_lineage
domain: orchestration-ledger
aliases: [lineage]
tokens: [orchestration, artifact_lineage, orchestration.artifact_lineage, id, tenant_id, from_artifact_id, to_artifact_id, relation_kind, transformation_run_id, receipt_id, created_at, activity_id, activity_version, transformation_signature]
summary: "Typed edge between artifacts (derived_from, supersedes, corrects, produced_by, consumed_by)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"artifact_lineage\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.artifact_lineage

table in domain `orchestration-ledger`.

> curated (model_assisted, unreviewed) — Typed edge between artifacts (derived_from, supersedes, corrects, produced_by, consumed_by).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind) |
| 3 | `from_artifact_id` | `uuid` | no | — | unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind) |
| 4 | `to_artifact_id` | `uuid` | no | — | unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind) |
| 5 | `relation_kind` | `text` | no | — | unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind); _curated:_ derived_from, supersedes, corrects, produced_by, consumed_by. |
| 6 | `transformation_run_id` | `uuid` | yes | — | — |
| 7 | `receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](operation_receipt.md).id; _curated:_ Set on edges written in the apply transaction. |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `activity_id` | `text` | yes | — | — |
| 10 | `activity_version` | `text` | yes | — | — |
| 11 | `transformation_signature` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind)
- check `artifact_lineage_activity_ck`: `((relation_kind <> ALL (ARRAY['derived_from'::text, 'generated'::text, 'quoted_from'::text])) OR ((relation_kind = 'derived_from'::text) AN…`
- check `artifact_lineage_check`: `(from_artifact_id <> to_artifact_id)`
- check `artifact_lineage_relation_kind_check`: `(relation_kind = ANY (ARRAY['derived_from'::text, 'supersedes'::text, 'corrects'::text, 'produced_by'::text, 'consumed_by'::text, 'used'::t…`
- check `artifact_lineage_transformation_signature_check`: `((transformation_signature IS NULL) OR (transformation_signature ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `receipt_id` → [`orchestration.operation_receipt`](operation_receipt.md)`.id` on delete restrict; `tenant_id,from_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,to_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,transformation_run_id` → [`content.transformation_run`](../content/transformation_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`artifact_lineage_tenant_id_from_artifact_id_to_artifact_id__key` unique

## Triggers

- `artifact_lineage_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `artifact_retirement_04ca3be08f017b8b7cd7b05f` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_27245a53128a8a6640034f09` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_artifact_lineage_admission` → [`orchestration.validate_verification_artifact_lineage`](../../functions/orchestration/validate_verification_artifact_lineage.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["artifact_lineage"]["Insert"]`; row: `Database["orchestration"]["Tables"]["artifact_lineage"]["Row"]`; update: `Database["orchestration"]["Tables"]["artifact_lineage"]["Update"]`

## Examples

Artifacts of one type

```bash
knowledge db query artifacts.by_type --param artifact_type=knowledge_read_snapshot --param limit=50
```
Snapshot artifacts are derived_from the read intent artifact.

Defined in: `20260903010000_knowledge_content_contract.sql`.
