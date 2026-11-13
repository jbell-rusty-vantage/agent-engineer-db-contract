"""P15: create_agent and invalid_tool_calls (langchain issues f68ed948, 173bbf5c).
A (173bbf5c): the model->tools routing ends the loop when tool_calls is empty, even if invalid_tool_calls are present.
B (f68ed948): from 1.4.3, create_agent adds an error ToolMessage for each invalid tool call on the next model request."""
import warnings
from _fake import *
warnings.simplefilter("ignore")

BAD = [{"name": "get_invoice_status", "args": "{\"invoice_id\": ", "id": "bad1", "error": "malformed JSON", "type": "invalid_tool_call"}]


def ai(tool_calls, invalid):
    from langchain_core.messages import AIMessage
    return AIMessage(content="", tool_calls=tool_calls, invalid_tool_calls=invalid)


def arm_only_invalid():
    from langchain.agents import create_agent
    RECORD.clear()
    agent = create_agent(model=fake_model([ai([], BAD), final("unused")]), tools=[invoice_tool()])
    out = agent.invoke({"messages": [("user", "status of INV-1?")]}, config={"recursion_limit": 8})
    return {"model_calls": len(RECORD), "messages": [m.type for m in out["messages"]], "tool_messages": [str(m.content)[:160] for m in out["messages"] if m.type == "tool"]}


def arm_valid_and_invalid():
    from langchain.agents import create_agent
    RECORD.clear()
    good = [{"name": "get_invoice_status", "args": {"invoice_id": "INV-1"}, "id": "ok1", "type": "tool_call"}]
    agent = create_agent(model=fake_model([ai(good, BAD), final("INV-1 is paid.")]), tools=[invoice_tool()])
    out = agent.invoke({"messages": [("user", "status of INV-1?")]}, config={"recursion_limit": 8})
    second = RECORD[1] if len(RECORD) > 1 else []
    return {"model_calls": len(RECORD), "second_request_types": [m["type"] for m in second], "second_request_tool_contents": [m["content"][:200] for m in second if m["type"] == "tool"],
            "tool_messages": [str(m.content)[:160] for m in out["messages"] if m.type == "tool"]}


a, ea = attempt(arm_only_invalid)
b, eb = attempt(arm_valid_and_invalid)
tool_contents = (b or {}).get("second_request_tool_contents") or []
error_msgs = [t for t in tool_contents if "bad1" in t]  # an error ToolMessage names the invalid call's id
emit("P15", {"only_invalid": a, "only_invalid_error": ea, "valid_and_invalid": b, "valid_and_invalid_error": eb},
     {"ran": a is not None and b is not None, "loop_ends_with_only_invalid": bool(a) and a["model_calls"] == 1 and not a["tool_messages"],
      "next_request_tool_messages": len(tool_contents), "next_request_carries_error_toolmessage": len(tool_contents) >= 2 and bool(error_msgs)})
