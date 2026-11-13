"""P4: does the deprecated prebuilt accept the new create_agent keywords system_prompt= and middleware=? (CopilotKit #6614)"""
import inspect, warnings
from _fake import *
warnings.simplefilter("ignore")
cra, err = attempt(lambda: __import__("langgraph.prebuilt", fromlist=["create_react_agent"]).create_react_agent)
if not cra:
    emit("P4", {"import_error": err}, {"prebuilt_exists": False})
    raise SystemExit
res = {}
for kw, val in (("system_prompt", "SYS"), ("middleware", [])):
    _, e = attempt(lambda: cra(fake_model([final("ok")]), [invoice_tool()], **{kw: val}))
    res[kw] = e
emit("P4", {"signature_params": list(inspect.signature(cra).parameters), "errors": res},
     {"prebuilt_exists": True, "system_prompt_rejected": res["system_prompt"] is not None, "middleware_rejected": res["middleware"] is not None})
