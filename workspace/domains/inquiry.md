---
id: "dom:inquiry"
kind: domain
lens: ours
schemas: [inquiry, dataset]
aliases: [research request, acceptance, obligation, delivery, assertion, support, watch, dataset, cells]
relations: [inquiry.acceptance, inquiry.obligation, inquiry.delivery, inquiry.assertion, inquiry.support, inquiry.watch, dataset.field, dataset.row, dataset.cell, dataset.proposal]
functions: [product.check_cell_value, product.dataset_commit, product.dataset_edit, product.dataset_snapshot, product.proposal_problems, product.support_counts, product.support_detail]
tasks: [price-with-locator, what-changed-since]
summary: "Build 07 research loop (lens ours): a brief is accepted with obligations, outputs are delivered, assertions carry typed support, datasets are revisioned cells."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# Inquiry and datasets (research requests, assertions, support)

Build 07 research loop (lens ours): a brief is accepted with obligations, outputs are delivered, assertions carry typed support, datasets are revisioned cells.

> curated (model_assisted, unreviewed) — A research request starts as a `brief` work whose revision metadata is validated by
> `product.proposal_problems` (`propose_research`). `inquiry.acceptance` records that a
> workspace accepted it with numbered `inquiry.obligation` rows; `inquiry.delivery`
> (`deliver_output`, `decide_delivery`) ties an output revision — usually a `report` work —
> to an obligation. `inquiry.assertion` is a statement inside a report revision and
> `inquiry.support` its typed support (source revision, locator, capture, claim, guidance
> item, assertion, dataset cell or decision; `add_support`, `get_support`, `trace_assertion`,
> `trace_reverse`). `inquiry.watch` (`create_watch`, `set_watch_state`) keeps a question open
> for refresh.
> 
> Datasets are works too: `dataset.field` defines columns, `dataset.row` and `dataset.cell`
> hold revisioned values (a version is visible in revision n when from <= n < to), and
> `dataset.proposal` carries proposed changes (`propose_dataset_change`,
> `decide_dataset_change`). `commit_dataset_revision` snapshots cells into an immutable work
> revision (`product.dataset_snapshot`).
> 
> This is where L4 answers land: a research loop files its result as a report revision and
> supports each assertion with `q:facts.locators` locators or claims rather than prose.
> Operation pages: `ops/propose_research.md`, `ops/deliver_output.md`, `ops/add_support.md`,
> `ops/get_report.md`, `ops/create_dataset.md`. Trap: support by prose summary; only a
> locator, claim, cell or decision counts.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, brief_work_id, acceptance_no), (tenant_id, workspace_id, id); RLS | helpers only |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | table | PK (id); unique (tenant_id, workspace_id, acceptance_id, obligation_key), (tenant_id, workspace_id, id); RLS | helpers only |
| [`inquiry.delivery`](../relations/inquiry/delivery.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, revision_id, assertion_key); RLS | helpers only |
| [`inquiry.support`](../relations/inquiry/support.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`inquiry.watch`](../relations/inquiry/watch.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`dataset.field`](../relations/dataset/field.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`dataset.row`](../relations/dataset/row.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |
| [`dataset.cell`](../relations/dataset/cell.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`dataset.proposal`](../relations/dataset/proposal.md) | table | PK (id); unique (tenant_id, workspace_id, dataset_work_id, dedupe_key), (tenant_id, workspace_id, id); RLS | helpers only |

## Functions

[`product.check_cell_value`](../functions/product/check_cell_value.md), [`product.dataset_commit`](../functions/product/dataset_commit.md), [`product.dataset_edit`](../functions/product/dataset_edit.md), [`product.dataset_snapshot`](../functions/product/dataset_snapshot.md), [`product.proposal_problems`](../functions/product/proposal_problems.md), [`product.support_counts`](../functions/product/support_counts.md), [`product.support_detail`](../functions/product/support_detail.md)

## Named queries

[`q:facts.locators`](../queries/README.md), [`q:ours.works_authored`](../queries/README.md)

## Tasks

[`price-with-locator`](../tasks/price-with-locator.md), [`what-changed-since`](../tasks/what-changed-since.md)

Schemas: [`inquiry`](../schemas/inquiry/README.md), [`dataset`](../schemas/dataset/README.md).
