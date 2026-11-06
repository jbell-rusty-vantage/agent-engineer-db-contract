-- 0014b | Wire two FKs missed in 0002, and document the ones left soft on purpose.
--
-- orchestration.capability_profile is created later in 0002 than mission and
-- work_item, so both capability_profile_id columns were created bare and never
-- constrained. That was an oversight, not a decision. Caught by scanning for
-- uuid columns named *_id with no FK.

begin;

alter table orchestration.mission
  add constraint mission_capability_profile_fk
  foreign key (capability_profile_id) references orchestration.capability_profile(id);

alter table orchestration.work_item
  add constraint work_item_capability_profile_fk
  foreign key (capability_profile_id) references orchestration.capability_profile(id);

-- ---------------------------------------------------------------------------
-- The observability event tables keep SOFT references on purpose. Recording the
-- reasoning so the same scan does not read these as the same kind of oversight.
--
--   normalized_event.raw_event_id -> raw_event
--     raw_event is partitioned and its primary key is composite (id, occurred_at).
--     A single-column FK cannot target it, and widening the column pair purely to
--     satisfy a constraint would bloat the hottest table in the system.
--
--   normalized_event.mission_id -> orchestration.mission
--     These are append-only, high-volume projections of a telemetry stream.
--     Enforcing referential integrity on every event insert costs a lookup per
--     row on the one table guaranteed to grow without bound, and it would couple
--     mission deletion to telemetry retention. Telemetry referencing a mission
--     that was later purged is acceptable; slowing every event insert is not.
--
--   span.trace_id / normalized_event.trace_id -> observability.trace
--     Same reasoning. Spans routinely arrive before their trace row is written,
--     so an FK here would reject valid out-of-order telemetry.
-- ---------------------------------------------------------------------------
comment on column observability.normalized_event.raw_event_id is
  'Soft reference. raw_event is partitioned with a composite PK, so a single-column FK cannot target it.';

comment on column observability.normalized_event.mission_id is
  'Soft reference by design: append-only high-volume telemetry, decoupled from mission lifecycle.';

comment on column observability.span.trace_id is
  'Soft reference by design: spans can arrive before their trace row exists.';

commit;
