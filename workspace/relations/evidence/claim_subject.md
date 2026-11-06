---
id: "rel:evidence.claim_subject"
kind: table
schema: evidence
name: claim_subject
domain: evidence
aliases: [claim role]
tokens: [evidence, claim_subject, evidence.claim_subject, tenant_id, claim_id, entity_id, role]
summary: "Entity participation in a claim as subject, object, or context."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"claim_subject\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.claim_subject

table in domain `evidence`.

> curated (model_assisted, unreviewed) — Entity participation in a claim as subject, object, or context.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `claim_id` | `uuid` | no | — | PK; FK → [`evidence.claim`](claim.md).id |
| 3 | `entity_id` | `uuid` | no | — | PK; FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `role` | `text` | no | — | PK; _curated:_ subject, object, or context. |

## Constraints

- PK (tenant_id, claim_id, entity_id, role)
- check `claim_subject_role_check`: `(role = ANY (ARRAY['subject'::text, 'object'::text, 'context'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: none.

## Indexes

_None._

## Triggers

- `km_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:evidence.claims_for_entity`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["claim_subject"]["Insert"]`; row: `Database["evidence"]["Tables"]["claim_subject"]["Row"]`; update: `Database["evidence"]["Tables"]["claim_subject"]["Update"]`

## Examples

Claims for an entity

```bash
knowledge db query evidence.claims_for_entity --param entity_id=0192b000-0000-7000-8000-000000000001 --param limit=100
```
Primary key includes role so the same entity can appear in more than one role.

Defined in: `20260912010500_km_05_evidence.sql`.
