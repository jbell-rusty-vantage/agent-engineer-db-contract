"""Lesson 2: create_agent runs that loop for you. It compiles to a LangGraph graph whose nodes are 'model' and 'tools'."""
import json

from langchain.agents import create_agent
from langchain_core.callbacks import get_usage_metadata_callback

from scout import MODEL, TOOLS

agent = create_agent(
    model=MODEL,
    tools=TOOLS,
    system_prompt="You are Release Scout. Answer questions about LangChain, LangGraph and Deep Agents releases "
                  "using only your tools, and say which tool each fact came from.",
)
print("graph nodes:", list(agent.get_graph().nodes))
print(agent.get_graph().draw_mermaid())

question = "When did LangGraph first reach 1.0, and how long after that did the 1.1 line ship?"
with get_usage_metadata_callback() as usage:
    for chunk in agent.stream({"messages": [{"role": "user", "content": question}]}, stream_mode="updates"):
        for node, update in chunk.items():          # one event per step, keyed by the node that ran
            last = update["messages"][-1]
            if getattr(last, "tool_calls", None):
                print(f"[{node}] calls", [(c["name"], c["args"]) for c in last.tool_calls])
            else:
                print(f"[{node}]", (last.text if hasattr(last, "text") else str(last.content))[:400])
print("USAGE", json.dumps(usage.usage_metadata))
