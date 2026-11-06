# Skill drafts: `schema-explore`, `knowledge-db`, `knowledge-ingest`

Companion to [`../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) §5.4 and §7.4. These are the drafts of the three `SKILL.md` files. **Status (2026-09-12):** shipped; the canonical files are `ai-engineer-knowledge-services/skills/<name>/SKILL.md` (not the `apps/knowledge-executor/skills/` path this draft assumed) and are synced into the eve proving ground by `skill-pack-sync`. The shipped skills are the authority where they differ from these drafts. They mirror the structure of the existing `knowledge-verify` skill (frontmatter, one overriding rule, a stage table with quality gates and files, exit codes, references) so an agent that has learned one knows all four.

Session-layer only: skills contain instructions and references; the executables (`knowledge-db`, `knowledge-ingest`) and the executor URL come from the sandbox template (deployment layer). A skill never tells the agent to install anything.

File numbering continues the `knowledge-verify` convention so a run directory reads in order:

```
00-plan.md            (knowledge-verify)          01-schema-notes.md      (schema-explore)
05-read-intent.json   (knowledge-db)              06-snapshot.json        (knowledge-db)
07-gaps.md            (knowledge-db)              10-…70-…                (knowledge-verify)
80-ingestion-intent.json, 81-plan.json, 82-receipt.json, 83-verify-snapshot.json   (knowledge-ingest)
90-ingest-summary.md  (knowledge-ingest)
```

---

## 1. `schema-explore/SKILL.md`

```markdown
---
name: schema-explore
description: >-
  Use when you need to know what the shared knowledge database contains or how something is
  stored: which table/view/function holds a concept, how entities, relationships, two-clock
  temporal facts, evidence and claims relate, which named query answers a question, or what an
  ingestion proposal must contain. Navigates the bundled schema workspace (progressive
  disclosure) instead of guessing table names. Does not query the database; use knowledge-db.
allowed-tools:
  - Bash(rg *)
  - Bash(jq *)
  - Bash(cat *)
  - Bash(knowledge-db search *)
  - Bash(knowledge-db describe *)
  - Bash(knowledge-db domain *)
  - Bash(knowledge-db task *)
---

# schema-explore — find the right table, query, or proposal shape

The workspace is at `references/workspace/` (scoped bundle; `START_HERE.md` names the scope and
the fingerprint). It is generated from the database catalog at a pinned migration head. Blocks
marked `> curated` are human guidance validated against the catalog; everything else is
mechanically extracted.

## The navigation rule (overrides browsing habits)

1. **Search, then read.** Never list or read the workspace tree. Start with a search:
   `knowledge-db search "<words>"` (or `rg -n -i "<word>" references/workspace/search/index.json`).
2. **Domain before relation.** Read `domains/<slug>.md` for the hit's domain before any relation page.
3. **Task pages are shortcuts.** If a `task:` hit matches your question, follow it; it names the
   exact named query or proposal kind.
4. **Relation pages last**, and only the ones you will actually query or write to.
5. **≤ 4 file reads per question.** If you need more, you are browsing; go back to step 1 with better words.
6. **Only `enforced` is a guarantee.** Edges and rules marked `basis: enforced` are database
   constraints. `curated` guidance can be stale; if it conflicts with a relation page's Constraints
   section, the relation page wins, and you note the conflict in `01-schema-notes.md`.
7. **Omission is not permission or prohibition.** A relation missing from this bundle may still
   exist; the executor and database roles decide what you can do, not this folder.

## Sequence

| # | stage | command(s) | quality gate | file |
|---|---|---|---|---|
| 1 | orient | `cat references/workspace/START_HERE.md` (once per session) | you can state the scope id and fingerprint | `01-schema-notes.md` (header) |
| 2 | search | `knowledge-db search "<question words>" --limit 10` | ≥ 1 hit with a `domain` | append hits (ids) |
| 3 | domain | `knowledge-db domain <slug>` | you can name the read path and the write path for the concept | append 2–3 lines |
| 4 | task or relation | `knowledge-db task <slug>` or `knowledge-db describe rel:<schema>.<name>` | you can write the named query + params, or the proposal kind + required fields | append the answer |
| 5 | record | — | `01-schema-notes.md` lists every id consulted and the workspace fingerprint | `01-schema-notes.md` |

`knowledge-db search/describe/domain/task` are local (they read the bundle); they need no
network and cost no database time. `rg`/`jq` over `references/workspace/` are equivalent.

### Typical questions → where the answer is

| question | search words | you will end at |
|---|---|---|
| Does the DB know entity X? How do I look it up? | `resolve alias identifier` | `task:what-do-we-know-about-entity` → `q:entity.resolve`, `q:entity.card` |
| What is true about X now / on date D / as we knew at head K? | `as of point in time` | `dom:temporal-facts` → `q:entity.at`, `q:entity.timeline` |
| Which facts are stale or unsupported? | `stale last seen support` | `task:find-stale-facts` |
| How are prices stored? What units are allowed? | `price unit currency` | `voc:temporal.stream_kind` (`model_offering_price` row), `rules/README.md#prices` |
| How do I express "A is offered as B" / "P works at O since 2024"? | `offered_as` / `employed_by` | `dom:relationships` → `voc:taxonomy.relationship_kind` → proposal `relationship.assert` |
| What must an ingestion intent contain? | `ingestion intent proposal` | `task:compose-ingestion-intent` → `knowledge-ingest rules` |
| Why was my proposal rejected as VOCABULARY_VIOLATION? | the field named in the error | the vocabulary page for that `stream_kind`/`relationship_kind` |

## What not to do

- Do not read `schema-ir.json`, `search/index.json`, or `relations.txt` whole.
- Do not infer columns from TypeScript types when a relation page exists; the page has
  constraints, RLS, grants and triggers that types do not.
- Do not write SQL. There is no SQL surface; reads are named queries (`knowledge-db`) and writes
  are proposals (`knowledge-ingest`).

## Exit codes

`knowledge-db search|describe|domain|task`: 0 found; 1 not found (try other words; the JSON lists
`suggestions`); 2 bundle missing or corrupt (stop and report; the bundle digest is in `START_HERE.md`).

## References

- [references/workspace/START_HERE.md](references/workspace/START_HERE.md) — entry, scope, fingerprint
- [references/workspace/INDEX.md](references/workspace/INDEX.md) — domains and schemas
- [references/workspace/queries/README.md](references/workspace/queries/README.md) — every named query
- [references/workspace/rules/README.md](references/workspace/rules/README.md) — ingestion rules with `basis`
```

---

## 2. `knowledge-db/SKILL.md`

```markdown
---
name: knowledge-db
description: >-
  Use when you must read the shared knowledge database: check what it already contains about a
  subject, run named queries (entity resolution, current facts, point-in-time facts, timelines,
  relationships, evidence, staging, receipts) or hybrid retrieval, and record a reproducible
  snapshot with a knowledge head and digest that an ingestion intent can cite. Also use to read
  back and diff after an ingestion. Never writes; use knowledge-ingest to change the database.
allowed-tools:
  - Bash(knowledge-db *)
---

# knowledge-db — reproducible reads (CLI surface)

`knowledge-db` forwards to the knowledge executor (`KNOWLEDGE_EXECUTOR_URL`), which runs the
query under a bounded database role and returns one JSON document. You never hold a database
credential and never send SQL: every read is a **named query** from the workspace catalog.

## Preflight

```bash
knowledge-db health --out 04-health.json     # {"status":"ok","migrationHead":…,"workspaceFingerprint":…,"knowledgeHead":{"knowledgeSeq":…}}
mkdir -p /workspace/run && cd /workspace/run
```

If `health` reports `WORKSPACE_STALE` or `HEAD_MISMATCH`, stop and report; nothing you do will fix it.

## The snapshot rule (overrides ad-hoc querying)

1. **Every read you rely on is in a snapshot.** Exploratory `query` calls are fine, but the facts
   you will cite or build proposals on must come from a `snapshot` of a read intent
   (`05-read-intent.json` → `06-snapshot.json`). The snapshot's `snapshotDigest` and
   `knowledgeHead.knowledgeSeq` are what `knowledge-ingest` requires.
2. **Knowledge head, not timestamps.** Freshness is `knowledgeSeq`. Write it down.
3. **"Current" hides history.** `entity.card`, `current_facts` show facts valid now as known now.
   For "what was true on D" use `entity.at` with `at=D`; for "when did we learn X" use
   `entity.timeline` / `facts.history_for_stream`.
4. **Empty is a finding.** `entity.resolve` with all `score < 0.9`, or `entity.card` with no
   facts, means the database lacks it. Record it in `07-gaps.md`; do not invent.
5. **Ask the catalog before asking the schema.** `knowledge-db catalog --domain <slug>` lists
   queries with parameters; the schema-explore skill is for when no query fits.

## Sequence

| # | stage | command(s) | quality gate (exit 0) | file |
|---|---|---|---|---|
| 1 | health | `knowledge-db health` | `status: ok` | `04-health.json` |
| 2 | pick queries | `knowledge-db catalog --domain identity` etc. | you can name each query + params | — |
| 3 | probe | `knowledge-db query entity.resolve --param text="OpenAI"` | rows returned or an explicit empty | — |
| 4 | compose | write `05-read-intent.json` (`knowledge-read-intent.v1`) with resolve → card → relationships → facts/at → claims → `knowledge.head` | `knowledge-db snapshot 05-read-intent.json --validate-only` exits 0 | `05-read-intent.json` |
| 5 | snapshot | `knowledge-db snapshot 05-read-intent.json --out 06-snapshot.json` | `snapshotDigest` present; no op `status: error` | `06-snapshot.json` |
| 6 | gaps | read the snapshot; list missing entities, missing/stale facts (`k_from` old, `valid_during` ended, `temporal_basis: observation_bounded` older than the as-of date), conflicts (`belief: disputed`), unsupported facts (no `primary_claim_id`) | every gap names the snapshot `opId` it comes from | `07-gaps.md` |

### 3–4. Queries and read intents

```bash
knowledge-db query entity.resolve --param text="OpenAI" --param kinds='["organization"]'
knowledge-db query entity.card --param entity_id=0192b000-… --out card.json
knowledge-db query entity.at --param entity_id=… --param at=2026-03-15T00:00:00Z          # world time
knowledge-db query entity.at --param entity_id=… --k 37                                     # as known at head 37
knowledge-db query facts.current_by_stream --param subject_entity_id=… --param stream_kind=model_offering_price
knowledge-db query retrieval.hybrid_search --param query_text="OpenAI API pricing" --limit 20
knowledge-db query evidence.claims_for_entity --param entity_id=… --limit 100
```

- `--param k=v` values are JSON when they parse as JSON, else strings. Parameters are validated
  against the catalog's schema; `PARAMS_INVALID` lists the offending path.
- Row caps: default 200, `--limit` up to 2000. Beyond that the result is `truncated` and the
  full rows are an artifact (`overflow.artifactId`; fetch with `knowledge-db artifact get`).
- In a read intent, later operations may reference earlier results:
  `"entity_id": "$resolve.rows[0].entity_id"`. An unresolved reference skips that operation
  (`status: skipped`), it does not fail the snapshot; check for skipped ops.

### 6. Gap notes

`07-gaps.md` has four sections — **Missing** (no entity / no fact), **Stale** (fact exists but
its `valid_during` ended, its `k_from` is old, or it is `observation_bounded` before the as-of
date), **Conflicting** (`belief: disputed`, or two sources disagree), **Unsupported** (fact with
no `primary_claim_id` or no `segment_support`). Each line: subject, stream/relationship kind,
current value, snapshot `opId`, what evidence would resolve it. This file is the research plan
for `knowledge-verify`.

## After an ingestion: read back

```bash
knowledge-db query entity.what_changed --param entity_id=… --param k_from=41 --param k_to=42
knowledge-db snapshot 05-read-intent.json --out 83-verify-snapshot.json   # same intent, new head
```

Compare `83-verify-snapshot.json` to `06-snapshot.json`: `knowledgeHead.knowledgeSeq` must have
advanced by exactly the batches you committed; per-op `contentDigest` changes must be explained
by your receipt's `proposals[].created`/`supersedes`.

## Exit codes

| code | meaning | what to do |
|---|---|---|
| 0 | success (possibly with `skipped`/`truncated` ops) | read the JSON |
| 1 | `QUERY_UNKNOWN`, `PARAMS_INVALID`, `LIMITS_EXCEEDED` | fix the intent; `knowledge-db catalog` shows parameters |
| 2 | `WORKSPACE_STALE`, `HEAD_MISMATCH`, `DB_UNAVAILABLE`, `ROLE_DENIED` | stop and report the code |

## References

- [references/read-intent.md](references/read-intent.md) — `knowledge-read-intent.v1` and snapshot fields
- [references/workspace/queries/README.md](references/workspace/queries/README.md) — catalog (shared with schema-explore)
```

---

## 3. `knowledge-ingest/SKILL.md`

```markdown
---
name: knowledge-ingest
description: >-
  Use when verified facts must be written into the shared knowledge database: compose a
  knowledge-ingestion intent (entities, aliases, relationships, two-clock facts, events,
  evidence support, staged candidates) from a sealed knowledge-verify run and a knowledge-db
  snapshot, dry-run it, validate it, submit it to the deterministic executor, inspect the
  receipt, recover from stale-head or validation failures, and verify by re-reading. You never
  write to the database yourself; the executor does, under its own identity.
allowed-tools:
  - Bash(knowledge-ingest *)
  - Bash(knowledge-db *)
---

# knowledge-ingest — author intents, let the executor write

`knowledge-ingest` forwards to the knowledge executor (`KNOWLEDGE_EXECUTOR_URL`). The executor
validates your intent, plans it, and applies it in one database transaction as the only identity
allowed to write canonical facts. Every submission produces an immutable receipt whether it
succeeds or fails. Failures are instructions.

## Preconditions (all three, or do not start)

- a **sealed** `knowledge-verify` run (`47-seal.json` → `inspection.valid: true`) whose claims you will cite;
- a **snapshot** (`06-snapshot.json`) with `snapshotDigest` and `knowledgeHead.knowledgeSeq`;
- `knowledge-ingest rules --out 79-rules.json` succeeded; you have read `rules/README.md` for the entity kinds you touch.

## The proposal rule (overrides every shortcut)

1. **Cite or stage.** Every fact/relationship/event proposal cites ≥ 1 `{ runId, claimId }` from a
   sealed run with an admitted verdict. Anything you cannot cite becomes `candidate.stage` with a
   `reason`, or is left out. Never restate an uncited fact in the report.
2. **Declare time twice.** Every fact has a `worldInterval` (when it was true; `from` required)
   and a `temporalBasis` (`explicit` with an `extent` quoting the date; `observation_bounded`
   when the source only proves "true when captured"). Knowledge time is handled by the executor.
3. **Reference the snapshot you read.** `inputSnapshot` and `expectedKnowledgeHead` come from
   `06-snapshot.json`. Do not hand-edit them.
4. **One `intentId` per logical change set.** Re-submitting the *same file* is safe and returns
   the same receipt (`duplicateOf`). Changing proposals under the same `intentId` creates a new
   intent; prefer a new `intentId` suffix (`…-v2`) so the ledger stays readable.
5. **Use vocabulary codes exactly** (`stream_kind`, `relationship_kind`, `event_kind`, `unit`,
   `alias_kind`, identifier `scheme`). They are listed in `vocabularies/*.md`; `VOCABULARY_VIOLATION`
   names the allowed values.
6. **Never include SQL, roles, or receipt ids** in an intent. The executor decides those.

## Sequence

| # | stage | command(s) | quality gate (exit 0) | file |
|---|---|---|---|---|
| 1 | rules | `knowledge-ingest rules --out 79-rules.json` | `rulesVersion` recorded | — |
| 2 | compose | write `80-ingestion-intent.json` (`knowledge-ingestion-intent.v1`) from `07-gaps.md` + `47-seal.json` + `06-snapshot.json` | file parses | `80-ingestion-intent.json` |
| 3 | plan (dry-run) | `knowledge-ingest plan 80-ingestion-intent.json --out 81-plan.json` | `plannedOutcome ≠ rejected`; every `review_required`/`held` is one you accept | `81-plan.json` |
| 4 | validate | `knowledge-ingest validate 80-ingestion-intent.json` | exit 0 | — |
| 5 | submit | `knowledge-ingest submit 80-ingestion-intent.json --wait --out 82-receipt.json` | `outcome ∈ applied | partial | noop`; `knowledgeBatch.knowledgeSeq` present when applied/partial | `82-receipt.json` |
| 6 | duplicate check (when the task asks) | `knowledge-ingest submit 80-ingestion-intent.json --wait --out 82b-receipt.json` | `duplicateOf` = first `receiptId`; head unchanged | `82b-receipt.json` |
| 7 | read back | `knowledge-db query entity.what_changed …`; `knowledge-db snapshot 05-read-intent.json --out 83-verify-snapshot.json` | head advanced by your batches; created ids visible | `83-verify-snapshot.json` |
| 8 | summary | `knowledge-ingest status <intentId> --out 84-status.json` | — | `90-ingest-summary.md` |

### 2. Compose

Skeleton (full schema and worked example in [references/ingestion-intent.md](references/ingestion-intent.md)):

```json
{ "schemaVersion": "knowledge-ingestion-intent.v1", "intentId": "<topic>-<asof>",
  "context": { "tenantId": "<from health>", "correlationId": "<run id>", "actor": { "kind": "agent", "id": "<your id>" } },
  "contract": { "migrationHead": "<health>", "workspaceFingerprint": "<health>", "rulesVersion": "<79-rules.json>" },
  "inputSnapshot": { "snapshotId": "<06>", "snapshotDigest": "<06>", "knowledgeSeq": <06> },
  "expectedKnowledgeHead": <06.knowledgeHead.knowledgeSeq>, "onStale": "rebase_if_disjoint", "asOf": "<date>",
  "evidence": { "verificationRuns": [ { "runId": "<47>", "manifestDigest": "<47>" } ] },
  "subjects": [ { "ref": "…", "mode": "resolved", "entityId": "…", "kind": "…" }, { "ref": "…", "mode": "new", "kind": "…", "displayName": "…", "aliases": [], "identifiers": [], "onMatch": "review" } ],
  "proposals": [ { "proposalId": "p-01", "kind": "fact.assert_state", "subjectRef": "…", "streamKind": "…", "worldInterval": { "from": "…", "to": null, "bounds": "[)" }, "temporalBasis": "explicit", "extent": { "sourceText": "…", "precision": "day", "earliest": "…", "latest": "…", "locatorRef": "…" }, "belief": "accepted", "evidence": [ { "runId": "…", "claimId": "…", "locatorRef": "…", "role": "primary" } ] } ] }
```

Choosing the proposal kind:

| you want to say | kind | notes |
|---|---|---|
| "X exists and is a <kind>" | subject `mode: new` (+ implied `entity.create`) | `onMatch: review` unless you are sure it is new |
| "X is also called Y" / "X has id Y in scheme S" | `entity.alias` / `entity.identifier` | idempotent |
| "A <rel> B [since/until]" | `relationship.assert` | `worldInterval` required for temporal kinds (see `voc:taxonomy.relationship_kind`) |
| "X's <stream> is/was V [from D]" | `fact.assert_state` | `scopeKey` per rules (prices: the unit) |
| "On D, X <event>" | `event.assert` | `occurredDuring` + `precision` |
| "This quote also supports that fact" | `support.admit` | needs `locatorRef` |
| "I found X but cannot resolve/place it" | `candidate.stage` | no evidence needed; give `reason` |

### 3–4. Plan and validate

`plan` performs every check without writing and shows, per proposal, `outcome` and any
`rewrites` (rules the executor applied, e.g. `price.scope_key_is_unit`). Read it. If a proposal
is `no_op_duplicate`, the fact is already there; keep it (harmless) or drop it. If it is
`review_required` with `identity_ambiguous`, either pick the match (`onMatch: use_existing`) or
leave it for review. `validate` is the same as `plan` with a pass/fail exit; use it right before `submit`.

### 5. Submit and recover

`submit --wait` returns the receipt. Recovery by `failure.code`:

| code | what happened | do |
|---|---|---|
| `REBASE_REQUIRED` | the knowledge head advanced and a proposal touches a changed slot; `failure.whatChanged` lists it | re-run the read intent (`knowledge-db snapshot 05-read-intent.json --out 06b-snapshot.json`), compare, adjust or drop the touched proposals, update `inputSnapshot`/`expectedKnowledgeHead` from `06b`, submit under `intentId …-v2` |
| `VOCABULARY_VIOLATION` / `RULE_VIOLATION` | a code or unit is not allowed; details name the field and allowed values | fix the field; do not invent a new code — if none fits, `candidate.stage` |
| `EVIDENCE_NOT_ELIGIBLE` | run unsealed or claim verdict not admitted | back to `knowledge-verify` (judge/policy/seal), then resubmit |
| `SUBJECT_MERGED` | entity merged since your snapshot | use `details.mergedInto`, re-snapshot |
| `REVIEW_REQUIRED_ONLY` | nothing admissible | report it; do not force |
| `BATCH_OPEN` / `DB_UNAVAILABLE` | transient | the CLI already retried; wait and `submit` again (idempotent) |

A rejected submission still has a receipt (`outcome: rejected`); record its `receiptId`.

### 7–8. Verify and summarize

`90-ingest-summary.md`: intentId(s), idempotencyKey, receiptId(s) with outcomes, head before →
after, per-proposal outcomes and created ids, duplicate check result, what `what_changed`
reported, rejected attempts and why, files written. Finish your turn repeating head before/after
and the count of admitted / no-op / review / rejected proposals.

## Exit codes

| code | meaning | what to do |
|---|---|---|
| 0 | success — includes `duplicateOf`, `partial`, `noop` | read `outcome` and `proposals[].outcome` |
| 1 | quality gate failed (`INTENT_SCHEMA_INVALID`, `EVIDENCE_NOT_ELIGIBLE`, `VOCABULARY_VIOLATION`, `RULE_VIOLATION`, `REBASE_REQUIRED`, `SUBJECT_*`, `REVIEW_REQUIRED_ONLY`) | fix per the table above and re-run from `plan` |
| 2 | usage / network / executor (`WORKSPACE_STALE`, `HEAD_MISMATCH`, `DB_UNAVAILABLE`, `ROLE_DENIED`) | stop and report |

## References

- [references/ingestion-intent.md](references/ingestion-intent.md) — `knowledge-ingestion-intent.v1`, plan and receipt fields, worked example
- [references/failure-playbook.md](references/failure-playbook.md) — every code and its recovery
- [references/workspace/rules/README.md](references/workspace/rules/README.md) — ingestion rules (`basis: enforced | curated`)
- [references/workspace/vocabularies/](references/workspace/vocabularies/) — stream, relationship, event kinds; units; alias kinds; identifier schemes
```

---

## 4. Manifest and sync

`apps/verification-executor/skills/manifest.json` (shipped location) gains three entries (name, path, `references` globs). `skill-pack-sync` copies each skill into `research_ingestion_systems_agent/.agents/skills/<name>/`, and `pnpm skills:sync` in the proving ground additionally materializes the scoped workspace bundle into `schema-explore/references/workspace/` from the pinned db-contract (`materialize --scope db-aware-research`). `knowledge-db` and `knowledge-ingest` reference the same `queries/README.md`, `rules/README.md`, and `vocabularies/` via relative links into the `schema-explore` bundle, so the bundle exists once per sandbox.

The eve profile for arm A lists all four skills (`knowledge-verify`, `schema-explore`, `knowledge-db`, `knowledge-ingest`) plus the discovery skills; arm B lists `knowledge-verify` and discovery only; arm C lists none of the four (its guidance is in MCP tool descriptions).
