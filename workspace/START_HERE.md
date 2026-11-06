---
id: start
kind: entry
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
migration_head: "20261105010300"
contract_version: "0.6.0"
scope: null
---
# Start here

This workspace describes the shared AI Engineer database at migration head `20261105010300` (contract 0.6.0). It is generated from the database catalog; blocks marked `> curated` are human guidance that was validated against the catalog but is not enforced by it.

## Navigation rule (≤ 4 reads to an operation)

1. Search before reading: `rg -n "<word>" search/index.json` or `jq -c '.[] | select(.aliases[]? == "<alias>")' search/index.json`.
2. Read the **domain** page (`domains/<slug>.md`) before any relation page.
3. Read a **task** page (`tasks/<slug>.md`) if your question matches one; it names the exact named query or intent skeleton.
4. Open a **relation** or **function** page only to compose a proposal or an unusual read.
5. Never read `schema-ir.json` or `search/index.json` whole.

## Entry points

- `INDEX.md` — domains, schemas, counts.
- `relations.txt` — every relation name (grep it).
- `queries/README.md` — every named query you can run with `knowledge db query`.
- `rules/README.md` — ingestion rules the executor applies to your proposals.

## Reading and writing

Applications and agents read through named queries (role `app_reader` or `pipeline_agent`). Canonical facts are written only by `executor_service` through `temporal.begin_batch` → `temporal.assert_*` → `temporal.commit_batch`, and only via a receipt. You author intents; the knowledge executor writes. Only facts rendered as plain text or tables are enforced by the database; `> curated` blocks are guidance.
