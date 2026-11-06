# Intent, snapshot, plan, receipt, and catalog contracts

Companion to [`../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) §5.5–§6. These are the contracts the knowledge executor accepts and emits. They are written as JSON-Schema-shaped definitions plus worked examples drawn from the experiment task; ids in the examples are illustrative UUIDv7 values.

> **Status (2026-09-12; receipt fields updated 2026-11-01 for contract 0.6.0, section 5.1):** implemented. The Zod schemas live in `ai-engineer-knowledge-services/packages/db-read/src/read-intent.ts` (read intent / snapshot) and `packages/ingestion/src/` (ingestion intent / plan / receipt); the named-query catalog is generated into `workspace/queries/catalog.json`. Where the shipped code differs from this text, the code and the workspace catalog win; known differences: parallel duplicate submissions return `duplicateOf` after polling for the winner's receipt, or `DUPLICATE_PENDING` (exit 1) after 30 s; `claim.materialize` requires `context.attemptId`; the retrieval read variant is not executed (`RETRIEVAL_UNAVAILABLE`).

Contents

1. [`knowledge-read-intent.v1`](#1-knowledge-read-intentv1)
2. [`knowledge-read-snapshot.v1`](#2-knowledge-read-snapshotv1)
3. [`knowledge-ingestion-intent.v1`](#3-knowledge-ingestion-intentv1)
4. [`knowledge-ingestion-plan.v1`](#4-knowledge-ingestion-planv1)
5. [`knowledge-ingestion-receipt.v1`](#5-knowledge-ingestion-receiptv1)
6. [`knowledge-query-catalog.v1`](#6-knowledge-query-catalogv1)
7. [Canonicalization, digests, identity](#7-canonicalization-digests-identity)
8. [Error codes and exit lattice](#8-error-codes-and-exit-lattice)
9. [Database mapping summary](#9-database-mapping-summary)

Shared conventions

- All contracts carry `schemaVersion` (the literal name), and every identifier the agent chooses (`intentId`, `opId`, `proposalId`, `subjectRef`) is a slug `^[a-z0-9][a-z0-9._-]{0,63}$`. Executor-assigned identifiers are UUIDv7.
- `context` reuses the KS operation identity fields (`packages/contracts/src/identity.ts`): `tenantId` (uuid, required), `missionId?`, `activationId?`, `attemptId?`, `correlationId` (required, agent-generated if absent), `actor` (`{ kind: "agent" | "human" | "service", id: string }`).
- Timestamps are RFC 3339 UTC. World-time intervals are `{ "from": ts | null, "to": ts | null, "bounds": "[)" }` with `from` required for facts (the database requires `valid_during` bounded below).
- Knowledge time is `knowledgeSeq` (bigint as JSON number ≤ 2^53, else string).

---

## 1. `knowledge-read-intent.v1`

One reproducible read: an ordered list of operations executed in **one read-only transaction** at one knowledge head, one tenant, one role per operation. Retrieval search is an operation variant.

```jsonc
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "openai-baseline",                     // agent slug, unique within the run
  "context": { "tenantId": "00000000-0000-7000-8000-000000000001", "correlationId": "run-2026-09-1x-a01", "actor": { "kind": "agent", "id": "eve:db-aware-research" } },
  "contract": { "migrationHead": "20260912011200", "workspaceFingerprint": "sha256:3f9c…" },  // optional; executor fails WORKSPACE_STALE on mismatch when present
  "atKnowledgeSeq": null,                            // null = current head; a number replays a past head (read-only helpers accept p_k)
  "operations": [ /* Operation */ ],
  "limits": { "maxRowsPerOp": 200, "statementTimeoutMs": 15000 }   // may only lower executor defaults
}
```

### 1.1 Operation variants

```jsonc
// kind: named_query — the default
{ "opId": "resolve", "kind": "named_query", "query": "entity.resolve",
  "params": { "text": "OpenAI", "kinds": ["organization"] },
  "role": null,            // null = catalog role; may only choose a *less* privileged role than the catalog's
  "limit": 25 }

// kind: retrieval — hybrid search; text only, the executor embeds
{ "opId": "kb", "kind": "retrieval", "query": "retrieval.hybrid_search",
  "params": { "query_text": "OpenAI API pricing 2026", "space": "technical_1536", "filters": { "document_type": ["pricing_page","changelog"] } },
  "limit": 20 }

