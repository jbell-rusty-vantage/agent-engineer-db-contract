"""Lesson 9: orchestration with Send: fan out one worker per library in the same super-step, then reduce."""
import json
import operator
import time
from typing import Annotated, TypedDict

from langchain.chat_models import init_chat_model
from langchain_core.callbacks import get_usage_metadata_callback
from langgraph.graph import END, START, StateGraph
from langgraph.types import Send

from scout import MODEL, release_lines

model = init_chat_model(MODEL)


class Overall(TypedDict):
    libraries: list[str]
    profiles: Annotated[list[str], operator.add]    # each parallel worker appends one profile
    report: str


class Job(TypedDict):
    library: str


def fan_out(state: Overall):
    return [Send("profile", {"library": lib}) for lib in state["libraries"]]      # one task per library, run in parallel


def profile(job: Job) -> dict:
    t0 = time.perf_counter()
    lines = release_lines.invoke({"library": job["library"]})
    text = model.invoke(f"In one sentence, describe the release cadence of {job['library']} from these dates: {lines}").text
    return {"profiles": [f"{job['library']} ({time.perf_counter() - t0:.1f}s): {text}"]}


def reduce(state: Overall) -> dict:
    report = model.invoke("Compare these three libraries' release cadence in two sentences:\n" + "\n".join(state["profiles"])).text
    return {"report": report}


g = StateGraph(Overall)
g.add_node("profile", profile)
g.add_node("reduce", reduce)
g.add_conditional_edges(START, fan_out, ["profile"])
g.add_edge("profile", "reduce")
g.add_edge("reduce", END)
graph = g.compile()
print(graph.get_graph().draw_mermaid())
with get_usage_metadata_callback() as usage:
    t0 = time.perf_counter()
    out = graph.invoke({"libraries": ["langchain", "langgraph", "deepagents"], "profiles": []})
    wall = time.perf_counter() - t0
for p in out["profiles"]:
    print("-", p)
print("report:", out["report"])
print(f"wall time {wall:.1f}s (the three profiles ran in one super-step)")
print("USAGE", json.dumps(usage.usage_metadata))
