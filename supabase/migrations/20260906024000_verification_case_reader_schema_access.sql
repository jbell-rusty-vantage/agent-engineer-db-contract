-- Read-only verification case/evidence access needs schema usage in addition to
-- the table SELECT grants installed with the case/evidence tables.
begin;

grant usage on schema evidence to app_reader;

commit;
