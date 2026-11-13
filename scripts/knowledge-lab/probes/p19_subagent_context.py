"""P19: what a Deep Agents subagent receives and what the parent gets back (forum: c6f643af, f10d0649).
c6f643af: the task tool invokes the subagent with the delegated description as a new HumanMessage, not the parent's history.
f10d0649: the subagents middleware returns only the subagent's last message to the main agent."""
import warnings
from _fake import *
warnings.simplefilter("ignore")
SUB_SEEN = []


def recorder(responses, sink):
    from langchain_core.language_models.fake_chat_models import GenericFakeChatModel

    class Rec(GenericFakeChatModel):
        def bind_tools(self, tools, **kwargs):
            return self

        def _generate(self, messages, stop=None, run_manager=None, **kwargs):
            sink.append([{"type": m.type, "content": m.content if isinstance(m.content, str) else str(m.content)} for m in messages])
            return super()._generate(messages, stop=stop, run_manager=run_manager, **kwargs)
    return Rec(messages=iter(responses))


def run():
    from deepagents import create_deep_agent
    from langchain_core.messages import AIMessage
    # the subagent writes a todo (an intermediate tool turn), then answers: two AI messages in its run; the parent should get only the last
    sub_model = recorder([AIMessage(content="draft one (intermediate)", tool_calls=[{"name": "write_todos", "args": {"todos": [{"content": "add", "status": "in_progress"}]}, "id": "w1", "type": "tool_call"}]),
                          final("FINAL: the answer is 7")], SUB_SEEN)
    sub = {"name": "calc", "description": "Does arithmetic.", "system_prompt": "You are a calculator.", "model": sub_model}
    parent_model = fake_model([tool_call("task", {"description": "compute 3+4 and report", "subagent_type": "calc"}, "t1"), final("It is 7.")])
    agent = create_deep_agent(model=parent_model, subagents=[sub])
    out = agent.invoke({"messages": [("user", "SECRET-PARENT-CONTEXT: my favourite colour is teal. Now delegate 3+4 to calc.")]}, config={"recursion_limit": 20})
    tm = [str(m.content) for m in out["messages"] if m.type == "tool"]
    first = SUB_SEEN[0] if SUB_SEEN else []
    return {"sub_calls": len(SUB_SEEN), "sub_first_request": [{"type": m["type"], "content": m["content"][:200]} for m in first], "tool_messages": [t[:200] for t in tm]}


out, err = attempt(run)
o = out or {}
first = o.get("sub_first_request") or []
humans = [m for m in first if m["type"] == "human"]
tms = o.get("tool_messages") or []
emit("P19", {"result": out, "error": err},
     {"ran": out is not None, "sub_calls": o.get("sub_calls"), "sub_human_messages": len(humans), "sub_gets_only_description": len(humans) == 1 and "compute 3+4" in humans[0]["content"],
      "sub_sees_parent_history": any("SECRET-PARENT-CONTEXT" in m["content"] for m in first),
      "parent_gets_last_message_only": any("FINAL: the answer is 7" in t for t in tms) and not any("draft one" in t for t in tms),
      "tool_message_text": (tms or [""])[0][:120]})
