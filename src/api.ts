import type { Database } from "./database.generated.js";

type ApiView<N extends keyof Database["api"]["Views"]> = Database["api"]["Views"][N]["Row"];
type ApiFunctionRows<N extends keyof Database["api"]["Functions"]> = Database["api"]["Functions"][N]["Returns"];

/** L1 catalog views (Build 08 R2): derived from entities, attributes and current facts; filter, compare and rank here. */
export type ApiModel = ApiView<"models">;
export type ApiModelOffering = ApiView<"model_offerings">;
export type ApiOrganization = ApiView<"organizations">;
export type ApiPerson = ApiView<"people">;
export type ApiSoftware = ApiView<"software">;
export type ApiSoftwareRelease = ApiView<"software_releases">;
export type ApiTalk = ApiView<"talks">;
export type ApiEvent = ApiView<"events">;
export type ApiConcept = ApiView<"concepts">;
export type ApiPaper = ApiView<"papers">;
export type ApiBenchmarkScore = ApiView<"benchmark_scores">;
export type ApiWorkAuthored = ApiView<"works_authored">;
export type ApiGuidanceItem = ApiView<"guidance_items">;
export type ApiMissionProgress = ApiView<"mission_progress">;
export type ApiReviewQueueItem = ApiView<"review_queue">;

