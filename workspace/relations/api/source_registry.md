---
id: "rel:api.source_registry"
kind: view
schema: api
name: source_registry
domain: source-intelligence
lens: corpus
aliases: []
tokens: [api, source_registry, api.source_registry, source_entity_id, source_kind, source, platform, url, topic_entity_id, topic, as_of, method, source_role_code, conflict_of_interest, method_disclosure, claims_observed, claims_checked, confirmed, qualified, refuted, median_lead_days, noise_ratio, authority_score, recommended_watch_level, current_watch_level, urls, rationale, assessment_id, self_checked]
summary: "Latest assessment per source and topic: role prior, conflict of interest, method disclosure, track record from independently checked claims, self_checked (shown, not scored, D-61), lead days, noise, derived score and a watch suggestion only from 5 checked claims (D-69)."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"source_registry\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql", "20261113120300_build08_loop4_fixup_registry_view.sql", "20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.source_registry

view in domain `source-intelligence`, lens `corpus` — Latest assessment per source and topic: role prior, conflict of interest, method disclosure, track record from independently checked claims, self_checked (shown, not scored, D-61), lead days, noise, derived score and a watch suggestion only from 5 checked claims (D-69)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `source_entity_id` | `uuid` | yes | — | — |
| 2 | `source_kind` | `text` | yes | — | — |
| 3 | `source` | `text` | yes | — | — |
| 4 | `platform` | `text` | yes | — | — |
| 5 | `url` | `text` | yes | — | — |
| 6 | `topic_entity_id` | `uuid` | yes | — | — |
| 7 | `topic` | `text` | yes | — | — |
| 8 | `as_of` | `timestamp with time zone` | yes | — | — |
| 9 | `method` | `text` | yes | — | — |
| 10 | `source_role_code` | `text` | yes | — | — |
| 11 | `conflict_of_interest` | `text` | yes | — | — |
| 12 | `method_disclosure` | `text` | yes | — | — |
| 13 | `claims_observed` | `integer` | yes | — | — |
| 14 | `claims_checked` | `integer` | yes | — | — |
| 15 | `confirmed` | `integer` | yes | — | — |
| 16 | `qualified` | `integer` | yes | — | — |
| 17 | `refuted` | `integer` | yes | — | — |
| 18 | `median_lead_days` | `numeric(8,2)` | yes | — | — |
| 19 | `noise_ratio` | `numeric(10,2)` | yes | — | — |
| 20 | `authority_score` | `numeric(5,2)` | yes | — | — |
| 21 | `recommended_watch_level` | `text` | yes | — | — |
| 22 | `current_watch_level` | `text` | yes | — | — |
| 23 | `urls` | `bigint` | yes | — | — |
| 24 | `rationale` | `text` | yes | — | — |
| 25 | `assessment_id` | `uuid` | yes | — | — |
| 26 | `self_checked` | `integer` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Named queries: `q:evidence.source_registry`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](source_registry.details.md).

## TypeScript

row: `Database["api"]["Views"]["source_registry"]["Row"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`, `20261113120300_build08_loop4_fixup_registry_view.sql`, `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
