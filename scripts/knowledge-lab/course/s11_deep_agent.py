"""Lesson 11: Deep Agents. create_deep_agent is create_agent plus a harness: a to-do planner, a virtual filesystem,
subagents for context isolation, and summarization. Watch it plan, delegate and write a file."""
import json

from deepagents import create_deep_agent
from langchain_core.callbacks import get_usage_metadata_callback

from scout import MODEL, TOOLS, verified_facts

agent = create_deep_agent(
    model=MODEL,
    tools=TOOLS,
    system_prompt="You are Release Scout, a careful research agent. Plan with write_todos, delegate fact-checking to the "
                  "fact-checker subagent, and save your final brief to /brief.md.",
    subagents=[{"name": "fact-checker", "description": "Checks migration claims against verified facts.",
                "system_prompt": "Use verified_facts and report exactly what is verified.", "tools": [verified_facts]}],
)
with get_usage_metadata_callback() as usage:
    out = agent.invoke({"messages": [{"role": "user", "content": "Write a short brief for a team upgrading from langgraph 0.6 to 1.x: release dates, and the verified facts about create_react_agent and prompt."}]},
                       config={"recursion_limit": 60})
tools_used = [m.name for m in out["messages"] if m.type == "tool"]
print("tools the harness used:", tools_used)
print("todos:", json.dumps(out.get("todos"), indent=1))
files = out.get("files") or {}
print("files written:", list(files))
brief = files.get("/brief.md")
if brief:
    content = brief.get("content") if isinstance(brief, dict) else brief
    print("---- /brief.md ----\n" + ("\n".join(content) if isinstance(content, list) else str(content))[:1800])
print("USAGE", json.dumps(usage.usage_metadata))
