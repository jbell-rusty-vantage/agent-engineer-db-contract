---
id: "rel:taxonomy.facet_version"
kind: table
schema: taxonomy
name: facet_version
domain: relationships
aliases: []
tokens: [taxonomy, facet_version, taxonomy.facet_version, id, facet_id, version, status, notes, approved_by_review_task_id, approved_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"facet_version\"][\"Row\"]"
defined_in: ["20260826000400_taxonomy_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# taxonomy.facet_version

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `facet_id` | `uuid` | no | — | unique (facet_id, version); FK → [`taxonomy.facet`](facet.md).id |
| 3 | `version` | `integer` | no | — | unique (facet_id, version) |
| 4 | `status` | `taxonomy.facet_status` | no | `'draft'::taxonomy.facet_status` | — |
| 5 | `notes` | `text` | yes | — | — |
| 6 | `approved_by_review_task_id` | `uuid` | yes | — | FK → [`evaluation.review_task`](../evaluation/review_task.md).id |
| 7 | `approved_at` | `timestamp with time zone` | yes | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (facet_id, version)
- check `facet_version_positive`: `(version > 0)`

## Relationships

Outbound: `facet_id` → [`taxonomy.facet`](facet.md)`.id` on delete cascade; `approved_by_review_task_id` → [`evaluation.review_task`](../evaluation/review_task.md)`.id`.
Inbound: [`taxonomy.term`](term.md).facet_version_id.

## Indexes

`facet_version_facet_id_version_key` unique; `facet_version_one_active` unique where `(status = 'active'::taxonomy.facet_status)`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["facet_version"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["facet_version"]["Row"]`; update: `Database["taxonomy"]["Tables"]["facet_version"]["Update"]`

Defined in: `20260826000400_taxonomy_core.sql`.
