---
id: "rel:content.unit_link"
kind: table
schema: content
name: unit_link
domain: content
lens: corpus
aliases: []
tokens: [content, unit_link, content.unit_link, tenant_id, from_node_id, to_node_id, kind, method, confidence, created_at]
summary: "R4: typed edge between two units (a docs section documents an api_symbol; a slide cites a paper reference; a symbol unit in release B is the same symbol as in release A). Symbols are units, not entities, so unit_entity_role cannot carry this."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"content\"][\"Tables\"][\"unit_link\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# content.unit_link

table in domain `content`, lens `corpus` — R4: typed edge between two units (a docs section documents an api_symbol; a slide cites a paper reference; a symbol unit in release B is the same symbol as in release A). Symbols are units, not entities, so unit_entity_role cannot carry this..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 2 | `from_node_id` | `uuid` | no | — | PK; FK → [`content.document_node`](document_node.md).id |
| 3 | `to_node_id` | `uuid` | no | — | PK; FK → [`content.document_node`](document_node.md).id |
| 4 | `kind` | `text` | no | — | PK; documents \| cites \| supersedes \| implements \| mentions \| same_symbol \| imports (a symbol whose body uses a symbol of another library; loop 3). |
| 5 | `method` | `text` | no | `'rule'::text` | — |
| 6 | `confidence` | `numeric(5,4)` | no | `1.0` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (from_node_id, to_node_id, kind)
- check `unit_link_kind_check`: `(kind = ANY (ARRAY['documents'::text, 'cites'::text, 'supersedes'::text, 'implements'::text, 'mentions'::text, 'same_symbol'::text, 'import…`

## Relationships

Outbound: `from_node_id` → [`content.document_node`](document_node.md)`.id` on delete cascade; `to_node_id` → [`content.document_node`](document_node.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`unit_link_to_ix`

## Triggers

_None._

## Row-level security

Enabled.
- `unit_link_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Exposed through: [`api.api_symbols`](../api/api_symbols.md), [`api.symbol_docs`](../api/symbol_docs.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["content"]["Tables"]["unit_link"]["Insert"]`; row: `Database["content"]["Tables"]["unit_link"]["Row"]`; update: `Database["content"]["Tables"]["unit_link"]["Update"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
