"""Lesson 5: middleware. Hooks around the model and the tools, plus a human approval gate (HumanInTheLoopMiddleware)."""
import json
import time

from langchain.agents import create_agent
from langchain.agents.middleware import HumanInTheLoopMiddleware, ModelCallLimitMiddleware, before_model, wrap_tool_call
from langchain.tools import tool
from langchain_core.callbacks import get_usage_metadata_callback
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.types import Command

from scout import MODEL, TOOLS

NOTES = []


@tool
def publish_note(title: str, body: str) -> str:
    """Publish a release note to the team channel."""
    NOTES.append({"title": title, "body": body})
    return f"published {title!r}"


@before_model
def count_context(state, runtime):
    print(f"  [before_model] the model will see {len(state['messages'])} messages")


@wrap_tool_call
def time_tools(request, handler):
    t0 = time.perf_counter()
    result = handler(request)                       # run the tool (or the next middleware)
    print(f"  [wrap_tool_call] {request.tool_call['name']} took {1000 * (time.perf_counter() - t0):.1f} ms")
    return result


agent = create_agent(
    model=MODEL,
    tools=TOOLS + [publish_note],
    checkpointer=InMemorySaver(),                   # an interrupt needs somewhere to save the paused run
    middleware=[count_context, time_tools, ModelCallLimitMiddleware(run_limit=6),
                HumanInTheLoopMiddleware(interrupt_on={"publish_note": {"allowed_decisions": ["approve", "edit", "reject"]}})],
    system_prompt="You are Release Scout. Look up the newest langchain release, then publish a one-line release note about it.",
)
config = {"configurable": {"thread_id": "lesson-5"}}
with get_usage_metadata_callback() as usage:
    result = agent.invoke({"messages": [{"role": "user", "content": "Post a note about the newest langchain release."}]}, config=config, version="v2")
    for intr in result.interrupts:                  # the run is paused, saved in the checkpointer
        print("PAUSED FOR REVIEW:", json.dumps(intr.value, default=str)[:600])
    result = agent.invoke(Command(resume={"decisions": [{"type": "approve"}]}), config=config, version="v2")
print("notes published:", NOTES)
print("final:", result.value["messages"][-1].text[:300])
print("USAGE", json.dumps(usage.usage_metadata))
