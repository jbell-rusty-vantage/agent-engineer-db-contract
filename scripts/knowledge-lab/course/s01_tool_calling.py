"""Lesson 1: the model chooses a function and its arguments; your code runs it. The whole idea of an agent in 25 lines."""
import json

from langchain.chat_models import init_chat_model
from langchain.messages import HumanMessage
from langchain_core.callbacks import get_usage_metadata_callback

from scout import MODEL, latest_release

model = init_chat_model(MODEL)
llm = model.bind_tools([latest_release])            # advertise the tool's JSON schema to the model

with get_usage_metadata_callback() as usage:
    messages = [HumanMessage("What is the newest LangGraph release, and when did it ship?")]
    ai = llm.invoke(messages)                       # 1. the model decides: call latest_release(library="langgraph")
    print("model asked for:", json.dumps(ai.tool_calls, indent=1))
    messages.append(ai)
    for call in ai.tool_calls:                      # 2. your code executes the call
        tool_message = latest_release.invoke(call)  # a ToolCall in, a ToolMessage out
        print("tool returned:", tool_message.content)
        messages.append(tool_message)
    final = llm.invoke(messages)                    # 3. the model reads the result and answers
    print("answer:", final.text)
print("USAGE", json.dumps(usage.usage_metadata))
