# Experiment 3 protocol: schema workspace + skills vs Supabase CLI vs MCP

> **Status (2026-09-12):** executed. The protocol was implemented in `research_ingestion_systems_agent/experiments/exp3-schema-workspace/` (fixture, gold, runner, blinded evaluator) and all three arms ran on an isolated disposable database. Measured results live in that directory's `results/README.md`; the spec's "Implementation record" summarizes them. The text below is the protocol as designed; where the implementation deviated (interleaved run order, per-run cost guard, injection timing), the results README says so.

Companion to [`../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md`](../SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md) §8. This is a **protocol** as written before the runs; no result is claimed in this file. It is written to be executed in the existing eve proving ground (`research_ingestion_systems_agent/`, eve 0.44.4, `tools/experiment-runner/run.mjs`, `agents/verified-research`) after spec phases M1–M4 land (M5 runs A and B; M6 runs C).

Contents: 1 hypotheses · 2 arms · 3 shared components · 4 task brief · 5 fixture · 6 injected failures · 7 isolation and reset · 8 run procedure · 9 budgets · 10 metrics · 11 evaluation · 12 run manifest and artifacts · 13 repetition and analysis · 14 confounds and how B or C can win · 15 live-web lane · 16 checklist before the first run.

---

## 1. Hypotheses (falsifiable)

- **H1 (primary).** Given the same model, task, budgets, database state, and evidence, arm A (workspace + skills + intent executor) produces a higher ingestion-validity score and a higher navigation-accuracy score than arm B (Supabase CLI over the same database), with no worse report quality.
- **H2.** Arm A completes the duplicate-submission and stale-state recovery sub-tasks with fewer human interventions and fewer failed tool calls than arm B.
- **H3 (interface).** Holding the executor constant, arm C (MCP tools) and arm A do not differ in ingestion validity, but differ in tool calls and tokens; the direction is not predicted.
- **H0 alternatives the design must be able to show.** B wins on wall-clock or tool calls (raw SQL collapses multi-step reads into one query); B matches A on validity because the database's own constraints catch the same errors; C beats A on tokens because tool descriptions replace file navigation.

Each hypothesis is judged per metric in §10 with the analysis in §13. A is the hypothesis under test, not the expected winner.

---

## 2. Arms

All arms: same model (`openai/gpt-5.6-terra`, reasoning `high`, judge model the same, pinned in `experiment.json`), same eve agent (`agents/verified-research`), same sandbox image, same task brief (§4), same fixture (§5), same budgets (§9), same evaluation (§11). Discovery tools are **disabled** in controlled runs; evidence is the fixed capture set (§3.2).

