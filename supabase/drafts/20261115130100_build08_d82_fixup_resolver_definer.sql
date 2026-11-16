-- Build 08 D-82 fixup (lab): the resolver names util.default_tenant_id(), and authenticated has no USAGE on schema util. Read through
-- a view (not through a definer function) a signed-in session failed with "permission denied for schema util" on a fresh connection;
-- a connection that had first resolved inside a definer function kept the cached plan and worked, which hid it. The resolver reads
-- only session settings, so it runs as its owner; authenticated gains no privilege on the schema.
begin;
alter function util.current_tenant_id() security definer;
commit;
