---
id: "rel:catalog.relationship"
kind: table
schema: catalog
name: relationship
domain: relationships
lens: corpus
aliases: [edge, link]
tokens: [catalog, relationship, catalog.relationship, id, tenant_id, kind, from_entity_id, to_entity_id, qualifier, episode, properties, primary_claim_id, k_from, k_to, created_at]
summary: One edge table; kinds constrain endpoints and may be temporal.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"relationship\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# catalog.relationship

table in domain `relationships`, lens `corpus` — The only link between two entities: kind -> taxonomy.relationship_kind (endpoint kinds enforced); temporal kinds carry a relationship_active stream..

> curated (model_assisted, unreviewed) — One edge table; kinds constrain endpoints and may be temporal.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | — | FK → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md).code |
| 4 | `from_entity_id` | `uuid` | no | — | FK → [`catalog.entity`](entity.md).id |
| 5 | `to_entity_id` | `uuid` | no | — | FK → [`catalog.entity`](entity.md).id |
| 6 | `qualifier` | `text` | no | `''::text` | _curated:_ Disambiguates parallel edges of the same kind. |
| 7 | `episode` | `integer` | no | `1` | _curated:_ Integer >= 1 for repeated engagements. |
| 8 | `properties` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `primary_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 10 | `k_from` | `bigint` | no | — | — |
| 11 | `k_to` | `bigint` | yes | — | _curated:_ Null means current knowledge of the edge. |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `relationship_check`: `(from_entity_id <> to_entity_id)`
- check `relationship_check1`: `((k_to IS NULL) OR (k_to > k_from))`
- check `relationship_episode_check`: `(episode >= 1)`

## Relationships

Outbound: `from_entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant); `kind` → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md)`.code`; `primary_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `to_entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant).
Inbound: [`evidence.claim`](../evidence/claim.md).relationship_id, [`retrieval.chunk_relationship_evidence`](../retrieval/chunk_relationship_evidence.md).relationship_id, [`temporal.event`](../temporal/event.md).relationship_id, [`temporal.stream`](../temporal/stream.md).subject_relationship_id.
Polymorphic target of: [`temporal.stream`](../temporal/stream.md) (check constraint stream_check).

## Indexes

`relationship_current_uq` unique where `(k_to IS NULL)`; `relationship_from_idx` where `(k_to IS NULL)`; `relationship_tenant_id_id_key` unique; `relationship_to_idx` where `(k_to IS NULL)`

## Triggers

- `guard_k` → [`temporal.guard_k`](../../functions/temporal/guard_k.md)
- `relationship_kinds` → [`catalog.check_relationship_kinds`](../../functions/catalog/check_relationship_kinds.md)
- `relationship_properties` → [`catalog.check_relationship_properties`](../../functions/catalog/check_relationship_properties.md)
- `sealed_batch` → [`temporal.require_sealed_batch`](../../functions/temporal/require_sealed_batch.md) (constraint trigger, deferred)
- `stamp_k` → [`temporal.stamp_k`](../../functions/temporal/stamp_k.md)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:catalog.benchmark_scores`, `q:catalog.concepts`, `q:catalog.events`, `q:catalog.organizations`, `q:catalog.papers`, `q:catalog.people`, `q:catalog.software`, `q:catalog.software_releases`, `q:catalog.talks`, `q:entity.relationships`, `q:entity.what_changed`, `q:relationships.current_by_kind`.
- Exposed through: [`api.advisories`](../api/advisories.md), [`api.benchmark_scores`](../api/benchmark_scores.md), [`api.benchmarks`](../api/benchmarks.md), [`api.capabilities`](../api/capabilities.md), [`api.compute_devices`](../api/compute_devices.md), [`api.compute_offerings`](../api/compute_offerings.md), [`api.concepts`](../api/concepts.md), [`api.current_relationships`](../api/current_relationships.md), [`api.events`](../api/events.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.protocol_versions`](../api/protocol_versions.md), [`api.registry_listings`](../api/registry_listings.md), [`api.software`](../api/software.md), [`api.software_releases`](../api/software_releases.md), [`api.talks`](../api/talks.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.assert_relationship`](../../functions/temporal/assert_relationship.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["relationship"]["Insert"]`; row: `Database["catalog"]["Tables"]["relationship"]["Row"]`; update: `Database["catalog"]["Tables"]["relationship"]["Update"]`

## Examples

Current develops edges

```bash
knowledge db query relationships.current_by_kind --param entity_id=null --param kind=develops --param limit=50
```
Temporal kinds also require an active relationship_active segment.

Defined in: unknown.
