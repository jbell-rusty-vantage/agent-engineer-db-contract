---
id: "sch:verification"
kind: schema
name: verification
lens: evidence
domains: [evidence]
relations: 1
functions: 3
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# verification

Evidence acts 4-5: verification observations and use decisions admitted into this domain store (Knowledge Services is the shared engine; this is the admission ledger). Lens `evidence`. Domains: [`evidence`](../../domains/evidence.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`use_admission`](../../relations/verification/use_admission.md) | table | unknown | Append-only record that knowledge_verification admitted a use decision inside the writing… | — |

Functions: [`assert_admitted_use`](../../functions/verification/assert_admitted_use.md), [`guard_use_admission`](../../functions/verification/guard_use_admission.md), [`require_receipt_admission`](../../functions/verification/require_receipt_admission.md).

Types: none.
