"""P8: create_agent + response_format + checkpointer returns turn N's structured_response on turn N+1 (langchain #36957; the reporter's fake-model reproduction, re-run as published)"""
import warnings
from _fake import *
warnings.simplefilter("ignore")
from pydantic import BaseModel, field_validator


class Answer(BaseModel):
    text: str

    @field_validator("text")
    @classmethod
    def not_bad(cls, v):
        if v == "BAD":
            raise ValueError("bad sentinel")
        return v


def run():
    from langchain.agents import create_agent
    from langchain.agents.structured_output import ToolStrategy
    from langgraph.checkpoint.memory import InMemorySaver
    m = fake_model([tool_call("Answer", {"text": "Hi"}, "1"), tool_call("Answer", {"text": "BAD"}, "2"), tool_call("Answer", {"text": "Bye"}, "3")])
    agent = create_agent(model=m, tools=[], response_format=ToolStrategy(schema=Answer, handle_errors=True), checkpointer=InMemorySaver())
    t = {"configurable": {"thread_id": "t"}}
    r1 = agent.invoke({"messages": [("user", "say hi")]}, config=t)
    n1 = len(RECORD)
    r2 = agent.invoke({"messages": [("user", "say bye")]}, config=t)
    return {"turn1": r1["structured_response"].text, "turn2": r2["structured_response"].text, "model_calls_turn1": n1, "model_calls_turn2": len(RECORD) - n1}


out, err = attempt(run)
emit("P8", {"result": out, "error": err}, {"ran": out is not None, "stale_turn2": (out or {}).get("turn2") == "Hi", "fresh_turn2": (out or {}).get("turn2") == "Bye"})
