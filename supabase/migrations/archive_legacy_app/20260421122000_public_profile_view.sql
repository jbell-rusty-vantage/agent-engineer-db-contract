-- U0.7 — public_profile view (whitelisted columns, security_invoker).
--
-- Resolves Q11. The /u/[username] page reads from this view, never from
-- public.profiles directly. Whitelist matches Q11 exactly: XP + tags + bio
-- + a handful of identity fields. Notes / saves / attempts / completions
-- are deliberately *not* exposed even when is_public = true.

create or replace view public.public_profile
with (security_invoker = true) as
  select id,
         username,
         display_name,
         headline,
         bio,
         avatar_url,
         expertise_tags,
         interest_tags,
         xp_total,
         current_role_title,
         country,
         is_public
  from public.profiles
  where is_public = true;

comment on view public.public_profile is
  'Public read surface for opted-in profiles (Q11). Whitelisted columns only; never join to user-private tables here.';

grant select on public.public_profile to anon, authenticated;
