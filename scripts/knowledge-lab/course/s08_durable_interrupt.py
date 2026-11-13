"""Lesson 8: durable execution. A graph pauses on interrupt(), its state is saved in Postgres, the process exits, and a
DIFFERENT process resumes it later with Command(resume=...). Run: python s08_durable_interrupt.py start | resume"""
import json
import os
import sys
from typing import TypedDict

from langchain.chat_models import init_chat_model
from langchain_core.callbacks import get_usage_metadata_callback
from langgraph.checkpoint.postgres import PostgresSaver
from langgraph.graph import END, START, StateGraph
from langgraph.types import Command, interrupt

from scout import MODEL, latest_release

DSN = os.environ["COURSE_PG_DSN"]
THREAD = {"configurable": {"thread_id": "lesson-8-durable-" + os.environ.get("COURSE_RUN_ID", "x")}}


class State(TypedDict, total=False):
    library: str
    draft: str
    approved: bool
    published: str


def draft_note(state: State) -> dict:
    fact = latest_release.invoke({"library": state["library"]})
    note = init_chat_model(MODEL).invoke(f"Write a one-line release note from this fact, no preamble: {fact}").text
    return {"draft": note}


def human_review(state: State) -> dict:
    decision = interrupt({"question": "Publish this note?", "draft": state["draft"]})   # pauses here, state saved
    return {"approved": decision == "yes"}


def publish(state: State) -> dict:
    return {"published": state["draft"] if state.get("approved") else "(rejected)"}


g = StateGraph(State)
for name, fn in [("draft_note", draft_note), ("human_review", human_review), ("publish", publish)]:
    g.add_node(name, fn)
g.add_edge(START, "draft_note"); g.add_edge("draft_note", "human_review"); g.add_edge("human_review", "publish"); g.add_edge("publish", END)

with PostgresSaver.from_conn_string(DSN) as saver, get_usage_metadata_callback() as usage:
    saver.setup()
    graph = g.compile(checkpointer=saver)
    if sys.argv[1] == "start":
        out = graph.invoke({"library": "deepagents"}, THREAD, durability="sync")    # write every checkpoint before moving on
        print("pid", os.getpid(), "paused at:", graph.get_state(THREAD).next, "interrupt:", json.dumps(out["__interrupt__"][0].value)[:300])
    else:
        print("pid", os.getpid(), "found paused run at:", graph.get_state(THREAD).next)
        out = graph.invoke(Command(resume="yes"), THREAD)
        print("published:", out["published"])
print("USAGE", json.dumps(usage.usage_metadata))
