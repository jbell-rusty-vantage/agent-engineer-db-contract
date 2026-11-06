---
id: "rel:evidence.source"
kind: table
schema: evidence
name: source
domain: evidence
aliases: [source, URL]
tokens: [evidence, source, evidence.source, id, tenant_id, source_class, canonical_url, url_pattern, publisher, sensitivity, license_spdx, license_notes, terms_url, robots_policy, created_at, updated_at, verification_contract_version, logical_identity, host, registrable_domain, publisher_entity_id, source_kind, first_seen_at, last_seen_at, last_encounter_kind, last_capture_id, capture_count, failure_streak, next_revisit_after, blocked_reason, state_knowledge_seq]
summary: Canonical source (URL/domain) with revisit and publisher pointers.
summary_basis: curated
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.source

table in domain `evidence`.

> curated (model_assisted, unreviewed) — Canonical source (URL/domain) with revisit and publisher pointers.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, source_class, logical_identity) |
| 3 | `source_class` | `text` | no | — | unique (tenant_id, source_class, logical_identity) |
| 4 | `canonical_url` | `text` | yes | — | — |
| 5 | `url_pattern` | `text` | yes | — | — |
| 6 | `publisher` | `text` | yes | — | — |
| 7 | `sensitivity` | `text` | no | `'public'::text` | — |
| 8 | `license_spdx` | `text` | yes | — | — |
| 9 | `license_notes` | `text` | yes | — | — |
| 10 | `terms_url` | `text` | yes | — | — |
| 11 | `robots_policy` | `text` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `verification_contract_version` | `text` | yes | — | — |
| 15 | `logical_identity` | `text` | yes | — | unique (tenant_id, source_class, logical_identity) |
| 16 | `host` | `text` | yes | — | — |
| 17 | `registrable_domain` | `text` | yes | — | _curated:_ Filter key for sources_by_domain. |
| 18 | `publisher_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id; _curated:_ Optional corpus.entity of the publisher. |
| 19 | `source_kind` | `text` | yes | — | — |
| 20 | `first_seen_at` | `timestamp with time zone` | yes | — | — |
| 21 | `last_seen_at` | `timestamp with time zone` | yes | — | — |
| 22 | `last_encounter_kind` | `text` | yes | — | — |
| 23 | `last_capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](source_capture.md).id |
| 24 | `capture_count` | `bigint` | no | `0` | — |
| 25 | `failure_streak` | `integer` | no | `0` | — |
| 26 | `next_revisit_after` | `timestamp with time zone` | yes | — | _curated:_ When the crawler may fetch again. |
| 27 | `blocked_reason` | `text` | yes | — | — |
| 28 | `state_knowledge_seq` | `bigint` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, source_class, logical_identity)
- check `source_sensitivity_check`: `(sensitivity = ANY (ARRAY['public'::text, 'restricted'::text, 'confidential'::text]))`
- check `source_source_class_check`: `(source_class = ANY (ARRAY['web_page'::text, 'api'::text, 'repository'::text, 'pdf'::text, 'image'::text, 'table'::text, 'transcript'::text…`
- check `source_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `source_verification_identity_ck`: `((verification_contract_version IS NULL) OR ((logical_identity IS NOT NULL) AND (btrim(logical_identity) <> ''::text)))`

## Relationships

Outbound: `last_capture_id` → [`evidence.source_capture`](source_capture.md)`.id`; `publisher_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id`.
Inbound: [`content.document`](../content/document.md).canonical_source_id, [`evidence.attribution`](attribution.md).source_id, [`evidence.degraded_assurance`](degraded_assurance.md).source_id, [`evidence.provider_result`](provider_result.md).source_id, [`evidence.source_capture`](source_capture.md).source_id, [`evidence.source_encounter`](source_encounter.md).source_id, [`staging.candidate`](../staging/candidate.md).source_id.

## Indexes

3 indexes; see [details](source.details.md).

## Triggers

- `source_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Named queries: `q:entity.card`, `q:evidence.sources_by_domain`.
- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.
- Via functions (best effort): [`corpus.import_research_starter_catalog`](../../functions/corpus/import_research_starter_catalog.md), [`evidence.rebuild_source_state`](../../functions/evidence/rebuild_source_state.md).

## TypeScript

insert: `Database["evidence"]["Tables"]["source"]["Insert"]`; row: `Database["evidence"]["Tables"]["source"]["Row"]`; update: `Database["evidence"]["Tables"]["source"]["Update"]`

## Examples

Sources on openai.com

```bash
knowledge db query evidence.sources_by_domain --param domain=openai.com --param limit=50
```
Empty on an unpopulated tenant.

Defined in: `20260826000300_evidence_core.sql`.
