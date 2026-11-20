---
id: "rel:catalog.entity_split"
kind: table
schema: catalog
name: entity_split
domain: identity
lens: corpus
aliases: []
tokens: [catalog, entity_split, catalog.entity_split, id, tenant_id, from_entity_id, reason_code, note, proposal_id, receipt_id, knowledge_seq, source_retired, undone_at, created_at]
summary: "A split of one record that mixed several things (our mistake, never a split in the world). The parts are in catalog.entity_split_part; what moved is in catalog.identity_move."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"entity_split\"][\"Row\"]"
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.entity_split

table in domain `identity`, lens `corpus` — A split of one record that mixed several things (our mistake, never a split in the world). The parts are in catalog.entity_split_part; what moved is in catalog.identity_move..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `from_entity_id` | `uuid` | no | — | FK → [`catalog.entity`](entity.md).id |
| 4 | `reason_code` | `text` | no | — | FK → [`temporal.correction_reason`](../temporal/correction_reason.md).code |
| 5 | `note` | `text` | yes | — | — |
| 6 | `proposal_id` | `uuid` | yes | — | FK → [`catalog.proposal`](proposal.md).id |
| 7 | `receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 8 | `knowledge_seq` | `bigint` | yes | — | — |
| 9 | `source_retired` | `boolean` | no | `false` | — |
| 10 | `undone_at` | `timestamp with time zone` | yes | — | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `from_entity_id` → [`catalog.entity`](entity.md)`.id`; `proposal_id` → [`catalog.proposal`](proposal.md)`.id`; `reason_code` → [`temporal.correction_reason`](../temporal/correction_reason.md)`.code`; `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`.
Inbound: [`catalog.entity_split_part`](entity_split_part.md).split_id, [`catalog.identity_move`](identity_move.md).split_id.
Polymorphic target of: [`catalog.identity_move`](identity_move.md) (check constraint identity_move_one_parent).

## Indexes

`entity_split_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:facts.changes_since`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`catalog.split_entity`](../../functions/catalog/split_entity.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["entity_split"]["Insert"]`; row: `Database["catalog"]["Tables"]["entity_split"]["Row"]`; update: `Database["catalog"]["Tables"]["entity_split"]["Update"]`

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
