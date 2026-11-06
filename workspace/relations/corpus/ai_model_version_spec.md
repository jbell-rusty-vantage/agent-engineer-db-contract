---
id: "rel:corpus.ai_model_version_spec"
kind: table
schema: corpus
name: ai_model_version_spec
domain: identity
aliases: []
tokens: [corpus, ai_model_version_spec, corpus.ai_model_version_spec, id, tenant_id, model_version_id, parameters_billions, context_tokens, modalities, specification, source_claim_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"ai_model_version_spec\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.ai_model_version_spec

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `model_version_id` | `uuid` | no | — | FK → [`corpus.ai_model_version`](ai_model_version.md).id |
| 4 | `parameters_billions` | `numeric` | yes | — | — |
| 5 | `context_tokens` | `bigint` | yes | — | — |
| 6 | `modalities` | `text[]` | yes | — | — |
| 7 | `specification` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `source_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `model_version_id` → [`corpus.ai_model_version`](ai_model_version.md)`.id` (+tenant); `source_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
Inbound: [`temporal.segment`](../temporal/segment.md).specification_id.

## Indexes

`ai_model_version_spec_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["ai_model_version_spec"]["Insert"]`; row: `Database["corpus"]["Tables"]["ai_model_version_spec"]["Row"]`; update: `Database["corpus"]["Tables"]["ai_model_version_spec"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
