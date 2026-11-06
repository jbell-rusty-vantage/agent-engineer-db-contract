---
id: "rel:taxonomy.facet"
kind: table
schema: taxonomy
name: facet
domain: relationships
aliases: []
tokens: [taxonomy, facet, taxonomy.facet, id, tenant_id, slug, label, description, cardinality, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"facet\"][\"Row\"]"
defined_in: ["20260826000400_taxonomy_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# taxonomy.facet

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `label` | `text` | no | — | — |
| 5 | `description` | `text` | yes | — | — |
| 6 | `cardinality` | `text` | no | `'multi'::text` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- check `facet_cardinality_check`: `(cardinality = ANY (ARRAY['single'::text, 'multi'::text]))`

## Relationships

Outbound: none.
Inbound: [`taxonomy.assignment_review_requirement`](assignment_review_requirement.md).facet_id, [`taxonomy.facet_version`](facet_version.md).facet_id.

## Indexes

`facet_tenant_id_slug_key` unique

## Triggers

- `facet_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["facet"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["facet"]["Row"]`; update: `Database["taxonomy"]["Tables"]["facet"]["Update"]`

Defined in: `20260826000400_taxonomy_core.sql`.