| | **A — workspace + skills + executor** | **B — Supabase CLI, direct DB** | **C — executor over MCP** |
|---|---|---|---|
| Profile id | `db-aware-research-cli` | `db-direct-supabase-cli` | `db-aware-research-mcp` |
| Surface (`RESEARCH_SURFACE`) | `cli` | `cli` | `mcp` |
| Skills materialized | `knowledge-verify`, `schema-explore` (with `references/workspace/` = scoped bundle `db-aware-research`), `knowledge-db`, `knowledge-ingest` | `knowledge-verify` only | none |
| Executables in sandbox (deployment layer) | `knowledge-verify`, `knowledge-db`, `knowledge-ingest` (one tarball, remote mode) | `knowledge-verify`, `supabase` (CLI 2.115.0 binary), `psql` **not** installed | `knowledge-verify` not installed; nothing DB-related |
| Connections (MCP) | none for DB | none for DB | `knowledge-executor` MCP (tools `schema_*`, `db_*`, `ingest_*`, `artifact_get`) + `verification` MCP (`verify_*`) |
| Database access | none; executor holds credentials | `SUPABASE_DB_URL` for the **isolated** experiment database, login role `exp_agent` with `GRANT pipeline_agent, executor_service TO exp_agent` (can `SET ROLE`) | none; executor holds credentials |
| Schema knowledge provided | scoped workspace bundle (L0–L3, tasks, queries, rules, vocabularies) | the database itself: `pg_catalog`, `information_schema`, `obj_description`/`col_description` comments, `\df`-equivalent queries; the task brief names the schemas that exist and states "facts are written via functions in schema `temporal`; consult their comments" | MCP tool descriptions (≤ 300 chars each, embedding the START_HERE navigation rule) + tool results (`schema_search/describe/domain/task` return the same bundle pages as A's files) |
| Write path | `knowledge-ingest submit` (intent → executor → receipt) | agent-authored SQL: must insert `orchestration.operation_intent` + `operation_receipt`, then `set role executor_service; select temporal.begin_batch(...) … commit_batch(receipt_id, key, digest, summary)` | `ingest_submit` (same executor as A) |
| Read path | named queries via `knowledge-db` | raw SQL via `supabase db query --db-url "$SUPABASE_DB_URL" -o json` | named queries via `db_query`/`db_snapshot` |
| Verification | `knowledge-verify` CLI (remote) | same | `verify_*` MCP |

### 2.1 What the comparison measures

- **A vs B** compares **complete capability packages**: curated schema knowledge + guided procedure + a validating executor, versus raw SQL + the database's self-description. B has strictly more power (arbitrary SQL, direct role assumption, ad-hoc joins) and strictly less guidance. An A-over-B result is therefore attributable to the *package*, never to transport. A B-over-A result on speed is expected on some sub-tasks and must be reported as such.
- **A vs C** compares **interface effects** with the executor held constant: identical named queries, identical intent validation, identical receipts. Differences are attributable to files-plus-skills (A) versus tool-descriptions-plus-structured-results (C), plus the eve MCP vs bash tool-call mechanics.
- **B vs C** is reported but not interpreted causally (both package and interface differ).

### 2.2 Verified Supabase CLI facts and the adjustments they force on B

Verified on the workstation (CLI 2.98.2; db-contract pins 2.115.0; re-verify on the pinned version at M5):

| Capability | Verified? | Use in B |
|---|---|---|
| `supabase db query [sql] --db-url <url> [-f file] [-o json|table|csv]` | yes — connects directly to the connection string (message "Connecting to remote database…"), no Docker | **primary tool**: all reads and writes |
| `supabase db query --linked` | not used — goes through the Management API and needs a linked hosted project | excluded |
| `supabase gen types --db-url … --schema …` | yes | allowed (schema hints) |
| `supabase inspect db *` | yes, but these are statistics (bloat, index usage, long-running queries), not a schema browser | allowed, not useful |
| `supabase db dump` | needs Docker | **excluded** (Docker not assumed in the sandbox) |
| `supabase migration *`, `db push/reset` | Docker or linked project | excluded; the runner resets the DB, not the agent |
| Multi-statement transactions in one `db query` call | to verify at M5: `-f file` with `begin; … commit;` is expected to work as one session; if the CLI splits statements into separate sessions, B **cannot** hold `set role` + `begin_batch` + `commit_batch` in one transaction | **blocking check** for B; see fallback |

**Adjustments.** (1) B's baseline is `db query` over `pg_catalog`/`information_schema` plus the temporal helpers; no `db dump`, no `psql`. (2) B must create `operation_intent` and `operation_receipt` rows itself (as `executor_service`, which has DML on `orchestration.*`) because `temporal.commit_batch` requires a receipt id; the task brief tells B this in one sentence and the protocol counts it as part of B's task. (3) **Fallback if the multi-statement check fails:** install `psql` (`postgresql-client`) in B's sandbox and allow `psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f file.sql`; record the substitution in the run manifest (`armB.transport: "psql"`). This is the smallest change that keeps B "direct SQL against a scoped connection". If Docker becomes available in the sandbox, that does not change B.

`exp_agent` is created by the fixture script on the isolated database only: `create role exp_agent login password '…' in role pipeline_agent, executor_service; grant usage on schema orchestration, temporal, corpus, evidence, staging, taxonomy, api, util to exp_agent;`. It is never created on a shared database.

---

## 3. Shared components

### 3.1 Knowledge executor (A and C)

One process on the host (port `4320`, `executorUrlInSandbox: http://host.docker.internal:4320`) with: pinned workspace (fingerprint recorded), catalog, rules, DB connection to the isolated stack via a login role `executor_login in role pipeline_agent, executor_service`, artifact store pointing at the isolated stack's Storage (`research-ingestion-intents` bucket exists there after `db:reset`), verification-executor URL for evidence eligibility. The same binary and config serve A (CLI remote mode) and C (MCP). The verification executor from exp2 keeps running on `4310`.

### 3.2 Fixed evidence set

Twelve pre-captured pages (OpenAI docs/pricing/models/changelog/blog/help-center, plus one third-party page that **contradicts** an OpenAI page on a date) captured once with `knowledge-verify capture` into a shared run `exp3-evidence-2026-09-11`, sealed, and copied into every arm's verification store before the run (`store/` directory snapshot). Agents may also capture the same URLs again (allowed — captures are content-addressed), but discovery tools are off, and the task brief lists the twelve URLs. The set's digests are in `experiments/exp3-schema-workspace/evidence/manifest.json`. The set is chosen so that: two questions are fully answerable, two require reconciling a stale fixture fact, one has a genuine conflict between sources, one is unanswerable from the set (the correct behaviour is to say so), and the rest are routine.

### 3.3 Task brief and instructions

`task.md` (identical text for all arms) + per-arm `instructions/surface.ts` additions of ≤ 40 lines that only describe *which executables/tools exist*, not how to think about the schema. The per-arm text is committed and diffed in the report.

---

## 4. Task brief (`task.md`, verbatim for all arms)

> **Task.** Produce a source-attributed report on OpenAI's AI products and software **as of 2026-09-11**, and bring the shared knowledge database up to date with what you verify.
>
> **Questions the report must answer** (each with citations; say explicitly when the evidence set does not answer one):
> 1. Which model families and model versions does OpenAI currently offer through its API, and which are deprecated or retired as of the as-of date?
> 2. For the flagship API model, what are the current input and output prices (per 1M tokens) and since when?
> 3. Which end-user products (ChatGPT tiers, apps, agent products) exist, and what is each one's availability status?
> 4. Which developer software (SDKs, CLIs, agent frameworks, MCP-related tooling) does OpenAI publish, and what is the relationship between each and the models/products?
> 5. What changed between 2026-06-01 and 2026-09-11 (releases, deprecations, price changes)?
> 6. Who holds the named leadership roles referenced in the evidence, and since when?
> 7. Where do sources conflict, and which value did you accept and why?
> 8. What does the database already assert that the evidence shows to be stale or wrong?
>
> **Database work.** Before researching: determine what the knowledge database already contains about OpenAI and these products, and record it reproducibly. Identify gaps, stale facts, and conflicts. After verifying evidence: write the verified facts into the database (new entities, relationships, time-bounded facts, events, evidence support) so that a later reader sees them as current knowledge with correct validity periods; read back to confirm. Then submit the **same** write a second time and report what happened. During the task, the database may change underneath you and one of your writes may be rejected; recover and explain.
>
> **Evidence.** Use only the twelve listed sources (captures of them are already in your verification store; you may re-capture). Every factual sentence ends with a verified `[claimId]`.
>
> **Deliverables** in `/workspace/run/`: the report (`50-report.md`), your snapshot(s) of the database before and after, your write intents or SQL, receipts or transaction results, and a summary of what you changed (head before/after, counts).
>
> **Budget.** ≤ 220 tool calls, ≤ 90 minutes wall clock. Stop and summarize when you reach either.

Arm B's appendix (≤ 6 sentences): connection string env var; schemas that exist; "canonical facts are written only through functions in schema `temporal` as role `executor_service`, inside a batch that must reference an `orchestration.operation_receipt` row; the functions carry comments describing arguments"; reads may use any role granted to you; do not create or alter tables.

---

## 5. Fixture: `exp3-seed`

A deterministic SQL + JSON fixture applied after `db:reset`, committed under `experiments/exp3-schema-workspace/fixture/`. Applied through the temporal helpers (so `k` stamps are real) in **four sealed batches** (heads 1–4) using a fixture executor script, not raw inserts:

| Batch | Content | Purpose |
|---|---|---|
| 1 | `organization` OpenAI (aliases, identifiers: website, wikidata); 3 `ai_model` families with 6 `ai_model_version`s; 5 `model_offering`s with `offered_as`/`version_of`; `develops` relationships | baseline identities |
| 2 | `model_offering_availability` and `model_offering_price` segments for the 5 offerings with `valid_during` starting 2025-11 … 2026-04, `temporal_basis explicit` with extents; 3 `model_release` events | facts that are partly **stale**: two prices are superseded by the evidence set; one offering is `ga` in the DB but `deprecated` in the evidence |
| 3 | 4 `product` entities with `product_feature_availability`; 2 `software_library` entities without relationships to models (gap); 3 `person` entities with `employed_by` + `engagement_role` streams, one of which ended in the evidence but is open in the DB | relationship gaps and a stale employment |
| 4 | 1 `disputed` segment (valuation) and 1 near-duplicate organization "OpenAI Foundation" with score-0.6 alias overlap; 2 `staging.candidate` rows unresolved | conflict + identity ambiguity |

Plus: `evidence.claim` rows for batches 2–3 with locators pointing at two of the twelve fixed captures (registered as `evidence.source_capture`), so half the fixture facts have `primary_claim_id` and half do not (unsupported → a gap the agent should notice).

`fixture/gold/` contains the machine-checkable gold: `gold-baseline.json` (what a correct pre-research snapshot must contain: entity ids by identifier, current facts per stream), `gold-gaps.json` (the 9 planted gaps/stale/conflicts), `gold-delta.json` (the set of facts, relationships, events that a correct ingestion produces, expressed as stream slots + intervals + values, and the fixture segments that must be **closed**), `gold-answers.json` (per question: required entities/values/dates/citations, or "unanswerable"). Gold is written by hand from the evidence set and checked by a script that asserts the gold is consistent with the fixture and the captures (`pnpm exp3:check-gold`).

Fixture identity: `fixtureDigest = sha256(canonical(fixture SQL + JSON))`, recorded in the run manifest; the post-fixture `knowledge_head.knowledge_seq` must be `4` and `db-before.json` must equal the committed `fixture/expected-db-before.json` byte for byte (else the run aborts).

---

## 6. Injected failures

Both injections are performed by the runner on a trigger, identically for all arms, and logged with timestamps into `injections.jsonl`.

| Injection | Trigger | Mechanism | Correct agent behaviour | Measured by |
|---|---|---|---|---|
| **Stale state** | first time the agent's snapshot/read of the flagship offering is observed (A/C: executor `db_snapshot` log; B: `pg_stat_statements`-free approach — the runner watches for the first `select` touching `temporal.segment` for that entity in the isolated DB's `log_statement=all` log) **and** at least 8 minutes have elapsed | runner commits a sealed batch (head +1) that asserts a new `model_offering_price` for the flagship offering's `per_1m_output_tokens` slot with a different value, evidence-backed by one of the twelve captures | A/C: `REBASE_REQUIRED` (touched slot) or automatic rebase (disjoint) → re-snapshot → reconcile → resubmit. B: `begin_batch(p_expected_head)` raises 40001 (if B passed the expected head) or B's write silently lands on top of the newer fact (if B did not pass it); in both cases the report must reflect the newer value | `recovery.stale.detected`, `recovery.stale.resolved`, final DB state vs `gold-delta.json` (which includes the injected value as the current one) |
| **Validation failure** | none — planted in the evidence | one pricing capture prints a unit "per 1K tokens" for a legacy offering; the vocabulary allows only `per_1m_*` units; rules page says convert to per-1M and cite a `context` quote | A/C: `VOCABULARY_VIOLATION` at `plan` if the agent copies the unit; correct behaviour is conversion + context quote or `candidate.stage`. B: `commit_batch` raises `unit not allowed for stream kind` | `recovery.validation.hit`, `recovery.validation.resolved_correctly` (converted value present with correct unit, or staged with reason) |

