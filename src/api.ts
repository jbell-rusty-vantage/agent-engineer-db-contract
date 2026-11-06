import type { Database } from "./database.generated.js";

export type ApiLeaderboardEntry =
  Database["api"]["Functions"]["leaderboard"]["Returns"][number];
export type ApiLibraryProfile =
  Database["api"]["Views"]["library_profile"]["Row"];
export type ApiMissionProgress =
  Database["api"]["Views"]["mission_progress"]["Row"];
export type ApiReviewQueueItem =
  Database["api"]["Views"]["review_queue"]["Row"];
export type ApiTechnicalRecordSearchResult =
  Database["api"]["Views"]["technical_record_search"]["Row"];
