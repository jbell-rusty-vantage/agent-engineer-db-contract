---
id: "sch:guidance"
kind: schema
name: guidance
lens: corpus
domains: [guidance]
relations: 4
functions: 0
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# guidance

Expert engineering knowledge as typed items (problem, solution pattern, failure mode, compatibility constraint, operational practice, implementation example, security consideration, usage pattern) bound to entities and versions. Lens `corpus`. Domains: [`guidance`](../../domains/guidance.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`assurance_level`](../../relations/guidance/assurance_level.md) | table | unknown | — | — |
| [`item`](../../relations/guidance/item.md) | table | unknown | One expert knowledge item typed by guidance.item_kind with assurance, provenance claim an… | → `guidance.item_kind`, → `guidance.assurance_level`, → `orchestration.operation_receipt`, → `evidence.claim` |
| [`item_kind`](../../relations/guidance/item_kind.md) | table | unknown | Vocabulary of guidance item kinds; payload_schema validates guidance.item.payload. | — |
| [`item_subject`](../../relations/guidance/item_subject.md) | table | unknown | Which entities an item is about and in which role (subject, component, version, alternati… | → `catalog.entity`, → `guidance.item` |

Functions: none.

Types: [`types/guidance.md`](../../types/guidance.md).

Vocabularies: [`item_kind`](../../vocabularies/guidance.item_kind.md).
