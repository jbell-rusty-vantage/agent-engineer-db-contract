"""P2: create_agent and the prompt -> system_prompt rename. Is prompt= rejected loudly or accepted silently?
(agentmail post: "silently renamed a core parameter"; LangChain v1 migration guide: "Parameter renamed to system_prompt")"""
import inspect
from _fake import *

ca, err = attempt(lambda: __import__("langchain.agents", fromlist=["create_agent"]).create_agent)
if not ca:
    emit("P2", {"import_error": err}, {"create_agent_exists": False})
    raise SystemExit
params = list(inspect.signature(ca).parameters)
res = {}
for kw in ("system_prompt", "prompt"):
    RECORD.clear()
    agent, e_build = attempt(lambda: ca(fake_model([final("ok")]), [invoice_tool()], **{kw: "SYS-MARKER-" + kw}))
    out, e_run = attempt(lambda: agent.invoke({"messages": [("user", "hi")]})) if agent else (None, None)
    seen = RECORD[0] if RECORD else []
    res[kw] = {"build_error": e_build, "run_error": e_run, "system_message_reached_model": any(m["type"] == "system" and "SYS-MARKER-" + kw in m["content"] for m in seen)}
emit("P2", {"signature_params": params, "results": res},
     {"create_agent_exists": True, "has_system_prompt_param": "system_prompt" in params, "has_prompt_param": "prompt" in params,
      "system_prompt_reaches_model": res["system_prompt"]["system_message_reached_model"],
      "prompt_kwarg_rejected": res["prompt"]["build_error"] is not None, "prompt_kwarg_error_type": (res["prompt"]["build_error"] or {}).get("type"),
      "prompt_kwarg_silently_ignored": res["prompt"]["build_error"] is None and res["prompt"]["run_error"] is None and not res["prompt"]["system_message_reached_model"]})
