# Build 07 R1: research requests and missions, editable datasets, reports with claims and evidence

**Status: ACCEPTED by John, 2026-11-05** (“Approved. Let's do it.”, with the recommended answers to Q1–Q4) **and implemented in the lab**: folded into the unreleased lab migrations on branch `build-04-product-schema-lab`, as Build 05 was. Clean replay and proof results are in the [Build 07 record](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-07-RESEARCH-TO-CONTENT.md). Section J lists where the build differs from this text; J takes precedence.

Units: **RV22** (research request, interview, proposal, acceptance, output obligations), **RV08** (product research datasets, reports, interactive experiences), **RV10 seam** (statements inside reports and datasets, their support and contradiction, review). Accepted inputs: FC-D06–FC-D15 (datasets, revisions, reports, preservation, interactivity), FC-D27 (refresh and watches), the bounded-decision model, Build 02's rule that private content never becomes a tenant-shared row.

## A. The research-to-content path in one paragraph

A person or agent writes a **research brief** (an ordinary `brief` work) through a conversation or directly. A brief revision that contains a plan and a list of required outputs is a **proposal**. Accepting an exact proposal revision, with a budget and an execution origin, creates an **acceptance**: the authority under which research runs. The acceptance lists **output obligations** (for example "a dataset of provider pricing" and "a comparison report"). Work runs in Mission Control (Deep Agents first) or, until MC is integrated, in a harness, with the real origin recorded. Each output is an ordinary work revision (dataset, report, experience, file) that is **delivered** against an obligation and then accepted or rejected. Datasets are **editable** between fixed revisions. Every substantive statement in a report or value in a dataset can carry **support**: evidence that supports, contradicts or qualifies it, a calculation, or a bounded decision. Refreshing or a watch produces a **proposed change** to a dataset that someone reviews; old report revisions stay bound to the old dataset revision.

## B. Decisions

| # | Decision | Why |
| --- | --- | --- |
| D1 | Brief, proposal and interview reuse existing records: `authoring.work(kind='brief')` revisions with body `aieng.research-brief.v1`; the interview is a `conversation.thread` bound to the brief | No second document/revision mechanism. A proposal is just a brief revision that passes proposal validation |
| D2 | Acceptance, obligations and deliveries are relational (`inquiry.*`) | They need integrity, reverse queries ("which mission produced this cell?") and an independent lifecycle |
| D3 | MC is referenced, not copied: MC coordinates are typed columns with no physical FK, because MC is a separately installed component | Native and MC planning identities stay distinct (RV22 card). An adapter verifies the coordinates; a harness origin is labelled as such |
| D4 | Datasets are stored as **versioned relational cells** (each field/row/cell version carries the revision range it is valid in). The draft is the open range; committing a revision closes nothing and copies nothing | Cell-level edits, attribution and support with exact revision reads, without copying the whole table per revision. Exports (CSV/Parquet/JSON) are artifacts bound as `representation` |
| D5 | Statements and support are **workspace-scoped** product rows (`inquiry.assertion`, `inquiry.support`). Shared `evidence.claim` is referenced when a statement uses shared knowledge; promoting a private statement into shared knowledge is a separate explicit operation (RV09/RV10, later) | Build 02 rule: `evidence.*` has no workspace column, so private findings must not be written there |
| D6 | One support table serves report statements and dataset cells/rows | One answer to "why does this value/sentence say this?" and one reverse query from evidence to everything it supports |
| D7 | Refresh, corrections and watch results are **change proposals** on a dataset (staged cell versions), reviewed before they become a revision | FC-D08: reviewable delta; old references stay pinned |
| D8 | Reader views and scenarios are the reader's own `view` works anchored to a released experience/report; they never modify the report | FC-D12: reader assumptions are distinct from sourced findings |
| D9 | Disclosure status is explicit on values and statements: undisclosed, not found in named sources, conflicting and not applicable are distinct from unknown | State of AI Research addition for RV10 |
| D10 | Legacy `research.*` (report v1, KS report-v2 projection) and `corpus.dataset` (catalogued external datasets such as benchmarks) are unchanged | Report-v2 projection is KS-owned; external catalogued datasets are a different thing from a user's research dataset. Removal of retired report-v1 tables waits for the RV21 consumer inspection |

## C. Changes to accepted relations

| Object | Change |
| --- | --- |
| `authoring.work.kind` | + `view` (a reader's saved filter/scenario over a released report or experience) |
| `authoring.work_revision.body_schema` | + `aieng.research-brief.v1`, `aieng.dataset-revision.v1`, `aieng.report-body.v1` (report = v2 block tree plus `assertions`), `aieng.view.v1` |
| `authoring.revision_binding.relation` | + `scenario_of` (view → released report/experience item). Delivery against an obligation is recorded in `inquiry.delivery`, not as a binding |
| `authoring.revision_binding` targets | + `assertion_id` (an exact statement, e.g. a lesson citing a report finding). Dataset cells are reached through `inquiry.support` and the `uses` binding to the exact dataset revision, not as binding targets |
| `authoring.event.kind` | + `proposal_submitted`, `accepted`, `acceptance_withdrawn`, `delivered`, `delivery_accepted`, `delivery_rejected`, `change_proposed`, `change_applied`, `change_rejected`, `watch_paused` |
| `authoring.block_type` | + `finding` (a statement block with its assertion key and evidence drill-down), + `dataset_view` (table/filter view over a pinned dataset revision; role `dataset` required) |
| Dataset body (`aieng.dataset-revision.v1`) | Replaces R1's bounded 100-row/20-field inline snapshot. The revision body holds title, description, field order, counts and the canonical content digest; cells live in `dataset.*` |

## D. New relations

All are tenant + workspace scoped, forced row security, immutable unless stated, written only through `api.product_command`.

### Requests and missions (`inquiry`)

| Relation / one row | Columns | Key rules |
| --- | --- | --- |
| `inquiry.acceptance` / one accepted scope of research | `id, tenant_id, workspace_id, brief_work_id, brief_revision_id, acceptance_no, revises_acceptance_id?, accepted_by, accepted_event_id, budget_limit_usd numeric(10,2), budget_policy jsonb, world_from?, world_to?, world_precision, knowledge_policy text ('sealed','latest_at_run'), execution_origin text ('mc','native_harness','manual'), mc_installation_id?, mc_application_id?, mc_mission_id?, mc_revision_id?, mc_run_id?, state text ('accepted','running','delivered','closed','cancelled','failed','superseded'), state_changed_at, created_at` | Brief revision must validate as a proposal (has plan + ≥1 obligation). `acceptance_no` unique per brief. `revises_acceptance_id` creates a new scope; the old row moves to `superseded` (prior acceptance never authorizes expanded work). `execution_origin='mc'` requires mission + revision ids. State is the only mutable column, moved by commands |
| `inquiry.obligation` / one required output of an acceptance | `id, acceptance_id, obligation_key, form text ('dataset','report','experience','finding_set','file','course_content'), enforcement ('required','expected','optional'), expected_work_kind?, criteria jsonb (aieng.output-criteria.v1), mc_obligation_key?, position` | Unique (acceptance, key). Criteria are explicit checks (fields present, minimum supported share, source classes, freshness), not a hidden grade. `mc_obligation_key` maps to MC `output_obligation_revision.obligation_key` |
| `inquiry.delivery` / one output offered against an obligation | `id, obligation_id, revision_id?, artifact_id?, file_set_id?, mc_output_revision_id?, delivered_by, origin ('mc','native_harness','manual'), state ('submitted','accepted','rejected','withdrawn'), assessment jsonb (criteria results), decided_by?, decided_event_id?, created_at, decided_at?` | Exactly one target. Revision kind must match `expected_work_kind`. Accepted deliveries per obligation are the fulfillment; "fulfilled" is derived, not stored. The producing agent cannot accept its own delivery when the policy requires review |
| `inquiry.watch` / one opt-in recurring refresh | `id, brief_work_id, subjects jsonb, sources jsonb, cadence text (ISO 8601 duration), budget_per_run_usd, budget_total_usd, stop_condition jsonb, targets (dataset work ids) uuid[], mc_schedule_ref?, state ('active','paused','stopped'), created_by, created_at, state_changed_at` | Configuration only: no scheduler here. Each run is a normal acceptance with `revises_acceptance_id` and `budget_policy.trigger='watch'`. Mutable: state only |

### Datasets (`dataset`)

A dataset is `authoring.work(kind='dataset')`. Revision numbers are the work's `revision_no`. The **draft** is the next revision number, not yet committed.

| Relation / one row | Columns | Key rules |
| --- | --- | --- |
| `dataset.field` / one field definition, valid over a revision range | `id, dataset_work_id, field_key uuid, name, value_type ('text','number','integer','boolean','date','datetime','money','percent','entity','url','json'), unit?, currency?, meaning text, required bool, from_revision_no, to_revision_no?` | Stable `field_key` across revisions. Changing type/unit/meaning closes the old version and opens a new one. Field name unique among open versions |
| `dataset.row` / one row identity, valid over a revision range | `id, dataset_work_id, row_key uuid, entity_id?, label?, from_revision_no, to_revision_no?` | `entity_id` links a row to the shared catalog entity (a company, a model) when known |
| `dataset.cell` / one value version | `id, dataset_work_id, row_key, field_key, value jsonb?, value_status ('observed','calculated','inferred','estimated','unknown','not_found','undisclosed','conflicting','not_applicable'), observed_at?, entered_by, entered_kind ('human','agent','import'), entered_origin_ref jsonb, proposal_id?, from_revision_no?, to_revision_no?` | One open version per (row, field) outside proposals. `value` null unless status is a value status. Edit attribution is separate from support (FC-D07). Staged cells carry `proposal_id` and no revision range until applied |
| `dataset.proposal` / one reviewable change to a dataset | `id, dataset_work_id, base_revision_no, reason ('refresh','correction','watch','agent_edit','import'), acceptance_id?, summary jsonb (added/changed/removed counts per field), dedupe_key, state ('open','applied','rejected','stale'), decided_by?, decided_at?, created_by, created_at` | Unique (dataset, dedupe_key): an identical refresh result produces no second proposal and no alert. Applying opens/closes cell versions and commits a new revision atomically. `stale` when the base is no longer the head |

Committing a revision writes `authoring.work_revision` with the content digest over the open field/row/cell set. Reading revision *n* selects versions where `from ≤ n < coalesce(to, ∞)`. A report binds `uses` → that exact dataset revision.

### Statements and support (`inquiry`)

| Relation / one row | Columns | Key rules |
| --- | --- | --- |
| `inquiry.assertion` / one statement made in an exact work revision | `id, revision_id, assertion_key uuid, block_key?, kind ('finding','claim','estimate','comparison','recommendation','assumption','limitation','question'), statement text, structured jsonb?, support_status ('supported','partially_supported','contradicted','unsupported','judgment','unknown','undisclosed','not_applicable'), entity_ids uuid[], world_from?, world_to?, world_precision, uses_claim_id?, promoted_claim_id?, created_by` | Stable `assertion_key` across revisions (like block keys), so "this finding in every revision" is one query. `block_key` must exist in the revision's block projection. `support_status` is the author/agent's declared status; derived support counts are computed from `inquiry.support`. `uses_claim_id` cites shared knowledge; `promoted_claim_id` is set only by the later promotion operation |
| `inquiry.support` / one piece of support or contradiction | `id, subject: assertion_id? or (dataset_work_id, row_key?, field_key?, cell_id?)`, `role ('supports','contradicts','qualifies','context','calculated_from','inferred_by')`, target exactly one of `locator_id, capture_id, claim_id, record_id, binding_id, assertion_id, cell_id, decision_revision_id + answer_key`, `method jsonb? (calculation expression and inputs)`, `assessed_by, assessed_kind ('human','agent','verification'), verification_ref? (KS run/observation id), assessed_at` | Dataset-level, row-level and cell-level support are all allowed (FC-D07 does not require a citation per cell). `calculated_from` requires `method`; `inferred_by` requires a decision answer or an agent with method. Contradiction is kept, never deleted. Provenance does not prove truth: support records who judged what, against which exact evidence |

## E. Commands and reads (database layer)

Commands (added to `api.product_command`): `propose_research` (validate a brief revision as a proposal), `accept_research`, `withdraw_acceptance`, `set_acceptance_state`, `deliver_output`, `decide_delivery`, `define_dataset_fields`, `edit_dataset_cells` (draft edits), `commit_dataset_revision`, `propose_dataset_change`, `decide_dataset_change`, `record_assertions` (part of revising a report), `add_support`, `create_watch`, `set_watch_state`, `save_view`.

Reads (added to `api.product_read`): `get_acceptance` (with obligations, deliveries, fulfillment), `get_dataset` (any revision, paged, with cell status and support counts), `get_dataset_diff` (revision or proposal against base), `get_cell_support`, `get_report` (blocks + assertions + support summary), `trace_assertion` (statement → support → evidence/locator/capture → source; and dataset cell → inputs), `trace_reverse` (capture/claim/cell → every assertion, dataset revision, report and acceptance that uses it), `list_watches`.

The service (`aiengineer/ai-engineer-service`) exposes these through the existing operation catalog, so API, MCP and CLI stay at parity.

## F. Access and lifecycle rules

- Workspace membership governs all `inquiry.*` and `dataset.*` rows. Release closure (Build 01 R2) follows `uses` bindings into dataset revisions and assertions, and applies `access.source_restriction` and usage (`reference_only` evidence is cited, not copied, into a release).
- A purchased or released report keeps its exact dataset revision and assertion rows; corrections are new revisions (FC-D14).
- Removal follows Build 02 tracked deletion; a legal hold on a capture blocks removal of supports that reference it.
- Budget: `budget_limit_usd` is the hard ceiling for the acceptance; MC's budget enforcement applies when `execution_origin='mc'`. Native harness runs record actual spend in `budget_policy.actual` and refuse new paid work past the limit.

## G. Keeping current

| Trigger | What happens | User-visible result | Duplicate case |
| --- | --- | --- | --- |
| Manual refresh of a dataset | New acceptance revising the old one, scoped to the dataset; results become a `dataset.proposal` | Diff by field and row with support for each change | Same result → same `dedupe_key` → no proposal, no notice |
| Watch run | Same, with `trigger='watch'` and per-run budget | Change notice naming affected reports and experiences (reverse trace) | Same |
| Retraction, correction or access loss of a cited capture/claim | Existing `change_detected` event on bound revisions; affected assertions listed by `trace_reverse` | Report shows "evidence changed" on affected statements; author proposes a revision | Event dedupe key per (capture, change) |
| Decision definition/model revision | Affected `inferred_by` cells listed; re-evaluation is a new proposal, never a silent rewrite | Proposed relabels with old/new answers | Unchanged answers produce no change |

## H. Proof plan if approved (lab)

On the existing disposable stack (`disposable-aieng-build04`), after replaying the canonical chain with the folded migrations:

1. **Real sample, $0 paid spend:** the brief "Compare frontier model API offerings: price per million input/output tokens, context window, and published availability, W = [2026-10-01, 2026-11-01) UTC, day precision". Capture 4–6 public provider pricing/documentation pages with plain HTTP fetch (no paid search or model calls), register them as captures with locators. The agent doing the work is labelled `native_harness`; MC coordinates are absent and reported as such.
2. **Dataset shape A** (provider/model/price/context/date/source) and **shape B** (task, conditions, measured latency/cost; labelled fixture values, since no paid calls are authorized) with real field types, units, statuses including `undisclosed` and `conflicting`.
3. **Report** with findings bound to support, one contradicting source, one calculated value (price ratio) with method, one `inferred_by` value from a labelled deterministic decision fixture.
4. **Experience** as a harness-built file set bound to the report and dataset revisions; a reader `view` that filters without changing the report.
5. **Update:** a correction proposal changes one price; applying it creates dataset revision 2; report revision 1 still reads revision 1; an identical refresh creates no proposal and no notice.
6. **Denials and traces:** outsider cannot read any of it; producer cannot accept own delivery; forward trace (statement → source bytes) and reverse trace (capture → statements, cells, report, acceptance) return exact rows; missing-link outcome reported for a statement with no support.
7. Regression: the existing 104 database checks and the service surface suites still pass.

## I. Not in this build

Commerce catalog, listings and entitlements; KS verification runs over private assertions (only references are modeled); promotion of private statements into shared `evidence.claim`; MC scheduling for watches; real paid research; RV12 retrieval over datasets; per-provider decision adapters; removal of retired report-v1 tables.

## J. As built (lab, 2026-11-05)

71 product relations (60 + 11). Differences from sections B–E, each forced by the lab or simpler with the same meaning:

| # | Recommendation said | Built | Why |
| --- | --- | --- | --- |
| J1 | Support targets shared `locator`/`capture` for fetched pages | Fetched pages are private `document` work revisions (bytes in custody, URL and fetch metadata in `metadata.source`); `inquiry.support.source_revision_id` + `selector` (`aieng.text-quotes.v1`) + `excerpt` | Lab finding F-25: shared `evidence.source_capture` requires an MC attempt or KS operation (`num_nonnulls(produced_by_attempt_id, knowledge_operation_id) = 1`). Inventing one would manufacture provenance. Shared locator/capture/claim targets remain for shared evidence |
| J2 | New `body_schema` values (`aieng.research-brief.v1` …) | Bodies stay `aieng.work-body.v2`; each kind's contract is `metadata.research` / `metadata.dataset` / `metadata.source` / `metadata.view`, with its own `schema` name | One body grammar; the existing validator and block projection apply unchanged |
| J3 | `define_dataset_fields`, `edit_dataset_cells`, `record_assertions`, `save_view` | `create_dataset` (commits revision 1) and one `edit_dataset` (fields, rows, values). Statements are part of `create_work` / `revise_work` (`revision.assertions`). A view is `create_work(kind='view')` with a `scenario_of` binding | Fewer operations, same capability; statements are sealed with their revision |
| J4 | `links_to` targets | `links_to` may also target an `assertion_id` (an experience linking a finding) | Lab finding F-28 |
| J5 | "The producing agent cannot accept its own delivery" | People only: accepting research, accepting/rejecting deliveries, applying dataset changes, closing, opting into and resuming watches. Agent clients get `FORBIDDEN`. Agents propose, deliver, edit drafts, cite and pause | Enforced through the existing human/agent client distinction, with no separate producer identity |
| J6 | `get_cell_support` | `get_support` (statement or cell; includes row-level support) | — |

Implemented operations:
- 14 commands: `propose_research`, `accept_research`, `set_acceptance_state`, `withdraw_acceptance`, `deliver_output`, `decide_delivery`, `create_watch`, `set_watch_state`, `create_dataset`, `edit_dataset`, `commit_dataset_revision`, `propose_dataset_change`, `decide_dataset_change`, `add_support`.
- 8 reads: `get_acceptance`, `get_dataset`, `get_dataset_diff`, `get_support`, `get_report`, `trace_assertion`, `trace_reverse`, `list_watches`.

Release exposure follows cited statements and the source documents that support statements and dataset values.

Not built:
- obligation criteria are stored and the person's assessment recorded, but not evaluated automatically;
- `withdraw_acceptance` has no lab check yet;
- no MC adapter fills the `mc_*` columns;
- no scheduler runs watches;
- statements cannot yet be promoted to shared `evidence.claim`.
