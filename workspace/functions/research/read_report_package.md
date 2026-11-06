---
id: "fn:research.read_report_package(uuid,text,int4)"
kind: function
schema: research
name: read_report_package
domain: research-v2
overloads: ["fn:research.read_report_package(uuid,text,int4)"]
security: definer
volatility: stable
executors: [app_reader, control_plane, executor_service, pipeline_agent, service_role]
raises: [EXACT_REVISION_UNAVAILABLE]
touches: { reads: [research.report_v2_revision], writes: [] }
tokens: [research, read_report_package, research.read_report_package]
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.read_report_package

Domain `research-v2`.

## read_report_package(uuid, text, integer) → TABLE(report_id text, revision integer, report_revision_id text, report_revision_digest text, schema_version text, report_kind text, task_id text, run_id uuid, run_head_digest text, renderer_version text, structured_body jsonb, body jsonb, ledger jsonb, assertion_refs jsonb, manifest_index jsonb, domain_report_id uuid)

function, stable, security definer, language plpgsql, config `search_path=""`. Exact research-report.v2 package read: custody refs and digests of the structured body, exact body bytes and ledger, the revision's assertion refs and its run manifest index, for the exact (report_id, revision) only and only once the run is sealed; otherwise EXACT_REVISION_UNAVAILABLE (KSA05). Bytes are fetched from custody by digest, never through this function. SECURITY DEFINER so app_reader (no util/table access by design) reads through it: p_tenant must equal app.tenant_id (knowledge_verification.assert_tenant) and every query filters by that tenant.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_report_id` | `text` | — | — |
| `p_revision` | `integer` | — | — |

Execute: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`.

Raises (mechanically extracted): `EXACT_REVISION_UNAVAILABLE`.

Touches (best effort): reads [`research.report_v2_revision`](../../relations/research/report_v2_revision.md); writes —; calls —.

TypeScript: `Database["research"]["Functions"]["read_report_package"]`.

Defined in: `20261024010100_research_report_v2_projection.sql`.
