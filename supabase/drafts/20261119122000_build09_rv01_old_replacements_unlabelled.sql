-- Build 09, unit RV01 (acceptance answer RV01-8 B): a replacement made before reasons existed keeps no guessed label.
-- 20261119120000 called every old replacement that starts later than the fact it replaces a world_change. We do not know
-- that the world changed for those rows; some read as a second parse of the same page. Their label is cleared: they read
-- as "replaced, kind not recorded". Rows written from 2026-11-20 on, by the rule of temporal.assert_state, are not touched.
alter table temporal.segment disable trigger guard_k;
alter table temporal.segment disable trigger sealed_batch;
update temporal.segment s set revision_kind = null
  from temporal.knowledge_batch kb
 where kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from and kb.recorded_at < '2026-11-20T00:00:00Z'
   and s.revision_kind = 'world_change';
alter table temporal.segment enable trigger guard_k;
alter table temporal.segment enable trigger sealed_batch;
comment on column temporal.segment.revision_kind is 'How this fact relates to the one it replaces: world_change (the world changed), correction (our belief was wrong; needs correction_reason) or carried (the unchanged part of an older fact, cut again). Empty for a first fact, and for a replacement made before 2026-11-20 whose kind was never recorded.';