A third planned nuisance, **duplicate submission**, is required by the task itself (resubmit the same write). Correct: A/C receipt `duplicateOf` set, head unchanged; B: second `commit_batch` with the same `idempotency_key` violates `unique(tenant_id, idempotency_key)` or, if B chose a new key, creates a second batch that `assert_state` turns into no-ops (head advances by one with zero changes) — both are acceptable if the agent *reports correctly what happened*; a head advance with duplicated segments is a failure.

---

## 7. Isolation and reset

- **Database**: the db-contract local stack (`pnpm db:start` in `ai-engineer-db-contract`, PG 17) on a dedicated port; never the shared `supabase-blue-ocean` project. `experiment.json.database = { "kind": "local", "projectDir": "../ai-engineer-db-contract", "port": 54322 }`.
- **Reset between runs**: `supabase db reset` (applies all migrations) → `pnpm exp3:fixture` (four batches + roles `exp_agent`/`executor_login` + `log_statement=all`) → `pnpm exp3:snapshot db-before.json` → assert equals expected. Storage buckets are emptied by the reset.
- **Executor state**: the knowledge executor is restarted per run with a fresh artifact cache; the verification store is restored from the sealed evidence snapshot (`evidence/store/`).
- **Sandbox**: eve creates a fresh sandbox per session; the runner starts a new session per run.
- **Secrets**: `SUPABASE_DB_URL` (B only) points at `127.0.0.1`-forwarded `host.docker.internal:54322` with the throwaway `exp_agent` password rotated per run by the fixture script; it is never written into `events.jsonl` (the runner redacts it) and the protocol forbids running B against any other database.
- **Network**: discovery keys are absent from the environment in controlled runs (`FIRECRAWL_API_KEY`/`TAVILY_API_KEY` unset), so an agent that tries discovery gets a clear failure that is counted as a failed tool call, not as evidence.