// kind: artifact — fetch a stored artifact's bytes (JSON only) into the snapshot by reference
{ "opId": "prior", "kind": "artifact", "artifactId": "0192c0e0-…", "include": "digest_only" }   // digest_only | inline (≤ 256 KB)
```

`params` may reference earlier operations with `$<opId>.rows[<n>].<column>` or `$<opId>.value.<path>` (single-JSON results). Reference resolution is deterministic: operations run in array order; a reference to a missing row makes the operation `skipped` with reason `REF_UNRESOLVED`, never the whole intent.

### 1.2 Validation rules (executor phase "read-validate")

| Rule | Error |
|---|---|
| `query` exists in `queries/catalog.json` of the pinned workspace | `QUERY_UNKNOWN` |
| `params` validates against the catalog entry's `params` JSON Schema | `PARAMS_INVALID` |
| requested `role` ⊆ catalog role's privileges (`app_reader` ≤ `pipeline_agent`) | `ROLE_DENIED` |
| ≤ 32 operations, `limit ≤ 2000`, `statementTimeoutMs ≤ 60000` | `LIMITS_EXCEEDED` |
| `atKnowledgeSeq` ≤ current head | `HEAD_MISMATCH` |
| `contract.*` matches executor pins when supplied | `WORKSPACE_STALE` |

Validation is fully static except the head check; `knowledge-db snapshot --validate-only` runs it without touching the database.

---

## 2. `knowledge-read-snapshot.v1`

The executor's answer to a read intent. Its `snapshotDigest` is the object an ingestion intent cites as `inputSnapshot`.

```jsonc
{
  "schemaVersion": "knowledge-read-snapshot.v1",
  "snapshotId": "0192c0f1-1a2b-7c3d-8e4f-000000000001",          // executor UUIDv7
  "intentRef": { "intentId": "openai-baseline", "intentDigest": "sha256:…", "artifactId": "0192c0f0-…" },
  "context": { /* copied from intent, with executor-added executorVersion */ "executorVersion": "knowledge-executor/0.1.0" },
  "contract": { "migrationHead": "20260912011200", "workspaceFingerprint": "sha256:3f9c…", "catalogVersion": "sha256:…" },
  "knowledgeHead": { "knowledgeSeq": 41, "updatedAt": "2026-09-1xT10:03:12Z" },  // head at transaction start
  "atKnowledgeSeq": 41,                                                        // the head actually used
  "executedAt": "2026-09-1xT10:03:13Z",                                        // volatile; excluded from digests
  "operations": [
    { "opId": "resolve", "kind": "named_query", "query": "entity.resolve", "role": "app_reader",
      "params": { "text": "OpenAI", "kinds": ["organization"] },
      "status": "ok",                            // ok | empty | skipped | error | truncated
      "rowCount": 2, "truncated": false,
      "columns": ["entity_id","kind","display_name","score"],
      "rows": [ { "entity_id": "0192b000-…-0001", "kind": "organization", "display_name": "OpenAI", "score": 1.0 },
                { "entity_id": "0192b000-…-0044", "kind": "organization", "display_name": "OpenAI Foundation", "score": 0.61 } ],
      "contentDigest": "sha256:…",              // canonical(rows) — see §7
      "durationMs": 12 },
    { "opId": "card", "kind": "named_query", "query": "entity.card", "role": "app_reader",
      "params": { "entity_id": "0192b000-…-0001" }, "resolvedFrom": { "entity_id": "$resolve.rows[0].entity_id" },
      "status": "ok", "rowCount": 1, "value": { "entity": {}, "aliases": [], "facts": [], "relationships": [], "events": [], "sources": [] },
      "contentDigest": "sha256:…", "durationMs": 31 },
    { "opId": "kb", "kind": "retrieval", "query": "retrieval.hybrid_search", "role": "app_reader",
      "params": { "query_text": "OpenAI API pricing 2026", "space": "technical_1536" },
      "embedding": { "model": "text-embedding-3-small", "dimension": 1536, "inputDigest": "sha256:…" },   // never the vector itself
      "status": "ok", "rowCount": 20, "rows": [ /* chunk_id, document_id, score, snippet, locator_id */ ],
      "contentDigest": "sha256:…", "durationMs": 88 },
    { "opId": "big", "kind": "named_query", "query": "facts.history_for_stream", "status": "truncated", "rowCount": 2000,
      "overflow": { "artifactId": "0192c0f2-…", "totalRows": 5312, "contentDigest": "sha256:…" }, "rows": [ /* first 200 */ ] }
  ],
  "snapshotDigest": "sha256:…",       // sha256 over canonical([ {opId, query, params, role, atKnowledgeSeq, contentDigest} ... ]) in array order
  "storage": { "artifactId": "0192c0f1-…", "bucket": "research-ingestion-intents", "objectPath": "…/…json", "lineage": [ { "relation": "derived_from", "to": "0192c0f0-…" } ] }
}
```

Rules

- One transaction: `set transaction read only; set local app.tenant_id; set local statement_timeout`. Per operation `SET LOCAL ROLE <role>` then `RESET ROLE`.
- `rows` are JSON objects keyed by column; `bytea`/`vector` columns are rendered as `sha256:` digests, never raw.
- Two executions at the same `atKnowledgeSeq` with the same intent must yield the same `snapshotDigest` unless a catalog query is declared `volatile: true` (e.g. `staging.unresolved` sorted by `created_at` with ties); such ops are excluded from `snapshotDigest` and flagged `volatile: true` in the snapshot.
- The snapshot is stored before it is returned; the returned object includes `storage`.

---

## 3. `knowledge-ingestion-intent.v1`

Authored by the agent. Describes **what should become true**, with evidence, against a specific snapshot and knowledge head. It never contains SQL and never names database roles.

### 3.1 Envelope

```jsonc
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "openai-products-2026-09-11",
  "context": { "tenantId": "00000000-0000-7000-8000-000000000001", "correlationId": "run-…", "attemptId": null, "missionId": null,
               "actor": { "kind": "agent", "id": "eve:db-aware-research" } },
  "contract": { "migrationHead": "20260912011200", "workspaceFingerprint": "sha256:3f9c…", "rulesVersion": "ingestion-rules.v1@sha256:9ab…" },
  "inputSnapshot": { "snapshotId": "0192c0f1-…", "snapshotDigest": "sha256:…", "knowledgeSeq": 41 },
  "expectedKnowledgeHead": 41,
  "onStale": "rebase_if_disjoint",                  // fail | rebase_if_disjoint
  "evidence": { "verificationRuns": [ { "runId": "vr_01J…", "manifestDigest": "sha256:…" } ] },
  "asOf": "2026-09-11",                              // the report's as-of date; default world-time 'to' for observation_bounded facts
  "subjects": [ /* Subject */ ],
  "proposals": [ /* Proposal */ ],
  "notes": "free text for humans; excluded from idempotency key",
  "idempotencyKey": "sha256:…"                        // optional in the file; computed and verified by the executor (§7)
}
```

### 3.2 Subjects

Subjects bind proposal references to entities. A subject is either **resolved** (exists in the snapshot) or **new**.

```jsonc
{ "ref": "openai", "mode": "resolved", "entityId": "0192b000-…-0001", "kind": "organization",
  "resolvedFrom": { "snapshotOpId": "resolve", "row": 0 } }

