---
id: "rel:temporal.correction_reason"
kind: table
schema: temporal
name: correction_reason
domain: temporal-facts
lens: corpus
aliases: []
tokens: [temporal, correction_reason, temporal.correction_reason, code, applies_to, description]
summary: Coded reasons for a correction of our own belief (never for a change in the world). applies_to says where a code may be used. not_recorded is set by backfill only.
summary_basis: comment
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"correction_reason\"][\"Row\"]"
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# temporal.correction_reason

table in domain `temporal-facts`, lens `corpus` — Coded reasons for a correction of our own belief (never for a change in the world). applies_to says where a code may be used. not_recorded is set by backfill only..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `applies_to` | `text[]` | no | — | — |
| 3 | `description` | `text` | no | — | — |

## Constraints

- PK (code)
- check `correction_reason_applies_to_check`: `((applies_to <@ ARRAY['fact'::text, 'relationship'::text, 'merge'::text, 'split'::text]) AND (cardinality(applies_to) >= 1))`

## Relationships

Outbound: none.
Inbound: [`catalog.entity_merge`](../catalog/entity_merge.md).reason_code, [`catalog.entity_split`](../catalog/entity_split.md).reason_code, [`catalog.relationship`](../catalog/relationship.md).closed_reason, [`temporal.segment`](segment.md).correction_reason.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["temporal"]["Tables"]["correction_reason"]["Insert"]`; row: `Database["temporal"]["Tables"]["correction_reason"]["Row"]`; update: `Database["temporal"]["Tables"]["correction_reason"]["Update"]`

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
