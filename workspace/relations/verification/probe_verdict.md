---
id: "rel:verification.probe_verdict"
kind: table
schema: verification
name: probe_verdict
domain: evidence
lens: evidence
aliases: []
tokens: [verification, probe_verdict, verification.probe_verdict, id, tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, decided_at, supersedes_id]
summary: "Loop 4: what a probe's runs say about one claim. agent_proposed by default; a human confirmation is a separate state. An executed deterministic probe may move the claim to verified (supported) or disputed (contradicted); live arms and community claims never verify alone."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"verification\"][\"Tables\"][\"probe_verdict\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# verification.probe_verdict

table in domain `evidence`, lens `evidence` — Loop 4: what a probe's runs say about one claim. agent_proposed by default; a human confirmation is a separate state. An executed deterministic probe may move the claim to verified (supported) or disputed (contradicted); live arms and community claims never verify alone..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `claim_id` | `uuid` | no | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 4 | `probe_id` | `uuid` | no | — | FK → [`verification.probe`](probe.md).id |
| 5 | `verdict` | `evidence.support_verdict` | no | — | — |
| 6 | `cells` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `rationale` | `text` | no | — | — |
| 8 | `decided_by` | `text` | no | — | — |
| 9 | `review_state` | `text` | no | `'agent_proposed'::text` | — |
| 10 | `decided_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `supersedes_id` | `uuid` | yes | — | FK → [`verification.probe_verdict`](probe_verdict.md).id |

## Constraints

- PK (id)
- check `probe_verdict_review_state_check`: `(review_state = ANY (ARRAY['agent_proposed'::text, 'human_confirmed'::text, 'human_rejected'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `probe_id` → [`verification.probe`](probe.md)`.id`; `supersedes_id` → [`verification.probe_verdict`](probe_verdict.md)`.id`.
Inbound: [`verification.probe_verdict`](probe_verdict.md).supersedes_id.

## Indexes

`probe_verdict_claim_ix`

## Triggers

_None._

## Row-level security

Enabled.
- `probe_verdict_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Exposed through: [`api.claim_verdicts`](../api/claim_verdicts.md), [`api.community_claims`](../api/community_claims.md), [`api.probes`](../api/probes.md), [`api.source_track_record`](../api/source_track_record.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.

## TypeScript

insert: `Database["verification"]["Tables"]["probe_verdict"]["Insert"]`; row: `Database["verification"]["Tables"]["probe_verdict"]["Row"]`; update: `Database["verification"]["Tables"]["probe_verdict"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
