---
id: "rel:catalog.relationship"
kind: table
schema: catalog
name: relationship
domain: relationships
lens: corpus
aliases: [edge, link]
tokens: [catalog, relationship, catalog.relationship, id, tenant_id, kind, from_entity_id, to_entity_id, qualifier, episode, properties, primary_claim_id, k_from, k_to, created_at, closed_kind, closed_reason, closed_by_event_id]
summary: One edge table; kinds constrain endpoints and may be temporal.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"relationship\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
| 13 | `closed_kind` | `text` | yes | — | Why the edge stopped being current knowledge: world_change or correction. Set by temporal.close_relationship and by merge and split. |
| 14 | `closed_reason` | `text` | yes | — | FK → [`temporal.correction_reason`](../temporal/correction_reason.md).code; Coded reason when closed_kind is correction. |
| 15 | `closed_by_event_id` | `uuid` | yes | — | FK → [`temporal.event`](../temporal/event.md).id; The event that ended the edge, when a source names one. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `relationship_check`: `(from_entity_id <> to_entity_id)`
- check `relationship_check1`: `((k_to IS NULL) OR (k_to > k_from))`
- check `relationship_closed_kind_check`: `(closed_kind = ANY (ARRAY['world_change'::text, 'correction'::text]))`
- check `relationship_closed_kind_needs_closure`: `((closed_kind IS NULL) OR (k_to IS NOT NULL))`
- check `relationship_correction_has_reason`: `((closed_kind IS DISTINCT FROM 'correction'::text) OR (closed_reason IS NOT NULL))`
- check `relationship_episode_check`: `(episode >= 1)`
- check `relationship_reason_only_on_correction`: `((closed_reason IS NULL) OR (closed_kind = 'correction'::text))`

## Relationships

9 outbound and 9 inbound foreign keys; full list in [details](relationship.details.md).

## Indexes

4 indexes; see [details](relationship.details.md).

## Triggers

5 triggers; see [details](relationship.details.md).

## Row-level security

Enabled; 1 policies in [details](relationship.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:acquisition.attention_due`, `q:catalog.benchmark_scores`, `q:catalog.concepts`, `q:catalog.events`, `q:catalog.organizations`, `q:catalog.papers`, `q:catalog.people`, `q:catalog.software`, `q:catalog.software_releases`, `q:catalog.talks`, `q:entity.relationships`, `q:entity.what_changed`, `q:facts.changes_since`, `q:relationships.current_by_kind`.
- Exposed through: [`api.advisories`](../api/advisories.md), [`api.benchmark_scores`](../api/benchmark_scores.md), [`api.benchmarks`](../api/benchmarks.md), [`api.capabilities`](../api/capabilities.md), [`api.compute_devices`](../api/compute_devices.md), [`api.compute_offerings`](../api/compute_offerings.md), [`api.concepts`](../api/concepts.md), [`api.current_relationships`](../api/current_relationships.md), [`api.events`](../api/events.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.protocol_versions`](../api/protocol_versions.md), [`api.registry_listings`](../api/registry_listings.md), [`api.software`](../api/software.md), [`api.software_releases`](../api/software_releases.md), [`api.talks`](../api/talks.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`catalog._move_relationship`](../../functions/catalog/_move_relationship.md), [`catalog.split_entity`](../../functions/catalog/split_entity.md), [`catalog.undo_merge`](../../functions/catalog/undo_merge.md), [`temporal.assert_relationship`](../../functions/temporal/assert_relationship.md), [`temporal.close_relationship`](../../functions/temporal/close_relationship.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["relationship"]["Insert"]`; row: `Database["catalog"]["Tables"]["relationship"]["Row"]`; update: `Database["catalog"]["Tables"]["relationship"]["Update"]`

## Examples

Current develops edges

```bash
knowledge db query relationships.current_by_kind --param entity_id=null --param kind=develops --param limit=50
```
Temporal kinds also require an active relationship_active segment.

Defined in: unknown.
