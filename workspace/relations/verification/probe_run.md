---
id: "rel:verification.probe_run"
kind: table
schema: verification
name: probe_run
domain: verified-knowledge
lens: evidence
aliases: []
tokens: [verification, probe_run, verification.probe_run, id, tenant_id, probe_id, cell_label, cell, resolved, lock_sha256, python_version, platform, started_at, ended_at, exit_code, outcome, observations, output_capture_id, output_locator_id, tokens_in, tokens_out, cost_usd, latency_ms, sweep_id, mission_id, origin_kind, receipt_id, created_at]
summary: "Loop 4: one execution of a probe in one cell. outcome pass/fail is about the probe's own checks, not about the claim; observations hold what was seen (warnings, exception types and messages, keys, counts). The output JSON is captured like any other source (capture method probe_execution) so verdicts cite a locator."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"verification\"][\"Tables\"][\"probe_run\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# verification.probe_run

table in domain `verified-knowledge`, lens `evidence` — Loop 4: one execution of a probe in one cell. outcome pass/fail is about the probe's own checks, not about the claim; observations hold what was seen (warnings, exception types and messages, keys, counts). The output JSON is captured like any other source (capture method probe_execution) so verdicts cite a locator..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `probe_id` | `uuid` | no | — | FK → [`verification.probe`](probe.md).id |
| 4 | `cell_label` | `text` | no | — | — |
| 5 | `cell` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `resolved` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `lock_sha256` | `text` | yes | — | — |
| 8 | `python_version` | `text` | yes | — | — |
| 9 | `platform` | `text` | yes | — | — |
| 10 | `started_at` | `timestamp with time zone` | no | — | — |
| 11 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 12 | `exit_code` | `integer` | yes | — | — |
| 13 | `outcome` | `text` | no | — | — |
| 14 | `observations` | `jsonb` | no | `'{}'::jsonb` | — |
| 15 | `output_capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](../evidence/source_capture.md).id |
| 16 | `output_locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id |
| 17 | `tokens_in` | `integer` | yes | — | — |
| 18 | `tokens_out` | `integer` | yes | — | — |
| 19 | `cost_usd` | `numeric(10,6)` | yes | — | — |
| 20 | `latency_ms` | `integer` | yes | — | — |
| 21 | `sweep_id` | `uuid` | yes | — | FK → [`acquisition.attention_sweep`](../acquisition/attention_sweep.md).id |
| 22 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 23 | `origin_kind` | `text` | no | `'standalone'::text` | — |
| 24 | `receipt_id` | `uuid` | yes | — | — |
| 25 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `probe_run_origin_kind_check`: `(origin_kind = ANY (ARRAY['standalone'::text, 'mission'::text]))`
- check `probe_run_outcome_check`: `(outcome = ANY (ARRAY['pass'::text, 'fail'::text, 'error'::text, 'skipped'::text]))`

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id`; `output_capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.id`; `output_locator_id` → [`evidence.locator`](../evidence/locator.md)`.id`; `probe_id` → [`verification.probe`](probe.md)`.id`; `sweep_id` → [`acquisition.attention_sweep`](../acquisition/attention_sweep.md)`.id`.
Inbound: none.

## Indexes

`probe_run_probe_ix`

## Triggers

_None._

## Row-level security

Enabled.
- `probe_run_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Named queries: `q:evidence.probe_matrix`, `q:evidence.probe_revalidation_due`, `q:evidence.probes`.
- Exposed through: [`api.probes`](../api/probes.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.
- Via functions (best effort): [`api.record_probe_run`](../../functions/api/record_probe_run.md).

## TypeScript

insert: `Database["verification"]["Tables"]["probe_run"]["Insert"]`; row: `Database["verification"]["Tables"]["probe_run"]["Row"]`; update: `Database["verification"]["Tables"]["probe_run"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
