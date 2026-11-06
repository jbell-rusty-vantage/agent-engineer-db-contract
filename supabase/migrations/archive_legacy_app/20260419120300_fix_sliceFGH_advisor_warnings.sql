-- Migration 15 (housekeeping): fix advisor warnings introduced by Slice F/G/H.
--
-- multiple_permissive_policies on attempt, course_enrollment, module_completion:
-- the FOR ALL `*_modify_own` policy already covers SELECT for the authenticated
-- role, so the explicit `*_select_own` policies are redundant and force two
-- permissive policies to be evaluated per query. Drop them.
--
-- Same pattern the 20260418120600_fix_advisor_warnings migration applied to
-- the M5/M6 tables (profiles select policies were collapsed for the same
-- reason).
--
-- The unused_index INFO advisories are expected for brand-new tables (no
-- queries have hit them yet) and are not addressed here; they will clear
-- naturally as the app starts using the indexes.

drop policy if exists "attempt_select_own" on public.attempt;
drop policy if exists "course_enrollment_select_own" on public.course_enrollment;
drop policy if exists "module_completion_select_own" on public.module_completion;
