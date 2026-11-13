"""P6: legacy imports (hub, AgentExecutor) moved to langchain-classic at 1.0 (LangChain v1 migration guide)"""
import importlib, warnings
from _fake import *
warnings.simplefilter("ignore")
tests = {"langchain.hub": lambda: importlib.import_module("langchain.hub"),
         "langchain.agents.AgentExecutor": lambda: getattr(importlib.import_module("langchain.agents"), "AgentExecutor"),
         "langchain_classic.hub": lambda: importlib.import_module("langchain_classic.hub"),
         "langchain_classic.agents.AgentExecutor": lambda: getattr(importlib.import_module("langchain_classic.agents"), "AgentExecutor")}
obs = {k: (attempt(f)[1] or "ok") for k, f in tests.items()}
emit("P6", obs, {k.replace(".", "_") + "_imports": v == "ok" for k, v in obs.items()})
