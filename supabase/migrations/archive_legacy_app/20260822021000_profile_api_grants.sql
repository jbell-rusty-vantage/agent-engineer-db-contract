-- The hosted project predates the checked-in local baseline and already had
-- API grants. A clean `supabase db reset` needs the same narrow privileges;
-- RLS remains the authorization boundary for the underlying tables.

grant select, insert, update on public.profiles to authenticated;
grant select on public.current_user_stats to authenticated;
grant select on public.public_profile to anon, authenticated;
grant select, update on public.notification to authenticated;