---

## 8. Run procedure (`tools/experiment-runner/run.mjs` extended)

```
for arm in [A, B]            # M5;  then [C] in M6
  for r in 1..N (N ≥ 3)
    reset database (§7) → apply fixture → db-before.json → verify digest
    restore verification store; start knowledge executor (A, C) with pinned workspace; record health
    start eve dev with RESEARCH_SURFACE for the arm; open session with x-capability-profile = arm profile
    write run-manifest.json (§12) BEFORE the first turn
    send task.md; stream events → events.jsonl; runner watches for the stale-state trigger and injects
    on session end or budget: collect /workspace/run/**, executor receipts, artifacts, verification store delta
    db-after.json → db-delta.json (§10.3)
    metrics.json (§10) → evaluation.json (§11)
```

Runs are sequential (one database). A run whose manifest, `db-before.json`, or executor health fails validation is discarded **before** the first turn and re-attempted; a run that fails after the first turn is kept and scored (it is data).

---

## 9. Budgets (identical per arm)

| Budget | Value | Enforcement |
|---|---|---|
| Tool calls | 220 | eve session hard stop; the runner counts `tool_call` events |
| Wall clock | 90 min | runner timeout; session ended gracefully with a final-summary request |
| Model tokens | not capped (measured) | — |
| Executor per-call | statement timeout 15 s / 60 s heavy; row cap 200/2,000 | executor |
| B per-call | `statement_timeout = 60s` set on `exp_agent` role | database |