/** L2/L3 named functions. */
export type ApiLeaderboardEntry = ApiFunctionRows<"leaderboard">[number];
export type ApiChange = ApiFunctionRows<"changes_since">[number];
export type ApiPriceHistoryRow = ApiFunctionRows<"price_history">[number];
export type ApiFactLocator = ApiFunctionRows<"fact_locators">[number];
export type ApiSearchHit = ApiFunctionRows<"search_unified">[number];
export type ApiTalkSegment = ApiFunctionRows<"talk_segments">[number];
// Build 08 loop 2 (2026-11-10): benchmarks with versions and conditioned scores, compute devices/offerings, repository symbols,
// API endpoints, advisories, registry listings, protocol versions.
export type ApiBenchmark = ApiView<"benchmarks">;
export type ApiComputeDevice = ApiView<"compute_devices">;
export type ApiComputeOffering = ApiView<"compute_offerings">;
export type ApiSymbol = ApiView<"api_symbols">;
export type ApiEndpoint = ApiView<"endpoints">;
export type ApiAdvisory = ApiView<"advisories">;
export type ApiRegistryListing = ApiView<"registry_listings">;
export type ApiProtocolVersion = ApiView<"protocol_versions">;
export type ApiLeaderboardDiffRow = ApiFunctionRows<"leaderboard_diff">[number];
export type ApiCheapestComputeRow = ApiFunctionRows<"cheapest_compute">[number];
export type ApiSymbolChange = ApiFunctionRows<"symbol_changes">[number];
export type ApiAdvisoryForRow = ApiFunctionRows<"advisories_for">[number];
// Build 08 loop 3 (2026-11-11): symbol history and docs links, digest items as retrieval targets with passages and video deep
// links, talks by entity at two levels, release digests, unverified claim candidates with their library surfaces, capabilities
// (MCP tools/prompts/resources, bundle file manifests, hook entries) with custody levels.
export type ApiSymbolDoc = ApiView<"symbol_docs">;
export type ApiDigestItem = ApiView<"digest_items">;
export type ApiClaimSurface = ApiView<"claim_surfaces">;
export type ApiMcpTool = ApiView<"mcp_tools">;
export type ApiMcpPrompt = ApiView<"mcp_prompts">;
export type ApiMcpResource = ApiView<"mcp_resources">;
export type ApiBundleFile = ApiView<"bundle_files">;
export type ApiHookEntry = ApiView<"hook_entries">;
export type ApiCapability = ApiView<"capabilities">;
export type ApiSymbolHistoryRow = ApiFunctionRows<"symbol_history">[number];
export type ApiDigestItemPassage = ApiFunctionRows<"digest_item_passages">[number];
export type ApiTalkAbout = ApiFunctionRows<"talks_about">[number];
export type ApiReleaseDigestItem = ApiFunctionRows<"release_digest">[number];
export type ApiUnitEntity = ApiFunctionRows<"unit_entities">[number];
// Build 08 loop 4 (2026-11-13): source intelligence (registry with per-topic assessments and track records, community claims),
// attention allocation (policies with their last sweep, the due-list a Mission Control watch mission calls), experiments (probes,
// per-cell matrix, claim verdicts), design interview outputs and the library dossier (jsonb).
export type ApiSourceRegistryRow = ApiView<"source_registry">;
export type ApiSourceTrackRecord = ApiView<"source_track_record">;
export type ApiCommunityClaim = ApiView<"community_claims">;
export type ApiClaimVerdict = ApiView<"claim_verdicts">;
export type ApiProbe = ApiView<"probes">;
export type ApiAttentionPolicy = ApiView<"attention_policies">;
export type ApiProbeMatrixRow = ApiFunctionRows<"probe_matrix">[number];
export type ApiAttentionDueRow = ApiFunctionRows<"attention_due">[number];
export type ApiInterviewOutput = ApiFunctionRows<"interview_outputs">[number];
// Build 08 loop 6 (2026-11-13): claims verified through a Knowledge Services admission (decision, admission-bound receipt, payload, verdicts).
export type ApiVerifiedClaim = ApiView<"verified_claims">;
// Build 08 loop 7 (2026-11-15, D-80): restated claims and the attribution-framed originals they were atomized from; search_unified gains p_collapse (D-77).
export type ApiClaimRestatement = ApiView<"claim_restatements">;
// Build 08 loop 5 (2026-11-13): claim triage, probe revalidation on release, releases whose bound claims' verdicts changed.
// api.search_unified gains p_evidence_weight (default 0.15) and reports channel_scores.evidence; api.source_registry gains self_checked.
export type ApiClaimTriage = ApiView<"claim_triage">;
export type ApiProbeRevalidationDueRow = ApiFunctionRows<"probe_revalidation_due">[number];
export type ApiReleaseNeedingReview = ApiFunctionRows<"releases_needing_review">[number];
// Build 08 D-82 (2026-11-15): the search a signed-in session calls, api.search_knowledge (corpus and evidence lenses, no workspace
// parameter; the same row shape as search_unified). api.search_unified takes the private scope from its caller and is not
// executable by anon or authenticated. A signed-in PostgREST session now resolves the deployment tenant, so the tenant-filtered
// views and functions above answer it. api.product_scope(scope) is the client-grant check of api.product_read on its own, for
// a service that composes such a read and received a client token.
export type ApiKnowledgeSearchHit = ApiFunctionRows<"search_knowledge">[number];
// Build 08 AIDB-2 (2026-11-16, contract 0.8.0): the governed writes of the research verification chain. Nine api functions, each
// callable by named bounded roles only (never anon, a signed-in user or app_reader), each taking a caller-supplied
// p_idempotency_key first and an optional p_actor last, each returning one JSON object. The tenant comes from the session
// (app.tenant_id), never from an argument. A failure raises with the stable code as the message and its class as the SQLSTATE.
type ApiFunctionArgs<N extends keyof Database["api"]["Functions"]> = Database["api"]["Functions"][N]["Args"];
export type ApiRecordClaimArgs = ApiFunctionArgs<"record_claim">;
export type ApiRestateClaimArgs = ApiFunctionArgs<"restate_claim">;
export type ApiRegisterProbeArgs = ApiFunctionArgs<"register_probe">;
export type ApiRecordProbeRunArgs = ApiFunctionArgs<"record_probe_run">;
export type ApiProposeVerdictArgs = ApiFunctionArgs<"propose_verdict">;
export type ApiRecordTriageArgs = ApiFunctionArgs<"record_triage">;
export type ApiRecordSourceAssessmentArgs = ApiFunctionArgs<"record_source_assessment">;
export type ApiRaiseAttentionSweepArgs = ApiFunctionArgs<"raise_attention_sweep">;
export type ApiSettleAttentionSweepArgs = ApiFunctionArgs<"settle_attention_sweep">;
/** p_actor: who acted. The session role is recorded by the database; a label never names a person. */
export interface ApiGovernedActor {
  label?: string;
  /** orchestration.mission id of the AI Engineer mission whose budget bounds the work (required with `mc` for sweeps and probe runs). */
  mission_id?: string;
  /** The Mission Control invocation that caused the write; all fields but activation_id are required together. */
  mc?: { mission_id: string; run_id: string; operation_id: string; operation_attempt: number; execution_generation: number; lane: string; activation_id?: string };
  /** sha256:<64 hex>; computed from the actor when absent. */
  origin_digest?: string;
}
export type ApiEvidenceLinkRole = "supports" | "contradicts" | "qualifies" | "context";
/** One evidence anchor: an existing locator, or a quote that is verbatim in a content unit of a capture. */
export type ApiEvidenceAnchor =
  | { locator_id: string; role?: ApiEvidenceLinkRole }
  | { capture_id: string; node_id: string; quote: string; selector_kind?: "text_quote"; role?: ApiEvidenceLinkRole }
  | { capture_id: string; node_id: string; pointer: string; selector_kind: "json_pointer"; quote?: string; role?: ApiEvidenceLinkRole };
