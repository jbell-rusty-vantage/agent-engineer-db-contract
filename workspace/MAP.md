---
id: map
kind: entry
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
lenses: [ours, private, corpus, evidence, machinery, legacy]
---
# Map: schemas by lens

## ours
- `access` — Who may act (lens ours): account profiles, MCP/CLI client grant… → [schema](schemas/access/README.md) · [dom:access](domains/access.md)
- `authoring` — What we author (lens ours): immutable revisions of courses, mod… → [schema](schemas/authoring/README.md) · [dom:authoring](domains/authoring.md)
- `dataset` — Build 07 research loop (lens ours): a brief is accepted with ob… → [schema](schemas/dataset/README.md) · [dom:inquiry](domains/inquiry.md)
- `inquiry` — Build 07 research loop (lens ours): a brief is accepted with ob… → [schema](schemas/inquiry/README.md) · [dom:inquiry](domains/inquiry.md)
- `learning` — What learners do (lens ours): enroll in an offer, adopt a relea… → [schema](schemas/learning/README.md) · [dom:learning](domains/learning.md)
- `library` — A workspace's own material — uploaded sources, notes, conversat… → [schema](schemas/library/README.md) · [dom:library](domains/library.md)
- `product` — The product's command/read/worker dispatchers; every `when '<op… → [schema](schemas/product/README.md) · [dom:product-operations](domains/product-operations.md)

## private
- `conversation` — A workspace's own material — uploaded sources, notes, conversat… → [schema](schemas/conversation/README.md) · [dom:library](domains/library.md)

## corpus
- `acquisition` — How bytes were obtained: every product/harness/mission fetch is… → [schema](schemas/acquisition/README.md) · [dom:acquisition](domains/acquisition.md)
- `api` — Views and functions only. The sole surface exposed to apps and … → [schema](schemas/api/README.md) · [dom:api-surface](domains/api-surface.md)
- `catalog` — Industry identities: one entity row per thing (kind + validated… → [schema](schemas/catalog/README.md) · [dom:identity](domains/identity.md)
- `content` — Immutable authored-work identity, representations, structural n… → [schema](schemas/content/README.md) · [dom:content](domains/content.md)
- `guidance` — Expert engineering knowledge as typed items (problem, solution … → [schema](schemas/guidance/README.md) · [dom:guidance](domains/guidance.md)
- `ranking` — Metric definitions/observations, features, groups, policies, sn… → [schema](schemas/ranking/README.md) · [dom:ranking](domains/ranking.md)
- `retrieval` — Vector spaces, vector catalog, retrieval plans/runs, evidence p… → [schema](schemas/retrieval/README.md) · [dom:retrieval](domains/retrieval.md)
- `staging` — Typed candidates, discovery results, mentions, identity resolut… → [schema](schemas/staging/README.md) · [dom:staging](domains/staging.md)
- `taxonomy` — Versioned multi-facet taxonomies and their enforced assignments. → [schema](schemas/taxonomy/README.md) · [dom:relationships](domains/relationships.md)
- `temporal` — A fact is a segment on a stream with a world interval and a kno… → [schema](schemas/temporal/README.md) · [dom:temporal-facts](domains/temporal-facts.md)

## evidence
- `evidence` — Sources, captures, locators, signatures, claims, support, verif… → [schema](schemas/evidence/README.md) · [dom:evidence](domains/evidence.md)
- `verification` — Evidence acts 4-5: verification observations and use decisions … → [schema](schemas/verification/README.md) · [dom:evidence](domains/evidence.md)

Machinery and legacy (hidden by default): machinery: `curriculum`, `evaluation`, `knowledge_service`, `observability`, `orchestration`, `util`; legacy: `public` — see [INDEX.md](INDEX.md).
