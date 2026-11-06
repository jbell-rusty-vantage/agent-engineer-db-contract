---
id: "rel:retrieval.chunk_span"
kind: table
schema: retrieval
name: chunk_span
domain: retrieval
aliases: [chunk span]
tokens: [retrieval, chunk_span, retrieval.chunk_span, tenant_id, chunk_id, ordinal, document_node_id, start_offset, end_offset, locator_id, selected_text_sha256, created_at]
summary: "Character offsets of a chunk inside a document node, optionally with a locator."
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"chunk_span\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.chunk_span

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Character offsets of a chunk inside a document node, optionally with a locator.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `chunk_id` | `uuid` | no | — | PK |
| 3 | `ordinal` | `integer` | no | — | PK |
| 4 | `document_node_id` | `uuid` | no | — | _curated:_ Parent content.document_node. |
| 5 | `start_offset` | `integer` | yes | — | _curated:_ Inclusive start inside the node text. |
| 6 | `end_offset` | `integer` | yes | — | — |
| 7 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id |
| 8 | `selected_text_sha256` | `text` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, chunk_id, ordinal)
- check `chunk_span_check`: `((end_offset IS NULL) OR ((start_offset IS NOT NULL) AND (end_offset >= start_offset)))`
- check `chunk_span_ordinal_check`: `(ordinal >= 0)`
- check `chunk_span_selected_text_sha256_check`: `(selected_text_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `chunk_span_start_offset_check`: `((start_offset IS NULL) OR (start_offset >= 0))`

## Relationships

Outbound: `locator_id` → [`evidence.locator`](../evidence/locator.md)`.id` on delete restrict; `tenant_id,chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict; `tenant_id,document_node_id` → [`content.document_node`](../content/document_node.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `chunk_span_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["chunk_span"]["Insert"]`; row: `Database["retrieval"]["Tables"]["chunk_span"]["Row"]`; update: `Database["retrieval"]["Tables"]["chunk_span"]["Update"]`

## Examples

Packet members may cite the node

```bash
knowledge db query retrieval.evidence_packet --param packet_id=0192c000-0000-7000-8000-000000000001
```
Timecodes come from the node, not from these offsets.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
