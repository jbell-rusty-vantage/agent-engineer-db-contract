---
id: "rel:evidence.source_assessment"
kind: table
schema: evidence
name: source_assessment
domain: source-intelligence
lens: evidence
aliases: []
tokens: [evidence, source_assessment, evidence.source_assessment, id, tenant_id, subject_entity_id, topic_entity_id, as_of, method, source_role_code, conflict_of_interest, method_disclosure, claims_observed, claims_checked, confirmed, qualified, refuted, median_lead_days, noise_ratio, authority_score, recommended_watch_level, rationale, inputs, assessed_by, receipt_id, supersedes_id, created_at, self_checked]
summary: "Loop 4: what we know about a source (channel, actor, organization, person) on a topic at a time. Components, never a bare score: role prior, conflict of interest, method disclosure, track record from verdicts, lead time against first-party docs, sweep noise. Append-only; a new row supersedes. authority_score is derived: (4·prior + 100·(confirmed + 0.5·qualified)) / (4 + checked)."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_assessment\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# evidence.source_assessment

table in domain `source-intelligence`, lens `evidence` — Loop 4: what we know about a source (channel, actor, organization, person) on a topic at a time. Components, never a bare score: role prior, conflict of interest, method disclosure, track record from verdicts, lead time against first-party docs, sweep noise. Append-only; a new row supersedes. authority_score is derived: (4·prior + 100·(confirmed + 0.5·qualified)) / (4 + checked)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `subject_entity_id` | `uuid` | no | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 4 | `topic_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 5 | `as_of` | `timestamp with time zone` | no | `now()` | — |
| 6 | `method` | `text` | no | — | — |
| 7 | `source_role_code` | `text` | yes | — | FK → [`content.source_role`](../content/source_role.md).code |
| 8 | `conflict_of_interest` | `text` | no | `'unknown'::text` | — |
| 9 | `method_disclosure` | `text` | no | `'not_applicable'::text` | — |
| 10 | `claims_observed` | `integer` | no | `0` | — |
| 11 | `claims_checked` | `integer` | no | `0` | — |
| 12 | `confirmed` | `integer` | no | `0` | — |
| 13 | `qualified` | `integer` | no | `0` | — |
| 14 | `refuted` | `integer` | no | `0` | — |
| 15 | `median_lead_days` | `numeric(8,2)` | yes | — | — |
| 16 | `noise_ratio` | `numeric(10,2)` | yes | — | — |
| 17 | `authority_score` | `numeric(5,2)` | yes | — | — |
| 18 | `recommended_watch_level` | `text` | yes | — | — |
| 19 | `rationale` | `text` | no | — | — |
| 20 | `inputs` | `jsonb` | no | `'{}'::jsonb` | — |
| 21 | `assessed_by` | `text` | no | — | — |
| 22 | `receipt_id` | `uuid` | yes | — | — |
| 23 | `supersedes_id` | `uuid` | yes | — | FK → [`evidence.source_assessment`](source_assessment.md).id |
| 24 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 25 | `self_checked` | `integer` | no | `0` | Loop 5 (D-61): checked claims that the subject stated and our own probes checked. Shown, never counted in confirmed / qualified / refuted or in authority_score: a check by the party that made the claim is not independent evidence of that party's reliability. |

## Constraints

- PK (id)
- 8 check constraints; see [details](source_assessment.details.md)

## Relationships

4 outbound and 1 inbound foreign keys; full list in [details](source_assessment.details.md).

## Indexes

1 indexes; see [details](source_assessment.details.md).

## Triggers

2 triggers; see [details](source_assessment.details.md).

## Row-level security

Enabled; 1 policies in [details](source_assessment.details.md).

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Named queries: `q:evidence.source_registry`.
- Exposed through: [`api.source_registry`](../api/source_registry.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`, `verifier_agent`.
- Via functions (best effort): [`api.record_source_assessment`](../../functions/api/record_source_assessment.md), [`evidence.derive_source_assessment`](../../functions/evidence/derive_source_assessment.md).

## TypeScript

insert: `Database["evidence"]["Tables"]["source_assessment"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_assessment"]["Row"]`; update: `Database["evidence"]["Tables"]["source_assessment"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