{ "ref": "gpt-5-6-terra-offering", "mode": "new", "kind": "model_offering",
  "displayName": "GPT-5.6 Terra (API)",
  "aliases": [ { "alias": "gpt-5.6-terra", "aliasKind": "api_model_id" } ],
  "identifiers": [ { "scheme": "openai_model_id", "value": "gpt-5.6-terra" } ],
  "typedPayload": { "modality": ["text","image"], "deployment": "api" },      // validated against the kind's typed table columns
  "onMatch": "review",                    // review | use_existing | fail — what to do if resolve_entity finds a strong match
  "evidence": [ { "runId": "vr_01J…", "claimId": "c_0007" } ] }
```

The `kind` must be a `taxonomy.entity_kind.code`. `typedPayload` keys must be columns of that kind's `canonical_table` (the workspace page for the typed table lists them). `new` subjects imply an `entity.create` proposal; listing one explicitly is optional and must agree.

### 3.3 Proposals

Common fields

```jsonc
{ "proposalId": "p-01", "kind": "<proposal kind>", "belief": "accepted",     // accepted | disputed | unknown
  "evidence": [ { "runId": "vr_01J…", "claimId": "c_0012", "locatorRef": "q_03", "role": "primary" } ],   // ≥ 1 for all kinds except candidate.stage
  "dependsOn": ["p-00"],                                                       // optional explicit ordering
  "rationale": "one sentence for the reviewer" }
