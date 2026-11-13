"""P3: which node names appear in stream_mode="updates"? ("Node name changed from agent to model", LangChain v1 migration guide)"""
import warnings
from _fake import *
warnings.simplefilter("ignore")


def keys(agent):
    return [k for chunk in agent.stream({"messages": [("user", "status of INV-1?")]}, stream_mode="updates") for k in chunk]


def resp():
    return [tool_call("get_invoice_status", {"invoice_id": "INV-1"}, "c1"), final("paid")]


ca, _ = attempt(lambda: __import__("langchain.agents", fromlist=["create_agent"]).create_agent)
cra, _ = attempt(lambda: __import__("langgraph.prebuilt", fromlist=["create_react_agent"]).create_react_agent)
obs = {}
if cra:
    obs["create_react_agent"], obs["create_react_agent_error"] = attempt(lambda: keys(cra(fake_model(resp()), [invoice_tool()])))
if ca:
    obs["create_agent"], obs["create_agent_error"] = attempt(lambda: keys(ca(fake_model(resp()), [invoice_tool()])))


def model_node(ks):
    ks = ks or []
    return "agent" if "agent" in ks else ("model" if "model" in ks else None)


emit("P3", obs, {"prebuilt_model_node": model_node(obs.get("create_react_agent")), "create_agent_model_node": model_node(obs.get("create_agent"))})
