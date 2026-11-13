"""P7: which function does the create_react_agent link on the LangGraph v1 pages document? Live pages plus installed signatures (loop-4 Phase A finding)"""
import inspect, re, urllib.request, warnings
from _fake import *
warnings.simplefilter("ignore")
pages = {}
for p in ("oss/python/migrate/langgraph-v1", "oss/python/releases/langgraph-v1"):
    req = urllib.request.Request("https://docs.langchain.com/" + p + ".md", headers={"User-Agent": "aieng-knowledge-lab/0.4 probe"})
    body, e = attempt(lambda: urllib.request.urlopen(req, timeout=60).read().decode("utf-8"))
    links = sorted(set(re.findall(r"\[`?create_react_agent`?\]\((https?://[^)\s]+)\)", body or "")))
    pages[p] = {"error": e, "links": links, "bytes": len(body or "")}
sig = {}
for name, (mod, attr) in (("langchain_classic.agents.create_react_agent", ("langchain_classic.agents", "create_react_agent")),
                          ("langgraph.prebuilt.create_react_agent", ("langgraph.prebuilt", "create_react_agent"))):
    f, e = attempt(lambda: getattr(__import__(mod, fromlist=[attr]), attr))
    sig[name] = {"error": e, "signature": str(inspect.signature(f))[:400] if f else None, "module": getattr(f, "__module__", None)}
all_links = [l for v in pages.values() for l in v["links"]]
cls, pre = sig["langchain_classic.agents.create_react_agent"]["signature"], sig["langgraph.prebuilt.create_react_agent"]["signature"]
emit("P7", {"pages": pages, "signatures": sig},
     {"links_found": len(all_links), "links_point_to_classic": bool(all_links) and all("langchain-classic" in l for l in all_links),
      "signatures_differ": bool(cls) and bool(pre) and cls != pre})
