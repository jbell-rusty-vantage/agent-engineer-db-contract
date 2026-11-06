begin;
-- Table grants alone do not make RLS-readable accounting usable; retain the
-- bounded table permissions while allowing the intended runtime roles to resolve
-- the orchestration schema.
grant usage on schema orchestration to executor_service,verifier_agent,control_plane,app_reader;
commit;
