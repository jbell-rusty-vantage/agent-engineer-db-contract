---
id: "rel:content.document_node"
kind: table
schema: content
name: document_node
domain: content
aliases: []
tokens: [content, document_node, content.document_node, id, tenant_id, representation_id, parent_id, ordinal, stable_local_key, node_kind, role, inline_text, artifact_id, selector, page_number, start_offset, end_offset, bbox, language, normalized_content_sha256, created_at, start_ms, end_ms, speaker_entity_id]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_node\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.document_node

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, representation_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, representation_id, parent_id, ordinal); unique (tenant_id, representation_id, stable_local_key); unique (tenant_id, representation_id, id) |
| 3 | `representation_id` | `uuid` | no | — | unique (tenant_id, representation_id, parent_id, ordinal); unique (tenant_id, representation_id, stable_local_key); unique (tenant_id, representation_id, id) |
| 4 | `parent_id` | `uuid` | yes | — | unique (tenant_id, representation_id, parent_id, ordinal) |
| 5 | `ordinal` | `integer` | no | — | unique (tenant_id, representation_id, parent_id, ordinal) |
| 6 | `stable_local_key` | `text` | no | — | unique (tenant_id, representation_id, stable_local_key) |
| 7 | `node_kind` | `text` | no | — | — |
| 8 | `role` | `text` | yes | — | — |
| 9 | `inline_text` | `text` | yes | — | — |
| 10 | `artifact_id` | `uuid` | yes | — | — |
| 11 | `selector` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `page_number` | `integer` | yes | — | — |
| 13 | `start_offset` | `integer` | yes | — | — |
| 14 | `end_offset` | `integer` | yes | — | — |
| 15 | `bbox` | `jsonb` | yes | — | — |
| 16 | `language` | `text` | yes | — | — |
| 17 | `normalized_content_sha256` | `text` | no | — | — |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 19 | `start_ms` | `integer` | yes | — | — |
| 20 | `end_ms` | `integer` | yes | — | — |
| 21 | `speaker_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, representation_id, parent_id, ordinal)
- unique (tenant_id, representation_id, stable_local_key)
- unique (tenant_id, representation_id, id)
- check `document_node_check`: `((parent_id IS NULL) OR (parent_id <> id))`
- check `document_node_check1`: `((end_offset IS NULL) OR ((start_offset IS NOT NULL) AND (end_offset >= start_offset)))`
- check `document_node_check2`: `((end_ms IS NULL) OR ((start_ms IS NOT NULL) AND (end_ms >= start_ms)))`
- check `document_node_normalized_content_sha256_check`: `(normalized_content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `document_node_ordinal_check`: `(ordinal >= 0)`
- check `document_node_start_ms_check`: `((start_ms IS NULL) OR (start_ms >= 0))`
- check `document_node_start_offset_check`: `((start_offset IS NULL) OR (start_offset >= 0))`

## Relationships

Outbound: `speaker_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,parent_id` → [`content.document_node`](document_node.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.conversion_finding`](conversion_finding.md).node_id, [`content.document_node`](document_node.md).parent_id, [`content.document_node_edge`](document_node_edge.md).from_node_id|to_node_id, [`content.document_summary`](document_summary.md).scope_node_id, [`content.document_summary_source`](document_summary_source.md).node_id, [`retrieval.chunk_span`](../retrieval/chunk_span.md).document_node_id, [`retrieval.packet_member`](../retrieval/packet_member.md).source_representation_id,source_document_node_id.

## Indexes

`document_node_tenant_id_id_key` unique; `document_node_tenant_id_representation_id_parent_id_ordinal_key` unique; `document_node_tenant_id_representation_id_stable_local_key_key` unique; `document_node_tenant_representation_id_uq` unique; `document_node_tree_idx`

## Triggers

- `artifact_retirement_5537e2f308b0b4387c6b3799` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `document_node_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.evidence_packet`.
- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_node"]["Insert"]`; row: `Database["content"]["Tables"]["document_node"]["Row"]`; update: `Database["content"]["Tables"]["document_node"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
