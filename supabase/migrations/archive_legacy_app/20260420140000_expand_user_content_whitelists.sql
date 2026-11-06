-- Migration: widen user-content whitelists + backfill agent_orchestration category.
--
-- Slice F/G/H landed `course`, `course_module`, `challenge`, `attempt`, but the
-- earlier `notes` / `saved_items` / `profile_followed_entity` whitelists were
-- frozen before those tables existed. As a result the app cannot today let a
-- signed-in user save a course, take a note on a module, or follow a
-- challenge -- the row inserts violate the CHECK constraints.
--
-- Two parts:
--   1. Widen the three CHECK whitelists to add the new entity kinds.
--   2. Tiny one-row data backfill so the agent_orchestration anchor video
--      (`CEvIs9y1uog`) has its `category` + `domain_layer` + `event_id` set.
--      Previous bucketing/ingest left those NULL because we paused before
--      writing a generic backfill script.
--
-- Both pieces are idempotent; re-running this migration is a no-op.
--
-- Reference: aiwiki/docs/08-data-model.md ("Course / challenge schema decisions")
-- and aiwiki/docs/03-taxonomy.md (26-key taxonomy / 5-layer meta-stack).

-- ============================================================================
-- 1. Widen entity-kind whitelists for user content
-- ============================================================================

-- saved_items: bookmark a course / module / challenge / attempt / image too.
alter table public.saved_items drop constraint if exists saved_items_entity_type_check;
alter table public.saved_items add constraint saved_items_entity_type_check
  check (entity_type in (
    'person','organization','session','youtube_video',
    'library','product','event','paper','report','news_item','repo',
    'course','course_module','challenge','attempt','image'
  ));

-- notes: take a note on the same widened set.
alter table public.notes drop constraint if exists notes_entity_type_check;
alter table public.notes add constraint notes_entity_type_check
  check (
    entity_type is null
    or entity_type in (
      'person','organization','session','youtube_video',
      'library','product','event','paper','report','news_item','repo',
      'course','course_module','challenge','attempt','image'
    )
  );

-- profile_followed_entity: follow courses / modules / challenges. (attempt
-- is per-user state so it does NOT need to be followable.)
alter table public.profile_followed_entity
  drop constraint if exists profile_followed_entity_kind_check;
alter table public.profile_followed_entity
  add constraint profile_followed_entity_kind_check check (
    entity_kind in (
      'person','organization','session','youtube_video',
      'library','product','event','paper','report','news_item',
      'repo','category','domain_layer',
      'course','course_module','challenge'
    )
  );

comment on constraint saved_items_entity_type_check on public.saved_items is
  'Allowed entity_type values for user-saved items. Extended 2026-04-20 to include course / course_module / challenge / attempt / image now that those tables exist.';
comment on constraint notes_entity_type_check on public.notes is
  'Allowed entity_type values for user notes. Same widened set as saved_items.';
comment on constraint profile_followed_entity_kind_check on public.profile_followed_entity is
  'Allowed entity_kind values for the follow graph. course / course_module / challenge added 2026-04-20.';


-- ============================================================================
-- 2. Backfill `youtube_video` category + domain_layer + event_id for the
--    agent_orchestration anchor video (CEvIs9y1uog -- "Don't Build Agents,
--    Build Skills Instead", Barry Zhang & Mahesh Murag, AIE Code Summit 2025).
-- ============================================================================

update public.youtube_video
   set category     = coalesce(category, 'agent_orchestration'),
       domain_layer = coalesce(domain_layer, 'agents'),
       event_id     = coalesce(event_id, 'aie-code-summit-2025')
 where video_id = 'CEvIs9y1uog';
