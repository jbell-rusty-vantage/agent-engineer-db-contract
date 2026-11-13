"""Build 08 loop 4: assemble the promoted migration from the lab drafts 20261113120000..20261113120400 (their union, in order, one transaction).
Run: python -I -X utf8 scripts/knowledge-lab/loop4_promote.py
"""
import os, re

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
DRAFTS = ["20261113120000_build08_loop4_source_intelligence_experiments.sql", "20261113120100_build08_loop4_fixup_attention_due.sql", "20261113120200_build08_loop4_fixup_assessment.sql",
          "20261113120300_build08_loop4_fixup_registry_view.sql", "20261113120400_build08_loop4_fixup_community_claims.sql"]
OUT = os.path.join(ROOT, "supabase", "migrations", "20261113120000_build08_loop4_source_intelligence_experiments.sql")
HEAD = """-- Build 08 knowledge loop 4 (source intelligence: a registry of channels and handle-level actors with per-topic assessments derived from
-- probe verdicts; attention allocation: policies, sweeps and the due-list a Mission Control watch mission calls; experiments: probes,
-- runs captured as evidence, verdicts; design interviews as product conversations; the library dossier; candidate B: D-47, D-50,
-- one producer in the digests space, benchmark_run removed), promoted 2026-11-13 from the lab drafts 20261113120000..20261113120400
-- (the five draft files stay in supabase/drafts/ as the sources). Lab-proven on disposable-aieng-build04; cycle record: Build 08 §22
-- in the AI Engineer review workspace.
begin;
"""


def body(text):
    text = re.sub(r"^\s*begin;\s*$", "", text, count=1, flags=re.M)
    idx = text.rstrip().rfind("commit;")
    return text[:idx].rstrip() + "\n" if idx >= 0 else text


parts = [HEAD]
for d in DRAFTS:
    parts.append(f"\n-- ---- from draft {d}\n")
    parts.append(body(open(os.path.join(ROOT, "supabase", "drafts", d), encoding="utf-8").read()))
parts.append("\ncommit;\n")
open(OUT, "w", encoding="utf-8", newline="\n").write("".join(parts))
print(OUT, sum(1 for _ in open(OUT, encoding="utf-8")), "lines")
