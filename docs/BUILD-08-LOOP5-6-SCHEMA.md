# Build 08 loops 5 and 6: verified claims through Knowledge Services, verdict-aware ranking, assessment rules, revalidation on release, triage

**Status: lab-proven on `disposable-aieng-build04` (2026-11-13) and promoted as two migrations.**

- [`20261113150000_build08_ks_admission_verified_claims.sql`](../supabase/migrations/20261113150000_build08_ks_admission_verified_claims.sql) is loop 6 (candidate F). It assembles drafts `20261113150000`, `..150100` and `..160100`.
- [`20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`](../supabase/migrations/20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql) is loop 5 (candidate H). It assembles drafts `20261113160000`, `..160200` and `..160300`.

**Fresh install.** On `disposable-aieng-b08replay`, from an empty database through `scripts/install-ai-engineer.mjs`: component, 197 domain migrations, head `20261113160000`. Its `pg_dump --schema-only` is identical to the lab's apart from the restrict token.

**Populated upgrade.** The lab's pre-review checkpoint (head `20261113120400`) was restored over a fresh install. The two migrations then applied cleanly, and the Knowledge Services harness verified the same 13 claims there under the final function.

**Not integrated or qualified.** Nothing here is integrated into `ai-engineer-service` or Mission Control, and nothing is applied to remote `aieng-db`. Cycle record: Build 08 §24 (loop 5) and §25 (loop 6) in the AI Engineer review workspace.

## A. Loop 6: Knowledge Services admission (D-55 kept)

| Change | What |
| --- | --- |
| D-72 gate | `evidence.enforce_verified_claim_gate`: `verified` needs an admitted creating receipt (unchanged), **or** a receipt that targets the claim with action `verified` (`orchestration.operation_receipt_target.action` gains `verified`) and whose use was admitted in the same transaction. The claim keeps its id, subjects, attributions, verdicts and bindings. `retrieval.history_claim_authorized` follows both bindings |
| D-73 | `verification.require_admitted_use`, which R2 dropped with the `research` schema, is restored; `verification.guard_use_admission` calls it. Before this, every admission since R2 failed with `schema "research" does not exist` |
| Native write | `verification.record_admitted_claim_verification(claim, use_decision_id, bound_effect_digest, processed_epoch, normalized_values_digest, origin_digest, effect_text, executor)` (EXECUTE: `executor_service`, `verifier_agent`, `control_plane`). In the caller's transaction it does three things. **D-74:** the payload text must hash to the semantic payload digest the component recorded for the decision's bound effect. The payload must name this claim and the sha256 of its statement. It then asserts the admitted use, writes the `claim_verification` intent (**D-75**), the admission-bound receipt and the receipt target, and sets status `verified` |
| Reader | `api.verified_claims`: claim, use decision, receipt, bound payload and current probe verdicts |

Who issues the decision: only the `knowledge_verification` component, from a sealed run. The harness is `platform/knowledge-services/scripts/experiments/build08-probe-admission/run.ts`: `ResearchCoordinator` over `PostgresResearchBinding`, deterministic and human support observations, a lab seal key. Its exact-use admission (`admitExactUseWithin`) now calls `verification.assert_admitted_use` and falls back to the `research.` form only where that form is installed.

## B. Loop 5: rules, ranking, revalidation, triage

| Change | What |
| --- | --- |
| D-61 | `evidence.source_assessment.self_checked`. `evidence.claim_is_self_stated(claim)` is true when `structured.source_role = own_experiment` or the claim is attributed to an entity whose prior role is `own_experiment`. `derive_source_assessment` keeps self-checked claims out of the score |
| D-69 | `recommended_watch_level` is null below 5 independently checked claims, and the rationale says so; `api.source_registry` gains `self_checked` |
| D-62 | `retrieval.evidence_signal(claim, document, unit_kind)`: +1 supported or verified, +0.5 qualified, −1 contradicted or disputed. `api.search_unified(..., p_evidence_weight double precision default 0.15)` multiplies by `1 + weight × signal` and reports `channel_scores.evidence` (signal, verdict, status, weight, factor). Weight 0 gives the loop-4 formula |
| T1 on release | `retrieval.promote_revision_passages(revision)` and `retrieval.promote_release_passages(release)`, plus trigger `release_item_promote_passages`. Because `retrieval.vector_item` is immutable, each active passage item gets a tier-1 successor that copies the projection and embedding, and the draft item is superseded |
| Revalidation (D-76) | `api.probe_revalidation_due(as_of)`: the newest catalogued release of a subject library differs from the version the probe's most recent unpinned run resolved, and is newer than it. A rebuilt latest cell replaces the old one |
| Review | `api.releases_needing_review()`: releases whose bound claims have a verdict, decided after the release, that differs from the one current when it was frozen |
| Triage | table `verification.claim_triage` (disposition, checkability, priority components, duplicate, probe, rationale, review state; append-only) and view `api.claim_triage` |
| D-64 (pipeline) | [`loop5_process.py releases`](../scripts/knowledge-lab/loop5_process.py) captures PyPI JSON and records the missing core releases (55), each with a `release_published` event that cites the capture and its JSON pointer. It also moves the 8 monorepo `sdk==`/`cli==` tags to new `langgraph-sdk` / `langgraph-cli` libraries |

## C. Consumers

[`src/api.ts`](../src/api.ts) gains `ApiVerifiedClaim`, `ApiClaimTriage`, `ApiProbeRevalidationDueRow` and `ApiReleaseNeedingReview`. [`src/database.generated.ts`](../src/database.generated.ts) is regenerated, and the workspace is rebuilt; validation reports 0 errors and 130 examples executed. `product.dispatch_read` calls `api.search_unified` positionally with 15 arguments and gets the default weight.

## D. Scripts

Loop 5:
- [`loop5_process.py`](../scripts/knowledge-lab/loop5_process.py): assess, releases, triage, probes, revalidate
- [`loop5_probes.py`](../scripts/knowledge-lab/loop5_probes.py): P14–P19, and `revalidate` for the rebuilt D4 cell
- [`loop5_questions.py`](../scripts/knowledge-lab/loop5_questions.py): Q1–Q9 and the loop-6 checks
- probes `p14`–`p19` in [`probes/`](../scripts/knowledge-lab/probes/)

Loop 6: [`loop6_admission.py`](../scripts/knowledge-lab/loop6_admission.py), the evidence pack and readback.

Owner review: [`loop4_review.py`](../scripts/knowledge-lab/loop4_review.py) records the human-confirmed verdicts, the release review and freeze, and the digest marks. Promotion: [`loop56_promote.py`](../scripts/knowledge-lab/loop56_promote.py).
