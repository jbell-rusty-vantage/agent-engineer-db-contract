---
id: "rel:content.unit_change"
kind: table
schema: content
name: unit_change
domain: content
lens: corpus
aliases: [unit diff, document diff]
tokens: [content, unit_change, content.unit_change, id, tenant_id, document_id, logical_key, unit_kind, from_version_id, to_version_id, from_node_id, to_node_id, change_kind, changed_attributes, detected_at, refresh_check_id, update_proposal_state]
summary: Unit-level diff between two versions matched by logical_key; drives update proposals for facts.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"unit_change\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# content.unit_change

table in domain `content`, lens `corpus` — A unit-level diff between two versions of a document, matched by logical_key: added/removed/attribute_changed/text_changed/moved, with the changed attribute values. Drives update proposals for facts..

> curated (model_assisted, unreviewed) — Unit-level diff between two versions matched by logical_key; drives update proposals for facts.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `document_id` | `uuid` | no | — | — |
| 4 | `logical_key` | `text` | no | — | — |
| 5 | `unit_kind` | `text` | no | — | — |
| 6 | `from_version_id` | `uuid` | yes | — | — |
| 7 | `to_version_id` | `uuid` | no | — | — |
| 8 | `from_node_id` | `uuid` | yes | — | — |
| 9 | `to_node_id` | `uuid` | yes | — | — |
| 10 | `change_kind` | `text` | no | — | added \| removed \| attribute_changed \| text_changed \| moved \| format_only (same logical key, same normalized content, different representation format: excluded from changes_since by default).; _curated:_ added, removed, attribute_changed, text_changed, moved. |
| 11 | `changed_attributes` | `jsonb` | no | `'{}'::jsonb` | _curated:_ Old and new attribute values for attribute_changed. |
| 12 | `detected_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `refresh_check_id` | `uuid` | yes | — | FK → [`content.refresh_check`](refresh_check.md).id |
| 14 | `update_proposal_state` | `text` | no | `'none'::text` | _curated:_ Whether an assertion update has been proposed/applied for this change. |

## Constraints

- PK (id)
- check `unit_change_change_kind_check`: `(change_kind = ANY (ARRAY['added'::text, 'removed'::text, 'attribute_changed'::text, 'text_changed'::text, 'moved'::text, 'format_only'::te…`
- check `unit_change_update_proposal_state_check`: `(update_proposal_state = ANY (ARRAY['none'::text, 'proposed'::text, 'applied'::text, 'rejected'::text]))`

## Relationships

Outbound: `refresh_check_id` → [`content.refresh_check`](refresh_check.md)`.id`; `tenant_id,document_id` → [`content.document`](document.md)`.tenant_id,id`; `tenant_id,from_node_id` → [`content.document_node`](document_node.md)`.tenant_id,id`; `tenant_id,to_node_id` → [`content.document_node`](document_node.md)`.tenant_id,id`; `tenant_id,to_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id`.
Inbound: [`content.digest_item`](digest_item.md).unit_change_id.

## Indexes

`unit_change_detected_idx`; `unit_change_document_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:content.unit_changes`, `q:facts.changes_since`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["unit_change"]["Insert"]`; row: `Database["content"]["Tables"]["unit_change"]["Row"]`; update: `Database["content"]["Tables"]["unit_change"]["Update"]`

## Examples

Recent unit changes

```bash
knowledge db query content.unit_changes --param document_id=null --param limit=100 --param since=2026-10-01T00:00:00Z
```
api.changes_since reports these beside fact changes.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
