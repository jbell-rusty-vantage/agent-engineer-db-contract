---
id: "rel:content.unit_assertion_mapping"
kind: table
schema: content
name: unit_assertion_mapping
domain: content
lens: corpus
aliases: [assertion mapping, act 3]
tokens: [content, unit_assertion_mapping, content.unit_assertion_mapping, id, unit_kind, unit_kind_version, document_type_code, source_role_code, target_kind, stream_kind, relationship_kind, event_kind, subject_template, value_template, qualifier_template, time_template, deterministic, risk_floor, status, description]
summary: "Declarative act 3 — how a unit kind's attributes become an assertion (stream kind, relationship, event or attribute) with templates; deterministic mappings take the cheap path."
summary_basis: curated
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"content\"][\"Tables\"][\"unit_assertion_mapping\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# content.unit_assertion_mapping

table in domain `content`, lens `corpus` — Declarative act 3: how a unit kind's attributes become an assertion (stream kind / relationship / event / attribute) with subject, value, qualifier and time templates; deterministic mappings on first-party structured units take the cheap path, others carry a risk floor for KS verification..

> curated (model_assisted, unreviewed) — Declarative act 3 — how a unit kind's attributes become an assertion (stream kind, relationship, event or attribute) with templates; deterministic mappings take the cheap path.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `unit_kind` | `text` | no | — | — |
| 3 | `unit_kind_version` | `integer` | no | `1` | — |
| 4 | `document_type_code` | `text` | yes | — | FK → [`content.document_type`](document_type.md).code |
| 5 | `source_role_code` | `text` | yes | — | FK → [`content.source_role`](source_role.md).code |
| 6 | `target_kind` | `text` | no | — | _curated:_ stream, relationship, event or attribute. |
| 7 | `stream_kind` | `text` | yes | — | FK → [`temporal.stream_kind`](../temporal/stream_kind.md).code |
| 8 | `relationship_kind` | `text` | yes | — | FK → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md).code |
| 9 | `event_kind` | `text` | yes | — | FK → [`temporal.event_kind`](../temporal/event_kind.md).code |
| 10 | `subject_template` | `jsonb` | no | — | — |
| 11 | `value_template` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `qualifier_template` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `time_template` | `jsonb` | no | `'{"valid_from": "$capture.captured_at", "temporal_basis": "…` | — |
| 14 | `deterministic` | `boolean` | no | `true` | _curated:_ True for first-party structured units whose mapping needs no verification judgement. |
| 15 | `risk_floor` | `text` | no | `'L0'::text` | _curated:_ Minimum verification risk class for non-deterministic mappings. |
| 16 | `status` | `text` | no | `'active'::text` | — |
| 17 | `description` | `text` | no | — | — |

## Constraints

- PK (id)
- check `mapping_target_consistent`: `(((target_kind = 'stream'::text) AND (stream_kind IS NOT NULL)) OR ((target_kind = 'relationship'::text) AND (relationship_kind IS NOT NULL…`
- check `unit_assertion_mapping_risk_floor_check`: `(risk_floor = ANY (ARRAY['L0'::text, 'L1'::text, 'L2'::text, 'L3'::text]))`
- check `unit_assertion_mapping_status_check`: `(status = ANY (ARRAY['candidate'::text, 'active'::text, 'retired'::text]))`
- check `unit_assertion_mapping_target_kind_check`: `(target_kind = ANY (ARRAY['stream'::text, 'relationship'::text, 'event'::text, 'entity_attribute'::text, 'claim_candidate'::text, 'guidance…`

## Relationships

Outbound: `document_type_code` → [`content.document_type`](document_type.md)`.code`; `event_kind` → [`temporal.event_kind`](../temporal/event_kind.md)`.code`; `relationship_kind` → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md)`.code`; `source_role_code` → [`content.source_role`](source_role.md)`.code`; `stream_kind` → [`temporal.stream_kind`](../temporal/stream_kind.md)`.code`; `unit_kind,unit_kind_version` → [`content.unit_kind`](unit_kind.md)`.code,version`.
Inbound: [`evidence.extraction_record`](../evidence/extraction_record.md).mapping_id.

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

insert: `Database["content"]["Tables"]["unit_assertion_mapping"]["Insert"]`; row: `Database["content"]["Tables"]["unit_assertion_mapping"]["Row"]`; update: `Database["content"]["Tables"]["unit_assertion_mapping"]["Update"]`

## Examples

Price rows map to offering_price

```bash
knowledge db query vocab.stream_kind --param code=offering_price
```
The mapping's value_template fills amount/currency/unit and payload.meter from price_row attributes.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