---

## 10. Metrics (`metrics.json`)

### 10.1 Outcome metrics (scored against gold, §11)

| Metric | Definition | Source |
|---|---|---|
| `report.quality` | rubric 0–5 per question (§11.2), averaged | `50-report.md`, judge + human |
| `report.attribution` | fraction of factual sentences with a verified claim that the report-check passes; penalty for uncited numbers/dates/names | `61-report-check.json`, mechanical |
| `read.query_correctness` | fraction of the 9 gold baseline facts/ids present in the agent's pre-ingestion snapshot(s) (A/C: `06-snapshot.json`; B: JSON outputs of `db query` found in `/workspace/run`) | gold-baseline, mechanical |
| `read.navigation_accuracy` | fraction of gold gaps (`gold-gaps.json`, 9) correctly identified in the agent's gap notes / report Q8; plus count of false gaps | gold-gaps, judge-assisted mechanical |
| `ingest.validity` | fraction of intended writes that were accepted by the database/executor without vocabulary/rule/schema errors; A/C: `proposals[].outcome ∈ admitted | no_op_duplicate` over all proposals; B: statements that succeeded over statements attempted (from DB log) | receipts / DB log |
| `ingest.canonical` | precision/recall of the final DB delta against `gold-delta.json` at the level of stream slot + interval + value / relationship triple / event | `db-delta.json`, mechanical |
| `temporal.correctness` | for each gold fact written: `valid_during` lower bound within precision of gold; `temporal_basis` matches gold's expectation (`explicit` when the source gives a date); stale fixture segments **closed** (`k_to` set) rather than left current alongside a new segment; no overlapping current segments (guaranteed by the exclusion constraint — a violation shows as a failed write) | `db-delta.json` |
| `dup.handling` | 1 if the second submission produced no new current segments and the agent's summary describes the outcome correctly; 0.5 if no duplicates but misdescribed; 0 otherwise | receipts, DB, summary |
| `recovery.stale` | detected (0/1), resolved correctly (0/1): final current value equals the injected value or a later evidence-backed value, with the agent's report acknowledging the change | injections, DB, report |
| `recovery.validation` | hit (0/1), resolved correctly (0/1) | receipts / DB log, DB |
| `human.interventions` | count of operator messages after the task message (target 0; any intervention is logged with reason) | `events.jsonl` |

