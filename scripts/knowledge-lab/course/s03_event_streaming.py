"""Lesson 3: event streaming (LangChain 1.3+): typed projections instead of branching on stream_mode chunks."""
import json

from langchain.agents import create_agent
from langchain_core.callbacks import get_usage_metadata_callback
from langchain_core.utils.uuid import uuid7
from langgraph.checkpoint.memory import InMemorySaver

from scout import MODEL, TOOLS

agent = create_agent(model=MODEL, tools=TOOLS, checkpointer=InMemorySaver(),
                     system_prompt="You are Release Scout. Use tools; answer in two sentences.")
config = {"configurable": {"thread_id": str(uuid7())}}
with get_usage_metadata_callback() as usage:
    stream = agent.stream_events({"messages": [{"role": "user", "content": "Is it true that create_agent renamed prompt? Check the verified facts."}]},
                                 config=config, version="v3")
    tokens = 0
    for kind, item in stream.interleave("messages", "tool_calls"):
        if kind == "messages":
            for token in item.text:
                tokens += 1
                print(token, end="", flush=True)
        elif kind == "tool_calls":
            print(f"\n>> tool call: {item.tool_name}({item.input})")
            for _delta in item.output_deltas:       # drain the tool's output stream first
                pass
            print(f">> tool result: {str(item.output)[:300]}")
    final_state = stream.output
print(f"\nstreamed text chunks: {tokens}; messages in final state: {len(final_state['messages'])}")
print("USAGE", json.dumps(usage.usage_metadata))
