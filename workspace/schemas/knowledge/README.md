---
id: "sch:knowledge"
kind: schema
name: knowledge
domains: [knowledge-records]
relations: 13
functions: 0
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge

The treasure domain: verified technical records and their relationships. Domains: [`knowledge-records`](../../domains/knowledge-records.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`advanced_usage_pattern`](../../relations/knowledge/advanced_usage_pattern.md) | table | unknown | — | → `knowledge.record` |
| [`assurance_level`](../../relations/knowledge/assurance_level.md) | table | unknown | — | — |
| [`benchmark_result`](../../relations/knowledge/benchmark_result.md) | table | unknown | — | → `corpus.benchmark_run`, → `knowledge.record` |
| [`compatibility_constraint`](../../relations/knowledge/compatibility_constraint.md) | table | unknown | — | → `knowledge.record` |
| [`failure_mode`](../../relations/knowledge/failure_mode.md) | table | unknown | — | → `knowledge.record` |
| [`implementation_example`](../../relations/knowledge/implementation_example.md) | table | unknown | — | → `knowledge.record`, → `corpus.repository_file` |
| [`operational_practice`](../../relations/knowledge/operational_practice.md) | table | unknown | — | → `knowledge.record` |
| [`record`](../../relations/knowledge/record.md) | table | unknown | Identity of a typed engineering record with assurance and a creating receipt. | → `knowledge.assurance_level`, → `orchestration.operation_receipt`, → `evidence.claim` |
| [`record_entity_link`](../../relations/knowledge/record_entity_link.md) | table | unknown | — | → `corpus.entity`, → `knowledge.record` |
| [`record_reconciliation`](../../relations/knowledge/record_reconciliation.md) | table | unknown | Reconciliation decisions between knowledge records. The authorizing review is found throu… | → `orchestration.operation_receipt` |
| [`security_consideration`](../../relations/knowledge/security_consideration.md) | table | unknown | — | → `knowledge.record` |
| [`solution_pattern`](../../relations/knowledge/solution_pattern.md) | table | unknown | — | → `knowledge.record` |
| [`technical_problem`](../../relations/knowledge/technical_problem.md) | table | unknown | — | → `knowledge.record` |

Functions: none.

Types: [`types/knowledge.md`](../../types/knowledge.md).