### 10.2 Cost metrics

| Metric | Source |
|---|---|
| `tool_calls.total`, by tool name, `tool_calls.failed` (non-zero exit / MCP error) | `events.jsonl` |
| `tokens.input`, `tokens.output`, `tokens.reasoning` (when reported), `cost_usd` | sum over `events.jsonl` step `usage.*` (runner change: aggregate what eve already records per step) |
| `latency.wall_clock_s`, `latency.first_db_read_s`, `latency.first_ingest_s`, `latency.report_done_s` | event timestamps |
| `executor.calls`, `executor.rejections_by_code` | executor receipts (A/C) |
| `db.statements`, `db.errors_by_sqlstate` | isolated DB `log_statement=all` (all arms; A/C traffic comes from the executor and is labeled by `application_name`) |
| `files.read_count`, `files.read_bytes` (A: workspace files read via `cat`/`rg`; B: n/a; C: bytes returned by `schema_*` tools) | sandbox bash log / MCP results |

### 10.3 DB delta

`db-delta.json` = structured diff of `db-after.json` − `db-before.json` over: `corpus.entity` (+alias/identifier), `corpus.relationship`, `temporal.segment` (opened, closed), `temporal.event_occurrence`, `evidence.claim`/`segment_support`, `staging.candidate`/`resolution_decision`, `orchestration.operation_intent`/`operation_receipt`, `temporal.knowledge_batch`. Rows are keyed by natural keys (stream slot + `lower(valid_during)`; relationship `(kind, from, to, qualifier, episode)`; entity by identifier), never by uuid, so gold comparison is id-independent.

