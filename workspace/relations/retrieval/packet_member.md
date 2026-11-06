---
id: "rel:retrieval.packet_member"
kind: table
schema: retrieval
name: packet_member
domain: retrieval
aliases: [packet member]
tokens: [retrieval, packet_member, retrieval.packet_member, id, packet_id, claim_id, technical_problem_id, solution_pattern_id, advanced_usage_pattern_id, implementation_example_id, failure_mode_id, benchmark_result_id, compatibility_constraint_id, operational_practice_id, security_consideration_id, locators, verification_state, freshness, contradiction_flags, coverage_role, created_at, tenant_id, vector_item_id, search_projection_id, scores, channel_explanations, graph_paths, authority, assurance, fresh_at, contradiction_ids, supersedes_ids, covered_subquery_ids, artifact_references, member_payload, member_sha256, source_representation_id, source_document_node_id, member_kind]
summary: "One member of an evidence packet, optionally tied to a document node."
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"packet_member\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.packet_member

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — One member of an evidence packet, optionally tied to a document node.

## Columns

`id` uuid not null, `packet_id` uuid not null, `claim_id` uuid, `technical_problem_id` uuid, `solution_pattern_id` uuid, `advanced_usage_pattern_id` uuid, `implementation_example_id` uuid, `failure_mode_id` uuid, `benchmark_result_id` uuid, `compatibility_constraint_id` uuid, `operational_practice_id` uuid, `security_consideration_id` uuid, `locators` jsonb not null, `verification_state` text, `freshness` text, `contradiction_flags` jsonb not null, `coverage_role` text, `created_at` timestamp with time zone not null, `tenant_id` uuid not null, `vector_item_id` uuid, `search_projection_id` uuid, `scores` jsonb not null, `channel_explanations` text[] not null, `graph_paths` jsonb not null, `authority` text, `assurance` text, `fresh_at` timestamp with time zone, `contradiction_ids` uuid[] not null, `supersedes_ids` uuid[] not null, `covered_subquery_ids` text[] not null, `artifact_references` jsonb not null, `member_payload` jsonb not null, `member_sha256` text, `source_representation_id` uuid, `source_document_node_id` uuid, `member_kind` text

Full column table: [details](packet_member.details.md).

## Constraints

- PK (id)
- unique (tenant_id, id)
- 3 check constraints; see [details](packet_member.details.md)

## Relationships

16 outbound and 0 inbound foreign keys; full list in [details](packet_member.details.md).

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
