"""P10: a CompiledSubAgent with a custom StateGraph: does the parent receive the subagent's answer as a ToolMessage, and does a deterministic parent stop?
(deepagents #2184, closed not planned: the loop depends on how a real model reads that ToolMessage; a fake model cannot show it)"""
import warnings
from _fake import *
warnings.simplefilter("ignore")


def run():
    from deepagents import create_deep_agent, CompiledSubAgent
    from langgraph.graph import StateGraph, MessagesState, END
    from langchain_core.messages import AIMessage
    sb = StateGraph(MessagesState)
    sb.add_node("expert", lambda s: {"messages": [AIMessage(content="The current user count is exactly 1200.")]})
    sb.set_entry_point("expert")
    sb.add_edge("expert", END)
    sub = CompiledSubAgent(name="data-specialist", description="Checks user counts.", runnable=sb.compile())
    model = fake_model([tool_call("task", {"description": "check the current total user count", "subagent_type": "data-specialist"}, "t1"), final("There are 1200 users.")])
    parent = create_deep_agent(model=model, subagents=[sub])
    out = parent.invoke({"messages": [("user", "Use the data-specialist to check the user count.")]}, config={"recursion_limit": 12})
    tm = [m for m in out["messages"] if m.type == "tool"]
    return {"tool_messages": [str(m.content)[:200] for m in tm], "final": out["messages"][-1].content, "model_calls": len(RECORD),
            "parent_saw_tool_result": any("1200" in str(m["content"]) for call in RECORD[1:] for m in call if m["type"] == "tool")}


out, err = attempt(run)
emit("P10", {"result": out, "error": err},
     {"ran": out is not None, "answer_arrives_as_tool_message": bool(out) and any("1200" in t for t in out["tool_messages"]),
      "deterministic_parent_stops": bool(out) and out["final"] == "There are 1200 users.", "recursion_error": (err or {}).get("type") == "GraphRecursionError"})
