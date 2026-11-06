---
id: "rel:knowledge_service.verification_component_binding"
kind: table
schema: knowledge_service
name: verification_component_binding
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, verification_component_binding, knowledge_service.verification_component_binding, singleton, component, component_version, migration_keys, bound_at]
summary: "The common verification component this AI Engineer binding consumes (Sprint V): the installed migration keys (a superset of 0001..0003) and greatest component version at bind time. Domain projections (research.*) reference knowledge_verification runs by (tenant_id, run_id); no common DDL is copied here."
summary_basis: comment
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"verification_component_binding\"][\"Row\"]"
defined_in: ["20261024010000_knowledge_component_binding.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.verification_component_binding

table in domain `knowledge-service-runtime` — The common verification component this AI Engineer binding consumes (Sprint V): the installed migration keys (a superset of 0001..0003) and greatest component version at bind time. Domain projections (research.*) reference knowledge_verification runs by (tenant_id, run_id); no common DDL is copied here..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `singleton` | `boolean` | no | `true` | PK |
| 2 | `component` | `text` | no | — | — |
| 3 | `component_version` | `text` | no | — | — |
| 4 | `migration_keys` | `text[]` | no | — | — |
| 5 | `bound_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (singleton)
- check `verification_component_binding_component_check`: `(component = 'knowledge_verification'::text)`
- check `verification_component_binding_singleton_check`: `singleton`

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["verification_component_binding"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["verification_component_binding"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["verification_component_binding"]["Update"]`

Defined in: `20261024010000_knowledge_component_binding.sql`.
