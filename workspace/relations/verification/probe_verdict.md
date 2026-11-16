---
id: "rel:verification.probe_verdict"
kind: table
schema: verification
name: probe_verdict
domain: verified-knowledge
lens: evidence
aliases: []
tokens: [verification, probe_verdict, verification.probe_verdict, id, tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, decided_at, supersedes_id]
summary: "Loop 4: what a probe's runs say about one claim. Append-only: a changed verdict is a new row that supersedes. agent_proposed by default; human_confirmed and human_rejected record a person's review and are not writable by a bounded role. A supportive verdict never verifies a claim (only a Knowledge Services admission does); a deterministic probe that contradicts a proposed claim moves it to disputed."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"verification\"][\"Tables\"][\"probe_verdict\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# verification.probe_verdict

table in domain `verified-knowledge`, lens `evidence` — Loop 4: what a probe's runs say about one claim. Append-only: a changed verdict is a new row that supersedes. agent_proposed by default; human_confirmed and human_rejected record a person's review and are not writable by a bounded role. A supportive verdict never verifies a claim (only a Knowledge Services admission does); a deterministic probe that contradicts a proposed claim moves it to disputed..

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

- `probe_verdict_append_only` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `probe_verdict_human_judgment` → [`verification.guard_human_judgment`](../../functions/verification/guard_human_judgment.md)

## Row-level security

Enabled.
- `probe_verdict_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Named queries: `q:evidence.claim_triage`, `q:evidence.claim_verdicts`, `q:evidence.probes`, `q:evidence.source_track_record`, `q:ours.releases_needing_review`.
- Exposed through: [`api.claim_triage`](../api/claim_triage.md), [`api.claim_verdicts`](../api/claim_verdicts.md), [`api.community_claims`](../api/community_claims.md), [`api.probes`](../api/probes.md), [`api.source_track_record`](../api/source_track_record.md), [`api.verified_claims`](../api/verified_claims.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.
- Via functions (best effort): [`api.propose_verdict`](../../functions/api/propose_verdict.md).

## TypeScript

insert: `Database["verification"]["Tables"]["probe_verdict"]["Insert"]`; row: `Database["verification"]["Tables"]["probe_verdict"]["Row"]`; update: `Database["verification"]["Tables"]["probe_verdict"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
