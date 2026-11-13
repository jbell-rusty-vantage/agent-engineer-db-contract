"""P1: does langgraph.prebuilt.create_react_agent emit a deprecation warning that points to create_agent? (agentmail post; LangGraph v1 migration guide)"""
import warnings
from _fake import *

warnings.simplefilter("always")
with warnings.catch_warnings(record=True) as at_import:
    warnings.simplefilter("always")
    mod, err_import = attempt(lambda: __import__("langgraph.prebuilt", fromlist=["create_react_agent"]))
obs = {"import_error": err_import, "import_warnings": warn_list(at_import)}
if mod:
    with warnings.catch_warnings(record=True) as at_call:
        warnings.simplefilter("always")
        agent, err_build = attempt(lambda: mod.create_react_agent(fake_model([tool_call("get_invoice_status", {"invoice_id": "INV-1"}, "c1"), final("INV-1 is paid.")]), [invoice_tool()]))
        out, err_run = attempt(lambda: agent.invoke({"messages": [("user", "What is the status of INV-1?")]})) if agent else (None, None)
    w = warn_list(at_call)
    obs.update(build_error=err_build, run_error=err_run, call_warnings=w, answer=out["messages"][-1].content if out else None)
    deps = [x for x in w if "deprecat" in x["category"].lower() or "deprecat" in x["message"].lower()]
    emit("P1", obs, {"deprecation_warning": bool(deps), "names_create_agent": any("create_agent" in x["message"] for x in deps),
                     "warning_category": deps[0]["category"] if deps else None, "agent_answered": bool(out)})
else:
    emit("P1", obs, {"deprecation_warning": None, "names_create_agent": None, "agent_answered": False})
