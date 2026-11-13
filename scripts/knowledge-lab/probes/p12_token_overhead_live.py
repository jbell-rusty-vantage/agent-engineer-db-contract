"""P12 (live arm): one-tool agent via create_agent on a small Claude model: input/output tokens, tool invoked, latency.
(agentmail post: LangGraph mean 1,288 input tokens on claude-haiku-4-5, 10/10 tool calls.) The key is read from ANTHROPIC_API_KEY in the environment only."""
import json, os, time, warnings
from _fake import *
warnings.simplefilter("ignore")
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic
from langchain_core.tools import tool

model_id = os.environ.get("PROBE_MODEL", "claude-haiku-4-5")
runs = []
for i in range(int(os.environ.get("PROBE_RUNS", "5"))):
    called = []

    @tool
    def get_invoice_status(invoice_id: str) -> str:
        """Return the status of an invoice."""
        called.append(invoice_id)
        return json.dumps({"invoice_id": invoice_id, "status": "paid", "amount_usd": 120})

    agent = create_agent(ChatAnthropic(model=model_id, max_tokens=512), [get_invoice_status],
                         system_prompt="You are a billing assistant. Use the tool to look up invoices.")
    t0 = time.time()
    out, err = attempt(lambda: agent.invoke({"messages": [("user", "What is the status of invoice INV-2048?")]}))
    usage = [m.usage_metadata for m in (out or {}).get("messages", []) if getattr(m, "usage_metadata", None)]
    last = (out or {}).get("messages", [None])[-1]
    runs.append({"error": err, "latency_ms": int((time.time() - t0) * 1000), "tool_invoked": bool(called), "model_calls": len(usage),
                 "input_tokens": sum(u.get("input_tokens", 0) for u in usage), "output_tokens": sum(u.get("output_tokens", 0) for u in usage),
                 "answer": (last.content if isinstance(getattr(last, "content", None), str) else str(getattr(last, "content", "")))[:300]})
ok = [r for r in runs if not r["error"]]
mean_in = round(sum(r["input_tokens"] for r in ok) / len(ok), 1) if ok else None
emit("P12", {"model": model_id, "runs": runs},
     {"runs_ok": len(ok), "tool_invoked_all": bool(ok) and all(r["tool_invoked"] for r in ok), "mean_input_tokens": mean_in,
      "mean_output_tokens": round(sum(r["output_tokens"] for r in ok) / len(ok), 1) if ok else None,
      "median_latency_ms": sorted(r["latency_ms"] for r in ok)[len(ok) // 2] if ok else None,
      "within_15pct_of_1288": mean_in is not None and abs(mean_in - 1288) / 1288 <= 0.15, "within_30pct_of_1288": mean_in is not None and abs(mean_in - 1288) / 1288 <= 0.30})
