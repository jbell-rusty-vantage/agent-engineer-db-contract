---
id: "rel:research.finding"
kind: table
schema: research
name: finding
domain: research
aliases: []
tokens: [research, finding, research.finding, id, mission_id, title, statement, structured, proposed_record_kind, resolution, resolved_record_id, rejection_reason, provenance_claim_id, created_at, resolved_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"finding\"][\"Row\"]"
defined_in: ["20260826000900_research.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.finding

table in domain `research`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `mission_id` | `uuid` | no | — | FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 3 | `title` | `text` | no | — | — |
| 4 | `statement` | `text` | no | — | — |
| 5 | `structured` | `jsonb` | yes | — | — |
| 6 | `proposed_record_kind` | `text` | yes | — | — |
| 7 | `resolution` | `research.finding_resolution` | no | `'pending'::research.finding_resolution` | — |
| 8 | `resolved_record_id` | `uuid` | yes | — | — |
| 9 | `rejection_reason` | `text` | yes | — | — |
| 10 | `provenance_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `resolved_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- check `finding_promoted_has_record`: `((resolution = 'promoted'::research.finding_resolution) = (resolved_record_id IS NOT NULL))`
- check `finding_proposed_record_kind_check`: `(proposed_record_kind = ANY (ARRAY['technical_problem'::text, 'solution_pattern'::text, 'advanced_usage_pattern'::text, 'implementation_exa…`
- check `finding_rejected_has_reason`: `((resolution <> 'rejected'::research.finding_resolution) OR (rejection_reason IS NOT NULL))`

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id` on delete cascade; `provenance_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`.
Inbound: none.

## Indexes

`finding_mission_idx`; `finding_unresolved_idx` where `(resolution = 'pending'::research.finding_resolution)`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["finding"]["Insert"]`; row: `Database["research"]["Tables"]["finding"]["Row"]`; update: `Database["research"]["Tables"]["finding"]["Update"]`

Defined in: `20260826000900_research.sql`.
