---
id: "sch:verification"
kind: schema
name: verification
lens: evidence
domains: [evidence, verified-knowledge]
relations: 6
functions: 14
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# verification

Evidence acts 4-5: verification observations and use decisions admitted into this domain store (Knowledge Services is the shared engine; this is the admission ledger). Lens `evidence`. Domains: [`evidence`](../../domains/evidence.md), [`verified-knowledge`](../../domains/verified-knowledge.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`claim_triage`](../../relations/verification/claim_triage.md) | table | small | Loop 5: what to do with a claim candidate before anyone checks it: probe it, check the do… | → `evidence.claim`, → `verification.probe` |
| [`probe`](../../relations/verification/probe.md) | table | unknown | Loop 4: an experiment that tests stated claims against a matrix of environments. Cells ar… | → `conversation.thread` |
| [`probe_claim`](../../relations/verification/probe_claim.md) | table | unknown | — | → `evidence.claim`, → `verification.probe` |
| [`probe_run`](../../relations/verification/probe_run.md) | table | unknown | Loop 4: one execution of a probe in one cell. outcome pass/fail is about the probe's own … | → `orchestration.mission`, → `evidence.source_capture`, → `evidence.locator`, → `verification.probe` |
| [`probe_verdict`](../../relations/verification/probe_verdict.md) | table | small | Loop 4: what a probe's runs say about one claim. Append-only: a changed verdict is a new … | → `evidence.claim`, → `verification.probe` |
| [`use_admission`](../../relations/verification/use_admission.md) | table | unknown | Append-only record that knowledge_verification admitted a use decision inside the writing… | — |

Functions: [`assert_admitted_use`](../../functions/verification/assert_admitted_use.md), [`chain_anchor`](../../functions/verification/chain_anchor.md), [`chain_begin`](../../functions/verification/chain_begin.md), [`chain_fail`](../../functions/verification/chain_fail.md), [`chain_norm`](../../functions/verification/chain_norm.md), [`chain_record`](../../functions/verification/chain_record.md), [`chain_sha`](../../functions/verification/chain_sha.md), [`chain_target`](../../functions/verification/chain_target.md), [`chain_uuid`](../../functions/verification/chain_uuid.md), [`guard_human_judgment`](../../functions/verification/guard_human_judgment.md), [`guard_use_admission`](../../functions/verification/guard_use_admission.md), [`record_admitted_claim_verification`](../../functions/verification/record_admitted_claim_verification.md), [`require_admitted_use`](../../functions/verification/require_admitted_use.md), [`require_receipt_admission`](../../functions/verification/require_receipt_admission.md).

Types: none.
