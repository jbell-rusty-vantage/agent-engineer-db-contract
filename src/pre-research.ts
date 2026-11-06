import type { Database } from "./database.generated.js";

export type PublicTableName = keyof Database["public"]["Tables"];
export type PublicTableRow<Table extends PublicTableName> =
  Database["public"]["Tables"][Table]["Row"];
export type PublicTableInsert<Table extends PublicTableName> =
  Database["public"]["Tables"][Table]["Insert"];
export type PublicTableUpdate<Table extends PublicTableName> =
  Database["public"]["Tables"][Table]["Update"];

export type PreResearchArtifact =
  PublicTableRow<"research_pre_research_artifact">;
export type PreResearchRun = PublicTableRow<"research_pre_research_run">;
export type PreResearchStageExecution =
  PublicTableRow<"research_pre_research_stage_execution">;
export type PreResearchVideoState =
  PublicTableRow<"research_pre_research_video_state">;
export type ResearchApplicationDomain =
  PublicTableRow<"research_application_domain">;
export type ResearchCategoryDefinition =
  PublicTableRow<"research_category_definition">;
export type ResearchEntityCandidate =
  PublicTableRow<"research_entity_candidate">;
export type ResearchEvidenceAnchor =
  PublicTableRow<"research_evidence_anchor">;
export type ResearchIngestionIntent =
  PublicTableRow<"research_ingestion_intent">;
export type ResearchOrganizationCandidate =
  PublicTableRow<"research_organization_candidate">;
export type ResearchResourceCandidate =
  PublicTableRow<"research_resource_candidate">;
export type ResearchStarterChannel =
  PublicTableRow<"research_starter_channels">;
export type ResearchStarterVideo =
  PublicTableRow<"research_starter_videos">;
export type ResearchVideoAnalysis =
  PublicTableRow<"research_video_analysis">;
