"""Lesson 6: the same agent written in the LangGraph Graph API: state with reducers, nodes, a conditional edge, a loop."""
import json
import operator
from typing import Annotated

from typing_extensions import TypedDict
from langchain.chat_models import init_chat_model
from langchain_core.callbacks import get_usage_metadata_callback
from langgraph.graph import END, START, StateGraph
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition

from scout import MODEL, TOOLS


class State(TypedDict):
    messages: Annotated[list, add_messages]         # reducer: append (and merge by id), never overwrite
    model_calls: Annotated[int, operator.add]       # reducer: sum the partial updates


llm = init_chat_model(MODEL).bind_tools(TOOLS)


def call_model(state: State) -> dict:
    return {"messages": [llm.invoke(state["messages"])], "model_calls": 1}   # a node returns a partial update


def build():
    g = StateGraph(State)
    g.add_node("model", call_model)
    g.add_node("tools", ToolNode(TOOLS))
    g.add_edge(START, "model")
    g.add_conditional_edges("model", tools_condition, {"tools": "tools", END: END})   # tool calls? go to tools, else stop
    g.add_edge("tools", "model")                                                     # the loop
    return g


if __name__ == "__main__":
    graph = build().compile()
    print(graph.get_graph().draw_mermaid())
    with get_usage_metadata_callback() as usage:
        steps = 0
        for chunk in graph.stream({"messages": [("user", "Compare how many releases langchain and langgraph have shipped.")], "model_calls": 0},
                                  stream_mode="updates"):
            steps += 1
            for node, update in chunk.items():
                last = update["messages"][-1]
                print(f"super-step {steps}: [{node}]", [c["name"] for c in getattr(last, "tool_calls", [])] or str(last.content)[:300])
        state = graph.invoke({"messages": [("user", "In one sentence: newest deepagents release?")], "model_calls": 0})
    print("model_calls reducer total on the second run:", state["model_calls"])
    print("USAGE", json.dumps(usage.usage_metadata))
