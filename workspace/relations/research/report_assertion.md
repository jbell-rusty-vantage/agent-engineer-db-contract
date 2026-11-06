---
id: "rel:research.report_assertion"
kind: table
schema: research
name: report_assertion
domain: research
aliases: [report assertion, UTF-16 span]
tokens: [research, report_assertion, research.report_assertion, id, tenant_id, report_version_id, section_id, assertion_key, statement_kind, proposition, artifact_id, start_utf16, end_utf16, block_pointer, qualifiers, derivation]
summary: Proposition bound to an exact final Markdown span and structured block pointer.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_assertion\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_assertion

table in domain `research`.

> curated (model_assisted, unreviewed) — Offsets are UTF-16 [start,end) in the final artifact, not byte offsets or authoring-local block positions. Preserve Unicode and qualifiers; derived statements retain premises or calculations.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, report_version_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, report_version_id, id) |
| 3 | `report_version_id` | `uuid` | no | — | unique (report_version_id, assertion_key); unique (tenant_id, report_version_id, id) |
| 4 | `section_id` | `uuid` | no | — | — |
| 5 | `assertion_key` | `text` | no | — | unique (report_version_id, assertion_key) |
| 6 | `statement_kind` | `text` | no | — | — |
| 7 | `proposition` | `text` | no | — | — |
| 8 | `artifact_id` | `uuid` | no | — | — |
| 9 | `start_utf16` | `integer` | no | — | — |
| 10 | `end_utf16` | `integer` | no | — | — |
| 11 | `block_pointer` | `text` | no | — | — |
| 12 | `qualifiers` | `jsonb` | no | `'[]'::jsonb` | — |
| 13 | `derivation` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (id)
- unique (report_version_id, assertion_key)
- unique (tenant_id, report_version_id, id)
- check `report_assertion_assertion_key_check`: `(btrim(assertion_key) <> ''::text)`
- check `report_assertion_block_pointer_check`: `(block_pointer ~~ '/sections/%'::text)`
- check `report_assertion_check`: `(end_utf16 > start_utf16)`
- check `report_assertion_derivation_check`: `(jsonb_typeof(derivation) = 'object'::text)`
- check `report_assertion_proposition_check`: `(btrim(proposition) <> ''::text)`
- check `report_assertion_qualifiers_check`: `(jsonb_typeof(qualifiers) = 'array'::text)`
- check `report_assertion_start_utf16_check`: `(start_utf16 >= 0)`
- check `report_assertion_statement_kind_check`: `(statement_kind = ANY (ARRAY['reported'::text, 'observed'::text, 'derived'::text, 'interpretation'::text, 'recommendation'::text, 'illustra…`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`; `tenant_id,report_version_id,section_id` → [`research.report_section_version`](report_section_version.md)`.tenant_id,report_version_id,section_id`.
Inbound: [`research.report_assertion_claim`](report_assertion_claim.md).report_version_id,assertion_id.

## Indexes

`report_assertion_report_version_id_assertion_key_key` unique; `report_assertion_tenant_id_report_version_id_id_key` unique

## Triggers

- `artifact_retirement_f49db3d8ea1d49bc669c2167` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
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

insert: `Database["research"]["Tables"]["report_assertion"]["Insert"]`; row: `Database["research"]["Tables"]["report_assertion"]["Row"]`; update: `Database["research"]["Tables"]["report_assertion"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
