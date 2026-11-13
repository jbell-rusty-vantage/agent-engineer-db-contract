"""P16: two tools in one model turn each return Command(graph=Command.PARENT, ...) from create_agent used as a subgraph node
(langgraph issues 937ef76c, 54a6442e; closed 2026-09). Does the parent apply both updates?"""
import operator, warnings
from typing import Annotated
from _fake import *
warnings.simplefilter("ignore")


def run():
    from langchain.agents import create_agent
    from langchain_core.messages import AIMessage
    from langchain_core.tools import tool
    from langgraph.graph import StateGraph, MessagesState, END
    from langgraph.types import Command

    @tool
    def mark_a() -> Command:
        """Mark A in the parent."""
        return Command(graph=Command.PARENT, update={"hits": ["a"]})

    @tool
    def mark_b() -> Command:
        """Mark B in the parent."""
        return Command(graph=Command.PARENT, update={"hits": ["b"]})

    class Parent(MessagesState):
        hits: Annotated[list, operator.add]

    two = AIMessage(content="", tool_calls=[{"name": "mark_a", "args": {}, "id": "a1", "type": "tool_call"}, {"name": "mark_b", "args": {}, "id": "b1", "type": "tool_call"}])
    inner = create_agent(model=fake_model([two, final("done")]), tools=[mark_a, mark_b])
    g = StateGraph(Parent)
    g.add_node("worker", inner)
    g.set_entry_point("worker")
    g.add_edge("worker", END)
    out = g.compile().invoke({"messages": [("user", "mark both")], "hits": []}, config={"recursion_limit": 10})
    return {"hits": out.get("hits")}


out, err = attempt(run)
hits = (out or {}).get("hits") or []
emit("P16", {"result": out, "error": err},
     {"ran": out is not None, "hits": "|".join(sorted(hits)), "both_updates_applied": sorted(hits) == ["a", "b"], "only_one_update_applied": len(hits) == 1, "error_type": (err or {}).get("type")})
