---
id: "rel:content.document_summary_source"
kind: table
schema: content
name: document_summary_source
domain: content
aliases: []
tokens: [content, document_summary_source, content.document_summary_source, tenant_id, summary_id, node_id, weight]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_summary_source\"][\"Row\"]"
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_summary_source

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `summary_id` | `uuid` | no | — | PK; FK → [`content.document_summary`](document_summary.md).id |
| 3 | `node_id` | `uuid` | no | — | PK; FK → [`content.document_node`](document_node.md).id |
| 4 | `weight` | `numeric(5,4)` | no | `1` | — |

## Constraints

- PK (tenant_id, summary_id, node_id)
- check `document_summary_source_weight_check`: `((weight >= (0)::numeric) AND (weight <= (1)::numeric))`

## Relationships

Outbound: `node_id` → [`content.document_node`](document_node.md)`.id` (+tenant); `summary_id` → [`content.document_summary`](document_summary.md)`.id` (+tenant).
Inbound: none.

## Indexes

_None._

## Triggers

- `km_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `summary_node_integrity` → [`content.check_summary_sources`](../../functions/content/check_summary_sources.md) (constraint trigger, deferred)
- `summary_sources` → [`content.check_summary_lineage`](../../functions/content/check_summary_lineage.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["content"]["Tables"]["document_summary_source"]["Insert"]`; row: `Database["content"]["Tables"]["document_summary_source"]["Row"]`; update: `Database["content"]["Tables"]["document_summary_source"]["Update"]`

Defined in: `20260912010600_km_06_content.sql`.
