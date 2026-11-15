---
id: "sch:acquisition"
kind: schema
name: acquisition
lens: corpus
domains: [acquisition]
relations: 3
functions: 0
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# acquisition

How bytes were obtained: every product/harness/mission fetch is a ledger row before it becomes an evidence.source_capture. Search/provider attempts stay in evidence until the KS executor moves (deferred). Lens `corpus`. Domains: [`acquisition`](../../domains/acquisition.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`attention_policy`](../../relations/acquisition/attention_policy.md) | table | unknown | Loop 4: what we watch, how often (cadence, triggers), how deep (depth, selection) and on … | → `conversation.thread`, → `inquiry.watch`, → `orchestration.mission` |
| [`attention_sweep`](../../relations/acquisition/attention_sweep.md) | table | unknown | Loop 4: one execution of an attention policy: trigger, window, items seen / selected / ca… | → `orchestration.mission`, → `acquisition.attention_policy` |
| [`fetch`](../../relations/acquisition/fetch.md) | table | small | One attempt to obtain bytes from a URL — who, with what tool, outcome, hash, spend — reco… | → `evidence.source_capture`, → `acquisition.attention_sweep` |

Functions: none.

Types: none.
