-- pgcrypto lives in the extensions schema on Supabase. The claim
-- function search_path was research_private, public, so digest()
-- resolved as digest(text, unknown) and the claim failed.

alter function research_private.claim_pre_research_video(integer, text, text, text, text)
  set search_path = research_private, public, extensions;
