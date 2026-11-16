---
id: "sch:staging"
kind: schema
name: staging
lens: corpus
domains: [staging]
relations: 4
functions: 0
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# staging

Typed candidates, discovery results, mentions, identity resolution. Lens `corpus`. Domains: [`staging`](../../domains/staging.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`candidate`](../../relations/staging/candidate.md) | table | unknown | Proposed identity awaiting resolution; not a draft fact. | → `taxonomy.entity_kind`, → `catalog.entity`, → `evidence.source` |
| [`identity_match`](../../relations/staging/identity_match.md) | table | unknown | Scored match between a candidate and an existing entity. | → `staging.candidate`, → `catalog.entity` |
| [`resolution_decision`](../../relations/staging/resolution_decision.md) | table | unknown | create, match, reject, or defer decision with a receipt. | → `staging.candidate`, → `catalog.entity`, → `orchestration.operation_receipt` |
| [`vetting_decision`](../../relations/staging/vetting_decision.md) | table | unknown | admit, reject, or defer vetting decision with a receipt. | → `staging.candidate`, → `orchestration.operation_receipt` |

Functions: none.

Types: [`types/staging.md`](../../types/staging.md).