```

Kinds and kind-specific fields (see spec §6.1 for the executor action per kind):

| kind | fields |
|---|---|
| `entity.create` | `subjectRef` (a `new` subject) |
| `entity.alias` | `subjectRef`, `alias`, `aliasKind` |
| `entity.identifier` | `subjectRef`, `scheme`, `value` |
| `relationship.assert` | `relationshipKind`, `fromRef`, `toRef`, `qualifier?`, `episode?`, `properties?` (validated by `relationship_kind.property_schema`), `worldInterval?` (required when the kind is temporal), `extent?`, `temporalBasis` |
| `fact.assert_state` | `subjectRef` **or** `relationshipRef` (a `proposalId` of a `relationship.assert` or an existing `relationshipId`), `streamKind`, `scopeKey?` (default `""`), `worldInterval`, `status?`, `amount?`, `currency?`, `unit?`, `refEntityRef?`, `payload?`, `extent?`, `temporalBasis`, `specificationRef?` |
| `event.assert` | `eventKind`, `subjectRef`, `objectRef?`, `occurredDuring` (world interval), `precision`, `occurrenceKind` (`actual|scheduled|cancelled`), `payload?`, `extent?` |
| `support.admit` | `targetRef` (a fact/event `proposalId` or existing `segmentId`/`occurrenceId`), `supportRole` (`primary|corroborating|contradicting`), evidence with `locatorRef` required |
| `claim.materialize` | `claimIds[]` from one run; implied when other proposals cite claims not yet in `evidence.claim` |
| `metric.observe` | `subjectRef`, `metricKind`, `value`, `unit?`, `observedAt`, `evidence` with `locatorRef` |
| `candidate.stage` | `entityKind`, `displayName`, `payload`, `reason` (`identity_ambiguous|no_stream_kind|needs_human`), `evidence?` |
| `report.publish` | `reportArtifactId` (registered by the verification run), `title`, `asOf`, `claimIds[]`; staged: requires `context.missionId` today |

`extent` is `{ "sourceText": "March 2026", "precision": "month", "earliest": "2026-03-01", "latest": "2026-03-31", "locatorRef": "q_11" }`; the executor calls `temporal.make_extent`. `temporalBasis ∈ explicit | carry_forward | observation_bounded | unresolved`; `explicit`/`carry_forward` require `extent`.

### 3.4 Worked example (experiment task, trimmed)

```jsonc
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "openai-products-2026-09-11",
  "context": { "tenantId": "00000000-0000-7000-8000-000000000001", "correlationId": "exp3-a-r1", "actor": { "kind": "agent", "id": "eve:db-aware-research" } },
  "contract": { "migrationHead": "20260912011200", "workspaceFingerprint": "sha256:3f9c…", "rulesVersion": "ingestion-rules.v1@sha256:9ab…" },
  "inputSnapshot": { "snapshotId": "0192c0f1-…", "snapshotDigest": "sha256:5e1…", "knowledgeSeq": 41 },
  "expectedKnowledgeHead": 41,
  "onStale": "rebase_if_disjoint",
  "asOf": "2026-09-11",
  "evidence": { "verificationRuns": [ { "runId": "vr_01J8Q…", "manifestDigest": "sha256:c0d…" } ] },
  "subjects": [
    { "ref": "openai", "mode": "resolved", "entityId": "0192b000-…-0001", "kind": "organization" },
    { "ref": "gpt-5.6", "mode": "resolved", "entityId": "0192b000-…-0102", "kind": "ai_model" },
    { "ref": "gpt-5.6-terra-offering", "mode": "new", "kind": "model_offering", "displayName": "GPT-5.6 Terra (API)",
      "aliases": [ { "alias": "gpt-5.6-terra", "aliasKind": "api_model_id" } ],
      "identifiers": [ { "scheme": "openai_model_id", "value": "gpt-5.6-terra" } ],
      "typedPayload": { "deployment": "api" }, "onMatch": "review",
      "evidence": [ { "runId": "vr_01J8Q…", "claimId": "c_0007" } ] }
  ],
  "proposals": [
    { "proposalId": "p-01", "kind": "relationship.assert", "relationshipKind": "offered_as", "fromRef": "gpt-5.6", "toRef": "gpt-5.6-terra-offering",
      "temporalBasis": "observation_bounded", "belief": "accepted",
      "evidence": [ { "runId": "vr_01J8Q…", "claimId": "c_0007", "locatorRef": "q_02", "role": "primary" } ],
      "rationale": "Models page lists gpt-5.6-terra as an API offering of GPT-5.6." },
    { "proposalId": "p-02", "kind": "fact.assert_state", "subjectRef": "gpt-5.6-terra-offering", "streamKind": "model_offering_availability",
      "worldInterval": { "from": "2026-08-20T00:00:00Z", "to": null, "bounds": "[)" }, "status": "ga",
      "extent": { "sourceText": "August 20, 2026", "precision": "day", "earliest": "2026-08-20", "latest": "2026-08-20", "locatorRef": "q_04" },
      "temporalBasis": "explicit", "belief": "accepted",
      "evidence": [ { "runId": "vr_01J8Q…", "claimId": "c_0009", "locatorRef": "q_04", "role": "primary" } ] },
    { "proposalId": "p-03", "kind": "fact.assert_state", "subjectRef": "gpt-5.6-terra-offering", "streamKind": "model_offering_price",
      "worldInterval": { "from": "2026-08-20T00:00:00Z", "to": null, "bounds": "[)" }, "amount": 2.50, "currency": "USD", "unit": "per_1m_input_tokens",
      "extent": { "sourceText": "August 20, 2026", "precision": "day", "earliest": "2026-08-20", "latest": "2026-08-20", "locatorRef": "q_04" },
      "temporalBasis": "explicit", "belief": "accepted",
      "evidence": [ { "runId": "vr_01J8Q…", "claimId": "c_0011", "locatorRef": "q_06", "role": "primary" } ] },
    { "proposalId": "p-04", "kind": "fact.assert_state", "subjectRef": "gpt-5.6-terra-offering", "streamKind": "model_offering_price",
      "worldInterval": { "from": "2026-08-20T00:00:00Z", "to": null, "bounds": "[)" }, "amount": 10.00, "currency": "USD", "unit": "per_1m_output_tokens",
      "extent": { "sourceText": "August 20, 2026", "precision": "day", "earliest": "2026-08-20", "latest": "2026-08-20", "locatorRef": "q_04" },
      "temporalBasis": "explicit", "belief": "accepted",
      "evidence": [ { "runId": "vr_01J8Q…", "claimId": "c_0011", "locatorRef": "q_06", "role": "primary" } ] },
    { "proposalId": "p-05", "kind": "event.assert", "eventKind": "model_release", "subjectRef": "gpt-5.6", "objectRef": "openai",
      "occurredDuring": { "from": "2026-08-20T00:00:00Z", "to": "2026-08-21T00:00:00Z", "bounds": "[)" }, "precision": "day", "occurrenceKind": "actual",
      "belief": "accepted", "evidence": [ { "runId": "vr_01J8Q…", "claimId": "c_0009", "locatorRef": "q_04", "role": "primary" } ] },
    { "proposalId": "p-06", "kind": "candidate.stage", "entityKind": "organization", "displayName": "OpenAI Foundation",
      "payload": { "note": "resolve_entity returned score 0.61; unclear whether distinct from OpenAI" }, "reason": "identity_ambiguous" }
  ]
}
```

Note on `p-03`/`p-04`: two `model_offering_price` facts on the same subject and interval do **not** collide because `unit` is part of the fact's identity only through `scope_key`. The rules page (`rules/README.md#prices`) says: set `scopeKey` to the unit (`"per_1m_input_tokens"`) so each price series is its own stream. The executor's rule check (`rule: price.scope_key_is_unit`, basis `curated`) rewrites a missing `scopeKey` and records the rewrite in the plan; the exclusion constraint would otherwise reject the second one at commit. The experiment's injected validation failure uses `unit: "per_1k_tokens"` (not in `unit_values`) to trigger `VOCABULARY_VIOLATION`.

---

## 4. `knowledge-ingestion-plan.v1`

Output of `knowledge-ingest plan|validate` and stored before `submit` applies. Deterministic for a given intent, database head, rules version, and executor version.

