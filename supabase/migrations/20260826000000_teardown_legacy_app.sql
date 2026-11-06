-- 0000 | Teardown of the legacy aiengineerapp schema.
--
-- Drops 67 legacy tables, 2 views, 20 functions, 25 triggers and 60 RLS policies.
-- Leaves untouched: the 24 pre-research pipeline tables (live, running now), the
-- 16 factory_* tables, all 17 research_* enums, all 17 research_private functions,
-- and the three public functions those subsystems depend on.
--
-- Verified against the live catalog on 2026-08-25: this list is exactly the set of
-- public tables that are neither research_* (excluding research_lab_run) nor factory_*.

begin;

-- 1. Non-table dependencies must go first.
--    handle_new_user() writes to profiles; the storage policy reads learning_asset.
drop trigger if exists on_auth_user_created on auth.users;

drop policy if exists learning_assets_select_authenticated on storage.objects;
drop policy if exists avatars_select_public on storage.objects;
drop policy if exists avatars_insert_own    on storage.objects;
drop policy if exists avatars_update_own    on storage.objects;
drop policy if exists avatars_delete_own    on storage.objects;

-- 2. Release the two factory -> app foreign keys.
--    Both columns are 100% NULL (0 of 8 and 0 of 7 rows), so nothing is lost.
--    The columns themselves stay, unconstrained, pending a decision on the factory.
alter table public.factory_episode drop constraint if exists factory_episode_attempt_id_fkey;
alter table public.factory_task    drop constraint if exists factory_task_challenge_id_fkey;

-- 3. Views.
drop view if exists public.current_user_stats;
drop view if exists public.public_profile;

-- 4. The 67 legacy tables, in one statement so declaration order does not matter.
--    CASCADE reaches only objects owned by these tables: their own indexes,
--    triggers, RLS policies, and the app-side FKs into factory_* / research_*.
--    No research or factory table is reachable from this set.
drop table if exists
  public.attempt,
  public.challenge,
  public.challenge_competency,
  public.challenge_evidence,
  public.challenge_version,
  public.chunk,
  public.course,
  public.course_enrollment,
  public.course_module,
  public.course_module_completion,
  public.course_module_in_course,
  public.course_module_requires,
  public.course_module_review,
  public.curriculum_competency,
  public.curriculum_competency_edge,
  public.dataset_split_membership,
  public.entity_interaction_event,
  public.eval_case_version,
  public.event,
  public.graph_outbox,
  public.human_gate_decision,
  public.human_gate_request,
  public.image,
  public.image_attachment,
  public.knowledge_claim,
  public.knowledge_claim_evidence,
  public.learner_submission,
  public.learning_asset,
  public.learning_objective,
  public.library,
  public.library_appeared_in_session,
  public.library_appeared_in_video,
  public.library_uses_library,
  public.module_completion,
  public.module_uses_artifact,
  public.news_item,
  public.notes,
  public.notification,
  public.organization,
  public.organization_has_ceo,
  public.organization_sponsored_event,
  public.paper,
  public.paper_appeared_in_video,
  public.paper_authored_by,
  public.person,
  public.person_appeared_in_video,
  public.person_attended_event,
  public.person_employed_by,
  public.person_founded_organization,
  public.person_presented_at_session,
  public.product,
  public.product_appeared_in_video,
  public.product_journey_result,
  public.product_journey_spec,
  public.profile_followed_entity,
  public.profiles,
  public.repo,
  public.repo_for_library,
  public.report,
  public.research_lab_run,
  public.saved_items,
  public.score_event,
  public.session,
  public.session_recorded_as_video,
  public.user_entity_recommendation,
  public.youtube_channel,
  public.youtube_video
cascade;

-- 5. The 20 legacy functions, by exact identity signature.
--    NEVER drop set_updated_at (3 live pre-research triggers),
--    reject_immutable_row_change, or protect_factory_episode_identity_and_terminal.
drop function if exists public.award_xp_event(p_user_id uuid, p_kind text, p_ref_kind text, p_ref_id uuid, p_points integer, p_metadata jsonb, p_source_attempt uuid);
drop function if exists public.backfill_person_primary_org();
drop function if exists public.current_streak_days(p_user_id uuid);
drop function if exists public.explore_libraries(q text, layers text[], categories text[], tags text[], sort text, limit_count integer, offset_count integer);
drop function if exists public.explore_organizations(q text, layers text[], categories text[], tags text[], sort text, limit_count integer, offset_count integer);
drop function if exists public.explore_papers(q text, layers text[], categories text[], tags text[], sort text, limit_count integer, offset_count integer);
drop function if exists public.explore_people(q text, layers text[], categories text[], tags text[], sort text, limit_count integer, offset_count integer, role_buckets text[], org_ids text[]);
drop function if exists public.explore_people_facets(q text, tags text[], role_buckets text[], org_ids text[], facet_limit integer);
drop function if exists public.explore_sessions(q text, layers text[], categories text[], tags text[], sort text, limit_count integer, offset_count integer);
drop function if exists public.explore_youtube_videos(q text, layers text[], categories text[], tags text[], sort text, limit_count integer, offset_count integer);
drop function if exists public.handle_new_user();
drop function if exists public.immutable_array_to_string(arr text[], delim text);
drop function if exists public.maintain_course_latest();
drop function if exists public.maintain_course_module_latest();
drop function if exists public.match_chunks(query_embedding vector, query_text text, filter jsonb, source_kinds text[], match_count integer, full_text_weight double precision, semantic_weight double precision, rrf_k integer);
drop function if exists public.prevent_published_challenge_version_mutation();
drop function if exists public.reject_published_learning_asset_mutation();
drop function if exists public.replace_user_entity_recommendations(p_user_id uuid, p_rows jsonb);
drop function if exists public.search_all(q text, limit_count integer, kinds text[]);
drop function if exists public.search_fuzzy(prefix text, kinds text[], limit_count integer);

commit;
