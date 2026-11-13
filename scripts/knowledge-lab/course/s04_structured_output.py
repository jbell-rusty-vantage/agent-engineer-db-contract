"""Lesson 4: structured output. The agent's final answer is a validated Pydantic object, not prose."""
import json

from pydantic import BaseModel, Field
from langchain.agents import create_agent
from langchain_core.callbacks import get_usage_metadata_callback

from scout import MODEL, TOOLS


class Change(BaseModel):
    change: str = Field(description="what to change, in a few words")
    before: str = Field(description="the old code or name")
    after: str = Field(description="the new code or name")
    evidence: str = Field(description="the verified fact or tool output this rests on")


class MigrationPlan(BaseModel):
    summary: str
    changes: list[Change]


agent = create_agent(model=MODEL, tools=TOOLS, response_format=MigrationPlan,
                     system_prompt="You are Release Scout. Build migration plans only from verified facts (use the verified_facts tool).")
with get_usage_metadata_callback() as usage:
    result = agent.invoke({"messages": [{"role": "user", "content": "Give me a migration plan from langgraph.prebuilt.create_react_agent to langchain's create_agent. Check facts about prompt, deprecat and classic."}]})
plan: MigrationPlan = result["structured_response"]
print(type(plan).__name__, "with", len(plan.changes), "changes")
print(plan.model_dump_json(indent=1))
print("USAGE", json.dumps(usage.usage_metadata))
