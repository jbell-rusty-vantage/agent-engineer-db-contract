"""Build 08 loops 5 and 6: assemble the two promoted migrations from the lab drafts (their union, in order, one transaction each).
  20261113150000_build08_ks_admission_verified_claims.sql          <- drafts 20261113150000, 20261113150100, 20261113160100 (loop 6, F)
  20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql <- drafts 20261113160000, 20261113160200, 20261113160300 (loop 5, H)
The loop-6 fixup 20261113160100 was applied in the lab after the loop-5 draft; it touches only loop-6 objects (the native-write function,
the intent type), so it is folded into the loop-6 migration; the fresh install compares the schema with the lab.
Run: python -I -X utf8 scripts/knowledge-lab/loop56_promote.py
"""
import os, re

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
SETS = {
    "20261113150000_build08_ks_admission_verified_claims.sql": (["20261113150000_build08_loop6_ks_admission.sql", "20261113150100_build08_loop6_fixup_require_admitted_use.sql", "20261113160100_build08_loop6_fixup_bind_payload.sql"],
        """-- Build 08 knowledge loop 6 (candidate F): Knowledge Services admission of probe verdicts, the first verified claims. D-55 kept: verified
-- only under a receipt bound to an admitted knowledge_verification exact-use decision, admitted in the same transaction. D-72: an admitted
-- receipt may target an existing claim (action verified) so the claim keeps its identity; D-73: the exact-use checker R2 dropped is restored;
-- D-74: the native write binds the exact payload text to the decision's bound effect; D-75: the claim_verification intent type.
-- Promoted 2026-11-13 from the lab drafts 20261113150000, 20261113150100, 20261113160100 (kept in supabase/drafts/). Lab-proven on
-- disposable-aieng-build04; cycle record: Build 08 §25 in the AI Engineer review workspace.
begin;
"""),
    "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql": (["20261113160000_build08_loop5_followups.sql", "20261113160200_build08_loop5_fixup_revalidation_due.sql", "20261113160300_build08_loop5_fixup_latest_cell.sql"],
        """-- Build 08 knowledge loop 5 (candidate H): D-61 self-checked claims leave the score; D-69 no watch suggestion below 5 checked claims;
-- D-62 verdict-aware ranking as a reported evidence channel; released passages become T1; probe revalidation on release (D-76) and
-- releases that need review; the triage of claim candidates. Promoted 2026-11-13 from the lab drafts 20261113160000, 20261113160200,
-- 20261113160300 (kept in supabase/drafts/). Lab-proven on disposable-aieng-build04; cycle record: Build 08 §24.
begin;
"""),
}


def body(text):
    text = re.sub(r"^\s*begin;\s*$", "", text, count=1, flags=re.M)
    idx = text.rstrip().rfind("commit;")
    return text[:idx].rstrip() + "\n" if idx >= 0 else text



for name, (drafts, head) in SETS.items():
    parts = [head]
    for d in drafts:
        parts.append(f"\n-- ---- from draft {d}\n")
        parts.append(body(open(os.path.join(ROOT, "supabase", "drafts", d), encoding="utf-8").read()))
    parts.append("\ncommit;\n")
    out = os.path.join(ROOT, "supabase", "migrations", name)
    open(out, "w", encoding="utf-8", newline="\n").write("".join(parts))
    print(out, sum(1 for _ in open(out, encoding="utf-8")), "lines")
