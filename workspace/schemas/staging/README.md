---
id: "sch:staging"
kind: schema
name: staging
domains: [staging]
relations: 4
functions: 0
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# staging

Typed candidates, discovery results, mentions, identity resolution. Domains: [`staging`](../../domains/staging.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`candidate`](../../relations/staging/candidate.md) | table | small | Proposed identity awaiting resolution; not a draft fact. | → `taxonomy.entity_kind`, → `corpus.entity`, → `evidence.source` |
| [`identity_match`](../../relations/staging/identity_match.md) | table | unknown | Scored match between a candidate and an existing entity. | → `staging.candidate`, → `corpus.entity` |
| [`resolution_decision`](../../relations/staging/resolution_decision.md) | table | unknown | create, match, reject, or defer decision with a receipt. | → `staging.candidate`, → `corpus.entity`, → `orchestration.operation_receipt` |
| [`vetting_decision`](../../relations/staging/vetting_decision.md) | table | unknown | admit, reject, or defer vetting decision with a receipt. | → `staging.candidate`, → `orchestration.operation_receipt` |

Functions: none.

Types: [`types/staging.md`](../../types/staging.md).
