---
id: "rel:content.document_node_edge"
kind: table
schema: content
name: document_node_edge
domain: content
aliases: []
tokens: [content, document_node_edge, content.document_node_edge, tenant_id, from_node_id, to_node_id, relation_kind, metadata, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_node_edge\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.document_node_edge

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `from_node_id` | `uuid` | no | — | PK |
| 3 | `to_node_id` | `uuid` | no | — | PK |
| 4 | `relation_kind` | `text` | no | — | PK |
| 5 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, from_node_id, to_node_id, relation_kind)
- check `document_node_edge_check`: `(from_node_id <> to_node_id)`
- check `document_node_edge_relation_kind_check`: `(relation_kind = ANY (ARRAY['citation'::text, 'footnote'::text, 'caption'::text, 'cross_reference'::text, 'continues'::text, 'same_table'::…`

## Relationships

Outbound: `tenant_id,from_node_id` → [`content.document_node`](document_node.md)`.tenant_id,id` on delete restrict; `tenant_id,to_node_id` → [`content.document_node`](document_node.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `document_node_edge_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_node_edge"]["Insert"]`; row: `Database["content"]["Tables"]["document_node_edge"]["Row"]`; update: `Database["content"]["Tables"]["document_node_edge"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
