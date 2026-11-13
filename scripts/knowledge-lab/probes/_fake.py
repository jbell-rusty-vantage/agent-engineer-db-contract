"""Shared probe helpers (Build 08 loop 4). Runs inside a probe environment (uv venv per cell); no lab imports.

A deterministic tool-calling fake chat model that records what it was asked, a one-tool fixture (the agentmail billing
agent's getInvoiceStatus, re-created), and a JSON emitter. Every probe prints exactly one JSON object on stdout.
"""
import importlib.metadata as md, json, platform, sys, traceback, warnings

RECORD = []  # one entry per model call: the messages the model saw


def versions(*names):
    out = {}
    for n in names:
        try:
            out[n] = md.version(n)
        except md.PackageNotFoundError:
            out[n] = None
    return out


def fake_model(responses):
    from langchain_core.language_models.fake_chat_models import GenericFakeChatModel

    class ToolFakeModel(GenericFakeChatModel):
        def bind_tools(self, tools, **kwargs):  # the agent factories bind tools; the fake ignores them
            return self

        def _generate(self, messages, stop=None, run_manager=None, **kwargs):
            RECORD.append([{"type": m.type, "content": m.content if isinstance(m.content, str) else str(m.content)} for m in messages])
            return super()._generate(messages, stop=stop, run_manager=run_manager, **kwargs)

    return ToolFakeModel(messages=iter(responses))


def tool_call(name, args, cid):
    from langchain_core.messages import AIMessage
    return AIMessage(content="", tool_calls=[{"name": name, "args": args, "id": cid, "type": "tool_call"}])


def final(text):
    from langchain_core.messages import AIMessage
    return AIMessage(content=text)


def invoice_tool():
    from langchain_core.tools import tool

    @tool
    def get_invoice_status(invoice_id: str) -> str:
        """Return the status of an invoice."""
        return json.dumps({"invoice_id": invoice_id, "status": "paid", "amount_usd": 120})

    return get_invoice_status


def warn_list(caught):
    return [{"category": w.category.__name__, "message": str(w.message)[:400], "file": (w.filename or "").replace("\\", "/").split("/site-packages/")[-1]} for w in caught]


def attempt(fn):
    """Run fn; return (value, error) where error is {type, message}."""
    try:
        return fn(), None
    except Exception as e:  # noqa: BLE001 - a probe records every failure
        return None, {"type": type(e).__name__, "message": str(e)[:600], "where": traceback.extract_tb(e.__traceback__)[-1].filename.replace("\\", "/").split("/site-packages/")[-1] if e.__traceback__ else None}


def emit(probe, observations, checks):
    print(json.dumps({"probe": probe, "python": platform.python_version(), "platform": platform.platform(),
                      "versions": versions("langchain", "langchain-core", "langgraph", "langgraph-prebuilt", "langchain-classic", "deepagents", "langchain-anthropic", "pydantic"),
                      "observations": observations, "checks": checks}, ensure_ascii=False, default=str))
