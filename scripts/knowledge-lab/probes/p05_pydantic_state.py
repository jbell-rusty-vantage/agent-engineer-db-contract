"""P5: Pydantic state schemas: accepted by the prebuilt, rejected by create_agent? ("no more pydantic state", LangGraph v1 migration guide)
Beyond build and invoke: is the Pydantic model enforced (an invalid field value raises a validation error), is a custom field carried into the
result, and what type does the result have?"""
import warnings
from typing import Annotated
from _fake import *
warnings.simplefilter("ignore")
from pydantic import BaseModel
from langgraph.graph.message import add_messages


class PydState(BaseModel):
    messages: Annotated[list, add_messages]
    remaining_steps: int = 25
    customer_tier: str = "gold"


def exercise(factory):
    ag, e = attempt(lambda: factory(fake_model([final("ok"), final("ok")]), [invoice_tool()], state_schema=PydState))
    if not ag:
        return {"build_error": e}
    out, e2 = attempt(lambda: ag.invoke({"messages": [("user", "hi")], "customer_tier": "platinum"}))
    bad, e3 = attempt(lambda: ag.invoke({"messages": [("user", "hi")], "customer_tier": {"not": "a string"}}))
    return {"build_error": None, "run_error": e2, "result_type": type(out).__name__ if out is not None else None,
            "custom_field_in_result": (out.get("customer_tier") if isinstance(out, dict) else getattr(out, "customer_tier", None)) if out is not None else None,
            "invalid_value_error": e3, "invalid_value_accepted": e3 is None}


obs, checks = {}, {}
cra, _ = attempt(lambda: __import__("langgraph.prebuilt", fromlist=["create_react_agent"]).create_react_agent)
if cra:
    obs["prebuilt"] = exercise(cra)
    checks["prebuilt_accepts_pydantic"] = obs["prebuilt"].get("build_error") is None and obs["prebuilt"].get("run_error") is None
    checks["prebuilt_validates"] = obs["prebuilt"].get("invalid_value_accepted") is False
ca, _ = attempt(lambda: __import__("langchain.agents", fromlist=["create_agent"]).create_agent)
if ca:
    obs["create_agent"] = exercise(ca)
    checks["create_agent_accepts_pydantic"] = obs["create_agent"].get("build_error") is None and obs["create_agent"].get("run_error") is None
    checks["create_agent_validates"] = obs["create_agent"].get("invalid_value_accepted") is False
    checks["create_agent_carries_custom_field"] = obs["create_agent"].get("custom_field_in_result") == "platinum"
emit("P5", obs, checks)
