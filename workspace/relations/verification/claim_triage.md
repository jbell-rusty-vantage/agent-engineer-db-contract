---
id: "rel:verification.claim_triage"
kind: table
schema: verification
name: claim_triage
domain: evidence
lens: evidence
aliases: []
tokens: [verification, claim_triage, verification.claim_triage, id, tenant_id, claim_id, disposition, checkability, priority, components, duplicate_of_claim_id, probe_id, rationale, decided_by, review_state, decided_at, supersedes_id]
summary: "Loop 5: what to do with a claim candidate before anyone checks it: probe it, check the docs or the registry, or not checkable (advice, experience, opinion), duplicate, out of scope; with checkability, priority components, rationale and the probe it became. Append-only; a later row supersedes."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"verification\"][\"Tables\"][\"claim_triage\"][\"Row\"]"
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# verification.claim_triage

table in domain `evidence`, lens `evidence` — Loop 5: what to do with a claim candidate before anyone checks it: probe it, check the docs or the registry, or not checkable (advice, experience, opinion), duplicate, out of scope; with checkability, priority components, rationale and the probe it became. Append-only; a later row supersedes..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `claim_id` | `uuid` | no | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 4 | `disposition` | `text` | no | — | — |
| 5 | `checkability` | `text` | no | — | — |
| 6 | `priority` | `numeric(6,2)` | yes | — | — |
| 7 | `components` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `duplicate_of_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 9 | `probe_id` | `uuid` | yes | — | FK → [`verification.probe`](probe.md).id |
| 10 | `rationale` | `text` | no | — | — |
| 11 | `decided_by` | `text` | no | — | — |
| 12 | `review_state` | `text` | no | `'agent_proposed'::text` | — |
| 13 | `decided_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `supersedes_id` | `uuid` | yes | — | FK → [`verification.claim_triage`](claim_triage.md).id |

## Constraints

- PK (id)
- check `claim_triage_checkability_check`: `(checkability = ANY (ARRAY['deterministic_local'::text, 'needs_live_model'::text, 'needs_external_service'::text, 'historical_only'::text, …`
- check `claim_triage_disposition_check`: `(disposition = ANY (ARRAY['probe'::text, 'docs_check'::text, 'registry_check'::text, 'not_checkable'::text, 'duplicate'::text, 'out_of_scop…`
- check `claim_triage_review_state_check`: `(review_state = ANY (ARRAY['agent_proposed'::text, 'human_confirmed'::text, 'human_rejected'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `duplicate_of_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `probe_id` → [`verification.probe`](probe.md)`.id`; `supersedes_id` → [`verification.claim_triage`](claim_triage.md)`.id`.
Inbound: [`verification.claim_triage`](claim_triage.md).supersedes_id.

## Indexes

`claim_triage_claim_ix`

## Triggers

_None._

## Row-level security

Enabled.
- `claim_triage_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Exposed through: [`api.claim_triage`](../api/claim_triage.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.

## TypeScript

insert: `Database["verification"]["Tables"]["claim_triage"]["Insert"]`; row: `Database["verification"]["Tables"]["claim_triage"]["Row"]`; update: `Database["verification"]["Tables"]["claim_triage"]["Update"]`

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
