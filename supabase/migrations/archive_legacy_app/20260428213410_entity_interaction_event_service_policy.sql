-- Add an explicit service-role policy for the internal recommendation outbox.
-- Clients still have no direct access to entity_interaction_event rows.

drop policy if exists "entity_interaction_event_service_all" on public.entity_interaction_event;
create policy "entity_interaction_event_service_all"
on public.entity_interaction_event
for all
to service_role
using (true)
with check (true);

comment on policy "entity_interaction_event_service_all" on public.entity_interaction_event is
  'Allows trusted service-role processors to manage the internal recommendation interaction outbox.';
