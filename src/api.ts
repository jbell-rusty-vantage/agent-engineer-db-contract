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