```jsonc
{
  "schemaVersion": "knowledge-ingestion-plan.v1",
  "planId": "0192c100-…",
  "intentRef": { "intentId": "openai-products-2026-09-11", "intentDigest": "sha256:…", "idempotencyKey": "sha256:…", "artifactId": "0192c0ff-…" },
  "executor": { "version": "knowledge-executor/0.1.0", "rulesVersion": "ingestion-rules.v1@sha256:9ab…", "migrationHead": "20260912011200" },
  "head": { "snapshot": 41, "current": 41, "stale": false, "rebased": false, "whatChanged": [] },
  "evidence": { "runs": [ { "runId": "vr_01J8Q…", "sealed": true, "manifestDigestMatches": true } ],
                "claims": [ { "runId": "vr_01J8Q…", "claimId": "c_0007", "verdict": "directly_supported", "eligible": true, "existingClaimRowId": null } ] },
  "subjects": [
    { "ref": "openai", "resolution": "resolved", "entityId": "0192b000-…-0001", "lifecycle": "active" },
    { "ref": "gpt-5.6-terra-offering", "resolution": "create", "matches": [ { "entityId": "0192b000-…-0310", "score": 0.42, "basis": "alias" } ], "plannedEntityId": "0192c101-…" }
  ],
  "proposals": [
    { "proposalId": "p-01", "outcome": "admitted", "actions": [ { "fn": "temporal.assert_relationship", "args": { "kind": "offered_as", "from": "0192b000-…-0102", "to": "$subject:gpt-5.6-terra-offering", "valid_during": null, "claim": "$claim:c_0007" } } ] },
    { "proposalId": "p-02", "outcome": "admitted", "actions": [ { "fn": "temporal.make_extent", "args": {} }, { "fn": "temporal.assert_state", "args": { "stream_kind": "model_offering_availability", "status": "ga", "valid_during": "[2026-08-20T00:00:00Z,)" } } ] },
    { "proposalId": "p-03", "outcome": "admitted", "rewrites": [ { "rule": "price.scope_key_is_unit", "field": "scopeKey", "from": null, "to": "per_1m_input_tokens" } ], "actions": [ /* … */ ] },
    { "proposalId": "p-04", "outcome": "no_op_duplicate", "existing": { "segmentId": "0192b9aa-…", "k_from": 37 }, "actions": [] },
    { "proposalId": "p-05", "outcome": "admitted", "actions": [ { "fn": "temporal.assert_event", "args": { "event_kind": "model_release" } } ] },
    { "proposalId": "p-06", "outcome": "review_required", "reason": "identity_ambiguous", "actions": [ { "table": "staging.candidate", "op": "insert" } ] }
  ],
  "ruleChecks": [ { "rule": "price.currency_iso4217", "basis": "enforced", "result": "pass" }, { "rule": "table_cell_requires_context_quote", "basis": "curated", "result": "pass" } ],
  "plannedOutcome": "partial",                      // applied | noop | partial | rejected
  "plannedSummary": { "admitted": 4, "no_op_duplicate": 1, "review_required": 1, "held": 0, "quarantined": 0, "superseded": 0 },
  "order": ["claims", "p-06", "subjects", "p-01", "p-02", "p-03", "p-05"],
  "errors": []                                       // non-empty ⇒ plannedOutcome = rejected and submit refuses
}
```

`actions[].args` are structured records; the executor renders parameterized calls from them. `$subject:`/`$claim:` placeholders are resolved during apply.

---

## 5. `knowledge-ingestion-receipt.v1`

Returned by `submit`, `status`, and `receipt`. Backed by `orchestration.operation_receipt` (immutable) plus `temporal.knowledge_batch`.

```jsonc
{
  "schemaVersion": "knowledge-ingestion-receipt.v1",
  "receiptId": "0192c110-…",                          // orchestration.operation_receipt.id
  "operationIntentId": "0192c10f-…",                   // orchestration.operation_intent.id
  "intentRef": { "intentId": "openai-products-2026-09-11", "intentDigest": "sha256:…", "idempotencyKey": "sha256:…" },
  "planRef": { "planId": "0192c100-…", "artifactId": "0192c102-…" },
  "outcome": "partial",                                // applied | rejected | noop | partial   (= operation_receipt.outcome)
  "knowledgeBatch": { "batchId": "0192c111-…", "knowledgeSeq": 42, "inputDigest": "sha256:…" },   // null when rejected/noop without batch
  "head": { "before": 41, "after": 42, "rebased": false },
  "proposals": [
    { "proposalId": "p-01", "outcome": "admitted", "created": { "relationshipId": "0192c112-…", "segmentId": "0192c113-…" } },
    { "proposalId": "p-02", "outcome": "admitted", "created": { "extentId": "…", "streamId": "…", "segmentId": "…" }, "supersedes": [] },
    { "proposalId": "p-03", "outcome": "admitted", "created": { "segmentId": "…" }, "supersedes": ["0192b9a0-…"] },
    { "proposalId": "p-04", "outcome": "no_op_duplicate", "existing": { "segmentId": "0192b9aa-…" } },
    { "proposalId": "p-05", "outcome": "admitted", "created": { "eventId": "…", "occurrenceId": "…" } },
    { "proposalId": "p-06", "outcome": "review_required", "created": { "candidateId": "…" } }
  ],
  "subjects": [ { "ref": "gpt-5.6-terra-offering", "entityId": "0192c101-…", "created": true } ],
  "claims": [ { "runId": "vr_01J8Q…", "claimId": "c_0007", "claimRowId": "0192c114-…", "locatorIds": ["…"] } ],
  "affectedRefs": [ { "schema": "corpus", "table": "entity", "id": "0192c101-…" }, { "schema": "temporal", "table": "segment", "id": "…" } ],
  "targets": [                                         // additive (contract 0.6.0): the rows written to orchestration.operation_receipt_target, in ordinal order
    { "schema": "corpus", "table": "entity", "id": "0192c101-…", "role": "subject", "action": "created", "proposalId": null, "entityId": "0192c101-…", "entityKind": "organization", "claimId": null },
    { "schema": "evidence", "table": "claim", "id": "0192c114-…", "role": "provenance", "action": "created", "proposalId": "p-01", "entityId": null, "entityKind": null, "claimId": "0192c114-…" }
  ],
  "report": null,                                      // additive (contract 0.6.0): the research.report_v2_* projection of an AI Engineer exact-use apply; see 5.1
  "duplicateOf": null,                                 // receiptId when this submission matched an existing idempotency key
  "priorReceiptsForIntentId": [],                      // receipts with the same intentId but different keys
  "failure": null,                                     // { code, message, details, sqlstate?, whatChanged? } when outcome = rejected
  "storage": { "intentArtifactId": "…", "planArtifactId": "…", "receiptArtifactId": "…", "lineage": [ { "relation": "produced_by", "from": "receipt", "to": "plan" }, { "relation": "consumed_by", "from": "receipt", "to": "intent" } ], "storageState": "stored" },
  "operation": { "knowledgeServiceOperationId": "…", "ownershipMode": "eve" },
  "verify": { "suggestedReadIntent": { "schemaVersion": "knowledge-read-intent.v1", "intentId": "verify-openai-products-2026-09-11", "operations": [ { "opId": "changed", "kind": "named_query", "query": "entity.what_changed", "params": { "entity_id": "0192c101-…", "k_from": 41, "k_to": 42 } } ] } },
  "executedAt": "2026-09-1xT10:41:00Z", "executorVersion": "knowledge-executor/0.1.0"
}
```

