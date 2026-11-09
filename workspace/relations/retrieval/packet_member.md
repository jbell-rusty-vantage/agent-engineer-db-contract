---
id: "rel:retrieval.packet_member"
kind: table
schema: retrieval
name: packet_member
domain: retrieval
lens: corpus
aliases: [packet member]
tokens: [retrieval, packet_member, retrieval.packet_member, id, packet_id, claim_id, locators, verification_state, freshness, contradiction_flags, coverage_role, created_at, tenant_id, vector_item_id, search_projection_id, scores, channel_explanations, graph_paths, authority, assurance, fresh_at, contradiction_ids, supersedes_ids, covered_subquery_ids, artifact_references, member_payload, member_sha256, source_representation_id, source_document_node_id, guidance_item_id, member_kind]
summary: "One member of an evidence packet — a verified claim, a guidance item or a source-faithful representation — with scores and locators."
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"packet_member\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# retrieval.packet_member

table in domain `retrieval`, lens `corpus` — One member of an evidence packet: a verified claim, a guidance item or a source-faithful representation, with scores and locators..

> curated (model_assisted, unreviewed) — One member of an evidence packet — a verified claim, a guidance item or a source-faithful representation — with scores and locators.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `packet_id` | `uuid` | no | — | — |
| 3 | `claim_id` | `uuid` | yes | — | — |
| 14 | `locators` | `jsonb` | no | `'[]'::jsonb` | — |
| 15 | `verification_state` | `text` | yes | — | — |
| 16 | `freshness` | `text` | yes | — | — |
| 17 | `contradiction_flags` | `jsonb` | no | `'[]'::jsonb` | — |
| 18 | `coverage_role` | `text` | yes | — | — |
| 19 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 20 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 21 | `vector_item_id` | `uuid` | yes | — | — |
| 22 | `search_projection_id` | `uuid` | yes | — | — |
| 23 | `scores` | `jsonb` | no | `'{}'::jsonb` | — |
| 24 | `channel_explanations` | `text[]` | no | `'{}'::text[]` | — |
| 25 | `graph_paths` | `jsonb` | no | `'[]'::jsonb` | — |
| 26 | `authority` | `text` | yes | — | — |
| 27 | `assurance` | `text` | yes | — | — |
| 28 | `fresh_at` | `timestamp with time zone` | yes | — | — |
| 29 | `contradiction_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 30 | `supersedes_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 31 | `covered_subquery_ids` | `text[]` | no | `'{}'::text[]` | — |
| 32 | `artifact_references` | `jsonb` | no | `'[]'::jsonb` | — |
| 33 | `member_payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 34 | `member_sha256` | `text` | yes | — | generated: `encode(digest((member_payload)::text, 'sha256'::text), 'hex'::text)` |
| 35 | `source_representation_id` | `uuid` | yes | — | Tenant-scoped authoritative source-only member target. The evidence gate accepts faithful_normalization or byte-identical source_native representations in the accepted state. |
| 36 | `source_document_node_id` | `uuid` | yes | — | Optional section identity; the composite FK requires this node to belong to source_representation_id.; _curated:_ Joined for start_ms/end_ms in api.evidence_packet. |
| 38 | `guidance_item_id` | `uuid` | yes | — | FK → [`guidance.item`](../guidance/item.md).id; _curated:_ Set when the member is a guidance.item. |
| 39 | `member_kind` | `text` | yes | — | generated: ` CASE     WHEN (claim_id IS NOT NULL) THEN 'claim'::text     WHEN (guidance_item_id IS NOT NULL) THEN 'guidance_item'::text     WHEN (source_representation_id IS NOT NULL) THEN 'source_representation'::text     ELSE NULL::text END`; _curated:_ claim, guidance_item or representation. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `packet_member_exactly_one`: `(num_nonnulls(claim_id, guidance_item_id, source_representation_id) = 1)`
- check `packet_member_sha256_ck`: `(member_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `packet_member_source_node_requires_representation_ck`: `((source_document_node_id IS NULL) OR (source_representation_id IS NOT NULL))`

## Relationships

8 outbound and 0 inbound foreign keys; full list in [details](packet_member.details.md).

## Indexes

6 indexes; see [details](packet_member.details.md).

## Triggers

2 triggers; see [details](packet_member.details.md).

## Row-level security

Enabled; 1 policies in [details](packet_member.details.md).

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.evidence_packet`.
- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["packet_member"]["Insert"]`; row: `Database["retrieval"]["Tables"]["packet_member"]["Row"]`; update: `Database["retrieval"]["Tables"]["packet_member"]["Update"]`

## Examples

Packet with members

```bash
knowledge db query retrieval.evidence_packet --param packet_id=0192c000-0000-7000-8000-000000000001
```
Members array is empty when the packet is missing.

Defined in: `20260826001000_retrieval.sql`.
