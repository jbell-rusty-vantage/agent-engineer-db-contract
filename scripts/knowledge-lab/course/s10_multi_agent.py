"""Lesson 10: multi-agent with subagents as tools. A supervisor delegates to a historian and a fact-checker; each
subagent has its own prompt, tools and context window, and returns only its final answer."""
import json

from langchain.agents import create_agent
from langchain.tools import tool
from langchain_core.callbacks import get_usage_metadata_callback

from scout import MODEL, latest_release, release_lines, verified_facts

historian = create_agent(model=MODEL, tools=[latest_release, release_lines], name="historian",
                         system_prompt="You answer questions about when versions shipped. Be brief and cite dates.")
checker = create_agent(model=MODEL, tools=[verified_facts], name="fact_checker",
                       system_prompt="You answer only from verified facts. If none match, say so.")


@tool
def ask_historian(question: str) -> str:
    """Ask the release historian a question about versions and dates."""
    return historian.invoke({"messages": [{"role": "user", "content": question}]})["messages"][-1].text


@tool
def ask_fact_checker(question: str) -> str:
    """Ask the fact-checker what is verified about a migration topic."""
    return checker.invoke({"messages": [{"role": "user", "content": question}]})["messages"][-1].text


supervisor = create_agent(model=MODEL, tools=[ask_historian, ask_fact_checker], name="supervisor",
                          system_prompt="You coordinate two specialists. Delegate, then combine their answers in three sentences.")
with get_usage_metadata_callback() as usage:
    for chunk in supervisor.stream({"messages": [{"role": "user", "content": "A student on langgraph 0.6 wants to move to 1.x. When did 1.0 ship, and what is verified about the create_react_agent deprecation?"}]},
                                   stream_mode="updates"):
        for node, update in chunk.items():
            last = update["messages"][-1]
            calls = [c["name"] for c in getattr(last, "tool_calls", [])]
            print(f"[supervisor/{node}]", calls or str(last.content)[:500])
print("USAGE", json.dumps(usage.usage_metadata))