---

## 11. Evaluation procedure

### 11.1 Mechanical (`pnpm exp3:evaluate <run-dir>`)

Computes every metric in §10 that has a mechanical source, writes `evaluation.json` with per-item evidence (which gold item matched which DB row / snapshot row), and lists items needing a judge.

### 11.2 Report rubric (judge model + one human pass)

Per question, 0–5: 0 absent; 1 wrong or uncited; 2 partially right, cited; 3 right for the as-of date, cited, but missing validity periods; 4 right with periods and sources named; 5 also states conflicts/unanswerables correctly. The judge receives the report, `gold-answers.json`, and the twelve captures; it may not use outside knowledge (prompt committed). A human scores every run for Q7 and Q8 (conflict and stale-fact reasoning) and spot-checks 2 other questions per run; disagreements > 1 point are resolved by the human and logged.

### 11.3 Navigation accuracy

For A: which workspace ids the agent consulted (from `01-schema-notes.md` and bash log) versus the minimal set the gold gaps require; for B: which catalog queries/`gen types` calls it ran; for C: which `schema_*` tools. Reported descriptively; the score is the gap-recall number in §10.1.

### 11.4 Evaluator blinding

Run directories are renamed to opaque ids before judging; the judge prompt never states the arm. Human scoring is done on the blinded set; unblinding happens in the analysis notebook.

---

## 12. Run manifest and artifacts

`run-manifest.json` (written before the first turn, sealed with its digest after the run):

```jsonc
{ "experiment": "exp3-schema-workspace", "arm": "A", "profile": "db-aware-research-cli", "repetition": 1,
  "model": { "id": "openai/gpt-5.6-terra", "reasoning": "high", "judge": "openai/gpt-5.6-terra" },
  "eve": { "version": "0.44.4" }, "runner": { "commit": "…" },
  "database": { "kind": "local", "migrationHead": "20260912011200", "fixtureDigest": "sha256:…", "dbBeforeDigest": "sha256:…", "knowledgeSeqBefore": 4 },
  "workspace": { "fingerprint": "sha256:…", "scope": "db-aware-research", "bundleDigest": "sha256:…" },   // A, C
  "executor": { "version": "knowledge-executor/0.1.0", "health": { … } },                                   // A, C
  "armB": { "supabaseCli": "2.115.0", "transport": "supabase db query", "role": "exp_agent", "grants": ["pipeline_agent","executor_service"] },   // B
  "evidence": { "setId": "exp3-evidence-2026-09-11", "manifestDigest": "sha256:…", "discoveryEnabled": false },
  "task": { "digest": "sha256:…", "asOf": "2026-09-11" }, "budgets": { "toolCalls": 220, "wallClockMin": 90 },
  "skills": [ { "name": "knowledge-verify", "digest": "sha256:…" }, … ],
  "connections": ["verification"],
  "startedAt": "…", "endedAt": null, "manifestDigest": null }
```

Per run directory: `run-manifest.json`, `events.jsonl` (redacted), `transcript.md`, `final-message.md`, `workspace-run/` (everything the agent wrote: notes, read intents, snapshots, gap notes, captures ledger, claims intents, report, ingestion intents/SQL files, receipts, summaries), `executor/` (receipts, plans, snapshots as served; A/C), `db-log.txt` (statements with `application_name`), `injections.jsonl`, `db-before.json`, `db-after.json`, `db-delta.json`, `metrics.json`, `evaluation.json`, `judge/` (prompts and outputs).

---

## 13. Repetition and analysis

