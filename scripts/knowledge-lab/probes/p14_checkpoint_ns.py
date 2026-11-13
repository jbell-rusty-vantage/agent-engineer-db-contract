"""P14: checkpoint namespaces of a supervisor and its sub-agent sharing one checkpointer (forum 2720 pair).
Claim A (e438c12b): each create_agent agent gets its own default checkpoint_ns (the graph id), so supervisor and sub-agents write to
different namespaces. Claim B (3f32e433): after passing checkpoint_ns in the configurable config, the stored checkpoint_ns stays ''."""
import warnings
from _fake import *
warnings.simplefilter("ignore")


def run():
    from langchain.agents import create_agent
    from langchain_core.tools import tool
    from langgraph.checkpoint.memory import InMemorySaver
    saver = InMemorySaver()
    sub = create_agent(model=fake_model([final("sub-agent answer: 42")]), tools=[], name="researcher", checkpointer=saver)

    @tool
    def ask_researcher(question: str) -> str:
        """Ask the researcher sub-agent."""
        out = sub.invoke({"messages": [("user", question)]})
        return out["messages"][-1].content

    sup = create_agent(model=fake_model([tool_call("ask_researcher", {"question": "what is the answer?"}, "c1"), final("The researcher says 42.")]),
                       tools=[ask_researcher], name="supervisor", checkpointer=saver)
    sup.invoke({"messages": [("user", "ask the researcher")]}, config={"configurable": {"thread_id": "t-arm-a"}})
    ns_a = sorted({c.config["configurable"].get("checkpoint_ns", "") for c in saver.list({"configurable": {"thread_id": "t-arm-a"}})})
    saver_b = InMemorySaver()
    solo = create_agent(model=fake_model([final("hi")]), tools=[], name="solo", checkpointer=saver_b)
    solo.invoke({"messages": [("user", "hello")]}, config={"configurable": {"thread_id": "t-arm-b", "checkpoint_ns": "my-namespace"}})
    ns_b = sorted({c.config["configurable"].get("checkpoint_ns", "") for c in saver_b.list(None)})
    return {"arm_a_namespaces": ns_a, "arm_b_namespaces": ns_b}


out, err = attempt(run)
a = (out or {}).get("arm_a_namespaces") or []
b = (out or {}).get("arm_b_namespaces") or []
emit("P14", {"result": out, "error": err},
     {"ran": out is not None, "supervisor_root_ns_empty": "" in a, "subagent_separate_ns": any(x for x in a), "subagent_ns_is_graph_id": "researcher" in a,
      "subagent_ns_is_task_path": any(x.startswith("tools:") for x in a), "namespaces_a": "|".join(a), "explicit_ns_stored": "my-namespace" in b, "root_ns_stays_empty": b == [""]})
