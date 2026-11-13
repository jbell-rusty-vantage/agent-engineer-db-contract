"""Lesson 13: evaluate, change the harness, evaluate again. In lessons 6 and 12 the model answered "how many releases"
by counting minor version lines. Hypothesis: the tool descriptions, not the model, cause it. A tiny eval set with
answers taken from the knowledge base measures the failure before and after rewriting two docstrings."""
import json

from langchain.agents import create_agent
from langchain.tools import tool
from langchain_core.callbacks import get_usage_metadata_callback

import scout
from scout import MODEL, verified_facts

CASES = [  # question, the substring a correct answer must contain (from the captured PyPI data)
    ("How many releases has deepagents shipped?", "150"),
    ("How many releases has langchain published in total?", "528"),
    ("How many langgraph releases are there?", "286"),
    ("What is the newest langchain-core version?", "1.8.0"),
]


@tool
def latest_release(library: str) -> str:
    """Return the newest release of a library, its date, AND the total number of releases ever published.
    Use this for 'how many releases' questions. library: langchain, langchain-core, langgraph, deepagents, langgraph-sdk, langgraph-cli."""
    return scout.latest_release.func(library)


@tool
def release_lines(library: str) -> str:
    """Return when each minor version LINE (0.1, 0.2, 1.0 ...) first shipped. This is not a count of releases:
    each line contains many patch releases."""
    return scout.release_lines.func(library)


VARIANTS = {"baseline docstrings": scout.TOOLS, "rewritten docstrings": [latest_release, release_lines, verified_facts]}
REPEATS = 2
results = {}
with get_usage_metadata_callback() as usage:
    for name, tools in VARIANTS.items():
        agent = create_agent(model=MODEL, tools=tools, system_prompt="You are Release Scout. Use your tools. Answer with the number or version.")
        passed = []
        for question, expected in CASES:
            for _ in range(REPEATS):
                answer = agent.invoke({"messages": [{"role": "user", "content": question}]})["messages"][-1].text
                passed.append((question, expected in answer, answer.replace("\n", " ")[:120]))
        results[name] = passed
        print(f"{name}: {sum(p[1] for p in passed)}/{len(passed)} correct")
        for q, ok, a in passed:
            print(f"   {'PASS' if ok else 'FAIL'}  {q}  ->  {a}")
print("USAGE", json.dumps(usage.usage_metadata))