- N = 3 per arm minimum (M5: A and B → 6 runs; M6: C → 3 runs). If any metric's range within an arm exceeds its between-arm difference, N is raised to 5 for all arms before any claim is made.
- Report medians and full ranges per metric, per arm; no means of ordinal rubric scores; no significance tests at N ≤ 5 — the report says "consistent across runs" only when every run of one arm beats every run of the other.
- Per-question and per-sub-task tables (baseline read, gaps, ingestion, duplicate, stale recovery, validation recovery) so wins can be localized.
- Every claim in the results README links the run ids and the metric rows that support it.
- The results README is written **only after** the runs exist; until then it contains this protocol's summary and "not yet run".

---

## 14. Confounds and how B or C can win

| Confound | Effect | Handling |
|---|---|---|
| B has raw SQL and direct roles | B can answer multi-hop questions in one statement and can bypass executor rules; may be faster and may write invalid-but-accepted facts (e.g. `observation_bounded` without evidence link) | Report tool calls and latency honestly; `temporal.correctness` and `ingest.canonical` capture quality of what was written; a B win on speed is reported as a B win |
| A's skills encode the exact procedure the task rewards | A could win because it was told what to do, not because the workspace is good | Ablation lane (optional, after N=3): A without `schema-explore` (skills + executor, no workspace) to separate workspace value from procedure value |
| C's tool descriptions were written by the same people who wrote A's skills | C's guidance quality is a design choice | Descriptions are committed and quoted in the report; the protocol notes that C is "MCP with equivalent guidance", not "MCP with no guidance" |
| Eve's MCP tool-call mechanics vs bash | token accounting differs (MCP results are structured; bash output is text) | Report `files.read_bytes` and tool-result bytes side by side |
| Fixture written by the spec authors | gold may favour A's proposal vocabulary | `gold-delta.json` is expressed as stream slots/values, not proposal kinds; B's SQL can produce the same rows |
| Injection timing | trigger detection differs by arm (executor log vs DB log) | Injection time offsets are logged and compared; if they differ by > 5 min on average, the trigger is changed to a fixed elapsed time for all arms |
| Model nondeterminism | large run-to-run variance | N ≥ 3, ranges reported, no claims when ranges overlap |
| Verification executor shared | equalizes evidence handling | intended; noted |

Ways B can win that the design must be able to show: fewer tool calls and lower latency on read-heavy questions (Q1, Q5); equal `ingest.validity` because the database's checks catch the same classes of error; better `report.quality` on Q7 because it can join sources and facts freely. Ways C can win: fewer tokens (no file reads), higher `read.navigation_accuracy` (tool descriptions surface tasks directly), fewer failed tool calls (no shell quoting).

---

## 15. Live-web lane (descriptive only)

After controlled runs, one run per arm with discovery enabled (Firecrawl + Tavily; keys present), same task, no fixed evidence list, same fixture. Reported as a narrative with the same artifacts but **excluded** from every comparative table; its purpose is to show the flow end to end with real discovery and to surface failure modes the fixed set hides.

---

## 16. Checklist before the first run

- [ ] M1–M4 acceptance criteria met; `knowledge-db health` matches the isolated DB head.
- [ ] Supabase CLI 2.115.0 in the B sandbox image; multi-statement `db query -f` transaction check passed, or `psql` fallback recorded.
- [ ] `exp3-seed` applied twice yields identical `db-before.json`; `knowledge_seq = 4`.
- [ ] `pnpm exp3:check-gold` passes; gold reviewed by a second person.
- [ ] Evidence set sealed; digests in `evidence/manifest.json`; discovery keys absent from the controlled environment.
- [ ] Profiles `db-aware-research-cli`, `db-direct-supabase-cli`, `db-aware-research-mcp` exist; `RESEARCH_SURFACE` handling for C unchanged from exp1.
- [ ] Runner writes `run-manifest.json` before the first turn, aggregates usage into `metrics.json`, redacts `SUPABASE_DB_URL`, produces `db-delta.json`.
- [ ] Injection triggers tested on a dry run per arm.
- [ ] Judge prompt committed; blinding script tested.
- [ ] `experiments/exp3-schema-workspace/README.md` says "not yet run".
