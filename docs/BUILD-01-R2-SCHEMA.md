# Build 01 R2: RV14/RV15 residual schema — publishing, rich runtime, competency and credit compatibility

**Status: schema ACCEPTED by John, 2026-11-05 ("Approved."), with both recommended choices: amend R1 before migration; public creator library = authenticated principals of the deployment. Not migrated, not runtime-tested.** Schema-only packet under the "approve schema and continue" mode. It extends the accepted [R1 schema](BUILD-01-R1-SCHEMA.md) and is recorded in [Build 01](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-01-COURSE-FOUNDATION.md#recommendation-r2--rv14rv15-residual-schema-2026-11-05). No lab, prototype, course content, migration file or consumer change is requested.

R2 closes the three residual design areas R1 listed for RV14/RV15:

1. **Sharing and publication:** invited and public creator releases, the separate official system catalog, withdrawal, learner adaptation and the dependency-exposure check that keeps private sources private.
2. **Rich-artifact runtime:** standalone interactive/runnable experiences, reusable renderer components, exact runtime/package/model pins and execution classes.
3. **Competency and credit:** versioned competencies, outcome alignment, evidence-rule bindings to rubrics/policies, eligible generated-task routes and requirement-level carry-forward between releases.

Accepted R1 semantics are preserved: immutable sealed revisions, typed bindings, workspace scope with composite FKs, single command/read API, human-only release review, no grade/mastery tables, and explicit adoption that never rewrites history. Section A lists the small R1 amendments R2 needs; because R1 is not migrated, they cost nothing to apply now.

## A. R1 amendments (pre-migration)

| # | R1 object | Amendment | Why |
| --- | --- | --- | --- |
| M1 | `curriculum.release` | Becomes **`authoring.release`**. `course_work_id` → `root_work_id`; root kind course/track/module/lesson/activity/report/dataset/experience/component/competency. Replace `kind private_preview` with `audience_ceiling` workspace/named/public. Unique `(scope, root_work_id, release_no)`. Release review must bind root, closure digest **and** ceiling | Standalone reports, datasets, experiences and competency frameworks need the same freeze/release mechanism as courses (GF12). A second freeze table would duplicate R1. The ceiling records which exposure check the closure passed |
| M2 | `curriculum.release_transition` | References `authoring.release`; same root work, unchanged otherwise. `mapping` keeps occurrence/content-level diff; requirement-level credit moves to the new `curriculum.requirement_transition` | Typed credit joins (section C) |
| M3 | `learning.enrollment` | Lives in the **learner's own workspace**. Replace `course_work_id` with `(source_workspace_id, distribution_id)`, composite FK `(tenant_id, source_workspace_id, distribution_id)` → `authoring.distribution(tenant_id, workspace_id, id)`. Add `update_policy` manual/auto_compatible (default manual). UNIQUE `(scope, learner_id, distribution_id)`. Distribution root must be a course | Learner-owned study state for invited/public/official learners who are not creator-workspace members; supports portability (GF20) and EDU-D39/D40. A same-workspace private preview uses a `workspace` channel distribution, so R1's own-course study path still works |
| M4 | `learning.release_adoption` | `release_id` → `offer_id` (composite FK to `authoring.distribution_offer` through the enrollment's source scope; offer must belong to the enrollment's distribution). Add `basis` explicit/standing_consent. Standing consent requires `update_policy=auto_compatible`, a human-reviewed `compatible` transition and every requirement transition `carry` or `not_applicable`; `actor_id` remains the learner whose consent applies | Closes the "automatic opt-in compatibility" residual without automatic credit change |
| M5 | `curriculum.requirement_option.route` | Add `generated_eligible`: requires `uses` bindings (keys named in `evidence_rule`) to an exact `decision_definition` revision (task-quality check) and `action_policy` revision (eligibility threshold); `activity_revision_id` must be NULL | EDU-D20/D28: generated tasks count only under an approved generation/evaluation policy. Reuses the approved bounded-decision kinds rather than a new policy table |
| M6 | `authoring.work.kind` | Add `experience`, `component`, `competency` | Section B/C |
| M7 | `authoring.revision_binding` | Relations add `has_component` (competency→competency revision) and `adapted_from` (root of an adaptation → `release_item`). New nullable target column `release_item_id` (exactly-one-target check extended). `adapted_from` is the only binding allowed to cross workspaces, and only through an offer whose terms permit adaptation. Outcome-to-competency alignment is outcome-level, so it gets its own relation (section B), not a binding | Learner adaptations keep a typed link to the exact released source (EDU-D40) |
| M8 | `reviewed` event payload | `reviewType` adds `official_publication`, `runtime_review`, `transition_review`. Each binds exact digests; none carries over to a new release/revision | Separate official route; reviewed runtime exposure; reviewed credit mapping |
| M9 | Access helper and read API | Non-members can read only `release_item` rows with a visible disposition, through an active distribution grant (section D). Workspace membership rules are otherwise unchanged | Publication access without workspace membership |

## B. New relations

Conventions are R1's: `tenant_id, workspace_id` scope pair with composite FKs to `authoring.workspace`, PK `(id)` plus UNIQUE `(tenant_id, workspace_id, id)`, `util.uuidv7()` IDs, `now()` timestamps, CHECK-constrained text discriminators, actor FKs to `auth.users` with RESTRICT, FORCE RLS, writes only through `api.course_command`. `publisher_grant` is tenant-scoped (no workspace).

| Relation / one row | Columns beyond scope and identity | Keys, checks and lifecycle |
| --- | --- | --- |
| `authoring.release_item` / one item exposed by a release closure, with its disposition | `release_id uuid, item_key text, revision_id uuid?, artifact_id uuid?, capture_id uuid?, locator_id uuid?, claim_id uuid?, record_id uuid?, entity_id uuid?, via_binding_id uuid?, disposition text, substitute_artifact_id uuid?, decided_by uuid?, rationale text?, created_at` | UNIQUE(scope, release_id, item_key); exactly one target. disposition `include` / `snapshot` / `reference` / `withheld`. `snapshot` requires `substitute_artifact_id` (an authored derivative/excerpt artifact with redistributable rights in the same workspace). Author-chosen dispositions (any departure from the automatic rule in D.2) require `decided_by` + `rationale`. Inserted only by `freeze_release`; immutable. The manifest artifact remains the portable digest-verified export; these rows serve access checks and reverse impact queries |
| `authoring.distribution` / stable channel delivering one root work to one audience | `root_work_id uuid, channel text, title text, created_by uuid, created_at, closed_at timestamptz?, closed_event_id uuid?` | channel `workspace` / `invited` / `public_library` / `official_catalog`. Root kind as M1. At most one open `official_catalog` distribution per root work (partial unique). Closing is monotonic and stops new enrollments and offers; existing adopters follow each offer's end kind. Not a listing, price or entitlement |
| `authoring.distribution_member` / reader grant on an invited distribution | `distribution_id uuid, principal_id uuid, grant_basis text, granted_by uuid, created_at, revoked_at timestamptz?` | PK(scope, distribution_id, principal_id). Only for channel `invited`. grant_basis `invited` (future `entitlement` is reserved for the commerce packet, not accepted now). Owner/editor of the source workspace grants/revokes. Not workspace membership: never grants authoring, conversations, assessment history or unrelated notes |
| `authoring.distribution_offer` / one exact release offered in a distribution under frozen terms | `distribution_id uuid, release_id uuid, offer_no integer, terms_schema text, terms jsonb, approval_event_id uuid, offered_by uuid, created_at, ended_at timestamptz?, end_kind text?, end_event_id uuid?` | UNIQUE(scope, distribution_id, offer_no), UNIQUE(scope, distribution_id, release_id). Release root = distribution root; channel ≤ release `audience_ceiling` (workspace→workspace; invited→named or public; public_library/official_catalog→public). terms_schema `aieng.use-terms.v1`. For `official_catalog`, `approval_event_id` must be an `official_publication` review by a current `publisher_grant` holder binding this release closure digest + terms digest; otherwise a release review by a current owner/editor. `end_kind` `retire` (no new enrollment/adoption; existing adopters keep access) or `revoke` (content access denied; adopters keep their own records and see the reason). end fields set together, once. Latest non-ended offer is the current offer |
| `authoring.publisher_grant` / tenant authority to approve official-catalog offers | `tenant_id uuid, principal_id uuid, channel text, granted_by uuid?, created_at, revoked_at timestamptz?` | PK(tenant_id, principal_id, channel); channel `official_catalog`. Bootstrapped from trusted server configuration (John); later grants only by a current holder. Workspace roles never imply it. No automation exception exists; an automated publisher would need a new reviewed policy design |
| `authoring.runtime_requirement` / one exact declared runtime dependency of a revision | `revision_id uuid, local_key text, kind text, ecosystem text?, name text, version_spec text, resolved_version text?, entity_id uuid?, phase text, optional boolean, created_at` | UNIQUE(scope, revision_id, local_key). kind `language_runtime` / `package` / `model` / `provider_api` / `service` / `network_host` / `secret_name` / `hardware` / `renderer_capability`. ecosystem e.g. pypi/npm/oci/huggingface/provider (required for package/model). phase `build` / `run` / `test`. `secret_name` stores a name only; a CHECK rejects values resembling keys. Optional `entity_id` composite FK to `corpus.entity` when the catalog knows the subject. Sealed with the revision; immutable. Index `(tenant_id, kind, ecosystem, name)` |
| `curriculum.outcome_alignment` / exact outcome-to-competency alignment | `outcome_id uuid, competency_revision_id uuid, facet text, coverage text, rationale text, created_at` | UNIQUE(scope, outcome_id, competency_revision_id, facet). facet `independent` / `assisted` / `agent_directed`; coverage `full` / `partial`. Competency revision must be a sealed `competency` work revision in the same workspace or reachable as an `include` release item of an offer the workspace can read (official frameworks). Sealed with the outcome's revision; immutable. Reverse index on competency_revision_id |
| `curriculum.requirement_transition` / reviewed carry-forward rule between exact old and new requirements | `transition_id uuid, from_requirement_id uuid?, to_requirement_id uuid?, effect text, carry text, rationale text, created_at` | UNIQUE(scope, transition_id, from_requirement_id, to_requirement_id) with NULLs not distinct. effect `same` / `equivalent` / `narrowed` / `broadened` / `replaced` / `removed` / `added`; `added` has no from, `removed` no to, others both. carry `carry` / `reassess` / `not_applicable`; `broadened`, `replaced`, `added` cannot be `carry`. Endpoints belong to the transition's from/to release root revisions. Every old requirement appears exactly once. A transition may be `compatible` only if no row is `reassess` and none is `added`, and a `transition_review` event approved it. Defines rules only; applying carry-forward to actual evidence is RV17 |

**Totals:** R1's seventeen relations (with M1–M4 relocations/renames) plus eight new ones = **twenty-five** product relations. Still no submission, grade, mastery, listing, price, order or entitlement table.

### Removed or merged from older proposals

| Older proposal | R2 disposition |
| --- | --- |
| `authoring.publication`, `publication_event` | Merged into `distribution` + `distribution_offer` (availability and its end) and R1 `authoring.event` (reasons/reviews) |
| `authoring.publication_policy_version` | Not created. No automated publishing exists; human official review is required. Revisit only when John requests an automation exception |
| `learning.competency_version`, `competency_edge` | Competency = `competency` work kind on R1 revisions; prerequisite edges use `curriculum.prerequisite`; component edges use `has_component` bindings. Transfer edges belong to RV16 |
| `curriculum.objective_competency` | Becomes `curriculum.outcome_alignment` with facet/coverage |
| `curriculum.requirement_transition` | Kept, simplified: no separate evidence-policy version; the transition review and rules suffice |
| `authoring.dependency_notice` | Already R1 `authoring.event` `change_detected` / `change_acknowledged` |

## C. JSON contracts

All validated by the write function and shared client schema; unknown fields only inside a capped `extensions` object; canonical hashing as R1.

- **`aieng.use-terms.v1`** (offer terms): `study: true`; `adapt: none | private | shareable`; `redistribute: none | unmodified_with_attribution`; `derived_work: none | permitted_with_attribution`; `attribution` text; `updates: corrections_included | new_edition_required` (aligns with the accepted correction/new-edition commerce rule); `endorsement: creator | official` (derived from channel, not author-editable).
- **`aieng.runtime-profile.v1`** (metadata of `experience` revisions and of interaction blocks): `execution_class: static | sandboxed_web | notebook | container_service | external_hosted`; `entrypoint`; binding keys for `bundle`, `source_bundle`, `lockfile`, `static_export`, `accessible_fallback` (required for every interactive class), `transcript`/`captions` for media; runtime requirement keys; `network: none | declared_hosts`; `persistent_state: none | per_viewer | shared`; `reader_supplied_secrets: [secret_name keys]`; `what_remains_external` (text + bindings). Author secrets are never part of a bundle or profile.
- **`aieng.component.v1`** (metadata of `component` revisions, the renderer catalog): `renderer_id`, `input_schema`, `interaction_contract` (events emitted/consumed through the sandbox bridge), `requested_capabilities`, `fallback_requirement`, `supported_surfaces` (web/harness/static). Interaction blocks reference an exact component revision through a `uses` binding, replacing R1's free-text "trusted renderer ID/version".
- **`aieng.competency.v1`** (metadata of `competency` revisions): `statement`, `conditions`, `facets` offered, optional `levels` (ordered descriptors), `framework_ref` (optional external identifier/URI, e.g. a CASE CFItem identifier), `concept` binding keys (`covers` → `corpus.entity`).
- **`aieng.evidence-rule.v2`** (outcome and option rules; v1 rules remain readable): `observables`, `criteria_binding` (key of a `uses` binding to an exact `decision_definition` revision = rubric), `assistance` (declared allowed tools/AI modes, matched to the alignment facet), `min_evidence`, `freshness_days?`, `generation_policy_bindings` (only for `generated_eligible`), `facet`. Structural rule for options: same facet and same criteria binding target, or a stricter declared threshold; semantic equivalence remains a human approval (R1 `approval_state`).

## D. Behavior and invariants

### D.1 Who can do what

| Action | Authority |
| --- | --- |
| Freeze a release at a ceiling | Owner/editor review of exact root + closure + ceiling (R1, extended by M1) |
| Open/close a distribution; offer/end an offer; grant/revoke invited readers | Owner/editor of the source workspace; closing/ending records an `authoring.event` reason |
| Offer into `official_catalog` | Additionally an `official_publication` review by a current publisher grant holder for this exact release + terms. Never inherited by the next release |
| Enroll | Learner, in own workspace, while the distribution is open and the learner can read it (member for `invited`; any authenticated principal of the tenant for `public_library` / `official_catalog`; workspace member for `workspace`) |
| Adopt an offer | Learner explicitly, or standing consent under M4 |
| Adapt | Learner/creator with read access when terms allow; creates a new work in the adapter's workspace |
| Approve a compatible transition | Human owner/editor via `transition_review` |
| Approve a sandboxed/container experience above `workspace` ceiling | `runtime_review` by owner/editor naming the exact runtime profile digest |

### D.2 Dependency exposure at freeze

`course_read(operation='preview_exposure', root, ceiling)` computes, and `freeze_release` re-verifies, a disposition for every closure item:

| Item | `workspace` ceiling | `named` / `public` ceiling |
| --- | --- | --- |
| Authored revision in the closure | include | include |
| Artifact/capture with `redistributable` rights | include | include |
| Artifact/capture with `private_copy` | include | **blocker**: author chooses `snapshot` (permitted derivative), `reference`, `withheld` or replaces the dependency in a new revision |
| `reference_only` source | reference | reference when the original locator is itself public; otherwise withheld |
| `unknown` rights | include within workspace | **blocker** until decided |
| Claim, locator, knowledge record | include | include only if its source capture is `include`/`snapshot`/public `reference`; otherwise withheld |
| Experience with `sandboxed_web`, `notebook`, `container_service`, `external_hosted` | include | requires `runtime_review`; `container_service`/`external_hosted` also require that no author secret is needed (reader-supplied secrets only) |

Withheld items render as a labelled placeholder; generated previews, search snippets, exports and harness reads use the same `release_item` disposition, so a private source cannot leak through a derivative path. Publishing never changes the external provider's own sharing settings.

### D.3 Reads, withdrawal and revocation

A non-member reads released content only through `api.course_read` (`get_offer`, `get_released_revision`, `get_released_asset`) and bytes only through the authenticated product endpoint, both checking: active grant → offer not `revoke`-ended (or `retire`-ended with an existing adoption) → item disposition visible → current asset/source rights. A later `asset_scope` revocation or rights change denies affected bytes immediately for every audience and raises a `change_detected` event for the maintainer; it does not rewrite the release. Learners' enrollment, adoptions, personal revisions and (later) evidence remain theirs when an offer is revoked.

### D.4 Adaptation

`adapt_release` copies `include`/`snapshot` content into a new work in the adapter's workspace, keeps `reference` items as references, omits `withheld` items, and adds an `adapted_from` binding to the root release item. Upstream offers raise `change_detected` on the adaptation without overwriting it. An adaptation can be distributed only when `adapt=shareable`, with attribution; it never inherits the original's official endorsement or credit, because requirement transitions are same-root only.

### D.5 Runtime execution boundary

Schema records what an experience needs; it does not run it. `static` renders inline; `sandboxed_web` runs only in an isolated origin (sandboxed iframe without same-origin, CSP from declared hosts, bridge limited to the component's interaction contract); `notebook`/`container_service` require a platform or explicitly trusted runner (RV17/RV23–24 own sessions and receipts); `external_hosted` is shown as external with availability. Every interactive class carries an accessible fallback.

## E. API additions

`api.course_command` operations: `open_distribution`, `close_distribution`, `grant_reader`, `revoke_reader`, `offer_release`, `end_offer`, `adapt_release`, `set_update_policy`, `record_transition` (requirement transitions + review in one command). `grant_publisher`/`revoke_publisher` are server-configuration operations, never ordinary client commands. `freeze_release` gains `ceiling` and explicit disposition decisions; `create_work`/`revise_work` accept the new kinds, runtime requirements and alignments.

`api.course_read` operations: `preview_exposure`, `list_library` (public library and official catalog listings derived from current offers' root revisions), `get_offer`, `get_released_revision`, `get_released_asset`, `runtime_impact` (revisions/releases/offers depending on an ecosystem/name/version), `competency_usage` (outcomes and courses aligned to a competency revision), `transition_preview` (for a learner: which requirements carry, which need reassessment). Same error rules as R1: stale head conflict, validation error, indistinguishable not-found.

## F. Keeping current

| Subject | Trigger / change identity | Affected | What the user sees |
| --- | --- | --- | --- |
| Source rights/access in a released closure | `asset_scope` revocation, source rights change, capture withdrawal; distinct from fetch failure | `release_item` → offers → distributions | Maintainer: "exposed in N offers; withhold/replace/revoke"; readers: denied item with reason |
| Runtime pins (frameworks, packages, models, provider APIs) | Manual refresh against registry/provider data (and `corpus.library_release` where present); identity `(workspace, ecosystem/name, old resolved_version, new version, change_kind)` with change_kind new_release/deprecation/end_of_life/security_advisory | `runtime_requirement` → revisions → releases/offers | "What changed / why it matters / proposed revision"; never an automatic pin bump |
| Competency definitions | New competency revision | `outcome_alignment` → outcomes → courses | Proposed realignment; existing alignment stays pinned |
| Course releases | New offer in a distribution | Enrollments on that distribution | Diff + `transition_preview`; standing-consent auto-adoption only for compatible transitions |
| Official approval | Any new release | Official offer | Requires a fresh `official_publication` review |

Unchanged/duplicate checks produce no event (R1 dedupe identity). Scheduling and notification delivery remain with existing orchestration; R2 starts no watch or message.

## G. Scope boundaries and staged residuals

Complete in this design: invited/public creator distribution, official catalog route, withdrawal (retire/revoke), exposure-safe sharing, adaptation permissions, renderer catalog, runtime profiles/pins and execution classes, versioned competencies and alignment, evidence-rule bindings, generated-task eligibility route, requirement-level carry-forward and opt-in auto-adoption.

Staged elsewhere, with the seam named here:

- **Commerce** (listings, prices, orders, entitlements, seller payouts): commerce packet; seam = reserved `entitlement` grant basis and `use-terms` update semantics.
- **Anonymous public web access and cross-tenant hosted library**: release-surface/hosted packet; R2 public = authenticated principals of the tenant.
- **Youth/parent access, moderation, retention/deletion windows**: RV20; public library must not be offered to youth accounts before RV20 lands.
- **Applying credit to real evidence, prior-work/test-out acceptance, appeals**: RV17. **Individualized routes, competency transfer edges, mastery**: RV16.
- **Runner sessions, live E2E viewer, execution receipts**: RV17/RV23–RV25.
- **Selective promotion of private work into another workspace other than adaptation; general projects, conversations, search, wiki connectors**: RV18/RV19.

## H. Migration plan effect

Fold into R1's unexecuted three-file plan rather than adding a fourth: `…010000_course_authoring_foundation.sql` carries all twenty-five relations and new artifact type code `experience_bundle`; `…010100_course_curriculum_cutover.sql` is unchanged except that converted legacy curricula get revisions only (no distributions or enrollments are fabricated); `…010200_course_api_security.sql` adds the operations in E and the distribution-aware access helper. Generated types, `src/course.ts` contracts and workspace enrichment follow R1's plan. Package version target remains 0.7.0.
