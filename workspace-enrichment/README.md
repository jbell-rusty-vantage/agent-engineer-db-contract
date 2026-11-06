# Workspace enrichment (curated data)

Curated guidance that the schema-workspace generator merges into the IR (`schema-ir.v1`) at the
**lowest precedence**. Nothing here may assert a structural fact; every referenced relation,
column, function, vocabulary code, query, or task must exist or the build fails
(`ENRICHMENT_INVALID`). Rendered pages mark this content `> curated (provenance, reviewed)`.

Spec: `docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md` §4.1 (input 6), §4.7, §4.8, §5.5, §6.6.

Every file starts with `format: ai-engineer-workspace-enrichment/1`. Every entry carries
`provenance: human | model_assisted` and `reviewed: <YYYY-MM-DD> | null`.

Identifiers used in this folder are **qualified names**, not IR ids: relations `schema.name`,
functions `schema.name` (overloads grouped), columns `schema.name.column`, vocabulary rows
`schema.table:code`, queries by `name` (`entity.resolve`), tasks and domains by `slug`.

| File | Contents |
|---|---|
| `domains.yaml` | The L1 domain pages and the schema → default-domain map |
| `relations.yaml` | Per-relation overlays: aliases, summary, column notes, examples |
| `terminology.yaml` | Terms → definition + related ids (`search/terminology.json`) |
| `tasks.yaml` | Task pages: question → navigation → operation → shape → pitfalls |
| `queries.yaml` | Named-query catalog (`knowledge-query-catalog.v1`), executed at build time |
| `ingestion-rules.yaml` | Ingestion rules as data (`rules/ingestion-rules.v1.json`) |

## `domains.yaml`

```yaml
format: ai-engineer-workspace-enrichment/1
schema_domains:            # default domain for every relation/function of a schema (full coverage)
  corpus: identity
  temporal: temporal-facts
domains:
  - slug: temporal-facts
    title: Temporal facts (two clocks)
    provenance: human
    reviewed: 2026-09-11
    aliases: [facts, two-clock, bitemporal]
    schemas: [temporal]
    relations: [temporal.segment, temporal.stream]     # relations that matter (5–15); overrides schema default
    functions: [temporal.assert_state, api.entity_at]
    tasks: [what-do-we-know-about-entity]
    queries: [entity.at, facts.current_by_stream]
    summary: One line, shown in INDEX.md and search.
    body: |
      Markdown. Rendered inside the curated block of domains/<slug>.md. May reference
      `schema.relation` and `q:name`; the validator checks every backticked qualified name.
```

## `relations.yaml`

```yaml
format: ai-engineer-workspace-enrichment/1
relations:
  - relation: temporal.segment
    domain: temporal-facts                # optional; overrides schema_domains
    aliases: [fact, temporal fact, state segment]
    summary: "A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to)."
    notes: |
      Markdown shown at the top of the relation page (curated block).
    column_notes:
      valid_during: "world interval `[)`, bounded below"
    examples:
      - title: Input price in March 2026 as known at head 41
        query: entity.at                   # must exist in queries.yaml
        params: { entity_id: "0192b000-0000-7000-8000-000000000001", at: "2026-03-15T00:00:00Z", k: 41 }
        note: Rows have stream_kind='model_offering_price'.
    provenance: human
    reviewed: 2026-09-11
```

## `terminology.yaml`

```yaml
format: ai-engineer-workspace-enrichment/1
terms:
  - slug: knowledge-head
    term: knowledge head
    aliases: [head, knowledge_seq, K]
    definition: Per-tenant monotonic sequence of sealed knowledge batches.
    refs: [temporal.knowledge_head, temporal.begin_batch, q:knowledge.head]
    provenance: human
    reviewed: 2026-09-11
```

## `tasks.yaml`

```yaml
format: ai-engineer-workspace-enrichment/1
tasks:
  - slug: what-do-we-know-about-entity
    title: What do we already know about <name>?
    domains: [identity, temporal-facts]
    queries: [entity.resolve, entity.card]
    aliases: [baseline, prior knowledge]
    navigation: |
      `domains/identity.md` → `queries/README.md`
    operation: |
      Markdown with ```json / ```bash blocks. A read intent embedded in ```json is validated
      against knowledge-read-intent.v1 (query names must exist in the catalog).
    expected_shape: |
      Markdown.
    pitfalls: |
      Markdown.
    provenance: human
    reviewed: 2026-09-11
```

## `queries.yaml`

Each entry becomes one catalog entry (`workspace/queries/catalog.json`). At build time the
validator runs every entry with `example` params in a read-only transaction under
`SET LOCAL ROLE <role>` and `set local app.tenant_id`; an error fails the build
(`EXAMPLE_FAILED`). Entries with `execute: false` are listed under `pending` with the reason.

```yaml
format: ai-engineer-workspace-enrichment/1
defaults:
  role: app_reader
  limit: 200
  maxLimit: 2000
  statementTimeoutMs: { cheap: 15000, medium: 15000, heavy: 60000 }
queries:
  - name: entity.resolve
    title: Find entities by name, alias, or identifier
    kind: named_query                     # named_query | retrieval
    role: app_reader                      # app_reader | pipeline_agent
    sql: select * from api.resolve_entity($1::text)
    paramOrder: [text]                    # one entry per positional placeholder; "$embedding" for retrieval vectors
    params:                               # JSON Schema (draft 2020-12 subset: type, required, properties, format, enum, default, minimum, maximum, items, additionalProperties)
      type: object
      required: [text]
      properties:
        text: { type: string, minLength: 1 }
      additionalProperties: false
    result: { shape: rows, columns: [entity_id, kind, display_name, score] }   # rows | single_row | single_json
    cost_class: cheap                     # cheap | medium | heavy
    temporal: { world_time: n/a, knowledge: head }
    pagination: null
    volatile: false
    domain: identity
    tasks: [what-do-we-know-about-entity]
    aliases: [resolve, lookup]
    example: { text: OpenAI }
    execute: true
    provenance: human
    reviewed: 2026-09-11
```

`params` properties may declare `pgType` (e.g. `uuid`, `text[]`, `timestamptz`, `bigint`,
`jsonb`) to control how the executor casts the JSON value; when absent the SQL cast wins.

## `ingestion-rules.yaml`

```yaml
format: ai-engineer-workspace-enrichment/1
version: ingestion-rules.v1
rules:
  - id: price.scope_key_is_unit
    title: Price series are keyed by unit
    basis: curated                        # enforced (database already checks it) | curated (executor checks it)
    applies_to: { proposal_kind: fact.assert_state, stream_kind: model_offering_price }
    action: rewrite                       # rewrite | reject | hold | stage | note
    detail: |
      Markdown. For `rewrite` say which field is rewritten to what.
    refs: [temporal.stream_kind:model_offering_price, temporal.segment]
    provenance: human
    reviewed: 2026-09-11
```

## Drafting

`node scripts/schema-workspace/cli.mjs enrich --draft <schema.relation | domain:slug>` prints a
YAML stub with every referenced id pre-filled, `provenance: model_assisted`, `reviewed: null`.