/** Returned by every governed write: the ledger rows it left, and whether this call replayed an earlier one with the same key. */
export interface ApiGovernedWriteReceipt { intent_id: string; receipt_id: string; replayed: boolean }
export interface ApiRecordClaimResult extends ApiGovernedWriteReceipt {
  claim_id: string; created: boolean; reused: boolean; status: "proposed" | "verified" | "disputed" | "retracted" | "superseded"; locator_ids: string[]; subjects?: number; attributions?: number;
}
export interface ApiRestateClaimResult extends ApiGovernedWriteReceipt {
  claim_id: string; original_claim_id: string; created: boolean; reused: boolean; status: string; probe?: string;
  copied?: { subjects: number; attributions: number; evidence_links: number };
}
export interface ApiRegisterProbeResult extends ApiGovernedWriteReceipt { probe_id: string; slug: string; state: "active"; claims: number }
export interface ApiRecordProbeRunResult extends ApiGovernedWriteReceipt {
  probe_run_id: string; probe_id: string; probe: string; cell_label: string; outcome: "pass" | "fail" | "error" | "skipped";
  output_capture_id?: string; output_locator_id?: string; origin_kind: "standalone" | "mission"; over_budget: boolean;
}
export interface ApiProposeVerdictResult extends ApiGovernedWriteReceipt {
  verdict_id: string; written: boolean; unchanged: boolean; verdict: Database["evidence"]["Enums"]["support_verdict"];
  /** agent_proposed for every row this function writes; an unchanged result reports the state of the current row. */
  review_state: "agent_proposed" | "human_confirmed" | "human_rejected"; supersedes_id?: string;
  claim_status: string; claim_status_changed: boolean; evidence_locator_id?: string; needs_review: boolean; restatements_to_review: string[];
}
export interface ApiRecordTriageResult extends ApiGovernedWriteReceipt {
  triage_id: string; written: boolean; unchanged: boolean; disposition: string; review_state: "agent_proposed"; supersedes_id?: string;
}
export interface ApiRecordSourceAssessmentResult extends ApiGovernedWriteReceipt {
  assessment_id: string; method: "prior" | "derived"; written: boolean; unchanged: boolean; authority_score?: number;
  claims_observed?: number; claims_checked?: number; self_checked?: number; recommended_watch_level?: "W0" | "W1" | "W2" | "W3"; supersedes_id?: string;
}
export interface ApiRaiseAttentionSweepResult extends ApiGovernedWriteReceipt {
  sweep_id: string; policy_id: string; policy: string; origin_kind: "standalone" | "mission";
  /** false with budget_stopped true: the mission's budget is spent, the sweep is already settled, do no work. */
  open: boolean; budget_stopped: boolean; mission_spent_usd?: number; mission_budget_usd?: number; budget_usd_per_run: number; budget_credits_per_run: number;
}
export interface ApiSettleAttentionSweepResult extends ApiGovernedWriteReceipt {
  sweep_id: string; policy: string; outcome: "completed" | "partial" | "failed" | "budget_stopped"; settled: true;
  over_budget_usd: boolean; over_budget_credits: boolean; mission_spent_usd?: number; mission_budget_usd?: number; mission_budget_exhausted?: boolean;
}
/** The message of a refused governed write. SQLSTATE: 42501 not allowed, 22023 malformed argument, P0002 not found in the tenant, 23514 state refuses, 23505 taken. */
export type ApiGovernedWriteErrorCode =
  | "TENANT_CONTEXT_REQUIRED" | "HUMAN_REVIEW_NOT_AGENT_WRITABLE"
  | "IDEMPOTENCY_KEY_REQUIRED" | "ACTOR_INVALID" | "MISSION_REQUIRED" | "STATEMENT_REQUIRED" | "CLAIM_TYPE_UNKNOWN" | "STRUCTURED_INVALID" | "STRUCTURED_RESERVED"
  | "EVIDENCE_REQUIRED" | "EVIDENCE_INVALID" | "EVIDENCE_SELECTOR_UNSUPPORTED" | "QUOTE_REQUIRED" | "SUBJECT_INVALID" | "ATTRIBUTION_INVALID" | "RESTATEMENT_UNCHANGED" | "POLARITY_INVALID"
  | "PROBE_SLUG_INVALID" | "PROBE_INVALID" | "PROBE_KIND_INVALID" | "PROBE_MODEL_POLICY_INVALID" | "PROBE_MODEL_POLICY_MISMATCH" | "PROBE_BUDGET_INVALID" | "PROBE_CLAIMS_REQUIRED"
  | "PROBE_RUN_INVALID" | "PROBE_RUN_OUTPUT_REQUIRED" | "VERDICT_INVALID" | "VERDICT_REQUIRES_RUNS" | "RATIONALE_REQUIRED" | "TRIAGE_INVALID" | "TRIAGE_DUPLICATE_INVALID" | "TRIAGE_PROBE_INVALID"
  | "ASSESSMENT_METHOD_INVALID" | "ASSESSMENT_SUBJECT_INVALID" | "ASSESSMENT_ROLE_UNKNOWN" | "ASSESSMENT_INVALID" | "SWEEP_INVALID" | "SWEEP_COUNTS_INVALID"
  | "MISSION_NOT_FOUND" | "EVIDENCE_NOT_FOUND" | "EVIDENCE_UNIT_NOT_IN_CAPTURE" | "SUBJECT_NOT_FOUND" | "ATTRIBUTION_ENTITY_NOT_FOUND" | "ATTRIBUTION_SOURCE_NOT_FOUND" | "CLAIM_NOT_FOUND"
  | "PROBE_NOT_FOUND" | "SWEEP_NOT_FOUND" | "ASSESSMENT_SUBJECT_NOT_FOUND" | "ASSESSMENT_TOPIC_NOT_FOUND" | "ATTENTION_POLICY_NOT_FOUND"
  | "MISSION_ENDED" | "QUOTE_NOT_IN_UNIT" | "CLAIM_NOT_RESTATABLE" | "CLAIM_NOT_TRIAGEABLE" | "CLAIM_NOT_PROBED" | "PROBE_NOT_ACTIVE" | "PROBE_RUN_SPEND_NOT_ALLOWED"
  | "VERDICT_CELL_NOT_RUN" | "VERDICT_REJECTED_BY_PERSON" | "TRIAGE_REVIEWED_BY_PERSON" | "ASSESSMENT_BASE_REQUIRED" | "ASSESSMENT_REVIEWED_BY_PERSON"
  | "ATTENTION_POLICY_NOT_SWEEPABLE" | "SWEEP_NOT_OPEN" | "SWEEP_ALREADY_SETTLED" | "SWEEP_MISSION_MISMATCH"
  | "IDEMPOTENCY_KEY_REUSED" | "IDEMPOTENCY_KEY_FOREIGN_TENANT" | "RESTATEMENT_EXISTS" | "PROBE_SLUG_TAKEN" | "PROBE_RUN_DUPLICATE";

