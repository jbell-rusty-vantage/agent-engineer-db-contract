---
id: start
kind: entry
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
migration_head: "20261108120500"
contract_version: "0.6.0"
scope: null
---
# Start here

AI Engineer database at head `20261108120500` (contract 0.6.0); generated from the catalog, `> curated` blocks are guidance.

## Router: question shape → level → page

- **L1 catalog** — filter, compare, rank a kind of thing (no embeddings): [models](relations/api/models.md), [model_offerings](relations/api/model_offerings.md), [software](relations/api/software.md), [software_releases](relations/api/software_releases.md), [talks](relations/api/talks.md), [people](relations/api/people.md), [organizations](relations/api/organizations.md), [events](relations/api/events.md), [concepts](relations/api/concepts.md), [papers](relations/api/papers.md), [benchmark_scores](relations/api/benchmark_scores.md), [works_authored](relations/api/works_authored.md), [guidance_items](relations/api/guidance_items.md).
- **L2 facts and time** — true when, changed since, where a number was read: [changes_since](functions/api/changes_since.md), [price_history](functions/api/price_history.md), [fact_locators](functions/api/fact_locators.md), [entity_at](functions/api/entity_at.md), [what_changed](functions/api/what_changed.md), [modules_affected_by_release](functions/api/modules_affected_by_release.md).
- **L3 scoped semantic** — passages inside a scope (lens, tier, space, doc type, unit kind, entity, as-of, workspace): [search_unified](functions/api/search_unified.md), [talk_segments](functions/api/talk_segments.md), [document_units](functions/api/document_units.md), [document_digest](functions/api/document_digest.md).
- **L4 agentic** — budgeted loop over L1–L3 (search → read → verify with fact_locators), filed as a report: [`create_work`](ops/create_work.md) with kind `report` via [product_command](functions/api/product_command.md).

## Four reads, at most

1. `rg -n "<word>" search/index.json` (never whole); entries carry `lens` and `domain`.
2. The matching domain (`domains/<slug>.md`) or task (`tasks/<slug>.md`) page.
3. The one relation, function or operation page it names.
4. Run the named query ([queries/README.md](queries/README.md)) or the operation (`ops/<op>.md`).

## Lenses

`ours`, `private`, `corpus`, `evidence` — whose knowledge: ours (courses, notes, reports), private (one workspace's passages), corpus (industry knowledge), evidence (claims, locators, admissions). machinery and legacy: see [INDEX.md](INDEX.md).

## Entry points

[MAP.md](MAP.md) schemas by lens · [INDEX.md](INDEX.md) domains, ops, counts · `relations.txt` · [rules/README.md](rules/README.md) ingestion rules.

## Writing

Apps and agents write through product operations (`ops/`); canonical facts only via `executor_service` (`temporal.begin_batch` → `assert_*` → `commit_batch`, under a receipt). You author intents; the executor writes.
