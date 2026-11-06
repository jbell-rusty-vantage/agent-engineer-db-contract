---
id: "sch:provenance"
kind: schema
name: provenance
domains: [provenance]
relations: 4
functions: 0
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# provenance

Citation graph for product/system design: conversations, local docs, specs, and tracker projections. Not the research flywheel. Domains: [`provenance`](../../domains/provenance.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`binding`](../../relations/provenance/binding.md) | table | unknown | Pointer to Linear, GitHub, or a Cursor conversation. The ledger stays here; those systems… | → `provenance.object` |
| [`edge`](../../relations/provenance/edge.md) | table | unknown | Declared citation. from was informed by / derived from / supersedes to. Not a causal debu… | → `provenance.object`, → `provenance.revision` |
| [`object`](../../relations/provenance/object.md) | table | unknown | Stable design-object identity. One row per conversation, doc, spec, issue, or PR. | — |
| [`revision`](../../relations/provenance/revision.md) | table | unknown | Immutable sealed content for one object version. Bytes live at object_path in the provena… | → `provenance.object` |

Functions: none.

Types: none.