// Build 09, unit RV01 (2026-11-19, contract 0.11.0): why a fact changed, merges and splits of records, proposals.
// api.changes_since gains revision_kind, correction_reason, cause_event_id and cause_event_kind, lists edges opened and closed
// (change_source "relationship", scope_key carries the relationship kind) and merges and splits (change_source "identity"), and
// no longer lists the cut pieces of a replaced fact. api.current_facts gains revision_kind and correction_reason.
/** How a fact relates to the one it replaces. Empty for a first fact and for a replacement made before 2026-11-20. */
export type ApiRevisionKind = "world_change" | "correction" | "carried";
/** temporal.correction_reason: why our earlier belief was wrong. not_recorded is set by backfill only. */
export type ApiCorrectionReason =
  | "source_corrected" | "misread" | "better_source" | "late_evidence" | "wrong_entity" | "duplicate_record" | "mixed_record" | "merge_undone" | "not_recorded";
export type ApiEntityHistoryItem = ApiFunctionRows<"entity_history">[number];
/** Our own view, never a fact. The service's reader roles receive published proposals only. */
export type ApiProposal = ApiFunctionRows<"proposals">[number];
export type ApiProposalKind = "relationship" | "cause" | "identity";
export type ApiProposalReviewState = "agent_proposed" | "person_proposed" | "endorsed" | "rejected" | "withdrawn" | "confirmed_by_source" | "refuted_by_source";
/** api.change_explanation: the cause event, what a source said the reason was, and (only when asked) our proposals. */
export interface ApiChangeExplanation {
  target: "fact" | "event" | "relationship";
  revision_kind?: ApiRevisionKind | null; correction_reason?: ApiCorrectionReason | null; correction_reason_means?: string | null;
  closed_kind?: "world_change" | "correction" | null; closed_reason?: ApiCorrectionReason | null; ended_in_world_at?: string | null;
  cause_event: { event_id: string; kind: string; subject: string | null; object: string | null; occurred_from: string | null; payload: unknown } | null;
  stated_reasons: { claim_id: string; statement: string; status: string; quote: string | null; stated_by: string[] | null; source_url: string | null }[];
  proposals?: { proposal_id: string; ours: true; statement: string; rationale: string; confidence: "low" | "medium" | "high"; authored_by_kind: "person" | "agent"; authored_by: string;
    review_state: ApiProposalReviewState; publication: "private" | "published"; basis: unknown }[];
}
/** api.propose (governed write; pipeline_agent and executor_service). An agent role always writes agent_proposed and private. */
export interface ApiProposeResult extends ApiGovernedWriteReceipt { proposal_id: string; review_state: "agent_proposed" | "person_proposed"; publication: "private"; }
