-- PostgreSQL requires newly added enum values to be committed before they are
-- referenced by indexes, constraints, or functions. Keep these additions in
-- their own migration immediately before the v2 schema migration.

alter type public.research_pre_research_run_status
  add value if not exists 'research_complete';
alter type public.research_pre_research_run_status
  add value if not exists 'synthesizing';