### 5.1 Receipt targets, report projection and origin (contract 0.6.0, migration `20261031010000`)

Added by the provenance sprint (OVE-204 slice 3; KS `packages/knowledge-db/src/ingestion/receipt.ts`,
`receipt-targets.ts`, `executor.ts`). Both receipt fields are additive to `knowledge-ingestion-receipt.v1`; receipts
written before 0.6.0 omit them. A rejected receipt carries `targets: []` and `report: null`; a `noop` receipt (no batch)
lists the reused subject entities and claims as `reused` targets.

- **`targets[]`**: one entry per native row the receipt `created`, `reused` (already present, not rewritten),
  `superseded` (closed) or `staged`, written to `orchestration.operation_receipt_target` in the apply transaction after
  the receipt row, and returned as written. Fields: `schema` (`corpus`, `staging`, `temporal`, `evidence`, `knowledge`,
  `ranking`, `research`), `table`, `id` (text; composite ids are JSON tuples), `role` (`subject`, `canonical`,
  `supporting`, `provenance`, `staging`, `projection`), `action`, `proposalId` (the proposal that touched the row, or
  null), `entityId`/`entityKind` (read from `corpus.entity`; an entity id that names no row in the tenant is dropped to
  null rather than failing the apply) and `claimId` (the `evidence.claim` the row carries, or null). Unlike
  `affectedRefs`, which stays the unchanged K01 effect-receipt payload, targets include reused rows and name the
  proposal.
- **`report`**: on the AI Engineer exact-use path only (receipt `requires_admission`, `use_decision_id`,
  `bound_effect_digest`), the `research.report_v2_*` projection derived from the component use decision:
  `{ reportId, revision, reportRevisionId, reportRevisionDigest, runId, verificationSnapshotDigest, useDecisionId,
  subjectKind: "report" | "assertion", assertionRefDigest, resolution: "report_subject" |
  "latest_revision_citing_assertion", candidateRevisions, assertions }`. The projection rows also appear in `targets`
  with role `projection` (`created`, or `reused` when already projected). A guard mismatch rolls the whole apply back
  (KSA05/KSA07). `null` otherwise.
- **Origin digest** (database columns, not receipt JSON): for an exact-use intent the executor writes
  `orchestration.operation_intent.origin_digest`/`origin_kind` (the digest of the originating origin that
  `knowledge_verification.origin` records) and, for `origin_kind = 'mission_invocation'`, the Mission Control coordinates
  `mc_mission_id`, `mc_run_id`, `mc_activation_id`, `mc_operation_id`, `mc_operation_attempt`,
  `mc_execution_generation`, `mc_lane`; `orchestration.operation_receipt.origin_digest` repeats the digest. A
  materialized `evidence.claim` carries `producer_origin_digest` (exact-use) or `producer_attempt_id`; one is required
  (`claim_producer_identity`; the executor error is `PRODUCER_REQUIRED`). Everything one Mission Control run produced is
  `select * from orchestration.mission_run_effects where mc_run_id = $1`.

Rejected example (`REBASE_REQUIRED`):

```jsonc
{ "schemaVersion": "knowledge-ingestion-receipt.v1", "receiptId": "0192c120-…", "outcome": "rejected", "knowledgeBatch": null,
  "head": { "before": 41, "after": 43, "rebased": false },
  "failure": { "code": "REBASE_REQUIRED", "message": "knowledge head advanced 41→43 and 1 proposal touches a changed slot",
               "whatChanged": [ { "subjectRef": "gpt-5.6-terra-offering", "entityId": "…", "changes": [ { "kind": "segment", "streamKind": "model_offering_price", "scopeKey": "per_1m_input_tokens", "opened": ["…"], "closed": ["…"], "k": 43 } ] } ],
               "touchedBy": ["p-03"] },
  "proposals": [ { "proposalId": "p-03", "outcome": "superseded_candidate", "note": "re-snapshot and compare" } ] }
```

---

## 6. `knowledge-query-catalog.v1`

`workspace/queries/catalog.json`; rendered from `workspace-enrichment/queries.yaml`; every entry is executed against the disposable database during `workspace:validate` with its `example` params.

