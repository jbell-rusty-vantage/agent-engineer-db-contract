---
id: "rel:content.document_kind_assignment"
kind: table
schema: content
name: document_kind_assignment
domain: content
lens: corpus
aliases: [kind assignment, open-world kinds]
tokens: [content, document_kind_assignment, content.document_kind_assignment, id, tenant_id, document_id, document_type_code, method, confidence, rationale, assigned_at, superseded_by_id]
summary: Append-only kind assignments of a document; the current one has superseded_by_id null.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_kind_assignment\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# content.document_kind_assignment

table in domain `content`, lens `corpus` — Append-only kind assignments of a document (open world): the current one has superseded_by_id null; document.document_type_code is the initial assignment..

> curated (model_assisted, unreviewed) — Append-only kind assignments of a document; the current one has superseded_by_id null.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `document_id` | `uuid` | no | — | — |
| 4 | `document_type_code` | `text` | no | — | FK → [`content.document_type`](document_type.md).code |
| 5 | `method` | `text` | no | — | _curated:_ rule, census, model or person. |
| 6 | `confidence` | `numeric` | yes | — | — |
| 7 | `rationale` | `text` | yes | — | — |
| 8 | `assigned_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `superseded_by_id` | `uuid` | yes | — | FK → [`content.document_kind_assignment`](document_kind_assignment.md).id; _curated:_ Null for the current assignment. |

## Constraints

- PK (id)
- check `document_kind_assignment_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `document_kind_assignment_method_check`: `(method = ANY (ARRAY['rule'::text, 'model'::text, 'person'::text, 'census'::text]))`

## Relationships

Outbound: `document_type_code` → [`content.document_type`](document_type.md)`.code`; `superseded_by_id` → [`content.document_kind_assignment`](document_kind_assignment.md)`.id`; `tenant_id,document_id` → [`content.document`](document.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.document_kind_assignment`](document_kind_assignment.md).superseded_by_id.

## Indexes

`document_kind_assignment_current_idx` where `(superseded_by_id IS NULL)`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_kind_assignment"]["Insert"]`; row: `Database["content"]["Tables"]["document_kind_assignment"]["Row"]`; update: `Database["content"]["Tables"]["document_kind_assignment"]["Update"]`

## Examples

Grammar depends on the current kind

```bash
knowledge db query vocab.unit_kind --param code=null --param document_type=release_notes
```
Reassigning a kind changes which unit kinds apply.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
