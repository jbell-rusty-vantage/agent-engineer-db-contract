import type { Database } from "./database.generated.js";

export type ResearchReport = Database["research"]["Tables"]["report"]["Row"];
export type ResearchReportVersion = Database["research"]["Tables"]["report_version"]["Row"];
export type ResearchReportPackage = Database["research"]["Tables"]["report_package"]["Row"];
export type ResearchReportSection = Database["research"]["Tables"]["report_section_version"]["Row"];
export type ResearchReportAssertion = Database["research"]["Tables"]["report_assertion"]["Row"];
export type ResearchReportClaimBinding = Database["research"]["Tables"]["report_assertion_claim"]["Row"];
export type ResearchReportArtifact = Database["research"]["Tables"]["report_artifact"]["Row"];
export type ResearchReportQuestion = Database["research"]["Tables"]["report_question"]["Row"];
// v1 seals, assessments and ingestion links were withdrawn (20261025010000); seals and assessments are owned by the
// knowledge_verification component, and v2 revisions are projected through these rows.
export type ResearchReportV2Revision = Database["research"]["Tables"]["report_v2_revision"]["Row"];
export type ResearchReportV2Assertion = Database["research"]["Tables"]["report_v2_assertion"]["Row"];
export type ResearchReportV2Ingestion = Database["research"]["Tables"]["report_v2_ingestion"]["Row"];

// Native ledger provenance (20261031010000): one row per native row a receipt created, reused, superseded or staged,
// and the intent -> receipt -> target view for intents that carry Mission Control coordinates.
export type OperationReceiptTarget = Database["orchestration"]["Tables"]["operation_receipt_target"]["Row"];
export type MissionRunEffect = Database["orchestration"]["Views"]["mission_run_effects"]["Row"];