```jsonc
{
  "schemaVersion": "knowledge-query-catalog.v1",
  "catalogVersion": "sha256:…",                       // digest of canonical(entries)
  "migrationHead": "20260912011200",
  "defaults": { "role": "app_reader", "limit": 200, "maxLimit": 2000, "statementTimeoutMs": { "cheap": 15000, "medium": 15000, "heavy": 60000 } },
  "entries": [
    { "id": "q:entity.resolve", "name": "entity.resolve", "title": "Find entities by name/alias/identifier", "role": "app_reader",
      "sql": "select * from api.resolve_entity($1::text, $2::text[], $3::int)",
      "params": { "type": "object", "required": ["text"], "properties": { "text": { "type": "string", "minLength": 1 }, "kinds": { "type": "array", "items": { "type": "string" }, "default": null }, "limit": { "type": "integer", "maximum": 100, "default": 25 } }, "additionalProperties": false },
      "paramOrder": ["text", "kinds", "limit"],
      "result": { "shape": "rows", "columns": ["entity_id","kind","display_name","score","matched_on"] },
      "cost_class": "cheap", "temporal": { "world_time": "n/a", "knowledge": "head" }, "pagination": null, "volatile": false,
      "domain": "identity", "tasks": ["what-do-we-know-about-entity"], "example": { "text": "OpenAI" } },

    { "id": "q:entity.at", "name": "entity.at", "title": "Facts for one entity at a world time as known at a knowledge seq", "role": "app_reader",
      "sql": "select * from api.entity_at($1::uuid, $2::timestamptz, $3::bigint)", "paramOrder": ["entity_id", "at", "k"],
      "params": { "type": "object", "required": ["entity_id"], "properties": { "entity_id": { "type": "string", "format": "uuid" }, "at": { "type": "string", "format": "date-time", "default": "now()" }, "k": { "type": ["integer","null"], "default": null } }, "additionalProperties": false },
      "result": { "shape": "rows" }, "cost_class": "cheap", "temporal": { "world_time": "param:at", "knowledge": "param:k" }, "domain": "temporal-facts" },

    { "id": "q:facts.history_for_stream", "name": "facts.history_for_stream", "role": "pipeline_agent",
      "sql": "select s.id, s.valid_during, s.k_from, s.k_to, s.status, s.amount, s.currency, s.unit, s.belief, s.temporal_basis, s.replaces_segment_id from temporal.segment s join temporal.stream st on st.id = s.stream_id where st.subject_entity_id = $1 and st.kind = $2 and st.scope_key = coalesce($3,'') order by s.k_from, lower(s.valid_during) limit $4 offset $5",
      "paramOrder": ["entity_id", "stream_kind", "scope_key", "limit", "offset"],
      "pagination": { "kind": "offset", "limitParam": "limit", "offsetParam": "offset" }, "cost_class": "medium", "domain": "temporal-facts" },

    { "id": "q:retrieval.hybrid_search", "name": "retrieval.hybrid_search", "role": "app_reader", "kind": "retrieval",
      "sql": "select * from api.hybrid_knowledge_search_1536($1::text, $2::vector, $3::jsonb, $4::int)", "paramOrder": ["query_text", "$embedding", "filters", "limit"],
      "embedding": { "from": "query_text", "space": "technical_1536" }, "cost_class": "heavy", "domain": "retrieval" },

    { "id": "q:knowledge.head", "name": "knowledge.head", "role": "pipeline_agent",
      "sql": "select knowledge_seq, updated_at from temporal.knowledge_head where tenant_id = util.current_tenant_id()",
      "result": { "shape": "single_row" }, "cost_class": "cheap", "domain": "temporal-facts", "params": { "type": "object", "properties": {}, "additionalProperties": false } }
  ]
}
```

Validation at build: SQL parses; `paramOrder` covers every positional placeholder; the query executes with `example` (or generated defaults) under `SET LOCAL ROLE <role>` in a read-only transaction; `heavy` queries have an `EXPLAIN` gate rule. Entries needing objects that do not exist yet (`api.knowledge_head()` for `app_reader`) are listed under `pending` with the migration they require.

---

## 7. Canonicalization, digests, identity

- **Canonical JSON**: RFC 8785 (JCS) — sorted keys, no insignificant whitespace, numbers in shortest round-trip form, strings NFC. All digests are `sha256:` + lowercase hex over UTF-8 canonical bytes.
- `intentDigest` = digest of the whole intent file minus `idempotencyKey` and `notes`.
- `contentDigest` (per read op) = digest of `canonical(rows)` or `canonical(value)`; `rows` ordered as returned (catalog queries must have a total `order by`).
- `snapshotDigest` = digest of `canonical([{opId, query, params, role, atKnowledgeSeq, contentDigest} …])` excluding ops flagged `volatile`.
- **Idempotency key** = digest of `canonical({ tenantId, intentId, proposals, subjects, inputSnapshotDigest, rulesVersion })`. Same bytes ⇒ same key ⇒ `duplicateOf`. Same `intentId`, different proposals ⇒ different key ⇒ independent admission with `priorReceiptsForIntentId` populated.
- `knowledge_batch.input_digest` = `intentDigest`. `orchestration.operation_intent.idempotency_key` = the idempotency key. `operation_receipt.precondition_results` = `{ expectedKnowledgeHead, observedHead, snapshotDigest, rebased }`.
- Executor-assigned ids are UUIDv7 from the shared `packages/contracts` helper (handoff §5.6 obligation).

---

## 8. Error codes and exit lattice

