---
id: "sch:acquisition"
kind: schema
name: acquisition
lens: corpus
domains: [acquisition, source-intelligence]
relations: 3
functions: 0
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# acquisition

How bytes were obtained: every product/harness/mission fetch is a ledger row before it becomes an evidence.source_capture. Search/provider attempts stay in evidence until the KS executor moves (deferred). Lens `corpus`. Domains: [`acquisition`](../../domains/acquisition.md), [`source-intelligence`](../../domains/source-intelligence.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`attention_policy`](../../relations/acquisition/attention_policy.md) | table | unknown | Loop 4: what we watch, how often (cadence, triggers), how deep (depth, selection) and on … | → `conversation.thread`, → `inquiry.watch`, → `orchestration.mission` |
| [`attention_sweep`](../../relations/acquisition/attention_sweep.md) | table | unknown | Loop 4: one execution of an attention policy: trigger, window, items seen / selected / ca… | → `orchestration.mission`, → `acquisition.attention_policy` |
| [`fetch`](../../relations/acquisition/fetch.md) | table | small | One attempt to obtain bytes from a URL — who, with what tool, outcome, hash, spend — reco… | → `evidence.source_capture`, → `acquisition.attention_sweep` |

Functions: none.

Types: none.
