---
id: "sch:verification"
kind: schema
name: verification
lens: evidence
domains: [evidence]
relations: 5
functions: 3
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# verification

Evidence acts 4-5: verification observations and use decisions admitted into this domain store (Knowledge Services is the shared engine; this is the admission ledger). Lens `evidence`. Domains: [`evidence`](../../domains/evidence.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`probe`](../../relations/verification/probe.md) | table | unknown | Loop 4: an experiment that tests stated claims against a matrix of environments. Cells ar… | → `conversation.thread` |
| [`probe_claim`](../../relations/verification/probe_claim.md) | table | unknown | — | → `evidence.claim`, → `verification.probe` |
| [`probe_run`](../../relations/verification/probe_run.md) | table | unknown | Loop 4: one execution of a probe in one cell. outcome pass/fail is about the probe's own … | → `orchestration.mission`, → `evidence.source_capture`, → `evidence.locator`, → `verification.probe` |
| [`probe_verdict`](../../relations/verification/probe_verdict.md) | table | unknown | Loop 4: what a probe's runs say about one claim. agent_proposed by default; a human confi… | → `evidence.claim`, → `verification.probe` |
| [`use_admission`](../../relations/verification/use_admission.md) | table | unknown | Append-only record that knowledge_verification admitted a use decision inside the writing… | — |

Functions: [`assert_admitted_use`](../../functions/verification/assert_admitted_use.md), [`guard_use_admission`](../../functions/verification/guard_use_admission.md), [`require_receipt_admission`](../../functions/verification/require_receipt_admission.md).

Types: none.
