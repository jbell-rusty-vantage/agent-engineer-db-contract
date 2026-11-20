---
id: "rel:verification.probe"
kind: table
schema: verification
name: probe
domain: verified-knowledge
lens: evidence
aliases: []
tokens: [verification, probe, verification.probe, id, tenant_id, slug, title, hypothesis, kind, subject_entity_ids, script_path, script_sha256, environment, matrix, model_policy, budget_usd, designed_in_thread_id, designed_by, state, created_at]
summary: "Loop 4: an experiment that tests stated claims against a matrix of environments. Cells are dates (uv --exclude-newer) or explicit pins; the script is versioned by path and sha256. A design interview may have produced it."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"verification\"][\"Tables\"][\"probe\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# verification.probe

table in domain `verified-knowledge`, lens `evidence` — Loop 4: an experiment that tests stated claims against a matrix of environments. Cells are dates (uv --exclude-newer) or explicit pins; the script is versioned by path and sha256. A design interview may have produced it..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `title` | `text` | no | — | — |
| 5 | `hypothesis` | `text` | no | — | — |
| 6 | `kind` | `text` | no | — | — |
| 7 | `subject_entity_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 8 | `script_path` | `text` | yes | — | — |
| 9 | `script_sha256` | `text` | yes | — | — |
| 10 | `environment` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `matrix` | `jsonb` | no | `'[]'::jsonb` | — |
| 12 | `model_policy` | `text` | no | `'none'::text` | — |
| 13 | `budget_usd` | `numeric(10,4)` | no | `0` | — |
| 14 | `designed_in_thread_id` | `uuid` | yes | — | FK → [`conversation.thread`](../conversation/thread.md).id |
| 15 | `designed_by` | `text` | no | — | — |
| 16 | `state` | `text` | no | `'active'::text` | — |
| 17 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- check `probe_kind_check`: `(kind = ANY (ARRAY['executed'::text, 'static_docs'::text, 'resolution'::text, 'registry_check'::text, 'live_model'::text]))`
- check `probe_matrix_check`: `(jsonb_typeof(matrix) = 'array'::text)`
- check `probe_model_policy_check`: `(model_policy = ANY (ARRAY['none'::text, 'fake'::text, 'live'::text]))`
- check `probe_script_sha256_check`: `((script_sha256 IS NULL) OR (script_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `probe_state_check`: `(state = ANY (ARRAY['draft'::text, 'active'::text, 'retired'::text]))`

## Relationships

Outbound: `designed_in_thread_id` → [`conversation.thread`](../conversation/thread.md)`.id`.
Inbound: [`verification.claim_triage`](claim_triage.md).probe_id, [`verification.probe_claim`](probe_claim.md).probe_id, [`verification.probe_run`](probe_run.md).probe_id, [`verification.probe_verdict`](probe_verdict.md).probe_id.

## Indexes

`probe_tenant_id_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `probe_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Named queries: `q:evidence.claim_triage`, `q:evidence.claim_verdicts`, `q:evidence.probe_matrix`, `q:evidence.probe_revalidation_due`, `q:evidence.probes`, `q:evidence.source_track_record`.
- Exposed through: [`api.claim_triage`](../api/claim_triage.md), [`api.claim_verdicts`](../api/claim_verdicts.md), [`api.probes`](../api/probes.md), [`api.source_track_record`](../api/source_track_record.md), [`api.verified_claims`](../api/verified_claims.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.
- Via functions (best effort): [`api.register_probe`](../../functions/api/register_probe.md).

## TypeScript

insert: `Database["verification"]["Tables"]["probe"]["Insert"]`; row: `Database["verification"]["Tables"]["probe"]["Row"]`; update: `Database["verification"]["Tables"]["probe"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
