begin;

create index if not exists work_item_event_attempt_idx
  on orchestration.work_item_event (attempt_id) where attempt_id is not null;
create index if not exists metric_observation_locator_idx
  on ranking.metric_observation (locator_id) where locator_id is not null;
create index if not exists metric_observation_run_idx
  on ranking.metric_observation (run_id) where run_id is not null;

commit;
