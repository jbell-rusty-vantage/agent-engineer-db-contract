---
id: "rel:research.report_assertion_claim"
kind: table
schema: research
name: report_assertion_claim
domain: research
aliases: [report evidence, claim binding]
tokens: [research, report_assertion_claim, research.report_assertion_claim, tenant_id, report_version_id, assertion_id, run_id, claim_key, claim_digest, claim_id, evidence_manifest_artifact_id, role]
summary: "Run-qualified claim identity, evidence manifest, role and optional canonical claim."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_assertion_claim\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_assertion_claim

table in domain `research` — Run-qualified immutable claim references; optional canonical claim materialization. Verification/admission remains owned by evidence and policy..

> curated (model_assisted, unreviewed) — Identity is (run_id, claim_key, claim_digest). A null claim_id is allowed at authoring time. A binding does not prove verification or admission; follow its manifest to the evidence owners.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 2 | `report_version_id` | `uuid` | no | — | — |
| 3 | `assertion_id` | `uuid` | no | — | PK |
| 4 | `run_id` | `text` | no | — | PK |
| 5 | `claim_key` | `text` | no | — | PK |
| 6 | `claim_digest` | `text` | no | — | PK |
| 7 | `claim_id` | `uuid` | yes | — | — |
| 8 | `evidence_manifest_artifact_id` | `uuid` | no | — | — |
| 9 | `role` | `text` | no | — | PK |

## Constraints

- PK (assertion_id, run_id, claim_key, claim_digest, role)
- check `report_assertion_claim_claim_digest_check`: `(claim_digest ~ '^[0-9a-f]{64}$'::text)`
- check `report_assertion_claim_claim_key_check`: `(btrim(claim_key) <> ''::text)`
- check `report_assertion_claim_role_check`: `(role = ANY (ARRAY['supports'::text, 'premise'::text, 'context'::text, 'caveat'::text, 'contradicts'::text]))`
- check `report_assertion_claim_run_id_check`: `(btrim(run_id) <> ''::text)`

## Relationships

Outbound: `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id`; `tenant_id,evidence_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`; `tenant_id,report_version_id,assertion_id` → [`research.report_assertion`](report_assertion.md)`.tenant_id,report_version_id,id`.
Inbound: none.

## Indexes

`report_assertion_claim_reverse`

## Triggers

- `artifact_retirement_0a012448c7d8383641eaef9d` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `report_projection_open` → [`research.guard_report_projection`](../../functions/research/guard_report_projection.md)
- `report_row_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:reports.assertions`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_assertion_claim"]["Insert"]`; row: `Database["research"]["Tables"]["report_assertion_claim"]["Row"]`; update: `Database["research"]["Tables"]["report_assertion_claim"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
