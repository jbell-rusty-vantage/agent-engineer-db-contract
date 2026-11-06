---
id: "rel:corpus.registry_listing"
kind: table
schema: corpus
name: registry_listing
domain: identity
aliases: []
tokens: [corpus, registry_listing, corpus.registry_listing, id, tenant_id, registry_id, entity_id, external_id, canonical_url]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"registry_listing\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.registry_listing

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, registry_id, external_id) |
| 3 | `registry_id` | `uuid` | no | — | unique (tenant_id, registry_id, external_id); FK → [`corpus.registry`](registry.md).id |
| 4 | `entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id |
| 5 | `external_id` | `text` | no | — | unique (tenant_id, registry_id, external_id) |
| 6 | `canonical_url` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, registry_id, external_id)

## Relationships

Outbound: `entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `registry_id` → [`corpus.registry`](registry.md)`.id` (+tenant).
Inbound: none.

## Indexes

`registry_listing_tenant_id_id_key` unique; `registry_listing_tenant_id_registry_id_external_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["registry_listing"]["Insert"]`; row: `Database["corpus"]["Tables"]["registry_listing"]["Row"]`; update: `Database["corpus"]["Tables"]["registry_listing"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
