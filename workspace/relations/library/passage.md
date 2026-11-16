---
id: "rel:library.passage"
kind: table
schema: library
name: passage
domain: library
lens: private
aliases: [passage, note passage, my notes]
tokens: [library, passage, library.passage, id, tenant_id, workspace_id, revision_id, artifact_id, message_id, passage_no, locator, text, language, tsv, content_sha256, procedure_version, created_at]
summary: "Indexed text unit of a workspace's own material (a revision, an uploaded artifact or a conversation message); lens private, or ours once released."
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"library\"][\"Tables\"][\"passage\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# library.passage

table in domain `library`, lens `private`.

> curated (model_assisted, unreviewed) — Indexed text unit of a workspace's own material (a revision, an uploaded artifact or a conversation message); lens private, or ours once released.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `revision_id` | `uuid` | yes | — | _curated:_ Set when the passage comes from an authoring.work_revision. |
| 5 | `artifact_id` | `uuid` | yes | — | _curated:_ Set when it comes from an uploaded source. |
| 6 | `message_id` | `uuid` | yes | — | _curated:_ Set when it comes from a conversation.message. |
| 7 | `passage_no` | `integer` | no | — | — |
| 8 | `locator` | `jsonb` | no | — | _curated:_ Where in the source the passage sits. |
| 9 | `text` | `text` | no | — | — |
| 10 | `language` | `regconfig` | no | `'english'::regconfig` | — |
| 11 | `tsv` | `tsvector` | yes | — | generated: `to_tsvector(language, text)` |
| 12 | `content_sha256` | `text` | no | — | — |
| 13 | `procedure_version` | `text` | no | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `passage_check`: `(num_nonnulls(revision_id, artifact_id, message_id) = 1)`
- check `passage_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `passage_locator_check`: `((locator ->> 'schema'::text) = 'aieng.locator.v1'::text)`
- check `passage_passage_no_check`: `(passage_no >= 0)`
- check `passage_procedure_version_check`: `product.nonblank(procedure_version)`
- check `passage_text_check`: `(product.nonblank(text) AND (char_length(text) <= 8000))`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,message_id` → [`conversation.message`](../conversation/message.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`passage_target_uq` unique; `passage_tenant_id_artifact_id_fkey_ix`; `passage_tenant_id_workspace_id_id_key` unique; `passage_tenant_id_workspace_id_message_id_fkey_ix`; `passage_tenant_id_workspace_id_revision_id_fkey_ix`; `passage_tsv_ix`

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`confirm_removal`](../../ops/confirm_removal.md), [`index_passages`](../../ops/index_passages.md).

## TypeScript

insert: `Database["library"]["Tables"]["passage"]["Insert"]`; row: `Database["library"]["Tables"]["passage"]["Row"]`; update: `Database["library"]["Tables"]["passage"]["Update"]`

## Examples

Search my notes (operator form)

```bash
knowledge db query retrieval.search_unified --param lenses=["private","ours"] --param limit=20 --param query=backoff --param space_slugs=["learner_notes","own_content"] --param workspace_ids=["0192a000-0000-7000-8000-000000000001"]
```
Prefer the product search operation, which applies readability rules.

Defined in: `20261105010100_product_foundation.sql`.
