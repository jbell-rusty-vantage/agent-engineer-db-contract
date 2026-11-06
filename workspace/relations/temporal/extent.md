---
id: "rel:temporal.extent"
kind: table
schema: temporal
name: extent
domain: temporal-facts
aliases: [date extent]
tokens: [temporal, extent, temporal.extent, id, tenant_id, source_text, precision, earliest, latest, timezone, locator_id]
summary: Source text for a date with precision and optional earliest/latest bounds.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"extent\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.extent

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — Source text for a date with precision and optional earliest/latest bounds.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `source_text` | `text` | yes | — | — |
| 4 | `precision` | `text` | no | — | _curated:_ instant, day, month, quarter, year, relative, or unknown. |
| 5 | `earliest` | `timestamp with time zone` | yes | — | — |
| 6 | `latest` | `timestamp with time zone` | yes | — | — |
| 7 | `timezone` | `text` | yes | — | — |
| 8 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id; _curated:_ Optional quote that proved the date. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `extent_check`: `((earliest IS NULL) OR (latest IS NULL) OR (latest >= earliest))`
- check `extent_precision_check`: `("precision" = ANY (ARRAY['instant'::text, 'day'::text, 'month'::text, 'quarter'::text, 'year'::text, 'relative'::text, 'unknown'::text]))`

## Relationships

Outbound: `locator_id` → [`evidence.locator`](../evidence/locator.md)`.id` (+tenant).
Inbound: [`temporal.event_occurrence`](event_occurrence.md).extent_id, [`temporal.segment`](segment.md).extent_id.

## Indexes

`extent_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.make_extent`](../../functions/temporal/make_extent.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["extent"]["Insert"]`; row: `Database["temporal"]["Tables"]["extent"]["Row"]`; update: `Database["temporal"]["Tables"]["extent"]["Update"]`

## Examples

Facts that required an extent

```bash
knowledge db query entity.at --param at=2026-03-15T00:00:00Z --param entity_id=0192b000-0000-7000-8000-000000000001 --param k=0
```
explicit and carry_forward segments always have extent_id set.

Defined in: `20260912010400_km_04_temporal.sql`.
