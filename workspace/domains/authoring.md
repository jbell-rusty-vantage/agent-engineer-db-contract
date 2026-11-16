---
id: "dom:authoring"
kind: domain
lens: ours
schemas: [authoring]
aliases: [works, revisions, courses, modules, releases, distributions, offers, assets, deployments]
relations: [authoring.workspace, authoring.workspace_member, authoring.work, authoring.work_revision, authoring.revision_block, authoring.block_type, authoring.revision_binding, authoring.runtime_requirement, authoring.event, authoring.command, authoring.release, authoring.release_item, authoring.distribution, authoring.distribution_offer, authoring.distribution_member, authoring.publisher_grant, authoring.asset_scope, authoring.file_set, authoring.file_set_entry, authoring.deployment]
functions: [api.modules_affected_by_release, api.product_command, api.product_read, product.exposure, product.insert_revision, product.validate_body, product.walk_blocks]
tasks: [modules-affected-by-release, modules-covering-concept]
summary: "What we author (lens ours): immutable revisions of courses, modules, lessons, activities, briefs, reports and datasets; releases freeze closures for distribution."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# Authoring (works, revisions, releases, distribution)

What we author (lens ours): immutable revisions of courses, modules, lessons, activities, briefs, reports and datasets; releases freeze closures for distribution.

> curated (model_assisted, unreviewed) — `authoring.workspace` is a personal or shared team container with `authoring.workspace_member`
> roles (owner, editor, reader). `authoring.work` is the identity of a course, module, lesson,
> activity, brief, report, template or dataset; `authoring.work_revision` is immutable and
> `work.head_revision_id` is the mutable pointer (`revise_work` requires `p_expected_head`).
> Bodies are typed blocks (`authoring.revision_block`, `authoring.block_type`);
> `authoring.revision_binding` records which catalog entities, software or software versions a
> revision uses or covers, and `authoring.runtime_requirement` what it needs to run — this is
> what `api.works_authored.covers_concepts/uses_software` and
> `api.modules_affected_by_release` read.
> 
> Every state change is an `authoring.event` (actor kind human/agent, surface web/harness,
> review decisions with `closure_sha256`) and every command an `authoring.command` row keyed
> by idempotency key and input digest. Release: `freeze_release` computes the exposure of a
> root revision (`product.exposure`), applies author decisions to blockers and freezes
> `authoring.release` + `authoring.release_item`; `open_distribution` / `offer_release` publish
> it through `authoring.distribution` and `authoring.distribution_offer` to members or the
> public library; `authoring.publisher_grant` gates official publication. Assets
> (`authoring.asset_scope`, `authoring.file_set`, `authoring.deployment`) register uploaded
> artifacts, file sets and deployed static sites.
> 
> Read our works with `q:ours.works_authored`; write only through operations
> (`ops/create_work.md`, `ops/revise_work.md`, `ops/review_revision.md`,
> `ops/freeze_release.md`, `ops/offer_release.md`). Released course material is indexed with
> lens ours, tier 1, in the `own_content` space. Trap: agents may propose but not record human
> reviews (release_review, official_publication).

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`authoring.workspace`](../relations/authoring/workspace.md) | table | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`authoring.workspace_member`](../relations/authoring/workspace_member.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.work`](../relations/authoring/work.md) | Identity of an authored thing (course, module, lesson, activity, brief, report, template, dataset); head_revi… | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, id, kind), (tenant_id, workspace_id, slug); RLS | helpers only |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | Immutable revision of a work (title, body blocks, content hash); product operations create new ones, never up… | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, work_id, id), (tenant_id, workspace_id, work_id, revision_no); RLS | helpers only |
| [`authoring.revision_block`](../relations/authoring/revision_block.md) | table | PK (id); unique (tenant_id, revision_id, block_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.block_type`](../relations/authoring/block_type.md) | table | PK (code); RLS | helpers only |
| [`authoring.revision_binding`](../relations/authoring/revision_binding.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, revision_id, local_key); RLS | helpers only |
| [`authoring.runtime_requirement`](../relations/authoring/runtime_requirement.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, revision_id, local_key); RLS | helpers only |
| [`authoring.event`](../relations/authoring/event.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, dedupe_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.command`](../relations/authoring/command.md) | table | PK (id); unique (tenant_id, workspace_id, actor_id, idempotency_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.release`](../relations/authoring/release.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, root_work_id, release_no); RLS | helpers only |
| [`authoring.release_item`](../relations/authoring/release_item.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, release_id, item_key); RLS | helpers only |
| [`authoring.distribution`](../relations/authoring/distribution.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, distribution_id, offer_no), (tenant_id, workspace_id, distribution_id, release_id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.distribution_member`](../relations/authoring/distribution_member.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.publisher_grant`](../relations/authoring/publisher_grant.md) | table | PK (id); RLS | helpers only |
| [`authoring.asset_scope`](../relations/authoring/asset_scope.md) | table | PK (id); unique (tenant_id, artifact_id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.file_set`](../relations/authoring/file_set.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.file_set_entry`](../relations/authoring/file_set_entry.md) | table | PK (id); unique (tenant_id, workspace_id, file_set_id, path), (tenant_id, workspace_id, id); RLS | helpers only |
| [`authoring.deployment`](../relations/authoring/deployment.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id); RLS | helpers only |

## Functions

[`api.modules_affected_by_release`](../functions/api/modules_affected_by_release.md), [`api.product_command`](../functions/api/product_command.md), [`api.product_read`](../functions/api/product_read.md), [`product.exposure`](../functions/product/exposure.md), [`product.insert_revision`](../functions/product/insert_revision.md), [`product.validate_body`](../functions/product/validate_body.md), [`product.walk_blocks`](../functions/product/walk_blocks.md)

## Named queries

[`q:ours.modules_affected_by_release`](../queries/README.md), [`q:ours.works_authored`](../queries/README.md)

## Tasks

[`modules-affected-by-release`](../tasks/modules-affected-by-release.md), [`modules-covering-concept`](../tasks/modules-covering-concept.md)

Schemas: [`authoring`](../schemas/authoring/README.md).
