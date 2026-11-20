"""Build 08 knowledge loop 5: run the six new probes (P14-P19) in the loop-4 date cells (no lab write; loop5_process.py registers
the runs). Same environments and runner as loop 4 (loop4_probes.py): one subprocess per cell venv with a clean environment, no secrets.
Run: python -I -X utf8 scripts/knowledge-lab/loop5_probes.py [P14 ...]
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
import loop4_probes as R

R.OUT = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-5", "probe-runs")
os.makedirs(R.OUT, exist_ok=True)
D0, D1, D2, D3 = "D0-2025-10-16", "D1-2025-10-18", "D2-2026-04-23", "D3-latest"
R.PLAN = {
    "P14": ("p14_checkpoint_ns.py", [D1, D2, D3]),
    "P15": ("p15_invalid_tool_calls.py", [D2, D3]),
    "P16": ("p16_command_parent.py", [D2, D3]),
    "P17": ("p17_mustache_escaping.py", [D0, D2, D3]),
    "P18": ("p18_example_selector.py", [D0, D2, D3]),
    "P19": ("p19_subagent_context.py", [D2, D3]),
}

# revalidation cell (loop 5): the latest environment rebuilt after deepagents 0.7.38 (2026-11-13T14:32Z) made P10 and P19 due
D4 = "D4-latest-2026-11-13T15"
R.CELLS[D4] = {"exclude_newer": None, "packages": list(R.CELLS[D3]["packages"]), "optional": []}
REVALIDATE = {"P10": ("p10_compiled_subagent.py", [D4]), "P19": ("p19_subagent_context.py", [D4])}

if __name__ == "__main__":
    if sys.argv[1:2] == ["revalidate"]:
        R.build_envs()
        R.PLAN = {k: v for k, v in REVALIDATE.items() if not sys.argv[2:] or k in sys.argv[2:]}
        R.run([])
    else:
        R.run(sys.argv[1:])
