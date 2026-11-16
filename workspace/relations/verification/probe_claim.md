---
id: "rel:verification.probe_claim"
kind: table
schema: verification
name: probe_claim
domain: verified-knowledge
lens: evidence
aliases: []
tokens: [verification, probe_claim, verification.probe_claim, tenant_id, probe_id, claim_id, expectation]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"verification\"][\"Tables\"][\"probe_claim\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# verification.probe_claim

table in domain `verified-knowledge`, lens `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 2 | `probe_id` | `uuid` | no | — | PK; FK → [`verification.probe`](probe.md).id |
| 3 | `claim_id` | `uuid` | no | — | PK; FK → [`evidence.claim`](../evidence/claim.md).id |
| 4 | `expectation` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (probe_id, claim_id)

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `probe_id` → [`verification.probe`](probe.md)`.id` on delete cascade.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `probe_claim_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Named queries: `q:evidence.probes`.
- Exposed through: [`api.probes`](../api/probes.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.
- Via functions (best effort): [`api.propose_verdict`](../../functions/api/propose_verdict.md), [`api.register_probe`](../../functions/api/register_probe.md).

## TypeScript

insert: `Database["verification"]["Tables"]["probe_claim"]["Insert"]`; row: `Database["verification"]["Tables"]["probe_claim"]["Row"]`; update: `Database["verification"]["Tables"]["probe_claim"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
