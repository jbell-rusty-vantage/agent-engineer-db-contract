---
id: "sch:acquisition"
kind: schema
name: acquisition
lens: corpus
domains: [acquisition]
relations: 1
functions: 0
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# acquisition

How bytes were obtained: every product/harness/mission fetch is a ledger row before it becomes an evidence.source_capture. Search/provider attempts stay in evidence until the KS executor moves (deferred). Lens `corpus`. Domains: [`acquisition`](../../domains/acquisition.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`fetch`](../../relations/acquisition/fetch.md) | table | unknown | One attempt to obtain bytes from a URL — who, with what tool, outcome, hash, spend — reco… | → `evidence.source_capture` |

Functions: none.

Types: none.