| Code | Exit | Phase | Retryable | Meaning / agent action |
|---|---|---|---|---|
| `QUERY_UNKNOWN` | 1 | read-validate | no | Not in catalog; search `queries/README.md` |
| `PARAMS_INVALID` | 1 | read-validate | no | JSON Schema failure; details list paths |
| `LIMITS_EXCEEDED` | 1 | read-validate | no | Lower limits |
| `REF_UNRESOLVED` | 0 (op `skipped`) | read-execute | — | Earlier op returned no row |
| `INTENT_SCHEMA_INVALID` | 1 | 1 | no | Fix file; details list paths |
| `EVIDENCE_NOT_ELIGIBLE` | 1 | 3 | no | Run unsealed or claim verdict insufficient; re-verify |
| `SUBJECT_MERGED` | 1 | 4 | no | Use `mergedInto` id |
| `SUBJECT_UNKNOWN` | 1 | 4 | no | Resolved ref not found at current head |
| `VOCABULARY_VIOLATION` | 1 | 5 | no | Check `vocabularies/*.md`; details name the rule and allowed values |
| `RULE_VIOLATION` | 1 | 5 | no | Curated rule failed (`rules/README.md#<rule>`) |
| `REBASE_REQUIRED` | 1 | 6/8 | yes, after re-snapshot | Head moved and a touched slot changed; `whatChanged` attached |
| `REVIEW_REQUIRED_ONLY` | 1 | 7 | no | Every proposal is review/held; nothing to apply (submit refuses; plan succeeds) |
| `WORKSPACE_STALE` | 2 | 2 | no | Executor workspace fingerprint ≠ pinned/DB; operator issue |
| `HEAD_MISMATCH` | 2 | 2 | no | `migrationHead` ≠ DB head |
| `DB_UNAVAILABLE` | 2 | any | yes | Connection/timeouts |
| `ROLE_DENIED` | 2 | any | no | Requested role not permitted for the operation |
| `BATCH_OPEN` | 2 → auto-retry | 8 | yes | Another batch open; executor retries ≤ 3× then returns |
| `STORAGE_PENDING` | 0 | 10 | yes | Receipt committed, artifact upload pending; `status` completes it |
| `EXECUTOR_INTERNAL` | 2 | any | maybe | Bug; includes `correlationId` |

Exit 0 also covers `duplicateOf` responses and `partial` outcomes; the agent reads `outcome`/`proposals[].outcome` rather than the exit code for those.

---

## 9. Database mapping summary

| Contract element | Database object | Role that writes |
|---|---|---|
| read intent / snapshot artifacts | `orchestration.artifact` (`artifact_type knowledge_read_intent` / `knowledge_read_snapshot`, `bucket_class ledger`, bucket `research-ingestion-intents`) + `artifact_lineage derived_from` | `executor_service` (artifact insert; DML on `orchestration.artifact` is granted to executor) |
| ingestion intent envelope | `orchestration.operation_intent` (`intent_type 'knowledge_ingestion'`, `schema_version 1`, `payload`, `preconditions`, `idempotency_key`, `proposed_by_attempt`, `mission_id`, `approval_state`, `policy_decision`, and since 0.6.0 `origin_digest`, `origin_kind`, `mc_*` coordinates) | `executor_service` |
| plan | `orchestration.artifact` (`knowledge_ingestion_plan`) + lineage `derived_from` intent artifact | `executor_service` |
| receipt | `orchestration.operation_receipt` (`intent_id`, `executor_version`, `precondition_results`, `outcome`, `changes_summary`, `affected_refs`, since 0.6.0 `origin_digest`; exact-use adds `requires_admission`, `use_decision_id`, `bound_effect_digest`) + artifact (`knowledge_ingestion_receipt`) + lineage `produced_by` plan, `consumed_by` intent | `executor_service` |
| receipt targets (0.6.0) | `orchestration.operation_receipt_target` (`receipt_id`, `ordinal`, `target_schema`, `target_table`, `target_id`, `entity_id`, `entity_kind`, `role`, `action`, `proposal_id`, `claim_id`); read through `orchestration.mission_run_effects` | `executor_service` (apply transaction; forced RLS) |
| batch | `temporal.knowledge_batch` via `commit_batch(receipt_id, idempotency_key, input_digest, summary)` | `executor_service` via helper only |
| `entity.create` | `staging.candidate` → `staging.resolution_decision(create, receipt_id)` → `corpus.entity` (+ typed table, alias, identifier) with `created_by_receipt_id` → `entity_name` segment | `executor_service` |
| `relationship.assert` | `temporal.assert_relationship` → `corpus.relationship` (+ `relationship_active` segment) | helper |
| `fact.assert_state` / `event.assert` / `support.admit` | `temporal.make_extent`, `assert_state`, `assert_event`, `admit_support` | helper |
| `claim.materialize` | `evidence.source`, `source_capture`, `locator`, `claim(created_by_receipt_id)`, `claim_subject`; captures registered as `orchestration.artifact` (`source_captures`) | `executor_service` (also permitted to `pipeline_agent`, but executed by the executor for one identity per batch) |
| `metric.observe` | `ranking.metric_observation` | `executor_service` |
| `candidate.stage` | `staging.candidate` | `executor_service` |
| `report.publish` | `research.report`, `report_version`, `report_claim` | `executor_service` (staged; needs `mission_id`) |
| operation record | `knowledge_service.operation` (`operation_kind 'knowledge_ingestion'`, `ownership_mode`) + steps + outbox `knowledge.batch_sealed` | executor's KS persistence identity |
